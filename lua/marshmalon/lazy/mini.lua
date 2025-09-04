return {
        {
      'echasnovski/mini.nvim',
      version = '*', -- use latest stable version
      event = "VeryLazy",
      config = function()
        require('mini.icons').setup()
        -- Other mini.nvim modules you might use
      end,
    }
}

