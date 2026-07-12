{ config, lib, modulesPath, pkgs, ... }:

let
  # Framework 16 keyboard module (RP2040): measured into PCR 23 before LUKS
  # unlock. The TPM2 enrollment is bound to this PCR, so a tampered/swapped
  # module means the TPM stays sealed and unlock falls back to FIDO2.
  kbdVid = "32ac";
  kbdPid = "0012";
  bootselVid = "2e8a";
  bootselPid = "0003";
  kbdFwRegion = "0x10000000 0x1000F200";
  kbdPcr = "23";
  # Advisory only — the PCR is extended with the measured value either way,
  # so the TPM policy is the real gate. This just warns before the PIN
  # prompt appears. Update alongside re-enrollment when reflashing.
  kbdFwExpectedHash = "b93c8dfb93fa2db5e14f60db8e7deaba23a5f87a11f7f45faaf505ef85ead918";
  luksDevice = "/dev/disk/by-label/NIXLUKS";
  # tries=0: unlimited recovery-key attempts once the token mechanisms are
  # exhausted, instead of "Too many attempts" after the shared 3-try budget.
  # token-timeout is the TOTAL window from "please plug it in" (the monitor's
  # timer is one-shot, not per-event), and the OnlyKey needs plug + keypad PIN
  # + the gate service's next poll to fit inside it; when no token ever shows
  # up it also delays the recovery-key prompt by the same amount.
  luksUnlockOpts = [
    "tpm2-device=auto"
    "fido2-device=/dev/onlykey-fido2"
    "token-timeout=120"
    "tries=0"
  ];
  # Must be the bin/ path: it's what the generator's compiled-in
  # SYSTEMD_CRYPTSETUP_PATH uses, and the lib/systemd/systemd-cryptsetup
  # symlink is not copied into the initrd (exec would fail at boot).
  initrdCryptsetup = "${config.boot.initrd.systemd.package}/bin/systemd-cryptsetup";
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];
  boot = {
    initrd = {
      systemd = {
        storePaths = [
          "${pkgs.systemd}/lib/udev/fido_id"
          "${config.boot.initrd.systemd.package}/lib/systemd/systemd-pcrextend"
        ];
        extraBin = {
          qmk_hid = "${pkgs.qmk_hid}/bin/qmk_hid";
          picotool = "${pkgs.picotool}/bin/picotool";
          fido2-token = "${pkgs.libfido2}/bin/fido2-token";
        };
        # asDropin is required — the unit itself is created by a generator at
        # boot, and a full static unit here would shadow and break it.
        services."systemd-cryptsetup@cryptroot" = {
          overrideStrategy = "asDropin";
          environment = {
            # The libcryptsetup token-plugin pre-pass tries all LUKS2 tokens in
            # header order and a needs-PIN answer doesn't pause it, so a present
            # FIDO2 key always wins before the TPM2 PIN prompt can appear.
            # Disabling it makes systemd-cryptsetup use its built-in dispatch,
            # which honors the intended order: TPM2+PIN -> FIDO2 -> recovery.
            SYSTEMD_CRYPTSETUP_USE_TOKEN_MODULE = "0";
            # The FIDO2 prompts ("please plug in", "confirm presence") are
            # plain log notices, not ask-password queries, so they never reach
            # the console agent. Forcing the log target to stderr and copying
            # stderr to the console makes them visible at the unlock prompt.
            SYSTEMD_LOG_TARGET = "console";
          };
          serviceConfig = {
            StandardOutput = "journal+console";
            StandardError = "journal+console";
            # systemd-cryptsetup only falls through to the next unlock method
            # on EAGAIN; a FIDO2 token that is present but not ready (e.g. a
            # still-locked OnlyKey) yields a hard error like ENOSTR (action
            # timeout) that aborts the whole unit -> emergency shell, recovery
            # key never offered. So: tolerate failure of the generator's
            # original command (reconstructed here since a drop-in can only
            # replace ExecStart wholesale), then rerun without fido2-device so
            # any first-pass death still ends at the TPM2 PIN / recovery-key
            # prompts. If the first pass unlocked, the rerun sees the volume
            # already active and exits 0.
            ExecStart = [
              ""
              "-${initrdCryptsetup} attach 'cryptroot' '${luksDevice}' '-' '${lib.concatStringsSep "," luksUnlockOpts}'"
              "${initrdCryptsetup} attach 'cryptroot' '${luksDevice}' '-' 'tpm2-device=auto,tries=0'"
            ];
          };
        };
        # A freshly plugged OnlyKey is locked and silently drops CTAP
        # requests -- and neither systemd-cryptsetup nor libfido2 puts any
        # timeout on the conversation once the device node exists, so if
        # cryptsetup opens the token before the keypad PIN is entered, the
        # whole unlock wedges until the key is unplugged (requests sent
        # while locked are never answered, not even after unlocking).
        # Therefore udev must NOT create /dev/onlykey-fido2; this service
        # polls the key with a short-timeout GetInfo and only creates the
        # symlink once the key actually answers (= unlocked), then pokes
        # udev so cryptsetup's security-device monitor rescans it.
        services.onlykey-fido2-gate = {
          description = "Expose OnlyKey FIDO2 interface once the key is unlocked";
          wantedBy = [ "initrd.target" ];
          before = [ "systemd-cryptsetup@cryptroot.service" ];
          unitConfig.DefaultDependencies = false;
          serviceConfig = {
            Type = "simple";
            Restart = "always";
            RestartSec = 1;
            StandardOutput = "journal";
            StandardError = "journal";
          };
          script = ''
            link=/dev/onlykey-fido2
            while true; do
              # key unplugged: drop the dangling symlink so cryptsetup goes
              # back to waiting instead of erroring on a dead node
              if [ -L "$link" ] && [ ! -e "$link" ]; then
                rm -f "$link"
              fi
              if [ ! -e "$link" ]; then
                for h in /sys/class/hidraw/hidraw*; do
                  [ -e "$h" ] || continue
                  hid=$(readlink -f "$h/device" 2>/dev/null) || continue
                  case "$(basename "$hid")" in
                    0003:1D50:60FC.*) ;;
                    *) continue ;;
                  esac
                  [ "$(cat "$hid/../bInterfaceNumber" 2>/dev/null)" = "01" ] || continue
                  node="/dev/$(basename "$h")"
                  if timeout 2 fido2-token -I "$node" > /dev/null 2>&1; then
                    ln -sf "$(basename "$h")" "$link"
                    echo "OnlyKey answered, exposing $node as $link"
                    udevadm trigger --action=change "$h" || true
                  fi
                done
              fi
              sleep 1
            done
          '';
        };
        services.measure-keyboard = {
          description = "Verify keyboard firmware integrity";
          wantedBy = [ "initrd.target" ];
          before = [ "systemd-cryptsetup@cryptroot.service" ];
          unitConfig.DefaultDependencies = false;
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            StandardOutput = "journal";
            StandardError = "journal";
          };
          # Every failure path exits without extending the PCR: TPM2 unlock
          # then fails closed and systemd-cryptsetup falls back to FIDO2.
          script = ''
            pcrextend=${config.boot.initrd.systemd.package}/lib/systemd/systemd-pcrextend
            # limine is not systemd-stub, so without this pcrextend skips the
            # TPM extend entirely (with exit 0!) because the kernel image
            # itself was never measured into PCR 11.
            export SYSTEMD_FORCE_MEASURE=1
            RED='\033[1;31m'
            YELLOW='\033[1;33m'
            RESET='\033[0m'
            console() { # $1 = color, $2 = message; journal copy stays plain
              echo "$2"
              printf "%b%s%b\n" "$1" "measure-keyboard: $2" "$RESET" > /dev/console || true
            }
            fail() {
              console "$RED" "!!! $* !!!"
              exit 1
            }
            wait_usb() { # vid pid tries(x0.2s) -> sysfs path on stdout
              for _ in $(seq 1 "$3"); do
                for dev in /sys/bus/usb/devices/*; do
                  [ -e "$dev/idVendor" ] || continue
                  if [ "$(cat "$dev/idVendor")" = "$1" ] && [ "$(cat "$dev/idProduct")" = "$2" ]; then
                    echo "$dev"
                    return 0
                  fi
                done
                sleep 0.2
              done
              return 1
            }
            if ! wait_usb ${kbdVid} ${kbdPid} 50 > /dev/null; then
              fail "keyboard module ${kbdVid}:${kbdPid} not found; PCR ${kbdPcr} not extended"
            fi
            # The USB device appears in sysfs before its hidraw node exists, so
            # early jump attempts can fail with "No device found" — retry until
            # BOOTSEL enumerates. qmk_hid's exit status is meaningless even on
            # success (the jump kills the device mid-request), so BOOTSEL
            # enumeration is the only reliable signal either way.
            bootdev=""
            for _ in $(seq 1 10); do
              qmk_hid --vid ${kbdVid} --pid ${kbdPid} via --bootloader || true
              if bootdev=$(wait_usb ${bootselVid} ${bootselPid} 10); then
                break
              fi
            done
            if [ -z "$bootdev" ]; then
              fail "keyboard did not re-enumerate in BOOTSEL mode; PCR ${kbdPcr} not extended"
            fi
            flash_id=$(cat "$bootdev/serial")
            if ! picotool save -r ${kbdFwRegion} /tmp/kbd-fw.bin; then
              picotool reboot || true
              fail "firmware dump failed; PCR ${kbdPcr} not extended"
            fi
            fw_hash=$(sha256sum /tmp/kbd-fw.bin | cut -d' ' -f1)
            rm -f /tmp/kbd-fw.bin
            if [ "$fw_hash" != "${kbdFwExpectedHash}" ]; then
              console "$RED" "!!! KEYBOARD FIRMWARE HASH MISMATCH -- do NOT enter your TPM2 PIN on this keyboard (it will fail regardless) !!!"
              console "$RED" "!!! got $fw_hash !!!"
            fi
            for _ in $(seq 1 25); do
              [ -e /dev/tpmrm0 ] && break
              sleep 0.2
            done
            "$pcrextend" --pcr=${kbdPcr} "fw16-kbd-flash-id:$flash_id"
            "$pcrextend" --pcr=${kbdPcr} "fw16-kbd-fw-sha256:$fw_hash"
            picotool reboot || true
            wait_usb ${kbdVid} ${kbdPid} 50 > /dev/null \
              || console "$YELLOW" "!!! keyboard did not come back after measurement !!!"
            console "" "measured flash id $flash_id, firmware sha256 $fw_hash into PCR ${kbdPcr}"
          '';
        };
      };
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" "tpm_crb" ];
      luks.devices."cryptroot" = {
        device = luksDevice;
        crypttabExtraOpts = luksUnlockOpts;
      };
      services.udev.packages = [
        # fido_id tags FIDO hidraw interfaces "security-device", which is
        # the tag systemd-cryptsetup's plug-it-in monitor listens for. The
        # /dev/onlykey-fido2 symlink itself is deliberately NOT managed by
        # udev but by the onlykey-fido2-gate service: it must only appear
        # once the key is unlocked and answering CTAP requests.
        (pkgs.runCommand "udevFido2" {} ''
          mkdir -p $out/lib/udev/rules.d/
          cp ${pkgs.systemd}/lib/udev/rules.d/60-fido-id.rules \
          $out/lib/udev/rules.d/60-fido-id.rules
        '')
      ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    kernelParams = [ "mem_encrypt=on" ];
  };
  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
