{inputs, ...}: {
  flake.lib.mkNixos = {
    self,
    hostname,
    platform,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        self.modules.nixos.system-base
        (
          if platform == "wsl"
          then self.modules.nixos.wsl
          else self.modules.nixos.native
        )
        inputs.self.modules.nixos.${hostname}
      ];
    };
}
