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
          end,
          files = function(current)
            local agent = current()
            require("fzf-lua").files({
              actions = {
                ["enter"] = {
                  fn = function(selected, opts)
                    if not selected[1] then
                      return
                    end
                    local paths = {}
                    for _, raw in ipairs(selected) do
                      local path = require("fzf-lua.path").entry_to_file(raw, opts).path
                      if path and path ~= "" then
                        paths[#paths + 1] = path
                      end
                    end
                    if #paths > 0 then
                      local texts = {}
                      for _, path in ipairs(paths) do
                        texts[#texts + 1] = agent:eval({ path = path })
                      end
                      agent:send(table.concat(texts, "\n"))
                    end
                  end,
                },
              },
            })
          end
        },
        keymaps = {
          newline = { "<S-CR>" },
          ctrl_slash = { "<C-/>", "<C-_>" },
          stopinsert = { "<C-q>" },
          pick = { "<C-,>" },
          prompt = { "<C-s><C-p>" },
          files = { "<C-s><C-f>" },
          buffers = { "<C-s><C-b>" },
        },
        view = { width = 1.0, height = 1.0, border = "rounded" },
      },
      --- @type aviary.hawk.config.Options
      hawk = {
        keymaps = {
          edit = { "i" },
          hawk = { "<CR>" },
        },
        actions = {
          edit = function(tab)
            local row, lnum = tab:current()
            if row.kind ~= "meta" then
              return
            end
            ---@param value? string
            local function confirm(value)
              if value ~= nil then
                row:edit(value)
                tab:render(lnum - 1, lnum)
              end
            end
            if row.input.kind == "choice" then
              vim.ui.select(row.input.choices, {
                format_item = function(item)
                  return item == row.value and (item .. " [current]") or item
                end,
              }, confirm)
            else
              vim.ui.input({ default = row.value }, confirm)
            end
          end,
          hawk = function(tab)
            local row, lnum = tab:current()
            if row.kind == "diff" then
              row:jump(tab)
              return
            end
            if row.input.kind == "choice" then
              ---@param value? string
              local function confirm(value)
                if value ~= nil then
                  row:edit(value)
                  tab:render(lnum - 1, lnum)
                end
              end
              vim.ui.select(row.input.choices, {
                format_item = function(item)
                  return item == row.value and (item .. " [current]") or item
                end,
              }, confirm)
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
      { "<leader>gr", function() require("aviary").hawk.show() end, mode = "n", desc = "Review" },
      { "<c-.>", function() require("aviary").pigeon.show() end, mode = { "n", "x" }, desc = "Open agent terminal" },
    },
  },
}
