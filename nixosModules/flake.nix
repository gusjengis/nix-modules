{
  description = "System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      apple-silicon,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      system = builtins.currentSystem;
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hardware-configuration.nix
            ./configuration.nix
            /etc/nix-modules/nixosModules
            apple-silicon.nixosModules.default
          ];
        };
      };
    };
}
