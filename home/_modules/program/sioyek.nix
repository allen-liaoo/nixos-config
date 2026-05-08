{ ... }:

{
  programs.sioyek = {
    enable = true;
    config = {
      should_launch_new_window = "1";
    };
    bindings = {
      "next_page" = "<C-d>";
      "previous_page" = "<C-u>";
    };
  };
}
