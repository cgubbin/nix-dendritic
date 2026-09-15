{...}: {
  flake.modules.homeManager.git = {pkgs, ...}: {
    services.ssh-agent.enable = true;

    home.packages = with pkgs; [
      git-lfs
      git-open
    ];

    programs.git = {
      enable = true;

      delta = {
        enable = true;
        options = {
          line-numbers = true;
          side-by-side = true;
          navigate = true;
          syntax-theme = "default";
        };
      };

      aliases = {
        cleanup = "!git branch --merged | grep -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        root = "rev-parse --show-toplevel";
        s = "status -sb";
        l = "log --oneline --graph --decorate";
        ll = "log --stat --graph --decorate";
        d = "diff";
        dc = "diff --cached";
        co = "checkout";
        sw = "switch";
        br = "branch";
        ci = "commit";
        amend = "commit --amend";
        unstage = "restore --staged";
      };

      extraConfig = {
        branch.autosetuprebase = "always";
        color.ui = true;
        core.askPass = "";
        push.default = "tracking";
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };
  };
}
