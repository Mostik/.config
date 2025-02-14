vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.cursorline = false
vim.opt.swapfile = false

vim.opt.scrolloff = 0
vim.opt.completeopt = {"menu", "menuone", "noselect"}
vim.opt.termguicolors = true

vim.g.mapleader = ","
vim.wo.wrap = false;

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- vim.api.nvim_set_option("clipboard","unnamed")
vim.api.nvim_command("set clipboard+=unnamedplus")

-- Install Lazy package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins

local lazy = require("lazy")
lazy.setup({
  -- LSP
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'neovim/nvim-lspconfig',
  'hrsh7th/nvim-cmp' ,
  'hrsh7th/cmp-nvim-lsp',
  'nvim-lua/plenary.nvim',
  -- Search
  'nvim-pack/nvim-spectre',
  -- File explorer
  {
    'nvim-neo-tree/neo-tree.nvim', 
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
  },
  -- Buffer line
  {
    'akinsho/bufferline.nvim',
    version = "*", 
    dependencies = 'nvim-tree/nvim-web-devicons'
  },
  -- Git
  'sindrets/diffview.nvim',
  -- Color schemes
  'blazkowolf/gruber-darker.nvim',

  -- Other
  'nvim-treesitter/nvim-treesitter',
  'nativerv/cyrillic.nvim',
  'numToStr/Comment.nvim',
  'JoosepAlviste/nvim-ts-context-commentstring',
  { 'wakatime/vim-wakatime', lazy = false },
  'windwp/nvim-autopairs',
  'nmac427/guess-indent.nvim',
  'ojroques/nvim-bufdel',

  "max397574/better-escape.nvim",
  {
  'kaiuri/nvim-juliana',
    lazy = false,
    opts = { --[=[ configuration --]=] },
    config = true,
  },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
    }
  }

})

vim.cmd.colorscheme( "gruber-darker" )

require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
  }
})
require("cyrillic").setup()
require("guess-indent").setup()
require("mason").setup()
require("nvim-autopairs").setup()
require("mason-lspconfig").setup()
require("Comment").setup({
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})
require("ibl").setup({
  scope = { enabled = false },
})

require("bufferline").setup{}
require("bufdel").setup{
  next = 'tabs',
  quit = false,
}


local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("mason-lspconfig").setup_handlers {
  function(server_name)
    
  require("lspconfig")[server_name].setup({
    capabilities = capabilities,
  })
  end
}
local nvim_lsp = require('lspconfig')
nvim_lsp.denols.setup {
  on_attach = on_attach,
  root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
}

nvim_lsp.ts_ls.setup {
  on_attach = on_attach,
  root_dir = nvim_lsp.util.root_pattern("package.json"),
  single_file_support = false
}

local cmp = require("cmp")

cmp.setup({
  -- snippet = {
  --   expand = function(args)
  --     
  --   end
  -- },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
  }),
  mapping = cmp.mapping.preset.insert({
    ['<TAB>'] = cmp.mapping.select_next_item(),
    ['<S-TAB>'] = cmp.mapping.select_prev_item(),
    ['<ESC>'] = function() 
      cmp.mapping.abort()
      vim.cmd("stopinsert");
    end,
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      -- vim_item.kind = " "
      vim_item.menu = "->"
      vim_item.abbr = vim_item.abbr:match("[^(]+")

      return vim_item
    end
  },
})

vim.keymap.set({"n", "i"}, "<leader>s", ':Neotree close<CR><cmd> lua require("spectre").toggle()<CR>' )
vim.keymap.set({"n", "i"}, "<leader>e", '<cmd> lua require("spectre").close()<CR>:Neotree toggle<CR>' )
vim.keymap.set({"n", "i"}, "<leader>go", ':DiffviewClose<CR>:DiffviewOpen<CR>' )
vim.keymap.set({"n", "i"}, "<leader>gc", ':DiffviewClose<CR>' )

vim.keymap.set({"n", "i"}, "gd", function() vim.lsp.buf.definition() end )
vim.keymap.set({"n"}, "K", function() vim.lsp.buf.hover() end )

vim.keymap.set({"v"}, "<Tab>", ">gv")
vim.keymap.set({"v"}, "<S-Tab>", "<gv")

vim.keymap.set({"n", "i"}, "]b", ":BufferLineCycleNext<CR>")
vim.keymap.set({"n", "i"}, "[b", ":BufferLineCyclePrev<CR>")
vim.keymap.set({"n", "i"}, "<leader>c", ":BufDel<CR>")
vim.keymap.set({"n", "i"}, "<ESC>", function() vim.cmd("stopinsert") end )
vim.keymap.set({"i"}, '<D-Space>', '')

