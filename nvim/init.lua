vim.opt.termguicolors = true

vim.opt.number = false
vim.opt.relativenumber = false

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.scrolloff = 8

vim.opt.cursorline = true
vim.opt.fixendofline = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({{"Failed to clone lazy.nvim", "ErrorMsg"}}, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        transparent = true,
      })
      vim.cmd.colorscheme("kanagawa-wave")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          section_separators = "",
          component_separators = "",
          icons_enabled = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },
})

-- clang-format on save: uses .clang-format if exists, fallback to Google
local fmt_group = vim.api.nvim_create_augroup("ClangFormat", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = fmt_group,
  pattern = { "*.c", "*.cpp", "*.cc", "*.cxx", "*.h", "*.hpp", "*.hxx" },
  callback = function()
    if vim.fn.executable("clang-format") == 0 then
      return
    end
    local view = vim.fn.winsaveview()
    local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local result = vim.fn.system("clang-format -style=file -fallback-style=Google", content)
    if vim.v.shell_error == 0 then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result, "\n"))
      vim.fn.winrestview(view)
    end
  end,
})
