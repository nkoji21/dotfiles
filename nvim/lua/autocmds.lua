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
