-- nvim-notes: Project-scoped daily notes

local M = {}

local notes_dir = vim.fn.expand("~/.notes")

local function get_project()
  local toplevel = vim.trim(vim.fn.systemlist("git rev-parse --show-toplevel")[1] or "")
  if vim.v.shell_error == 0 and toplevel ~= "" then
    return vim.fn.fnamemodify(toplevel, ":t")
  end
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

local function get_daily_path()
  local project = get_project()
  local date = os.date("%Y-%m-%d")
  return notes_dir .. "/" .. project .. "/" .. date .. ".md"
end

function M.quick_note()
  vim.ui.input({ prompt = "Note: " }, function(input)
    if not input or input == "" then
      return
    end
    vim.schedule(function()
      local path = get_daily_path()
      vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
      local time = os.date("%H:%M")
      local line = "- " .. time .. " — " .. input .. "\n"
      local f, err = io.open(path, "a")
      if not f then
        vim.notify("Failed to save note: " .. err, vim.log.levels.ERROR)
        return
      end
      f:write(line)
      f:close()
      vim.notify("Note saved")
    end)
  end)
end

function M.open_daily()
  local path = get_daily_path()
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.cmd("botright split " .. vim.fn.fnameescape(path))
end

function M.setup()
  vim.keymap.set("n", "<leader>jn", M.quick_note, { desc = "Quick note" })
  vim.keymap.set("n", "<leader>jo", M.open_daily, { desc = "Open daily notes" })
end

return M
