vim.cmd.colorscheme("tokyonight")

vim.opt.clipboard = 'unnamedplus' -- use system keyboard for yank

vim.opt.nu = false                -- set line numbers -- set line numbers
vim.opt.relativenumber = false    -- use relative line numbers

-- set tab size to 2 spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.incsearch = true -- incremental search

vim.opt.termguicolors = true

vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- s
vim.opt.title = true
vim.opt.foldminlines = 10

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "❕",
            [vim.diagnostic.severity.INFO] = "💡",
            [vim.diagnostic.severity.HINT] = "❓",
        },
        numhl = {
            [vim.diagnostic.severity.WARN] = "WarningMsg",
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
        },
    },
})
