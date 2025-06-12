{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    
    profiles.default.extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc-icons
      catppuccin.catppuccin-vsc
      
      vscodevim.vim

      jnoortheen.nix-ide
      mkhl.direnv
      arrterian.nix-env-selector

      github.vscode-pull-request-github
      github.vscode-github-actions
      github.copilot
    ];
  };
}
