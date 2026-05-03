-- Workaround: terminal paste chunk corruption (fixed in nvim 0.12.2)
-- https://github.com/neovim/neovim/pull/39152
if vim.fn.has("nvim-0.12.2") == 0 then
  local paste_streaming = false

  vim.paste = (function(overridden)
    return function(lines, phase)
      if vim.bo.buftype ~= "terminal" then
        return overridden(lines, phase)
      end
      local chan = vim.bo.channel
      if not chan or chan == 0 then
        return overridden(lines, phase)
      end

      local text = table.concat(lines, "\n")
      local is_first = (phase == 1 or phase == -1)
      local is_last = (phase == 3 or phase == -1)

      if is_first and not paste_streaming then
        paste_streaming = true
        vim.api.nvim_chan_send(chan, "\27[200~")
      end
      vim.api.nvim_chan_send(chan, text)
      if is_last then
        vim.api.nvim_chan_send(chan, "\27[201~")
        paste_streaming = false
      end

      return true
    end
  end)(vim.paste)
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
