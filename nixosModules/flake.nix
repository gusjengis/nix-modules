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
            /etc/nixos/hardware-configuration.nix
            /etc/nixos/configuration.nix
            /etc/nix-modules/nixosModules
          ]
          ++ lib.optionals (system == "aarch64-linux") [
            apple-silicon.nixosModules.default
          ];
        };
      };
    };
}
