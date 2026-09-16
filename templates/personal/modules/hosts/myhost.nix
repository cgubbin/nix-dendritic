{
  self,
  inputs,
  config,
  ...
}: let
  sops = inputs.starter.lib.mkSopsHost {
    secretsPath = toString inputs.nix-secrets;
    hostFile = "<hostname>.yaml";
    userFile = "<hostname>-user.yaml";
  };
in {
  flake-file.inputs.nix-secrets = {
    url = "git+ssh://git@github.com/<ghusername>/nix-secrets.git";
    flake = false;
  };

  flake.modules.nixos."<hostname>" = {
    imports = [
      sops.nixos
      (inputs.starter.lib.mkSopsPasswordUser {username = "<username>";})
      self.modules.nixos."<username>"
    ];

    system.stateVersion = "26.05"; # set once, at first install — never bump this later
    home-manager.users."<username>".home.stateVersion = "26.05";
    networking.hostName = "<hostname>";

    # Add any other unfree packages here...
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) ["terraform"];
    home-manager.useGlobalPkgs = true; # makes home-manager use the system's pkgs, config included

    home-manager.sharedModules = [
      sops.homeManager
      (
        {config, ...}: {
          sops.secrets."netrc".path = "${config.home.homeDirectory}/.netrc";
        }
      )
    ];

    wsl = {
      wslConf = {
        network.hostname = "<hostname>";
      };
    };

    # to enable the shell, replace with the chosen shell
    # programs.fish.enable = true;
  };

  flake.nixosConfigurations."<hostname>" = inputs.starter.lib.mkNixos {
    inherit self;
    hostname = "<hostname>";
    platform = "wsl"; # or native
  };
}
