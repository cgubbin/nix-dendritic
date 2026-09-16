{inputs, ...}: {
  flake.modules.nixos."<username>" = {
    home-manager.users."<username>" = {
      imports = [inputs.self.modules.homeManager."<username>"];
    };

    users.users."<username>" = {
      isNormalUser = true;
      group = "<username>";
      extraGroups = ["wheel"];
    };
    users.groups."<username>" = {};

    wsl = {
      defaultUser = "<username>";
    };
  };

  flake.modules.homeManager."<username>" = {
    imports = [
      inputs.starter.modules.homeManager.claude-code
      inputs.starter.modules.homeManager.cli-tools
      inputs.starter.modules.homeManager.cloud-tools
      inputs.starter.modules.homeManager.direnv
      inputs.starter.modules.homeManager.git
      (inputs.import-tree ../../home/"<username>")
    ];
  };
}
