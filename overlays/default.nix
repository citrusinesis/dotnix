# This file contains custom overlays to extend nixpkgs
# All overlays defined here will be automatically imported by the flake
# and applied to both NixOS and Darwin configurations

{ inputs, ... }:

{
  # System unstable packages overlay
  # Provides access to nixpkgs-unstable packages via pkgs.unstable.package-name
  # Usage: pkgs.unstable.firefox, pkgs.unstable.claude-code, etc.
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # Home-manager specific bleeding edge packages overlay (fastest updates)
  # Provides access to latest packages via pkgs.bleeding.package-name
  # Usage: pkgs.bleeding.firefox, pkgs.bleeding.vscode, etc.
  bleeding-packages = final: _prev: {
    bleeding = import inputs.nixpkgs-bleeding {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}