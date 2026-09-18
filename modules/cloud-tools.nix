_: {
  flake.modules.homeManager.cloud-tools = {
    pkgs,
    config,
    ...
  }: {
    home = {
      packages = with pkgs; [
        ansible
        doctl
        goofys
        (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
        krew
        kubectl
        kubectx
        kubelogin-oidc
        k9s
        opentofu
        terraform
      ];

      sessionVariables.KREW_ROOT = "${config.home.homeDirectory}/.krew";
      sessionPath = ["${config.home.homeDirectory}/.krew/bin"];
    };

    programs.awscli = {
      enable = true;
    };
  };
}
