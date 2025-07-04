#!/usr/bin/env bash
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
  echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_step() {
  echo -e "  ${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_warning() {
  echo -e "  ${YELLOW}Warning:${NC} $1"
}

print_error() {
  echo -e "${RED}Error:${NC} $1"
}

check_command() {
  if ! command -v "$1" &> /dev/null; then
    print_error "$1 could not be found"
    return 1
  fi
  return 0
}

# Check if script is run as root (should not be for macOS)
if [[ "$OSTYPE" == "darwin"* ]] && [ "$EUID" -eq 0 ]; then
  print_error "This script should not be run as root on macOS"
  exit 1
fi

# Determine OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="darwin"
  HOST="squeezer"
  REBUILD_CMD="darwin-rebuild switch --flake .#squeezer"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
  HOST="blender"
  REBUILD_CMD="sudo nixos-rebuild switch --flake .#blender"
else
  print_error "Unsupported OS: $OSTYPE"
  exit 1
fi

print_header "Setting up Nix configuration for $HOST ($OS)"

# Check if Nix is installed
print_step "Checking for Nix installation"
if ! check_command nix; then
  print_error "Nix is not installed"
  
  if [[ "$OS" == "darwin" ]]; then
    print_step "Installing Nix on macOS"
    echo "Please visit https://nixos.org/download.html and follow the instructions for macOS"
    exit 1
  else
    print_step "Installing Nix on Linux"
    echo "Please visit https://nixos.org/download.html and follow the instructions for Linux"
    exit 1
  fi
fi

# Enable flakes if not already enabled
print_step "Enabling flakes"
if ! grep -q "experimental-features = nix-command flakes" ~/.config/nix/nix.conf 2>/dev/null; then
  mkdir -p ~/.config/nix
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
  print_step "Flakes enabled in ~/.config/nix/nix.conf"
else
  print_step "Flakes already enabled"
fi

# Check for nix-darwin on macOS
if [[ "$OS" == "darwin" ]]; then
  print_step "Checking for nix-darwin"
  if ! check_command darwin-rebuild; then
    print_step "Installing nix-darwin"
    nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
    ./result/bin/darwin-installer
    
    if ! check_command darwin-rebuild; then
      print_error "Failed to install nix-darwin"
      exit 1
    fi
  fi
fi

# Check for home-manager
print_step "Checking for home-manager"
if ! check_command home-manager; then
  print_warning "home-manager not found in PATH. It will be installed via the flake."
fi

# Create symbolic link to this repo
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
if [ -L ~/.nixconfig ]; then
  rm ~/.nixconfig
fi
print_step "Creating symbolic link to ~/.nixconfig"
ln -sf "$SCRIPT_DIR" ~/.nixconfig

# Initial build
print_step "Building initial configuration (this may take a while)"
if [[ "$OS" == "darwin" ]]; then
  cd "$SCRIPT_DIR" && darwin-rebuild switch --flake .#squeezer
else
  cd "$SCRIPT_DIR" && sudo nixos-rebuild switch --flake .#blender
fi

if [ $? -eq 0 ]; then
  print_header "Setup completed successfully!"
  echo ""
  echo "Your Nix configuration is now installed and linked to ~/.nixconfig"
  echo "To update your system, run: $REBUILD_CMD"
  echo ""
  if [[ "$OS" == "darwin" ]]; then
    echo "Note: You may need to restart your terminal or log out and back in for all changes to take effect."
  fi
else
  print_error "Setup failed. Please check the error messages above."
  exit 1
fi