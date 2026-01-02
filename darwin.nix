{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [ defaultbrowser ];

  homebrew = {
    enable = true;
    casks = [ "ghostty" "spotify" ];
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
  };

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.hostPlatform = "aarch64-darwin";

  security.pam.services.sudo_local.touchIdAuth = true;

  system = let
    scriptPkgs = [ pkgs.defaultbrowser ];
    scriptPath = pkgs.lib.makeBinPath scriptPkgs;
  in {
    activationScripts.postActivation.text = ''
      export PATH="${scriptPath}:$PATH"
      defaultbrowser firefox
    '';

    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    defaults = {
      dock = {
        appswitcher-all-displays = true;
        autohide = true;
        orientation = "bottom";
        persistent-apps = [
          { app = "/System/Applications/Apps.app"; }
          { app = "/Applications/Ghostty.app"; }
          { app = "/Users/diana/.nix-profile/Applications/Emacs.app"; }
          { app = "/Users/diana/.nix-profile/Applications/Firefox.app"; }
        ];
        show-recents = false;
      };
    };

    primaryUser = "diana";

    stateVersion = 6;
  };
}
