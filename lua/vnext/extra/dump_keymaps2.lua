-- Utility to escape quotes etc.
local function esc(str)
  return str and str:gsub("\\", "\\\\"):gsub('"', '\\"') or ""
end

-- Lookup sid → filename
local function keymap_source(km)
  if km.sid and km.sid > 0 then
    for _, script in ipairs(vim.fn.getscriptinfo()) do
      if script.sid == km.sid then
        return string.format("%s line %d", script.name, km.lnum or 0)
      end
    end
  end
  return nil
end

-- Convert Lua callback → text like <Lua 42: file.lua:42>
local function callback_to_str(fn)
  local ok, info = pcall(debug.getinfo, fn, "Sln")
  if not ok or not info then
    return "<LuaFn>"
  end
  local line = info.linedefined or 0
  local src = info.short_src or "?"
  return string.format("<Lua %d: %s:%d>", line, src, line)
end

local function dump_callback_info(fn)
  if type(fn) ~= "function" then
    print("Not a function:", vim.inspect(fn))
    return
  end

  local ok, info = pcall(debug.getinfo, fn, "nSlu")
  if not ok or not info then
    print("debug.getinfo failed")
    return
  end

  print("=== Callback Info ===")
  print("Function object:", fn)
  print("Name:", info.name or "<none>")
  print("Namewhat:", info.namewhat or "<none>")
  print("Source:", info.source or "<nil>")
  print("Short src:", info.short_src or "<nil>")
  print("Line defined:", info.linedefined or -1)
  print("Last line defined:", info.lastlinedefined or -1)
  print("What:", info.what or "<nil>")
  print("Current line:", info.currentline or -1)
  print("Num upvalues:", info.nups or 0)
  print("=====================")
end

-- Pretty-printer
local function DumpKeymaps()
  local outfile = vim.fn.stdpath("data") .. "/keymaps.lua"
  local out = io.open(outfile, "w")
  if not out then
    print("Error: could not open " .. outfile)
    return
  end

  -- write a header
  out:write([[
-- Auto-generated keymap dump
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end
]])

  local modes = { "n", "i", "v", "x", "s", "o", "t", "c" }

  for _, mode in ipairs(modes) do
    out:write(string.format("\n-- %s mode\n", mode))
    for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
      local lhs = esc(km.lhs)

      local rhs = ""
      if km.rhs and km.rhs ~= "" then
        rhs = esc(km.rhs)
      elseif km.callback then
        rhs = "<LuaFn>"
        -- rhs = esc(callback_to_str(km.callback))
        -- dump_callback_info(km.callback)
      end

      local opts = {}
      if km.desc then
        table.insert(opts, string.format('desc = "%s"', esc(km.desc)))
      end
      if km.silent == 1 then
        table.insert(opts, "silent = true")
      end
      if km.expr == 1 then
        table.insert(opts, "expr = true")
      end
      if km.nowait == 1 then
        table.insert(opts, "nowait = true")
      end
      if km.script == 1 then
        table.insert(opts, "script = true")
      end
      if km.noremap == 1 then
        table.insert(opts, "noremap = true")
      end

      local src = keymap_source(km)
      local optstr = ""
      if #opts > 0 or src then
        optstr = "{ " .. table.concat(opts, ", ") .. " }"
      end

      local line = string.format('map("%s", "%s", "%s"%s)', mode, lhs, rhs, optstr ~= "" and ", " .. optstr or "")

      if src then
        line = line .. " -- src " .. src
      end

      out:write(line .. "\n")
    end
  end

  out:write("\nreturn {}\n")
  out:close()
  print("Keymaps dumped to " .. outfile)
end

vim.api.nvim_create_user_command("DumpKeymaps", DumpKeymaps, {})
return {}
