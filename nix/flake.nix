{
  description = "cy's flake for chunk";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix }:
  let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      chunk = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
