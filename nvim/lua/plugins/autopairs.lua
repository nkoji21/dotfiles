return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local npairs = require("nvim-autopairs")
    npairs.setup({
      check_ts = true,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
      },
    })

    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")

    -- {} の間で改行したときに自動インデント
    npairs.add_rules({
      Rule("{", "}")
        :with_pair(cond.not_before_regex("[%w]", 1))
        :with_move(function(opts) return opts.char == "}" end)
        :with_cr(function() return true end)
        :set_end_pair_length(1),
    })
  end,
}
