{...}: {
  flake.modules.homeManager.git = {pkgs, ...}: {
    services.ssh-agent.enable = true;

    home.packages = with pkgs; [
      git-lfs
      git-open
    ];

    programs.git = {
      enable = true;
    };
  };
}
