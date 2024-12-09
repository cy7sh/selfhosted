{
  description = "cy's flake for chunk";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    testpkgs.url = "github:cything/nixpkgs/caddy-environmentfile";
  };

  outputs = { self, nixpkgs, sops-nix, ... }@inputs:
  let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      chunk = lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
