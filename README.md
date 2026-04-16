# nvim-notes

A simple Neovim plugin for project-scoped daily notes. Jot down quick thoughts without leaving your editor — notes accumulate in daily markdown files organized by project.

## How it works

Notes are stored at `~/.notes/<project>/YYYY-MM-DD.md` as timestamped bullet points:

```markdown
- 14:32 — fixed the auth bug
- 15:10 — need to revisit caching layer
- 16:45 — deployed v2.3.1 to staging
```

The project name is detected automatically from the git repo. In non-git directories, the folder name is used instead.

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "taratani21/nvim-notes",
  config = function()
    require("notes").setup()
  end,
}
```

## Keybindings

| Key | Action |
|-----|--------|
| `<leader>jn` | Quick note — type a one-liner, appended with timestamp |
| `<leader>jo` | Open today's daily file in a horizontal split |

## File structure

```
~/.notes/
  my-app/
    2026-04-14.md
    2026-04-15.md
    2026-04-16.md
  another-project/
    2026-04-16.md
```
