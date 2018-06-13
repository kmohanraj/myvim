set number

set noshowmode

let g:gitgutter_highlight_lines = 1

let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#statusline'
      \ },
      \ }

let g:gitgutter_sign_added = '++'
let g:gitgutter_sign_modified = '**'
let g:gitgutter_sign_removed = '--'
let g:gitgutter_sign_removed_first_line = '-1'
let g:gitgutter_sign_modified_removed = '-*'

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ----------------------------------------------------------------------------
" vimawesome.com
" ----------------------------------------------------------------------------

function! VimAwesomeComplete() abort
  let prefix = matchstr(strpart(getline('.'), 0, col('.') - 1), '[.a-zA-Z0-9_/-]*$')
  echohl WarningMsg
  echo 'Downloading plugin list from VimAwesome'
  echohl None
ruby << EOF
  require 'json'
  require 'open-uri'

  query = VIM::evaluate('prefix').gsub('/', '%20')
  items = 1.upto(max_pages = 3).map do |page|
    Thread.new do
      url  = "http://vimawesome.com/api/plugins?page=#{page}&query=#{query}"
      data = open(url).read
      json = JSON.parse(data, symbolize_names: true)
      json[:plugins].map do |info|
        pair = info.values_at :github_owner, :github_repo_name
        next if pair.any? { |e| e.nil? || e.empty? }
        {word: pair.join('/'),
         menu: info[:category].to_s,
         info: info.values_at(:short_desc, :author).compact.join($/)}
      end.compact
    end
  end.each(&:join).map(&:value).inject(:+)
  VIM::command("let cands = #{JSON.dump items}")
EOF
  if !empty(cands)
    inoremap <buffer> <c-v> <c-n>
    augroup _VimAwesomeComplete
      autocmd!
      autocmd CursorMovedI,InsertLeave * iunmap <buffer> <c-v>
            \| autocmd! _VimAwesomeComplete
    augroup END

    call complete(col('.') - strchars(prefix), cands)
  endif
  return ''
endfunction

augroup VimAwesomeComplete
  autocmd!
  autocmd FileType vim inoremap <c-x><c-v> <c-r>=VimAwesomeComplete()<cr>
augroup END

call plug#begin()

Plug 'tpope/vim-sensible'

Plug 'junegunn/fzf', { 'dir' : '~/.fzf', 'do' : './install --all' }

Plug 'junegunn/fzf.vim'

Plug 'itchyny/lightline.vim'

Plug 'airblade/vim-gitgutter'

Plug 'editorconfig/editorconfig-vim'

Plug 'tpope/vim-fugitive'

Plug 'tpope/vim-surround'

Plug 'valloric/youcompleteme'

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

Plug 'elixir-lang/vim-elixir', { 'for' : 'elixir' }

Plug 'mhinz/vim-mix-format', { 'for' : 'elixir' }

Plug 'joedicastro/vim-molokai256'

call plug#end()

map <C-o> :NERDTreeToggle<CR>

colo molokai256 
