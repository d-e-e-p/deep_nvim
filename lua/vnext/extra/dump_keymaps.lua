local function get_key_string(key)
  -- Replace problematic characters with placeholders
  key = key:gsub(" ", "<Space>")
  return key
end

local function DumpKeymapsMerged()
  local outfile = vim.fn.stdpath("data") .. "/keymaps_merged.lua"
  local out = io.open(outfile, "w")
  if not out then
    print("Error: could not open " .. outfile)
    return
  end

  -- Header: helper map()
  out:write([[
-- Generated keymap dump
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

]])

  local modes = { "n", "i", "v", "x", "s", "c", "o", "t" }

  -- Escape helper
  local function esc(str)
    return str and str:gsub("\\", "\\\\"):gsub('"', '\\"') or ""
  end

  local verbose_info = {}
  for _, mode in ipairs(modes) do
    verbose_info[mode] = {}
  end

  for _, mode in ipairs(modes) do
    local res = vim.api.nvim_exec2("verbose " .. mode .. "map", { output = true })
    local lines = vim.split(res.output, "\n", { trimempty = true })

    local current_mode, current_lhs
    for _, line in ipairs(lines) do
      out:write(string.format("-- line %s\n", line)) -- diag dump

      -- Start of a map line: e.g. `t  <C-N>       * <Cmd>close<CR>`
      local m, lhs = line:match("^%s*(%a)%s+(%S+)")
      if m and lhs then
        current_mode = m
        current_lhs = get_key_string(lhs)
      elseif line:match("^%s+Last set from") and current_mode and current_lhs then
        -- Source info line
        out:write(string.format("-- verbose_info[%s][%s] = %s\n", current_mode, current_lhs, line))
        verbose_info[current_mode][current_lhs] = line
        current_mode, current_lhs, current_desc = nil, nil, nil
      end
    end
  end

  -- Dump merged info
  for _, mode in ipairs(modes) do
    out:write(string.format("\n-- %s mode\n", mode))
    for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
      local lhs = km.lhs
      local rhs = km.rhs or (km.callback and "<LuaFn>") or ""
      local opts = {}

      if km.desc then
        table.insert(opts, string.format('desc = "%s"', esc(km.desc)))
      end
      if km.silent then
        table.insert(opts, "silent = true")
      end
      if km.expr then
        table.insert(opts, "expr = true")
      end
      if km.nowait then
        table.insert(opts, "nowait = true")
      end
      if km.script then
        table.insert(opts, "script = true")
      end

      local optstr = #opts > 0 and (", { " .. table.concat(opts, ", ") .. " }") or ""
      lhs = get_key_string(lhs)
      local src_comment = verbose_info[mode][lhs] and (" -- src " .. verbose_info[mode][lhs])
        or " -- not found src for key [" .. mode .. "][" .. lhs .. "]"

      out:write(string.format('map("%s", "%s", "%s"%s)%s\n', mode, esc(lhs), esc(rhs), optstr, src_comment))
    end
  end

  out:write("\nreturn {}\n")
  out:close()
  print("Keymaps merged and dumped to " .. outfile)
end

vim.api.nvim_create_user_command("DumpKeymapsMerged", DumpKeymapsMerged, {})
return {}

