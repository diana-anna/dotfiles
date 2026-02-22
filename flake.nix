{
  description = "Diana's Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, nur }:
    let
      systems = [ "aarch64-darwin" "x86_64-linux" ];
      mkHome = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};

          modules =
            [ ./home.nix { nixpkgs.overlays = [ nur.overlays.default ]; } ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
          extraSpecialArgs = { inherit system; };
        };
      mkHomeConfig = system:
        nixpkgs.lib.nameValuePair ("diana.${system}") (mkHome system);
      forAllSystems = f: nixpkgs.lib.genAttrs' systems f;

    in {
      darwinConfigurations."diana-macbook" = nix-darwin.lib.darwinSystem {
        modules = [ ./darwin.nix ];
        specialArgs = { inherit inputs; };
      };
      homeConfigurations = forAllSystems mkHomeConfig;
    };
}
