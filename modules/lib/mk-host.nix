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
        inputs.self.modules.nixos.system-base
        (
          if platform == "wsl"
          then inputs.self.modules.nixos.wsl
          else inputs.self.modules.nixos.native
        )
        self.modules.nixos.${hostname}
      ];
    };
}
