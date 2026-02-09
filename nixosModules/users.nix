{
  config,
  pkgs,
  ...
}:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gusjengis = {
    isNormalUser = true;
    description = "Anthony Green";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "docker"
    ];
    packages = with pkgs; [ home-manager ];
    openssh.authorizedKeys.keys = [
      (builtins.readFile /home/gusjengis/.config/secrets/ssh/shared_ed25519.pub)
    ];
  };
}
