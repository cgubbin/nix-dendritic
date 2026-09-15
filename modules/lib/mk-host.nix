{inputs, ...}: {
  flake.lib.mkNixos = {
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
        inputs.self.modules.nixos.${hostname}
      ];
    };
}
