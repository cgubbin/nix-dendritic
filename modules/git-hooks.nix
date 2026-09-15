{inputs, ...}: {
  flake-file.inputs.git-hooks-nix = {
    url = "github:cachix/git-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [inputs.git-hooks-nix.flakeModule];

  perSystem = {
    pre-commit.settings.hooks = {
      nixfmt-rfc-style = {
        enable = false;
        settings.width = 110;
      };
      deadnix.enable = true;
      statix.enable = true;
    };
  };
}
