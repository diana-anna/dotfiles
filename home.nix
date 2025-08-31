{ config, pkgs, ... }:

{
  home.username = "diana";
  home.homeDirectory = "/home/diana";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.sessionPath =
    [ "$HOME/.nix-profile/bin" "$HOME/.nix-profile/share/applications" ];

  home.packages = with pkgs; [
    haskellPackages.nixfmt
    htop
    ncdu
    nerd-fonts.ubuntu-mono
    pandoc
    pls
    signal-desktop
    telegram-desktop
    texlab # LaTeX LSP
    tmux
    tree
    vim

    (writeShellScriptBin "hm-history" ''
      nix profile diff-closures --profile ~/.local/state/nix/profiles/home-manager
    '')
    (writeShellScriptBin "hm-news" ''
      home-manager news --flake ~/dotfiles
    '')
    (writeShellScriptBin "hm-switch" ''
      home-manager switch --flake ~/dotfiles
    '')
  ];

  programs.home-manager.enable = true;

  programs.emacs.enable = true;

  programs.starship.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
