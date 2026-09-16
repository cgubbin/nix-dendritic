{inputs, ...}: let
  starterInputs = inputs;
in {
  flake-file.inputs.home-manager = {
    url = "https://flakehub.com/f/nix-community/home-manager/0.1";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.home-manager = {inputs, ...}: {
    imports = [starterInputs.home-manager.nixosModules.home-manager];
    home-manager.backupFileExtension = "backup_hm";
    home-manager.extraSpecialArgs = {inherit inputs;};
  };
}
