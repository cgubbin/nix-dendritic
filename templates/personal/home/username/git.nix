{...}: {
  programs.git = {
    settings = {
      user = {
        name = "<ghusername>";
        email = "<wpemail>";
      };
      github.user = "<ghusername>";
    };
  };
}
