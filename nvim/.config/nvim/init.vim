" Set leader to Space
let mapleader = " "
let g:mapleader = " "
let g:python3_host_prog = '/home/adithya/.venv/bin/python'
nnoremap <Space> <Nop>
vnoremap <Space> <Nop>

" Move by display lines instead of physical lines
nnoremap j gj
nnoremap k gk
" Optional: Make 0 and ^ always refer to the display line
nnoremap 0 g0
nnoremap ^ g^

" =========================
" 1. BASIC SETTINGS
" =========================
set nocompatible
syntax on
filetype plugin indent on
set clipboard=unnamedplus
set number
set tabstop=2
set shiftwidth=2
set expandtab
set softtabstop=2
set autoindent
set smartindent
set termguicolors
set signcolumn=yes
set updatetime=300
set shortmess+=c
set ignorecase
set smartcase
set wildmenu

" =========================
" 2. PLUGINS
" =========================
call plug#begin('~/.vim/plugged')
Plug 'karb94/neoscroll.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
" LSP & Completion
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'
Plug 'SirVer/ultisnips'
Plug 'windwp/nvim-autopairs'

" UI & Utils
Plug 'nikolvs/vim-sunbather'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
" Themes
Plug 'rose-pine/vim'
Plug 'bluz71/vim-moonfly-colors', { 'as': 'moonfly' }
" Plug 'mbbill/undotree'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'stevearc/oil.nvim'
Plug 'akinsho/toggleterm.nvim', {'tag': '*'}
Plug 'tiagovla/scope.nvim'
Plug 'MeanderingProgrammer/render-markdown.nvim'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
call plug#end()

" =========================
" 3. PLUGIN CONFIG (VIMSCRIPT)
" =========================
" UltiSnips
" CHANGED: Moved away from <C-j>/<C-k> so Telescope can use them. 
" CMP handles your snippets via <Tab> anyway!
let g:UltiSnipsExpandTrigger = '<C-l>'
let g:UltiSnipsJumpForwardTrigger = '<C-l>'
let g:UltiSnipsJumpBackwardTrigger = '<C-h>'
let g:UltiSnipsSnippetDirectories = ['UltiSnips']

" Theme
set background=dark
colorscheme moonfly
let g:moonflyCursorColor = v:true

" Keybindings
nnoremap <ESC> :nohlsearch<CR>
noremap <F1> <Nop>
inoremap <F1> <Nop>

" ADDED: Telescope project and word searching
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fw <cmd>Telescope grep_string<cr>
imap <C-BS> <C-W>

" =========================
" 4. LUA CONFIG
" =========================
lua << EOF
require("ibl").setup {
    indent = { char = "▏" },
    scope = { enabled = true },
}

-- 1. TERMINAL SETUP
require("toggleterm").setup({
  size = 20,
  open_mapping = [[<c-\>]],
  hide_numbers = true,
  start_in_insert = true,
  direction = 'float',
  float_opts = { border = 'curved' }
})

function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
end

local term_group = vim.api.nvim_create_augroup("TerminalConfig", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function() 
    vim.cmd("startinsert") 
    _G.set_terminal_keymaps()
  end,
  group = term_group,
})

-- 2. FILE EXPLORER (OIL)
require("oil").setup({
  default_file_explorer = true,
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- 3. TELESCOPE
local actions = require("telescope.actions")
require("telescope").setup({
  defaults = {
    mappings = {
      i = { 
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
      n = { 
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
    },
  },
})

-- 4. COMPLETION (CMP + ULTISNIPS + AUTOPAIRS)
require("nvim-autopairs").setup({
    enable_check_bracket_line = false,
    ignored_next_char = "[%w%.]", 
})

local cmp = require('cmp')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    
    -- UltiSnips Tab Logic
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
         -- CHANGED: Must match the new UltiSnipsExpandTrigger (<C-l>)
         vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-l>", true, true, true), "n", true)
      else
        fallback()
      end
    end, { "i", "s" }),
    
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'ultisnips' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  })
})

-- Integrate Autopairs with CMP
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

-- 5. LSP SETUP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<C-t>', '<C-o>', opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
  end,
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "clangd", "pyright" },
  handlers = {
    function(server_name)
      local opts = { capabilities = capabilities }
      if server_name == "pyright" then
        opts.settings = {
          python = { pythonPath = "/home/adi/myenv/bin/python" }
        }
      end
      require("lspconfig")[server_name].setup(opts)
    end,
  },
})

-- 6. SETUP SCOPE
require("scope").setup()
require('neoscroll').setup({
  mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
    '<C-u>', '<C-d>',
    '<C-b>', '<C-f>',
    '<C-y>', '<C-e>',
    'zt', 'zz', 'zb',
  },
  hide_cursor = true,          -- Hide cursor while scrolling
  stop_eof = true,             -- Stop at <EOF> when scrolling downwards
  respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  duration_multiplier = 1.0,   -- Global duration multiplier
  easing = 'linear',           -- Default easing function
  pre_hook = nil,              -- Function to run before the scrolling animation starts
  post_hook = nil,             -- Function to run after the scrolling animation ends
  performance_mode = false,    -- Disable "Performance Mode" on all buffers.
  ignored_events = {           -- Events ignored while scrolling
      'WinScrolled', 'CursorMoved'
  },
})
EOF
