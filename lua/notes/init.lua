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
  vim.b.is_notes_buffer = true
end

function M.new_note()
  vim.ui.input({ prompt = "Note name: " }, function(input)
    if not input or input == "" then
      return
    end
    if input:match("[/\\]") then
      vim.notify("Invalid name (no slashes)", vim.log.levels.ERROR)
      return
    end
    vim.schedule(function()
      local name = input:match("%.md$") and input or input .. ".md"
      local dir = notes_dir .. "/" .. get_project()
      vim.fn.mkdir(dir, "p")
      local path = dir .. "/" .. name
      vim.cmd("botright split " .. vim.fn.fnameescape(path))
      vim.b.is_notes_buffer = true
    end)
  end)
end

local function relative_date(date_str)
  local y, m, d = date_str:match("(%d+)-(%d+)-(%d+)")
  if not y then return date_str end
  local then_ts = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d) })
  local now = os.date("*t")
  local today_ts = os.time({ year = now.year, month = now.month, day = now.day })
  local days = math.floor((today_ts - then_ts) / 86400)
  if days == 0 then return "today" end
  if days == 1 then return "yesterday" end
  if days < 7 then return days .. " days ago" end
  if days < 30 then return math.floor(days / 7) .. " weeks ago" end
  if days < 365 then return math.floor(days / 30) .. " months ago" end
  return math.floor(days / 365) .. " years ago"
end

function M.list_notes()
  local project = get_project()
  local dir = notes_dir .. "/" .. project
  if vim.fn.isdirectory(dir) == 0 then
    vim.notify("No notes for " .. project)
    return
  end

  local all = vim.fn.glob(dir .. "/*.md", false, true)
  if #all == 0 then
    vim.notify("No notes for " .. project)
    return
  end
  local dated, custom = {}, {}
  for _, path in ipairs(all) do
    local name = vim.fn.fnamemodify(path, ":t:r")
    if name:match("^%d%d%d%d%-%d%d%-%d%d$") then
      table.insert(dated, path)
    else
      table.insert(custom, path)
    end
  end
  table.sort(dated, function(a, b) return a > b end)
  table.sort(custom)
  local files = {}
  for _, p in ipairs(dated) do table.insert(files, p) end
  for _, p in ipairs(custom) do table.insert(files, p) end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Notes: " .. project,
    finder = finders.new_table({
      results = files,
      entry_maker = function(path)
        local name = vim.fn.fnamemodify(path, ":t:r")
        local rel = name:match("^%d%d%d%d%-%d%d%-%d%d$") and relative_date(name) or ""
        return {
          value = path,
          display = string.format("%-14s %s", rel, name),
          ordinal = rel .. " " .. name,
          path = path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.file_previewer({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
      end)
      return true
    end,
  }):find()
end

function M.setup()
  vim.keymap.set("n", "<leader>jn", M.quick_note, { desc = "Quick note" })
  vim.keymap.set("n", "<leader>jo", M.open_daily, { desc = "Open daily notes" })
  vim.keymap.set("n", "<leader>jl", M.list_notes, { desc = "List notes" })
  vim.keymap.set("n", "<leader>jc", M.new_note, { desc = "Create named note" })
end

return M
