return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = {
        "c", "lua", "vim", "vimdoc", "elixir", "javascript", "html", "python", "typescript"
      },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      folding = {
        enable = true,
        -- These are the filetypes where treesitter folding will not be used
        -- It will fall back to the default `foldmethod` for these files.
        disable = { "json", "yaml" },
      },
    })
  end
}
