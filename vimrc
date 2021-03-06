set nocompatible

" First load the user-customized preinit file
source ~/.vim/01-preinit.vim

" global settings
syntax on
filetype plugin indent on
scriptencoding utf-8
set cb="exclude:.*"
set backspace=indent,eol,start
set relativenumber
set autoread
"set clipboard=unnamedplus " local clipboard integration
set showmode                    " display the current mode
set cursorline                  " highlight current line
set shortmess+=filmnrxoOtT      " abbrev. of messages (avoids 'hit enter')
set viewoptions=folds,options,cursor,unix,slash " better unix / windows compatibility
set wildmenu                    " show list instead of just completing
set wildmode=list:longest,full  " command <Tab> completion, list matches, then longest common part, then all.
map :q :qa
map :wq :wqa

" backup to ~/.tmp
set backup
set backupdir=~/.vim/tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim/tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup
" set noswapfile
" set nobackup

" Control-n to switch back & forth between relative & absolute numbers
function! NumberToggle()
  if(&relativenumber == 1)
    set number
  else
    set relativenumber
  endif
endfunc
nnoremap <C-n> :call NumberToggle()<cr>

" Only use relative numbers when we have focus (fixes issues with tests)
:au FocusLost * :set number
:au FocusGained * :set relativenumber
" Only use relative numbers in command mode
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber

" Load customized color scheme
source ~/.vim/03-colors.vim

" Auto-reload changed files on frame activation
source ~/.vim/src/autoread.vim
let autoreadargs={'autoread':1}
:silent execute WatchForChanges('*', autoreadargs)

" colors for trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" mouse fixes
" set mouse=a
set mouse=nv " Just for normal and visual modes
set ttymouse=xterm2
behave xterm
set selectmode=mouse
"set selection=inclusive keymodel=startsel selectmode=key

" build window hotkeys and setup
map <C-l> :Lint<CR>
map <C-b> :w<CR>:make %<CR>:cclose<R>:copen<CR><C-W><C-P>
map <C-g> :cclose<CR>
" These might conflict with omnicomplete
"map <C-p> :cp<CR>
"map <C-n> :cn<CR>

" Search & replace the text under the cursor
:nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" Toggle the UI on backtick for ssh copy-pasting
nnoremap <silent> <Char-0x60> :set invrelativenumber<CR>:TagbarToggle<CR>:NERDTreeMirrorToggle<CR>:wincmd p<CR>

" Fancy status bar stolen from spf13
  if has('cmdline_info')
    set ruler                   " show the ruler
    set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " a ruler on steroids
    set showcmd                 " show partial commands in status line and selected characters/lines in visual mode
  endif

  if has('statusline')
    set laststatus=2

    " Broken down into easily includeable segments
    set statusline=%<%f\    " Filename
    set statusline+=%w%h%m%r " Options
    set statusline+=%{fugitive#statusline()} "  Git Hotness
    set statusline+=\ [%{&ff}/%Y]            " filetype
    set statusline+=\ [%{getcwd()}]          " current dir
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
  endif


" tab stuff
  :set hidden
  :set tabpagemax=100
  :set switchbuf=usetab,newtab
  ":au BufAdd,BufNewFile * nested tab sball
  :set showtabline=2 " Always show, even for a single file
  map gf <C-w>gf " Always open files in new tabs

  " From http://vim.wikia.com/wiki/Show_tab_number_in_your_tab_line
  " Modified for better number formatting.
  " Modified to skip past plugin buffers like NERD_tree_1 in all cases.
  if exists("+showtabline")
    function MyTabLine()
      let numsep = '❳'
      "let numsep = '›'
      let s = ''
      let t = tabpagenr()
      let i = 1
      while i <= tabpagenr('$')
        let buflist = tabpagebuflist(i)
        let bufcount = len(buflist)
        let winnr = tabpagewinnr(i)
        " set the tab page number (for mouse clicks)
        let s .= '%' . i . 'T'
        let s .= '%#TabLine#'
        let s .= ' '
        let s .= '%#TabNum#'
        let s .= i . numsep
        let s .= '%*'
        let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')

        " Loop through the buffers, starting at the current, to find the first
        " one that's not a plugin
        let cur_winnr = winnr
        let file = bufname(buflist[winnr - 1])
        while file == 'NERD_tree_1' || file == 'ControlP'
          let winnr = (winnr + 1) % bufcount
          if winnr == cur_winnr
            break
          endif
          let file = bufname(buflist[winnr - 1])
        endwhile
        let file = fnamemodify(file, ':.')
        if file == ''
          let file = '[No Name]'
        endif
        let s .= file
        let i = i + 1
      endwhile
      let s .= '%T%#TabLineFill#%='
      let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
      return s
    endfunction
    set tabline=%!MyTabLine()
  endif

 " gui-like keyboard shortcuts
  map <Leader>w :TagbarClose<CR>:confirm bdelete<CR>
  noremap <Tab>       :tabn<CR>
  noremap <S-Tab>     :tabp<CR>
  let g:lasttab = 1
  nmap <Leader>t :exe "tabn ".g:lasttab<CR>
  au TabLeave * let g:lasttab = tabpagenr()

  " setup ,0 for last tab like chrome/firefox
  nmap <Leader>0 :tablast<CR>

  " switching to buffer 1 - 9 is mapped to ,[nOfBuffer]
  for buffer_no in range(1, 9)
    execute "nmap <Leader>" . buffer_no . " :normal " . buffer_no . "gt\<CR>"
  endfor

  " switching to buffer 10 - 100 is mapped to ,,[nOfBuffer]
  for buffer_no in range(10, 100)
    execute "nmap <Leader><Leader>" . buffer_no . " :normal " . buffer_no . "gt\<CR>"
  endfor

" Temporarily disable syntastic for typescript, it's just so slow.
let g:loaded_typescript_syntax_checker = 1

" vim airline
let g:airline_theme = 'solarized'
let g:airline#extensions#hunks#non_zero_only = 1

" Neocomplete stuff.
let g:acp_enableAtStartup = 0 " Disable AutoComplPop.
let g:neocomplete#auto_completion_start_length = 1
let g:neocomplete#enable_at_startup = 1 " Use neocomplete.
let g:neocomplete#enable_smart_case = 1 " Use smartcase.
let g:neocomplete#sources#syntax#min_keyword_length = 2 " Set minimum syntax keyword length.
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
let g:neocomplete#enable_auto_select = 0
let g:neocomplete#disable_auto_complete = 1

" Enable snipMate compatibility feature.
" let g:neosnippet#enable_snipmate_compatibility = 1
" let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

" Julia configuration
let g:julia_latex_to_unicode = 0  " Requires VIM 7.4
let g:julia_auto_latex_to_unicode = 0
" Actually the current vim-julia is broken. Added a temp code hack to fix.


" Session configuration. Auto create/load sessions when opening a directory.
let g:session_autosave = 'no'
let g:session_autoload = 'no'
if argc() == 0 || (argc() == 1 && isdirectory(argv(0)))
  function SaveGlobals()
    let s:globals = []
    for gk in keys(g:)
      let s:gkt = type(g:[gk])
      if !islocked('g:' . gk) && s:gkt != 2 && s:gkt != 4
        call add(s:globals, 'g:' . gk)
      endif
    endfor
    let g:session_persist_globals = s:globals
  endfunction

  call SaveGlobals()
  "autocmd VimEnter * nested call SaveGlobals()

  let s:session_dir = getcwd()
  if argc() == 1
    let s:session_dir = argv(0)
  endif

  " Remove trailing slash if found.
  let s:session_dir = substitute(s:session_dir, '\(\\\|\/\)$', '', '')

  let g:session_autosave = 'yes'
  "let g:session_autoload = 'yes'
  let g:session_autosave_periodic = 1
  let g:session_directory = s:session_dir . '/.vimsession'
  autocmd VimEnter * nested :OpenSession
endif


" load pathogen plugins
call pathogen#infect()

  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return neocomplete#smart_close_popup() . "\<CR>"
    " For no inserting <CR> key.
    return pumvisible() ? neocomplete#close_popup() : "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y>  neocomplete#close_popup()
  inoremap <expr><C-e>  neocomplete#cancel_popup()
  " Close popup by <Space>.
  inoremap <expr><Space> pumvisible() ? neocomplete#close_popup()."\<Space>" : "\<Space>"

  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript,typescript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" ctrl-p stuff
let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files --exclude-standard -co']
let g:ctrlp_map = '<C-t>'
let g:ctrlp_working_path_mode = 0 " always use CWD
let g:ctrlp_dotfiles = 0
let g:ctrlp_custom_ignore = '\.git$\|\.idea$\|.swp$'
let g:ctrlp_use_caching = 0 " causes too many issues with git branches
let g:ctrlp_open_new_file = 't' " open in new tab
" open in existing or new tab
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("e")': [],
  \ 'AcceptSelection("t")': ['<cr>', '<c-m>'],
  \ }
