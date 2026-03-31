{ pkgs, ... }:

{
  programs.vim = {
    enable = true;
    defaultEditor = true;
  
    settings = {
      number = true;
      tabstop = 2;
      shiftwidth = 2;
      copyindent = true;
      expandtab = true;
    };

    plugins = with pkgs.vimPlugins; [
      commentary          # gcc to comment
      indentLine
      surround            # motion + s + char, i.e. cs" = change surrounding to "
      vim-airline
      vim-airline-themes
      vim-gitgutter
    ];
  
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

      " vim airline themes
      let g:airline_theme='base16'

      " configure char to display for indent
      let g:indentLine_char = '¦'
    '';
  };
}
