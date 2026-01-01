{
  description = "Diana's Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, home-manager }:
    let
      mkHome = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};

          modules = [ ./home.nix ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
      forAllSystems = nixpkgs.lib.genAttrs' [ "aarch64-darwin" "x86_64-linux" ]
        (system: nixpkgs.lib.nameValuePair ("diana.${system}") (mkHome system ));

    in { homeConfigurations = forAllSystems; };
}
