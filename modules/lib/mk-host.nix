{inputs, ...}: let
  starterInputs = inputs;
in {
  flake.lib.mkNixos = {
    self,
    inputs,
    hostname,
    platform,
  }:
    starterInputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        starterInputs.self.modules.nixos.system-base
        (
          if platform == "wsl"
          then starterInputs.self.modules.nixos.wsl
          else starterInputs.self.modules.nixos.native
        )
        self.modules.nixos.${hostname}
      ];
    };
}