nmap <S-t> :CtrlPMRU<CR>

" buffergator stuff
let g:buffergator_sort_regime = 'mru'
let g:buffergator_suppress_keymaps = 1
nnoremap <silent> <Leader>b :BuffergatorOpen<CR>
nnoremap <silent> <Leader>B :BuffergatorClose<CR>
"noremap <buffer> <silent> <CR> :<C-U>call b:buffergator_catalog_viewer.visit_open_target(0, !g:buffergator_autodismiss_on_select, "tab sb")<CR>

" easymotion stuff
"let g:EasyMotion_leader_key = '<Leader>'

" nerdtree
let NERDTreeMinimalUI = 1
map <leader>r :NERDTreeFind<cr> " jump to current file in tree
let g:nerdtree_tabs_open_on_console_startup = 1
let g:nerdtree_tabs_focus_on_files = 1
let g:nerdtree_tabs_meaningful_tab_names = 1
let g:nerdtree_tabs_smart_startup_focus = 1

" ack
let g:ackprg="ack-grep -H --nocolor --nogroup --column"
map <leader>a :Ack<space>

" tagbar
let g:tagbar_autoclose = 0
let g:tagbar_autoshowtag = 1
let g:tagbar_left = 0
let g:tagbar_width = 36
let g:tagbar_compact = 1
let g:tagbar_sort = 0
autocmd BufWinEnter * nested if xolox#session#find_current_session() == '' | TagbarOpen | endif

" OmniComplete {
  if has("autocmd") && exists("+omnifunc")
    autocmd Filetype *
      \if &omnifunc == "" |
      \setlocal omnifunc=syntaxcomplete#Complete |
      \endif
  endif

  hi Pmenu  guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
  hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
  hi PmenuThumb  guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE

  " some convenient mappings
  inoremap <expr> <Esc>      pumvisible() ? "\<C-e>\<Esc>" : "\<Esc>"
  inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
  inoremap <expr> <Down>     pumvisible() ? "\<C-j>" : "\<Down>"
  inoremap <expr> <Up>       pumvisible() ? "\<C-k>" : "\<Up>"
  "inoremap <expr> <C-d>      pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
  "inoremap <expr> <C-u>      pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
  "inoremap <C-Space> <C-X><C-O>

  " automatically open and close the popup menu / preview window
  au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
  set completeopt=menuone,preview,longest
" }

" Load customized coding styles
source ~/.vim/02-coding-style.vim

" Finally load the user-customized postinit file
source ~/.vim/09-postinit.vim
