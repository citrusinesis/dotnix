# This file contains custom overlays to extend nixpkgs
# All overlays defined here will be automatically imported

{ inputs, ... }:

{
  # Unstable packages overlay
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}