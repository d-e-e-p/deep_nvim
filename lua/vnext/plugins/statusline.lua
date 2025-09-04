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
      --  "onedark",
      "catppuccin",
      "tokyonight",
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

    local function get_filename()
      local file = vim.fn.expand("%")
      local has_diagnostics = #vim.diagnostic.get(0) > 0
      local has_lsp = #vim.lsp.get_clients({ bufnr = 0 }) > 0
      local path_value = (has_diagnostics or has_lsp) and 0 or 3

      local filename
      if file == "" then
        filename = "[No Name]"
      elseif path_value == 0 then
        filename = vim.fn.fnamemodify(file, ":t")
      else
        filename = vim.fn.fnamemodify(file, ":p:~")
        -- add ft for non code files
        local filetype_component = require("lualine.components.filetype"):new()
        local formatted_filetype = filetype_component:update_status()
        if formatted_filetype and formatted_filetype ~= "" then
          filename = filename .. " (" .. formatted_filetype .. ")"
        end
        return filename
      end

      local f_status = ""
      if vim.bo.modified then
        f_status = f_status .. "[+] "
      end
      if vim.bo.readonly then
        f_status = f_status .. "[RO] "
      end
      if file ~= "" and vim.fn.filereadable(file) == 0 and vim.bo.buftype == "" then
        f_status = f_status .. "[New] "
      end

      return filename .. " " .. f_status
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
        lualine_a = { "mode", get_current_theme },
        lualine_b = {
          --  "branch",
          "diff",
          "diagnostics",
          "lsp_status",
        },
        lualine_c = {
          get_filename,
        },

        lualine_x = { "searchcount", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    }
  end,
  config = function(_, opts)
    -- For themes that require a plugin, attempt to load the corresponding colorscheme.
    -- This is because their lualine component might depend on the main plugin being active.
    local theme_name = opts.options.theme
    if theme_name == "catppuccin" or theme_name == "tokyonight" then
      pcall(vim.cmd.colorscheme, theme_name)
    end

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

    -- Don't display encoding if encoding is UTF-8
    local function encoding()
      local ret, _ = (vim.bo.fenc or vim.go.enc):gsub("^utf%-8$", "")
      return ret
    end

    table.insert(opts.sections.lualine_x, 1, {
      encoding,
      cond = function()
        return encoding() ~= ""
      end,
    })

    -- Don't display fileformat if fileformat is unix
    local function fileformat()
      local ret, _ = vim.bo.fileformat:gsub("^unix$", "")
      return ret
    end

    table.insert(opts.sections.lualine_x, 1, {
      fileformat,
      cond = function()
        return fileformat() ~= ""
      end,
    })

    local function hostname()
      local name = vim.fn.hostname()
      if name ~= "deepmac.local" then
        return name
      else
        return ""
      end
    end

    table.insert(opts.sections.lualine_c, 1, {
      hostname,
      cond = function()
        return hostname() ~= ""
      end,
    })

    require("lualine").setup(opts)
  end,
}
