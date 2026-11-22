--- @type LazyPluginSpec[]
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<C-n>"] = { "snippet_forward", "fallback" },
        ["<C-p>"] = { "snippet_backward", "fallback" },
      },
      completion = {
        list = {
          selection = {
            preselect = true,
          },
        },
        menu = { border = "rounded" },
        documentation = { window = { border = "rounded" } },
      },
      signature = { window = { border = "single" } },
    },
  },

  {
    "ZachVec/aviary.nvim",
    main = "aviary",
    opts = {
      --- @type aviary.pigeon.ConfigOverrides
      pigeon = {
        backend = "tmux",
        actions = {
          newline = function ()
            vim.api.nvim_chan_send(vim.b.terminal_job_id, "\27[13;2u")
          end,
          ctrl_slash = function ()
            vim.api.nvim_chan_send(vim.b.terminal_job_id, "\27[47;5u")
          end,
          stopinsert = function ()
            vim.cmd("stopinsert")
          end
        },
        keymaps = {
          newline = { "<S-CR>" },
          ctrl_slash = { "<C-/>", "<C-_>" },
          stopinsert = { "<C-q>" },
          prompt = { "<C-p>" },
          pick = { "<c-,>" }
        },
        tools = {
          claude = {
            command = { "claude", "--allow-dangerously-skip-permissions" }
          },
          dsh = {
            command = { "dsh-tui" }
          }
        },
        view = { width = 1.0, height = 1.0, border = "rounded" },
      },
    },
    keys = {
      { "<leader>ar", function() require("aviary").hawk.show() end, mode = "n", desc = "Aviary hawk" },
      { "<c-.>", function() require("aviary").pigeon.show() end, mode = { "n", "x" }, desc = "Aviary pigeon" },
    },
  },
}
