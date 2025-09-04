return {
  "nvim-lualine/lualine.nvim",
  event = "BufReadPost",
  opts = {
    extensions = { "lazy", "quickfix", "neo-tree" },
    options = {
      disabled_filetypes = { statusline = { "neo-tree", "Outline", "snacks_picker_list" } },
      theme = "ayu_dark",
    },
    sections = {
      --- +-------------------------------------------------+
      --- | A | B | C                             X | Y | Z |
      --- +-------------------------------------------------+
      lualine_a = { "mode" }, -- hide mode
      lualine_b = {
        --  "branch",
        "diff",
        "diagnostics",
        "lsp_status",
      },
      lualine_c = {
        {
          "filename",
          file_status = true, -- Displays file status (readonly status, modified status)
          newfile_status = true, -- Display new file status (new file means no write after created)
          path = 3, -- 0: Just the filename
          -- 1: Relative path
          -- 2: Absolute path
          -- 3: Absolute path, with tilde as the home directory
          -- 4: Filename and parent dir, with tilde as the home directory
        },
      },
      lualine_x = { "searchcount", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
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
