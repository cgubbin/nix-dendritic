{inputs, ...}: {
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.home-manager = {
    imports = [inputs.home-manager.nixosModules.home-manager];
    home-manager.backupFileExtension = "backup_hm";
  };
}
