{inputs, ...}: {
  flake.modules.nixos.system-base = {
    imports = with inputs.self.modules.nixos; [
      nix-index
      home-manager
      sops
    ];

    boot.binfmt.emulatedSystems = ["aarch64-linux"];
  };
}
