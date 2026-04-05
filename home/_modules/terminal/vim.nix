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
      commentary          # gcc to comment line, or gc + motion
      indentLine
      surround            # motion + s + char, i.e. cs( = change surrounding to (
      lightline-vim       # status line
      vim-cool            # disable search highlight after search
      vim-signify         # git diff on the left
      vim-peekaboo        # show contents of registers when pressing "
    ];
  
    extraConfig = ''
      set autoindent
      set backupcopy=yes
      set noshiftround
      set showcmd
      set softtabstop=2
      syntax on
  
      nnoremap <Esc> :noh<CR>

      " hide lineno for mouse selection during visual mode
      autocmd ModeChanged *:[vV\x16]* set nonumber
      autocmd ModeChanged [vV\x16]*:* set number

      let g:lightline = {
      \ 'colorscheme': 'one',
      \ }

      let g:indentLine_char = '¦'

      " show git diff relative to head (dont ignore staged changes)
      let g:gitgutter_diff_base = 'HEAD'

      "remove indent line and signify in visual mode
      augroup IndentLineVisualToggle
        autocmd!
        autocmd ModeChanged *:[vV\x16]* IndentLinesDisable | SignifyDisable
        autocmd ModeChanged [vV\x16]*:* IndentLinesEnable | SignifyEnable
      augroup END

    '';
  };
}
