{
  description = "My Nix Configuration";

  inputs = {
    # Core inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Darwin inputs
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Useful utilities
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, darwin, home-manager, flake-utils, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Import personal configuration
      personal = import ./personal.nix;
      
      # Helper to create nixos configurations
      mkNixosConfig = { system, hostName, username, modules ? [], extraUsers ? {} }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username; };
          modules = [
            # Host-specific configuration
            ./hosts/${hostName}
            
            # User-specific configuration
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/${username};
              home-manager.extraSpecialArgs = { inherit inputs username; };
              
              # Additional users configuration
              home-manager.users = extraUsers;
            }
          ] ++ modules;
        };
      
      # Helper to create darwin configurations
      mkDarwinConfig = { system, hostName, username, modules ? [] }:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs username; };
          modules = [
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
          
          # Uncomment the following to enable gaming configuration with separate game user
          # extraUsers = {
          #   game = import ./home/game { inherit inputs; username = "game"; };
          # };
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