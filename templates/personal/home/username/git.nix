{...}: {
  programs.git = {
    settings = {
      user = {
        name = "<username>";
        email = "<email>";
      };
      github.user = "<username>";
    };
  };
}
