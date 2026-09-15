{...}: {
  flake.modules.homeManager.cloud-tools = {pkgs, ...}: {
    home.packages = with pkgs; [
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

    programs.awscli = {
      enable = true;
    };
  };
}
