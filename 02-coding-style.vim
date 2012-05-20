" This file is for customizing coding style (tabs vs. spaces, etc).

set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2
set shiftwidth=2
set textwidth=80

" highlight 80 char width
if exists('+colorcolumn')
  set colorcolumn=81 " want the bar 1 char right to prevent confusion
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

" And override 80-column settings per-filetype
autocmd FileType html setlocal colorcolumn=0 textwidth=0
autocmd FileType sh setlocal colorcolumn=0 textwidth=0
