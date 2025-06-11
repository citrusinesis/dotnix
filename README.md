# ❄️ My Nix Configuration

| Host | OS      | Flake target         |
|------|---------|----------------------|
| 🖥️  **blender**  | NixOS   | `nixosConfigurations.blender`  |
| 💻  **squeezer** | macOS   | `darwinConfigurations.squeezer`|

## Quick start

### Rebuild systems

| Command | Target |
|---------|--------|
| `sudo nixos-rebuild switch --flake .#blender` | blender |
| `darwin-rebuild switch --flake .#squeezer`     | squeezer |
