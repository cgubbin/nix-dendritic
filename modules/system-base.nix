{inputs, ...}: {
  flake.modules.nixos.system-base = {
    imports = with inputs.self.modules.nixos; [
      nix-index
      home-manager
      sops
    ];
  };
}
