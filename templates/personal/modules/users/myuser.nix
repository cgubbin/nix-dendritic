{inputs, ...}: {
  flake.modules.nixos."<username>" = {
    home-manager.users."<username>" = {
      imports = [inputs.self.modules.homeManager."<username>"];
    };

    users.users."<username>" = {
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
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
