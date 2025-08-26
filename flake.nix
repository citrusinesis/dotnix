{
  description = "My Nix Configuration";

  inputs = {
    # Stable system base with modules
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # Well-tested unstable for system overlay
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Bleeding edge for home-manager packages (fastest updates)
    nixpkgs-bleeding.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    
    # Darwin inputs
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Useful utilities
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-bleeding, darwin, home-manager, flake-utils, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Import personal configuration
      personal = import ./personal.nix;
      
      # Import overlays
      overlays = import ./overlays { inherit inputs; };
      
      # Helper to create nixos configurations
      mkNixosConfig = { system, hostName, username, modules ? [], extraUsers ? {} }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username; };
          modules = [
            # Apply overlays
            { nixpkgs.overlays = builtins.attrValues overlays; }
            
            # Host-specific configuration
            ./hosts/${hostName}
            
            # User-specific configuration
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = {
                ${username} = import ./home/${username};
              } // extraUsers;
              home-manager.extraSpecialArgs = { inherit inputs username; };
            }
          ] ++ modules;
        };
      
      # Helper to create darwin configurations
      mkDarwinConfig = { system, hostName, username, modules ? [] }:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs username; };
          modules = [
            # Apply overlays
            { nixpkgs.overlays = builtins.attrValues overlays; }
            
            # Host-specific configuration
            ./hosts/${hostName}
            
            # User-specific configuration
            home-manager.darwinModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/${username};
              home-manager.extraSpecialArgs = { inherit inputs username; };
            }
          ] ++ modules;
        };
    in {
      nixosConfigurations = {
        blender = mkNixosConfig {
          system = "x86_64-linux";
          hostName = "blender";
          username = personal.user.username;
          extraUsers = {
            game = import ./home/game;
          };
        };
      };
      
      darwinConfigurations = {
        squeezer = mkDarwinConfig {
          system = "aarch64-darwin"; # Adjust if your Mac is Intel-based
          hostName = "squeezer"; 
          username = personal.user.username;
        };
      };
      
      # Development shell and additional outputs
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixpkgs-fmt
              nil # Nix LSP
            ];
          };
        }
      );
    };
}