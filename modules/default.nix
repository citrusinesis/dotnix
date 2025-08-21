# This file serves as a convenience import for all shared modules
# Individual hosts import specific modules directly (shared, nixos, darwin)
{ inputs, pkgs, lib, ... }:

{
  imports = [ 
    ./shared 
    # Individual platforms import their specific modules directly
    # ./nixos (imported by NixOS hosts)
    # ./darwin (imported by Darwin hosts)
  ];
}