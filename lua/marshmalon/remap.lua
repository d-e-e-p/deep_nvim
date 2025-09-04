local which_key = require "which-key"
local builtin = require('telescope.builtin')

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
    callback = function(event)
        local mappings = {
            { "<leader>l",  group = "LSP" },
            { "<leader>la", vim.lsp.buf.code_action,      desc = "Code action" },
            { "<leader>ld", vim.diagnostic.open_float,    desc = "Open diagnostic float" },
            { "<leader>ln", vim.lsp.buf.rename,           desc = "Rename" },
            { "<leader>lr", vim.lsp.buf.references,       desc = "References" },
            { "<leader>lw", vim.lsp.buf.workspace_symbol, desc = "Workspace symbol" },
            { "K",          vim.lsp.buf.hover,            desc = "Show hover information" },
            { "[d",         vim.diagnostic.goto_next,     desc = "Go to next diagnostic" },
            { "]d",         vim.diagnostic.goto_prev,     desc = "Go to previous diagnostic" },
            { "gd",         vim.lsp.buf.definition,       desc = "Go to definition" },
            { "gl",         vim.diagnostic.open_float,    desc = "Open diagnostic float" },
        }
        mappings.buffer = event.buf
        mappings.mode = "n"

        which_key.add({ mappings })

        -- https://www.mitchellhanberg.com/modern-format-on-save-in-neovim/
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = event.buf,
            callback = function()
                vim.lsp.buf.format { async = false, id = event.data.client_id }
            end

        })
    end,
})

local non_lsp_mappings = {
    mode = "n",
    { "<leader>e", ":Ex<CR>",                                              desc = "Open file explorer" },
    { "<leader>p", "\"_dP",                                                desc = "Paste without overwrite" },
    { "<leader>/", "<Plug>(comment_toggle_linewise_current)",              desc = "Toggle comment" },
    { "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], desc = "Search and replace word under cursor" },
    { "<leader>t", ":Today<CR>",                                           desc = "Open today's note" },
    { "J",         "mzJ`z",                                                desc = "Join lines and keep cursor position" },
    { "<C-d>",     "<C-d>zz",                                              desc = "Half page down and center" },
    { "<C-u>",     "<C-u>zz",                                              desc = "Half page up and center" },
    { "n",         "nzzzv",                                                desc = "Next search result and center" },
    { "N",         "Nzzzv",                                                desc = "Previous search result and center" },
    { "Q",         "<nop>",                                                desc = "Disable Ex mode" },
}


which_key.add({ non_lsp_mappings })

-- Telescope Commands
local telescope_mappings = {
    mode = "n",
    { "<leader>f",  group = "Find" },
    { "<leader>ff", builtin.find_files, desc = "Find files" },
    { "<leader>fg", builtin.git_files,  desc = "Find git files" },
    { "<leader>fl", builtin.live_grep,  desc = "Live grep" },
}

which_key.add({ telescope_mappings })

-- Register the semicolon mapping separately as it doesn't use the leader prefix
which_key.add({
    {
        mode = "n",
        { ";", builtin.buffers, desc = "Find buffers" },
    },
})

local visual_mappings = {
    mode = "v",
    { "J",         ":m '>+1<CR>gv=gv",                       desc = "Move selection down" },
    { "K",         ":m '<-2<CR>gv=gv",                       desc = "Move selection up" },
    { "<leader>/", "<Plug>(comment_toggle_linewise_visual)", desc = "Toggle comment" },
}

which_key.add({ visual_mappings })

-- insert commands
vim.keymap.set('i', '<Right>', '<Right>', { noremap = true }) -- Make the right arrow behave normally in insert mode