#!/bin/bash


git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime && \
  sh ~/.vim_runtime/install_awesome_vimrc.sh && \
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
  cat > ~/.vim_runtime/my_configs.vim <<EOF

set mouse=a
nnoremap <C-t> :NERDTree<CR>

call plug#begin()
  Plug 'preservim/nerdtree'
call plug#end()

EOF



