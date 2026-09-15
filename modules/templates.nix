{inputs, ...}: {
  flake.templates.personal = {
    path = ../templates/personal;
    description = "Personal Nix config depending on this starter flake";
    welcomeText = ''
      # Personal config scaffolded from the starter

      Before building anything:
      1. Rename `modules/hosts/myhost.nix` to your actual hostname, and edit
         the `"myhost"` strings inside it.
      2. Rename `modules/users/myuser.nix` to your actual username, and edit
         the `"myuser"` strings inside it.
      3. Rename `home/myuser/` to match.
      4. Run `nix run .#write-flake` to regenerate `flake.nix`, then
         `nix flake check`.
    '';
  };

  flake.templates.default = inputs.self.templates.personal;
}
