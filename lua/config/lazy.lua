local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
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

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
    { "neovim/nvim-lspconfig" },
    { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "saadparwaiz1/cmp_luasnip" },
    { "L3MON4D3/LuaSnip" },
    { "rafamadriz/friendly-snippets" },
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui" },
    { "jlcrochet/vim-razor" },
    { "kyazdani42/nvim-tree.lua" },
    { "nvim-telescope/telescope.nvim", requires = { { "nvim-lua/plenary.nvim" } } },
    { "folke/trouble.nvim", requires = "kyazdani42/nvim-web-devicons" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "gruvbox", "tokyonight", "habamax" } },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

require("nvim-treesitter.configs").setup({
  ensure_installed = { "c_sharp", "html" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

local nvim_lsp = require("lspconfig")

nvim_lsp.omnisharp.setup({
  cmd = {
    "C:/omnisharp/OmniSharp.exe",
    "--languageserver",
    "--hostPID",
    tostring(vim.fn.getpid()),
    "--loglevel",
    "trace",
  },
  filetypes = { "cs", "vb", "razor" },
  root_dir = nvim_lsp.util.root_pattern("*.csproj", "*.sln"),
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  on_attach = function(client, bufnr)
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    vim.api.nvim_set_keymap("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap(
      "n",
      "<leader>q",
      "<cmd>lua vim.diagnostic.setloclist()<CR>",
      { noremap = true, silent = true }
    )
    -- Keybindings for nvim-dap
    vim.api.nvim_set_keymap(
      "n",
      "<leader>db",
      '<cmd>lua require"dap".toggle_breakpoint()<CR>',
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>dc",
      '<cmd>lua require"dap".continue()<CR>',
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>di",
      '<cmd>lua require"dap".step_into()<CR>',
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>do",
      '<cmd>lua require"dap".step_over()<CR>',
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>dr",
      '<cmd>lua require"dap".repl.open()<CR>',
      { noremap = true, silent = true }
    )
  end,
})

local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
  }),
})

require("trouble").setup({})

-- nvim-dap configuration
local dap = require("dap")

-- Adapter configuration for .NET
dap.adapters.coreclr = {
  type = "executable",
  command = "path/to/vsdbg", -- Adjust this to the actual path of vsdbg
  args = { "--interpreter=vscode" },
}

-- Configuration for .NET
dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
      return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
    end,
  },
}
