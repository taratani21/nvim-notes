# nvim-notes: Simple Project-Scoped Daily Notes

## Overview

A single-file Neovim plugin that provides quick note-taking tied to the current project. Notes accumulate in daily markdown files stored at `~/.notes/<project>/YYYY-MM-DD.md`.

## Project Detection

- Primary: git repo basename via `git rev-parse --show-toplevel`
- Fallback: current working directory basename (for non-git directories)

## Keybindings

- `<leader>jn` — Quick note: opens a `vim.ui.input` prompt, appends a timestamped bullet to today's file
- `<leader>jo` — Open daily file: opens today's file in a horizontal split below

## File Structure

Notes are stored at `~/.notes/<project>/YYYY-MM-DD.md`.

Example content of `~/.notes/my-app/2026-04-16.md`:

```markdown
- 14:32 — fixed the auth bug
- 15:10 — need to revisit caching layer
```

## Quick Note Behavior (`<leader>jn`)

1. Determine project name (git basename or cwd basename)
2. Build path: `~/.notes/<project>/<date>.md`
3. Create directory and file if they don't exist (Lua `vim.fn.mkdir` with `"p"` flag)
4. Show `vim.ui.input` prompt with label "Note: "
5. On submit (non-empty input): append `- HH:MM — <text>\n` to the file
6. On cancel or empty input: do nothing

## Open Daily File Behavior (`<leader>jo`)

1. Determine project name (git basename or cwd basename)
2. Build path: `~/.notes/<project>/<date>.md`
3. Open via `:botright split <path>` (horizontal split below)
4. Directory/file creation handled by the existing `auto_create_dir` autocmd in init.lua

## Plugin File

Single file: `~/.config/nvim/lua/plugins/notes.lua`

Returns a lazy.nvim plugin spec with no external dependencies — just a `config` function that sets up keymaps and helper functions.

## No Scope

- No Telescope integration
- No configuration options
- No commands (keybindings only)
- No search or indexing
