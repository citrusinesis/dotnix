# This file contains custom overlays to extend nixpkgs
# All overlays defined here will be automatically imported

{ inputs, ... }:

{
  # Modify this file to add your custom overlays
  
  # Example of adding an overlay:
  # myOverlay = final: prev: {
  #   somePackage = prev.somePackage.overrideAttrs (oldAttrs: {
  #     # Your modifications here
  #   });
  # };
  
  # Example of importing an overlay from a separate file:
  # customPackages = import ./custom-packages.nix;
  
  # Example of using an overlay from an input:
  # nixpkgsUnstable = final: prev: {
  #   unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.system};
  # };
}