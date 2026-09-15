{inputs, ...}: {
  flake-file.inputs.llm-agents.url = "github:numtide/llm-agents.nix";

  flake.modules.nixos.claude-code = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
    ];
  };

  flake.modules.homeManager.claude-code = {pkgs, ...}: {
    home.packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
    ];
  };
}
