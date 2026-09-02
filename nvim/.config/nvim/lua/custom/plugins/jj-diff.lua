-- Change signs in the gutter for non-colocated jj repos (no .git, so gitsigns
-- can't see them). mini.diff draws hunks against the file's content in `@-`.
-- Colocated repos and plain git repos stay with gitsigns: this source refuses
-- to attach whenever a .git is found.

local function jj_root(buf)
  local jj = vim.fs.root(buf, '.jj')
  if not jj or vim.fs.root(buf, '.git') then return nil end
  return jj
end

local function refresh(buf, root)
  local path = vim.api.nvim_buf_get_name(buf)
  local rel = vim.fs.relpath(root, path)
  if not rel then return end
  local fileset = 'root-file:"' .. rel:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
  vim.system(
    { 'jj', '--ignore-working-copy', '--no-pager', 'file', 'show', '-r', '@-', '--', fileset },
    { cwd = root, text = true },
    vim.schedule_wrap(function(res)
      if not vim.api.nvim_buf_is_valid(buf) then return end
      -- Missing in @- means the file is new in this change: everything is "added".
      -- ('' not {}: an empty table would unset the reference and hide all signs.)
      local text = res.code == 0 and res.stdout or ''
      MiniDiff.set_ref_text(buf, text)
    end)
  )
end

-- Inline current-line blame for jj buffers, like gitsigns' current_line_blame.
-- On/off state is gitsigns' own config flag, so <leader>tb toggles both at once.
local blame_ns = vim.api.nvim_create_namespace 'jj_line_blame'
local blame_lines = {} -- buf -> annotate output, one entry per file line
local blame_template = 'if(commit.current_working_copy(), "You, uncommitted",'
  .. ' commit.author().name() ++ ", " ++ commit.author().timestamp().ago()'
  .. ' ++ " • " ++ coalesce(commit.description().first_line(), "(no description)")'
  .. ' ++ " (" ++ commit.change_id().shortest(8) ++ ")") ++ "\\n"'

local function blame_enabled() return require('gitsigns.config').config.current_line_blame end

local function show_blame(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.api.nvim_buf_clear_namespace(buf, blame_ns, 0, -1)
  -- Annotate is of the saved file: skip while there are unsaved edits (lines would drift).
  if not blame_enabled() or vim.bo[buf].modified or vim.api.nvim_get_current_buf() ~= buf then return end
  if vim.fn.mode():find '^i' then return end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local text = (blame_lines[buf] or {})[row]
  if not text or text == '' then return end
  vim.api.nvim_buf_set_extmark(buf, blame_ns, row - 1, 0, {
    virt_text = { { '    ' .. text, 'GitSignsCurrentLineBlame' } },
    virt_text_pos = 'eol',
    hl_mode = 'combine',
  })
end

local function refresh_blame(buf, root)
  if not blame_enabled() then return show_blame(buf) end
  local rel = vim.fs.relpath(root, vim.api.nvim_buf_get_name(buf))
  if not rel then return end
  vim.system(
    { 'jj', '--no-pager', 'file', 'annotate', '-T', blame_template, rel },
    { cwd = root, text = true },
    vim.schedule_wrap(function(res)
      blame_lines[buf] = res.code == 0 and vim.split(res.stdout, '\n') or nil
      show_blame(buf)
    end)
  )
end

local augroups = {}

local jj_source = {
  name = 'jj',
  attach = function(buf)
    local root = jj_root(buf)
    if not root or vim.bo[buf].buftype ~= '' then return false end

    local group = vim.api.nvim_create_augroup('jj_diff_' .. buf, { clear = true })
    augroups[buf] = group
    -- @- changes after `jj new`/`jj commit`/... so re-read it when coming back.
    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'FocusGained' }, {
      group = group,
      buffer = buf,
      callback = function()
        refresh(buf, root)
        refresh_blame(buf, root)
      end,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'InsertLeave', 'TextChanged', 'BufLeave' }, {
      group = group,
      buffer = buf,
      callback = function() show_blame(buf) end,
    })
    refresh(buf, root)
    refresh_blame(buf, root)

    local function toggle_blame()
      require('gitsigns').toggle_current_line_blame()
      refresh_blame(buf, root)
    end

    -- Buffer-local keymaps mirroring the gitsigns ones (those only exist in git buffers).
    local function map(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc }) end
    map(']c', function()
      if vim.wo.diff then return vim.cmd.normal { ']c', bang = true } end
      MiniDiff.goto_hunk 'next'
    end, 'Jump to next jj [c]hange')
    map('[c', function()
      if vim.wo.diff then return vim.cmd.normal { '[c', bang = true } end
      MiniDiff.goto_hunk 'prev'
    end, 'Jump to previous jj [c]hange')
    map('<leader>gp', MiniDiff.toggle_overlay, 'jj toggle diff overlay')
    map('<leader>hp', MiniDiff.toggle_overlay, 'jj toggle diff overlay')
    map('<leader>hr', function()
      local l = vim.fn.line '.'
      MiniDiff.do_hunks(buf, 'reset', { line_start = l, line_end = l })
    end, 'jj [r]eset hunk')
    map('<leader>hR', function() MiniDiff.do_hunks(buf, 'reset') end, 'jj [R]eset buffer')
    map('<leader>tb', toggle_blame, '[T]oggle jj show [b]lame line')
    map('<leader>gt', toggle_blame, 'jj [t]oggle line blame')
  end,
  detach = function(buf)
    blame_lines[buf] = nil
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_clear_namespace(buf, blame_ns, 0, -1) end
    if augroups[buf] then pcall(vim.api.nvim_del_augroup_by_id, augroups[buf]) end
    augroups[buf] = nil
  end,
}

require('mini.diff').setup {
  source = jj_source,
  view = {
    style = 'sign',
    signs = { add = '+', change = '~', delete = '_' },
  },
  -- Global mappings off: they'd clash with gitsigns and vim's diff-mode ]c.
  mappings = {
    apply = '',
    reset = '',
    textobject = '',
    goto_first = '',
    goto_prev = '',
    goto_next = '',
    goto_last = '',
  },
}
