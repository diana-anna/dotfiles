{ config, lib, pkgs, system, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.lists) optionals;
  inherit (pkgs.stdenv) isDarwin isLinux;
  homeDirectory = if isDarwin then "/Users/diana" else "/home/diana";
  common-packages = with pkgs; [
    bat
    bitwarden-desktop
    btop
    mu
    emacs.pkgs.mu4e
    nerd-fonts.daddy-time-mono
    nerd-fonts.departure-mono
    nerd-fonts._0xproto
    nerd-fonts.ubuntu-mono
    graphviz # for org-roam-ui
    gnupg
    htop
    hunspell
    hunspellDicts.en_US
    hunspellDicts.pl_PL
    imagemagick
    ispell
    haskellPackages.nixfmt
    nil
    ncdu
    pandoc
    pls
    ripgrep
    silver-searcher
    telegram-desktop
    texlab # LaTeX LSP
    tmux
    tree
    vim

    (writeShellScriptBin "full-switch" ''
      cd ~/dotfiles
      nix flake update
      ${if isDarwin then
        "sudo darwin-rebuild switch --flake .#diana-macbook"
      else
        ""}
      home-manager switch --flake .#diana.${system}
      cd -
    '')
    (writeShellScriptBin "dr-switch" ''
      sudo darwin-rebuild switch --flake ~/dotfiles#diana-macbook
    '')
    (writeShellScriptBin "hm-history" ''
      nix profile diff-closures --profile ~/.local/state/nix/profiles/home-manager
    '')
    (writeShellScriptBin "hm-news" ''
      home-manager news --flake ~/dotfiles#diana.${system}
    '')
    (writeShellScriptBin "hm-switch" ''
      home-manager switch --flake ~/dotfiles#diana.${system}
    '')
  ];
  linux-packages = with pkgs; [ libvterm signal-desktop ];
  darwin-packages = with pkgs; [ ];
