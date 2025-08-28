{ config, pkgs, lib, ... }:

{
  # Power management - disable sleep/suspend system-wide
  services.logind = {
    lidSwitch = "ignore";
    powerKey = "ignore";
    suspendKey = "ignore";
    hibernateKey = "ignore";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      HandleLidSwitch=ignore
      HandleLidSwitchExternalPower=ignore
    '';
  };
}