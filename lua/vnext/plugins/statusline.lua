-- to see config : lua print(vim.inspect(require('lualine').get_config()))
return {
  "nvim-lualine/lualine.nvim",
  event = "BufReadPost",
  dependencies = {
    { "catppuccin/nvim", name = "catppuccin" },
    { "folke/tokyonight.nvim", name = "tokyonight" },
    { "navarasu/onedark.nvim", name = "onedark" },
    { "EdenEast/nightfox.nvim", name = "nightfox" },
    { "rebelot/kanagawa.nvim", name = "kanagawa" },
    { "Mofiqul/dracula.nvim", name = "dracula" },
    { "ellisonleao/gruvbox.nvim", name = "gruvbox" },
    { "sainnhe/sonokai", name = "sonokai" },
    { "sainnhe/edge", name = "edge" },
    { "Shatur/neovim-ayu", name = "ayu" },
  },
  opts = function()
    local themes = {
      "ayu_dark",
      "onedark",
      "catppuccin",
      -- "tokyonight",
      "nightfox",
      "kanagawa",
      "dracula",
      "gruvbox_dark",
      "sonokai",
      "edge",
      "nord",
      "material",
      "palenight",
      "codedark",
      "jellybeans",
      "molokai",
    }
    math.randomseed(os.time())
    local random_theme = themes[math.random(#themes)]
    -- safely require the theme module for lualine
    pcall(require, "lualine.themes." .. random_theme)
    pcall(vim.cmd.colorscheme, random_theme)

    local function get_current_theme()
      local lualine_config = require("lualine").get_config()
      local current_theme = lualine_config.options.theme or "auto"

      -- If they don't match, show both
      if random_theme ~= current_theme then
        return "🎯 " .. random_theme .. " → 🎨 " .. current_theme
      end

      -- If they match, just show current theme
      return "🎨 " .. current_theme
    end

    -- Boolean function to check if buffer has diagnostics or LSP
    local function not_code()
      local no_diagnostics = #vim.diagnostic.get(0) == 0
      local no_lsp = #vim.lsp.get_clients({ bufnr = 0 }) == 0
      return no_diagnostics and no_lsp
    end

    local function is_code()
      return not not_code()
    end

    local function is_not_unix_fileformat()
      return vim.bo.fileformat ~= "unix"
    end

    local function is_not_utf8()
      return vim.bo.fileencoding ~= "utf-8"
    end

    local function get_hostname()
      local base = "deepmac"
      local name = vim.fn.hostname()
      -- strip everything after the first dot
      local short = name:match("^[^.]+") or name
      if short ~= base then
        return short
      else
        return ""
      end
    end

    local function get_mouse_mode()
        if vim.o.mouse == "" then
          return "⌨️  "
        else
          return "🖱 " 
        end
    end

    return {
      extensions = { "lazy", "quickfix", "neo-tree" },
      options = {
        disabled_filetypes = { statusline = { "neo-tree", "Outline", "snacks_picker_list" } },
        theme = random_theme,
      },
      sections = {
        --- +-------------------------------------------------+
        --- | A | B | C                             X | Y | Z |
        --- +-------------------------------------------------+
        --- path 0: fn 1: rel path 2: ab path 3: Absolute path, with ~ path 4: fn with dir
        lualine_a = { "mode" },
        lualine_b = {
          --  "branch",
          "diff",
          "diagnostics",
          {
            "lsp_status",
            symbols = {
              spinner = { "←", "↖", "↑", "↗", "→", "↘", "↓", "↙" },
              done = "✓",
            },
          },
        },
        lualine_c = {
          { "filename", newfile_status = true, path = 4, cond = not_code },
          { "filename", newfile_status = true, path = 0, cond = is_code },
        },

        lualine_x = {
          "searchcount",
          get_mouse_mode,
          get_current_theme,
          { "filetype", icon_only = false, cond = not_code },
          { "filetype", icon_only = true, cond = is_code },
          { "encoding", cond = is_not_utf8, show_bomb = true },
          { "fileformat", cond = is_not_unix_fileformat },
          get_hostname,
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    }
  end,
  config = function(_, opts)
    -- Show info when recording a macro
    local function is_macro_recording()
      local reg = vim.fn.reg_recording()
      if reg == "" then
        return ""
      end
      return "󰑋 " .. reg
    end

    table.insert(opts.sections.lualine_x, 1, {
      is_macro_recording,
      color = { fg = "#333333", bg = "#ff6666" },
      separator = { left = "", right = "" },
      cond = function()
        return is_macro_recording() ~= ""
      end,
    })

    require("lualine").setup(opts)
  end,
}
