let mapleader = " "

" sync clipboard
set clipboard=unnamedplus

nnoremap <silent> <S-l> :bnext<CR>
nnoremap <silent> <S-h> :bprevious<CR>
nnoremap <silent> <leader>q :BufferClose<CR>
nnoremap <silent> <leader>Q :q<CR>
nnoremap <silent> <leader>U ::bufdo bd<CR>
nnoremap <silent> <leader>vs :vsplit<CR>:bnext<CR>

" buffer position nav + reorder
nnoremap <silent> <A-1> <Cmd>BufferGoto 1<CR>
nnoremap <silent> <A-2> <Cmd>BufferGoto 2<CR>
nnoremap <silent> <A-3> <Cmd>BufferGoto 3<CR>
nnoremap <silent> <A-4> <Cmd>BufferGoto 4<CR>
nnoremap <silent> <A-5> <Cmd>BufferGoto 5<CR>
nnoremap <silent> <A-6> <Cmd>BufferGoto 6<CR>
nnoremap <silent> <A-7> <Cmd>BufferGoto 7<CR>
nnoremap <silent> <A-8> <Cmd>BufferGoto 8<CR>
nnoremap <silent> <A-9> <Cmd>BufferGoto 9<CR>
nnoremap <silent> <A-0> <Cmd>BufferLast<CR>
nnoremap <silent> <A-p> <Cmd>BufferPin<CR>

"windows - ctrl nav, fn resize
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l
nnoremap <silent> <F5> :resize +2<CR>
nnoremap <silent> <F6> :resize -2<CR>
nnoremap <silent> <F7> :vertical resize +2<CR>
nnoremap <silent> <F8> :vertical resize -2<CR>

nnoremap <silent> <Esc> :nohlsearch<CR>

nnoremap <silent> <leader>w :w<CR>
nnoremap <silent> <leader>d :w 

