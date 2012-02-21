call NERDTreeAddKeyMap({
       \ 'key': '2-leftmouse',
       \ 'scope': 'FileNode',
       \ 'callback': "NERDTreeOpenNodeInNewTab",
       \ 'quickhelpText': 'open file in a new tab' })

function! NERDTreeOpenNodeInNewTab(node)
      call a:node.openInNewTab({})
    endfunction
