{...}: {
  flake.modules.homeManager.cli-tools = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Nix linting
      alejandra
      deadnix
      nixd
      nixfmt
      statix

      age
    ];
  };
}
