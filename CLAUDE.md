# CLAUDE.md - Nix Configuration Project

## Project Overview

This is a personal Nix configuration flake managing both NixOS and macOS (Darwin) systems using Home Manager for user-specific configurations.

**Systems:**
- `blender` - x86_64 NixOS desktop with KDE Plasma 6, NVIDIA GPU, gaming setup
- `squeezer` - aarch64 macOS system

## Project Structure

```
.
├── flake.nix                 # Main flake configuration with inputs/outputs
├── personal.nix              # Personal information (git, user, timezone)
├── home/                     # Home Manager configurations per user
│   ├── citrus/               # Main user configuration
│   │   ├── default.nix       # Package lists and home settings
│   │   └── programs/         # Program-specific configurations
│   └── game/                 # Gaming user configuration
├── hosts/                    # Host-specific system configurations
│   ├── blender/              # NixOS desktop configuration
│   └── squeezer/             # macOS configuration
├── modules/                  # Reusable configuration modules
│   ├── shared/               # Cross-platform modules
│   ├── nixos/                # NixOS-specific modules
│   └── darwin/               # macOS-specific modules
└── overlays/                 # Package overlays for different channels
```

## Build Commands

**Note:** These commands require system privileges and should be run by the user:

### System Rebuilds
```bash
# NixOS (blender) - requires sudo
sudo nixos-rebuild switch --flake .#blender

# macOS (squeezer)
darwin-rebuild switch --flake .#squeezer
```

### Development & Testing
```bash
# Enter development shell with formatting tools
nix develop

# Format Nix files
nixpkgs-fmt **/*.nix

# Check flake syntax and dependencies
nix flake check
```

## Conventions & Patterns

### File Organization
- **Modular imports**: Each configuration file imports its dependencies via `imports = [ ... ]`
- **Personal data**: Centralized in `personal.nix` and imported where needed
- **Platform-specific logic**: Use `lib.mkIf pkgs.stdenv.isDarwin` / `pkgs.stdenv.isLinux`
- **Program configurations**: Separate files in `programs/` directories

### Naming Conventions
- **Hosts**: Lowercase, descriptive names (`blender`, `squeezer`)
- **Users**: Consistent usernames across systems (from `personal.nix`)
- **Files**: kebab-case for multi-word names

### Package Management Strategy
- **Multiple channels**: Stable base (`nixpkgs`), unstable system overlay (`nixpkgs-unstable`), bleeding edge for Home Manager (`nixpkgs-bleeding`)
- **System packages**: Minimal, shared essentials in `modules/shared/default.nix`
- **User packages**: Rich toolsets in `home/*/default.nix`
- **Package access**: `pkgs.bleeding.package-name` for latest versions

### Code Style
- **Indentation**: 2 spaces
- **Comments**: Explain complex configurations, especially hardware-specific settings
- **Module structure**: Standard `{ config, lib, pkgs, ... }:` parameter pattern
- **Imports first**: Always list imports at the top of configuration files

### Home Manager Integration
- **User isolation**: Each user gets their own home configuration
- **Program modules**: Split configurations into focused program files
- **State version**: Pin to release version (`"25.05"`)

### Hardware & System Specific
- **Conditional configs**: Use `lib.mkIf` for platform/hardware-specific settings
- **Hardware detection**: Reference hardware via `hardware-configuration.nix` 
- **Performance optimizations**: Document complex settings (e.g., GPU, audio, networking)

## Key Features

- **Multi-channel package management** with stable/unstable/bleeding edge
- **Cross-platform** shared modules for NixOS/Darwin
- **Gaming optimizations** on NixOS (Steam, GameMode, MangoHUD)
- **Development environment** with Nix LSP, formatters, and tools
- **Audio optimization** with PipeWire suspension fixes
- **Network optimization** with Tailscale exit node setup

## Making Changes

1. **Edit relevant configuration files** following existing patterns
2. **Test changes** with `nix flake check` for syntax
3. **Apply changes** with appropriate rebuild command (user must run with sudo for NixOS)
4. **Verify functionality** after rebuild completes

## Dependencies

- Nix with flakes enabled
- Home Manager (automatically managed)
- Platform-specific: systemd-boot (NixOS), nix-darwin (macOS)