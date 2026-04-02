{ ... }: 

{
  programs.sioyek = {
    enable = true;
    bindings = {
      "next_page" = "<C-d>";
      "previous_page" = "<C-u>";
    };
  };
}
