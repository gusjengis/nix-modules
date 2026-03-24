{ inputs, ... }:

{
  imports = [
    inputs.apple-silicon.nixosModules.default
  ];
}
