" This file is for any custom system-wide configuration that must happen last.

" Configure a 'Lint' command to run GPyLint on the current Python File.
" Use same gpylint.par as g4, even though 'gpylint' is more up-to-date.
" (e.g. The latter could handle @property before the former could.)
function! s:GPyLint()
  let a:lint = '/usr/bin/gpylint '
    \. '--output-format=parseable --include-ids=y'
  cexpr system(a:lint . ' ' . expand('%'))
endfunction
au FileType python command! Lint :call s:GPyLint()

" Make builds in python run lint
au FileType python setlocal errorformat=%+P[%f],%t:\ %#%l:%m
au FileType python setlocal makeprg=/usr/bin/gpylint\ --output-format=parseable\ %

set relativenumber
