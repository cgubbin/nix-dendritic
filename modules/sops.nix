{inputs, ...}: {
  flake-file.inputs.sops-nix = {
    url = "github:mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.sops = {
    imports = [inputs.sops-nix.nixosModules.sops];
    home-manager.sharedModules = [inputs.self.modules.homeManager.sops];
  };

  flake.modules.homeManager.sops = {
    imports = [inputs.sops-nix.homeManagerModules.sops];
  };

  # Wires nixos-level + home-manager-level sops config at a `<file>.yaml` /
  # `<file>-user.yaml` convention under a given secrets repo.
  flake.lib.mkSopsHost = {
    secretsPath,
    hostFile,
    userFile,
  }: {
    nixos = {
      sops = {
        defaultSopsFile = "${secretsPath}/secrets/${hostFile}";
        age = {
          keyFile = "/var/lib/sops-nix/key.txt";
          generateKey = true;
        };
      };
    };

    homeManager = {config, ...}: {
      sops = {
        defaultSopsFile = "${secretsPath}/secrets/${userFile}";
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
  };

  # Points a system user's login password at a sops secret instead of a
  # plaintext hashedPassword.
  flake.lib.mkSopsPasswordUser = {
    username,
    secretName ? "${username}-password",
  }: {config, ...}: {
    sops.secrets.${secretName}.neededForUsers = true;
    users.users.${username}.hashedPasswordFile = config.sops.secrets.${secretName}.path;
  };
}
