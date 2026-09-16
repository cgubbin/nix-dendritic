{
  self,
  inputs,
  config,
  ...
}: let
  sops = inputs.starter.lib.mkSopsHost {
    secretsPath = toString inputs.nix-secrets;
    hostFile = "myhost.yaml";
    userFile = "myhost-user.yaml";
  };
in {
  flake-file.inputs.nix-secrets = {
    url = "git+ssh://git@github.com/<you>/nix-secrets.git";
    flake = false;
  };

  flake.modules.nixos."myhost" = {
    imports = [
      sops.nixos
      (inputs.starter.lib.mkSopsPasswordUser {username = "myuser";})
      self.modules.nixos."myuser"
    ];

    system.stateVersion = "26.05"; # set once, at first install — never bump this later
    home-manager.users."myuser".home.stateVersion = "26.05";

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) ["terraform"];
    home-manager.useGlobalPkgs = true; # makes home-manager use the system's pkgs, config included

    home-manager.sharedModules = [
      sops.homeManager
      {
        sops.secrets."netrc".path = "${config.home.homeDirectory}/.netrc";
      }
    ];
  };

  flake.nixosConfigurations."myhost" = inputs.starter.lib.mkNixos {
    inherit self;
    hostname = "myhost";
    platform = "wsl"; # or native
  };
}
