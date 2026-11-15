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
      weaver = {
        picker = "snacks",
        prompts = {
          ["{file}"] = "{file} ",
          ["{line}"] = "{line} "
        }
      },
      pigeon = {
        backend = {
          default = "tmux",
          tmux = {
            width = "100%",
            height = "100%",
          },
        },
        tools = {
          dsh = {
            command = { "dsh-tui" }
          }
        }
      },
    },
    keys = {
      { "<leader>ar", function() require("aviary").hawk.show() end, mode = "n", desc = "Aviary Review" },
      { "<leader>sf", function() require("aviary").weaver.files() end, mode = "n", desc = "Send files" },
      { "<leader>sb", function() require("aviary").weaver.buffers() end, mode = "n", desc = "Send buffers" },
      { "<leader>sp", function() require("aviary").weaver.prompt() end, mode = {"n", "v"}, desc = "Send prompts" },
      { "<c-,>", function() require("aviary").pigeon.pick() end, mode = "n", desc = "Aviary switch" },
      { "<c-.>", function() require("aviary").pigeon.show() end, mode = "n", desc = "Aviary toggle" },
      { "<leader>aS", function() require("aviary").pigeon.status() end, mode = "n", desc = "Aviary status" },
    },
  },
}
