{ ... }:

{
  programs.vim = {
    enable = true;
  
    settings = {
      number = true;
      tabstop = 2;
      shiftwidth = 2;
      copyindent = true;
      expandtab = true;
    };
  
    extraConfig = ''
      set backupcopy=yes
      set softtabstop=2
      set autoindent
      set noshiftround
      set showcmd
      syntax on
  
      nnoremap <Esc> :noh<CR>

      " hide lineno for mouse selection during visual mode
      autocmd ModeChanged *:[vV\x16]* set nonumber
      autocmd ModeChanged [vV\x16]*:* set number
    '';
  };

  home.sessionVariables = {
    EDITOR = "vim";
  };
}
