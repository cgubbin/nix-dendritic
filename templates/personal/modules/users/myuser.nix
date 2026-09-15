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
  };

  flake.modules.homeManager."<username>" = {
    imports = [
      inputs.self.modules.homeManager.claude-code
      inputs.self.modules.homeManager.cli-tools
      inputs.self.modules.homeManager.cloud-tools
      (inputs.import-tree ../../home/"<username>")
    ];
  };
}
