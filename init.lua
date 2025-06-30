vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set nu rnu")
vim.cmd("set cursorline")
vim.opt.guicursor = ""


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require('lazy').setup({
  {'cohama/lexima.vim'},	
  {'folke/tokyonight.nvim'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
  {'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},},
{"nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function () 
      local configs = require("nvim-treesitter.configs")
  
      configs.setup({
          ensure_installed = { "c", "lua","python","go", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "markdown" },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },  
        })
    end },
{'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  lazy = false,},
  
})

-- Set colorscheme
vim.opt.termguicolors = true
vim.cmd.colorscheme('tokyonight-storm')

---
-- LSP setup
---

-- Reserve a space in the gutter
-- This will avoid an annoying layout shift in the screen
vim.opt.signcolumn = 'yes'

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  }
})



---
-- Autocompletion config
---
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
})


require'lspconfig'.gopls.setup{}
require("lspconfig").clangd.setup {
  cmd = {
      "clangd",
      "--fallback-style=webkit"      
  }
}
require'lspconfig'.pylsp.setup{}
require'lspconfig'.tinymist.setup{
 single_file_support = true,
  settings = {
    exportPdf = "onSave",
  },
}


require("lspconfig").rust_analyzer.setup {
    settings = {
      ["rust-analyzer"] = {
        check = {
          command = "clippy", -- Empfohlen: Nutze Clippy für bessere Linting-Ergebnisse
          allTargets = true,
        },
        procMacro = {
          enable = true,
        },
        hover = {
          actions = {
            run = true,
          },
        },
        diagnostics = {
          enable = true,
          disabled = {
            -- Beispiel: Wenn du bestimmte Warnungen nicht sehen möchtest
            -- "unresolved-macro-call",
          },
          experimental = {
            enable = true,
          },
        },
        cargo = {
            loadOutDirsFromEnv = true,
        },
      },
    },
    -- Zusätzliche on_attach Konfigurationen, die nur für rust_analyzer gelten
    -- (die allgemeinen on_attach-Einstellungen werden bereits aus config.lsp geladen)
    on_attach = function(client, bufnr)
        -- Hier könntest du rust-analyzer-spezifische Tastenkürzel hinzufügen
        -- Beispiel: ":RustLsp" Kommando ist nützlich für rust-analyzer
        vim.keymap.set("n", "<Leader>ra", "<cmd>RustLsp<CR>", { desc = "Rust Analyzer Commands" })
    end,
  }


-- Markdown Prev:

require('render-markdown').setup({

 callout = {
        note      = { raw = '[!NOTE]',      rendered = 'Note',      highlight = 'RenderMarkdownInfo',    category = 'github'   },
        tip       = { raw = '[!TIP]',       rendered = 'Tip',       highlight = 'RenderMarkdownSuccess', category = 'github'   },
        important = { raw = '[!IMPORTANT]', rendered = 'Important', highlight = 'RenderMarkdownHint',    category = 'github'   },
        warning   = { raw = '[!WARNING]',   rendered = 'Warning',   highlight = 'RenderMarkdownWarn',    category = 'github'   },
        caution   = { raw = '[!CAUTION]',   rendered = 'Caution',   highlight = 'RenderMarkdownError',   category = 'github'   },
        abstract  = { raw = '[!ABSTRACT]',  rendered = 'Abstract',  highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
        summary   = { raw = '[!SUMMARY]',   rendered = 'Summary',   highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
        tldr      = { raw = '[!TLDR]',      rendered = 'Tldr',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
        info      = { raw = '[!INFO]',      rendered = 'Info',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
        todo      = { raw = '[!TODO]',      rendered = 'Todo',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
        hint      = { raw = '[!HINT]',      rendered = 'Hint',      highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
        success   = { raw = '[!SUCCESS]',   rendered = 'Success',   highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
        check     = { raw = '[!CHECK]',     rendered = 'Check',     highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
        done      = { raw = '[!DONE]',      rendered = 'Done',      highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
        question  = { raw = '[!QUESTION]',  rendered = 'Question',  highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
        help      = { raw = '[!HELP]',      rendered = 'Help',      highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
        faq       = { raw = '[!FAQ]',       rendered = 'Faq',       highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
        attention = { raw = '[!ATTENTION]', rendered = 'Attention', highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
        failure   = { raw = '[!FAILURE]',   rendered = 'Failure',   highlight = 'RenderMarkdownError',   category = 'obsidian' },
        fail      = { raw = '[!FAIL]',      rendered = 'Fail',      highlight = 'RenderMarkdownError',   category = 'obsidian' },
        missing   = { raw = '[!MISSING]',   rendered = 'Missing',   highlight = 'RenderMarkdownError',   category = 'obsidian' },
        danger    = { raw = '[!DANGER]',    rendered = 'Danger',    highlight = 'RenderMarkdownError',   category = 'obsidian' },
        error     = { raw = '[!ERROR]',     rendered = 'Error',     highlight = 'RenderMarkdownError',   category = 'obsidian' },
        bug       = { raw = '[!BUG]',       rendered = 'Bug',       highlight = 'RenderMarkdownError',   category = 'obsidian' },
        example   = { raw = '[!EXAMPLE]',   rendered = 'Example',   highlight = 'RenderMarkdownHint' ,   category = 'obsidian' },
        quote     = { raw = '[!QUOTE]',     rendered = 'Quote',     highlight = 'RenderMarkdownQuote',   category = 'obsidian' },
        cite      = { raw = '[!CITE]',      rendered = 'Cite',      highlight = 'RenderMarkdownQuote',   category = 'obsidian' },
    },

    heading = {
		icons = { '1:', '2:', '3:', '4:' , '5:', '6:' },
		sign = false,

	},
	
	 link = {
        image = 'Img:',
        email = '->',
        hyperlink = '<>',
	},



})






-- Oil File:

require("oil").setup({
  -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
  -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
  default_file_explorer = true,})



vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  upadate_in_insert = false,
  severity_sort = true,
})


--- Set Terminal escape to Escape

vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])

vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

