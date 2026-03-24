{
  description = "System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      hardwareConfiguration = /etc/nixos/hardware-configuration.nix;
      hardwareConfigText = builtins.readFile hardwareConfiguration;
      system =
        if lib.hasInfix ''"aarch64-linux"'' hardwareConfigText then "aarch64-linux" else "x86_64-linux";
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            hardwareConfiguration
            /etc/nixos/configuration.nix
            /etc/nix-modules/nixosModules
          ];
        };
      };
    };
}
