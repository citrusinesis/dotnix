# This file contains custom overlays to extend nixpkgs
# All overlays defined here will be automatically imported by the flake
# and applied to both NixOS and Darwin configurations

{ inputs, ... }:

{
  # Unstable packages overlay
  # Provides access to nixpkgs-unstable packages via pkgs.unstable.package-name
  # Usage: pkgs.unstable.firefox, pkgs.unstable.claude-code, etc.
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}