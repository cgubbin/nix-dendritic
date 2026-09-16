{inputs, ...}: {
  flake-file.inputs.nixos-wsl = {
    url = "github:nix-community/NixOS-WSL/main";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.wsl = {
    imports = [inputs.nixos-wsl.nixosModules.default];
    wsl = {
      enable = true;
      useWindowsDriver = true;
    };
  };
}