in {
  home.username = "diana";
  home.homeDirectory = homeDirectory;

  home.stateVersion = "25.05"; # Please read the comment before changing.

  home.packages = common-packages ++ optionals isLinux linux-packages
    ++ optionals isDarwin darwin-packages;

  programs = {
    home-manager.enable = true;

    alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "UbuntuMono Nerd Font";
            style = "Regular";
          };
          italic = {
            family = "UbuntuMono Nerd Font";
            style = "Italic";
          };
          bold = {
            family = "UbuntuMono Nerd Font";
            style = "Bold";
          };
          bold_italic = {
            family = "UbuntuMono Nerd Font";
            style = "Bold Italic";
          };
          size = 16;
        };
      };
      theme = "ashes_light";
    };

    bash.enable = isLinux;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    emacs.enable = true;

    firefox = {
      enable = isDarwin;
      profiles.diana = {
        settings = {
          "browser.newtabpage.activity-stream.feeds.system.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "signon.rememberSignons" = false;
        };
      };
    };

    ghostty = {
      enable = isDarwin;
      package = null;
      settings = { theme = "light:Catppuccin Latte,dark:Catppuccin Frappe"; };
    };

    git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        commit.gpgsign = true;
        fetch.prune = true;
        github.user = "diana-anna";
        init.defaultBranch = "main";
        pull = { rebase = false; };
        push = { autoSetupRemote = true; };
        user.email = "17442895+diana-anna@users.noreply.github.com";
        user.name = "diana-anna";
      };
    };

    nix-your-shell = {
      enable = true;
      enableZshIntegration = true;
    };

    lsd = {
      enable = true;
      enableBashIntegration = isLinux;
      enableZshIntegration = isDarwin;
    };

    starship = {
      enable = true;
      settings = {
        aws.disabled = true;

        "$schema" = "https://starship.rs/config-schema.json";

        format = lib.strings.replaceStrings [ "\n" ] [ "" ] ''
          [](red)
          $os
          $username
          [](bg:peach fg:red)
          $directory
          [](bg:yellow fg:peach)
          $git_branch
          $git_status
          [](fg:yellow bg:green)
          $c
          $golang
          $haskell
          $java
          $kotlin
          $nodejs
          $php
          $python
          $rust
          [](fg:green bg:sapphire)
          $conda
          $nix_shell
          [](fg:sapphire bg:lavender)
          $time
          [ ](fg:lavender)
          $cmd_duration
          $line_break
          $character
        '';

        character = {
          disabled = false;
          success_symbol = "[❯](bold fg:green)";
          error_symbol = "[❯](bold fg:red)";
          vimcmd_symbol = "[❮](bold fg:green)";
          vimcmd_replace_one_symbol = "[❮](bold fg:lavender)";
          vimcmd_replace_symbol = "[❮](bold fg:lavender)";
          vimcmd_visual_symbol = "[❮](bold fg:yellow)";
        };

        cmd_duration = {
          show_milliseconds = false;
          format = "  in $duration ";
          style = "bg:lavender";
          disabled = false;
          show_notifications = true;
          min_time_to_notify = 45000;
        };

        directory = {
          format = "[ $path ]($style)";
          style = "bg:peach fg:crust";
          truncation_length = 5;
          truncation_symbol = "…/";
          truncate_to_repo = false;
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = "󰝚 ";
            "Pictures" = " ";
            "Developer" = "󰲋 ";
          };
        };

        git_branch = {
          symbol = "";
          style = "bg:yellow";
          format = "[[ $symbol $branch ](fg:crust bg:yellow)]($style)";
        };

        git_status = {
          style = "bg:yellow";
          format =
            "[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)";
        };

        line_break.disabled = true;

        nix_shell = {
          disabled = false;
          format =
            "[[ via $symbol $state \\($name\\)](fg:crust bg:sapphire)]($style)";
          style = "bg:sapphire";
          symbol = " ";
          impure_msg = "impure";
          pure_msg = "pure";
          unknown_msg = "";
        };

        os = {
          disabled = false;
          style = "bg:red fg:crust";
          symbols = {
            Alpine = "";
            Amazon = "";
            Android = "";
            Arch = "󰣇";
            Artix = "󰣇";
            CentOS = "";
            Debian = "󰣚";
            Fedora = "󰣛";
            Gentoo = "󰣨";
            Linux = "󰌽";
            Macos = "󰀵";
            Manjaro = "";
            Mint = "󰣭";
            Raspbian = "󰐿";
            RedHatEnterprise = "󱄛";
            Redhat = "󱄛";
            SUSE = "";
            Ubuntu = "󰕈";
            Windows = "";
          };
        };

        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:lavender";
          format = "[[  $time ](fg:crust bg:lavender)]($style)";
        };

        username = {
          show_always = true;
          style_user = "bg:red fg:crust";
          style_root = "bg:red fg:crust";
          format = "[ $user]($style)";
        };

        c = {
          symbol = " ";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        conda = {
          symbol = "  ";
          style = "fg:crust bg:sapphire";
          format = "[$symbol$environment ]($style)";
          ignore_base = false;
        };
        docker_context = {
          symbol = "";
          style = "bg:sapphire";
          format = "[[ $symbol( $context) ](fg:crust bg:sapphire)]($style)";
        };
        golang = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        haskell = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        java = {
          symbol = " ";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        kotlin = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        nodejs = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        php = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        python = {
          symbol = "";
          style = "bg:green";
          format =
            "[[ $symbol( $version)((#$virtualenv)) ](fg:crust bg:green)]($style)";
        };
        rust = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };

        palette = "catppuccin_mocha";

        palettes = {
          catppuccin_frappe = {
            rosewater = "#f2d5cf";
            flamingo = "#eebebe";
            pink = "#f4b8e4";
            mauve = "#ca9ee6";
            red = "#e78284";
            maroon = "#ea999c";
            peach = "#ef9f76";
            yellow = "#e5c890";
            green = "#a6d189";
            teal = "#81c8be";
            sky = "#99d1db";
            sapphire = "#85c1dc";
            blue = "#8caaee";
            lavender = "#babbf1";
            text = "#c6d0f5";
            subtext1 = "#b5bfe2";
            subtext0 = "#a5adce";
            overlay2 = "#949cbb";
            overlay1 = "#838ba7";
            overlay0 = "#737994";
            surface2 = "#626880";
            surface1 = "#51576d";
            surface0 = "#414559";
            base = "#303446";
            mantle = "#292c3c";
            crust = "#232634";
          };
          catppuccin_latte = {
            rosewater = "#dc8a78";
            flamingo = "#dd7878";
            pink = "#ea76cb";
            mauve = "#8839ef";
            red = "#d20f39";
            maroon = "#e64553";
            peach = "#fe640b";
            yellow = "#df8e1d";
            green = "#40a02b";
            teal = "#179299";
            sky = "#04a5e5";
            sapphire = "#209fb5";
            blue = "#1e66f5";
            lavender = "#7287fd";
            text = "#4c4f69";
            subtext1 = "#5c5f77";
            subtext0 = "#6c6f85";
            overlay2 = "#7c7f93";
            overlay1 = "#8c8fa1";
            overlay0 = "#9ca0b0";
            surface2 = "#acb0be";
            surface1 = "#bcc0cc";
            surface0 = "#ccd0da";
            base = "#eff1f5";
            mantle = "#e6e9ef";
            crust = "#dce0e8";
          };
          catppuccin_macchiato = {
            rosewater = "#f4dbd6";
            flamingo = "#f0c6c6";
            pink = "#f5bde6";
            mauve = "#c6a0f6";
            red = "#ed8796";
            maroon = "#ee99a0";
            peach = "#f5a97f";
            yellow = "#eed49f";
            green = "#a6da95";
            teal = "#8bd5ca";
            sky = "#91d7e3";
            sapphire = "#7dc4e4";
            blue = "#8aadf4";
            lavender = "#b7bdf8";
            text = "#cad3f5";
            subtext1 = "#b8c0e0";
            subtext0 = "#a5adcb";
            overlay2 = "#939ab7";
            overlay1 = "#8087a2";
            overlay0 = "#6e738d";
            surface2 = "#5b6078";
            surface1 = "#494d64";
            surface0 = "#363a4f";
            base = "#24273a";
            mantle = "#1e2030";
            crust = "#181926";
          };
          catppuccin_mocha = {
            rosewater = "#f5e0dc";
            flamingo = "#f2cdcd";
            pink = "#f5c2e7";
            mauve = "#cba6f7";
            red = "#f38ba8";
            maroon = "#eba0ac";
            peach = "#fab387";
            yellow = "#f9e2af";
            green = "#a6e3a1";
            teal = "#94e2d5";
            sky = "#89dceb";
            sapphire = "#74c7ec";
            blue = "#89b4fa";
            lavender = "#b4befe";
            text = "#cdd6f4";
            subtext1 = "#bac2de";
            subtext0 = "#a6adc8";
            overlay2 = "#9399b2";
            overlay1 = "#7f849c";
            overlay0 = "#6c7086";
            surface2 = "#585b70";
            surface1 = "#45475a";
            surface0 = "#313244";
            base = "#1e1e2e";
            mantle = "#181825";
            crust = "#11111b";
          };
        };
      };
    };

    zsh.enable = isDarwin;
  };

  fonts.fontconfig.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  dconf.settings = mkIf isLinux {
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Terminal.desktop"
        "org.gnome.Nautilus.desktop"
        "Alacritty.desktop"
        "htop.desktop"
        "tresorit.desktop"
        "emacs.desktop"
        "firefox_firefox.desktop"
        "chromium_chromium.desktop"
        "org.telegram.desktop.desktop"
        "signal.desktop"
        "spotify_spotify.desktop"
      ];
    };
    "org/gnome/terminal/legacy/profiles:/:1d4804e8-44e6-4c2b-a37c-95789cad0e61" =
      {
        font = "UbuntuMono Nerd Font Mono 12";
        use-system-font = false;
        visible-name = "diana";
      };
  };

  xdg.enable = false;
}
