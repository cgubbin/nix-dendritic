{...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = [config.pre-commit.devShell];
      packages = [pkgs.just pkgs.home-manager];
    };
  };
}
