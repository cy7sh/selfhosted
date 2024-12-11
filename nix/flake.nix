{
  description = "cy's flake for chunk";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    testpkgs.url = "github:NixOS/nixpkgs/248081c4729259c3add830d502779c5d04cbe074";
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
