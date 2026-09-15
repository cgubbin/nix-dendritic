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
    ];

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
