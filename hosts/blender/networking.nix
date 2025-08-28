{ config, pkgs, lib, ... }:

{
  # Networking configuration
  networking.hostName = "blender";
  networking.networkmanager.enable = true;

  # Enable the OpenSSH daemon
  services.openssh.enable = true;

  # Open ports in the firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Tailscale configuration
  services.tailscale = {
    enable = true;
    extraSetFlags = [
      "--advertise-exit-node"
      "--ssh"
    ];
  };

  # Enable IP forwarding for Tailscale exit node functionality
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1; 
    "net.ipv4.conf.all.forwarding" = 1; 
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Tailscale UDP optimization for exit nodes (Linux 6.2+ with Tailscale 1.54+)
  systemd.services.tailscale-udp-optimization = {
    description = "Tailscale UDP optimization for exit nodes";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "tailscale-udp-optimize" ''
        #!/bin/sh
        
        # Get the primary network interface
        NETDEV=$(${pkgs.iproute2}/bin/ip -o route get 8.8.8.8 | cut -f 5 -d " ")
        
        if [ -n "$NETDEV" ]; then
          echo "Optimizing network device: $NETDEV"
          ${pkgs.ethtool}/bin/ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
          echo "Tailscale UDP optimization applied successfully"
        else
          echo "Failed to detect network device"
          exit 1
        fi
      '';
    };
  };
}