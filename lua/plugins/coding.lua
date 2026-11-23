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
      --- @type aviary.hawk.config.Options
      hawk = {
        keymaps = {
          pick_revision = { "R" },
        },
        actions = {
          pick_revision = function(tab)
            local row, lnum = tab:current()
            if row.kind ~= "meta" then
              return
            end
            if row.input.kind ~= "revision" then
              return
            end
            local root = vim.fn.shellescape(row.input.root)
            local cmd = table.concat({
              "echo 'HEAD (current)'",
              "git -C " .. root .. " for-each-ref --format='%(refname:short) (branch)' refs/heads",
              "git -C " .. root .. " for-each-ref --format='%(refname:short) (remote)' refs/remotes",
              "git --no-pager -C " .. root .. " log -n 50 --format='%H (%h %s)'",
            }, "\n")
            require("fzf-lua").fzf_exec(cmd, {
              prompt = "Revision> ",
              fzf_opts = { ["--no-multi"] = true },
              actions = {
                ["enter"] = {
                  fn = function(selected)
                    if not selected[1] then
                      return
                    end
                    if not vim.api.nvim_buf_is_valid(tab.bufnr) then
                      return
                    end
                    local revision = selected[1]:match("^%S+")
                    if revision then
                      row:edit(revision)
                      tab:render(lnum - 1, lnum)
                    end
                  end,
                },
              },
            })
          end,
        },
      },
    },
    keys = {
      { "<leader>ar", function() require("aviary").hawk.show() end, mode = "n", desc = "Aviary hawk" },
      { "<c-.>", function() require("aviary").pigeon.show() end, mode = { "n", "x" }, desc = "Aviary pigeon" },
    },
  },
}
