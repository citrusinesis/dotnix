{ config, pkgs, lib, ... }:

{
  # Enable sound with PipeWire (recommended for Plasma 6)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Fix audio delay/pop when starting playback by disabling node suspension
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/disable-suspension.conf" ''
        monitor.alsa.rules = [
          {
            matches = [
              {
                # Matches all sources
                node.name = "~alsa_input.*"
              },
              {
                # Matches all sinks
                node.name = "~alsa_output.*"
              }
            ]
            actions = {
              update-props = {
                session.suspend-timeout-seconds = 0
              }
            }
          }
        ]
        # bluetooth devices
        monitor.bluez.rules = [
          {
            matches = [
              {
                # Matches all sources
                node.name = "~bluez_input.*"
              },
              {
                # Matches all sinks
                node.name = "~bluez_output.*"
              }
            ]
            actions = {
              update-props = {
                session.suspend-timeout-seconds = 0
              }
            }
          }
        ]
      '')
    ];
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
}