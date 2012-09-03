" First load the user-customized preinit file
source ~/.vim/01-preinit.vim

" global settings
syntax on
filetype plugin indent on
set cb="exclude:.*"
set relativenumber
set autoread
set clipboard=unnamedplus " local clipboard integration
map :q :qa
map :wq :wqa

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

" Load customized coding styles
source ~/.vim/02-coding-style.vim

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
set mouse=a
set ttymouse=xterm2
behave xterm
set selectmode=mouse
"set selection=inclusive keymodel=startsel selectmode=key

" build window hotkeys
map <C-b> :w<CR>:make<CR>:cclose<CR>:copen<CR><C-W><C-P>
map <C-g> :cclose<CR>
map <C-p> :cp<CR>
map <C-n> :cn<CR>

" Search & replace the text under the cursor
:nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" Toggle the UI on backtick for ssh copy-pasting
nnoremap <silent> <Char-0x60> :set invrelativenumber<CR>:TagbarToggle<CR>:NERDTreeMirrorToggle<CR>:wincmd p<CR>

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

" load pathogen plugins
call pathogen#infect()

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
function ShowTagbarAndFocus()
  call tagbar#OpenWindow('c')
endfunction
autocmd BufWinEnter * nested TagbarOpen
"autocmd VimEnter * nested call ShowTagbarAndFocus()

" temporary hack to force focus on the file
autocmd VimEnter * 2:wincmd w

" Finally load the user-customized postinit file
source ~/.vim/09-postinit.vim
