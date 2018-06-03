-- Parses command-line arguments.

-- On error, returns (nil, message, index).
-- If the default "--help" handler is run, returns 'help'.

return function (arg, opts)
  local skip_opts = false

  local result = {
    opt = {},
  }

  local counter_cache = {}
  local table_cache   = {}

  local i = 0 -- start at 0 since loop increments first

  while (i < #arg) do
    i = i + 1

    if (not (skip_opts)) and (#arg[i] > 0) then
      if (arg[i] == '--') then
        skip_opts = true
        goto continue
      end

      if (opts.options and opts.options[arg[i]]) then
        local name = arg[i]
        local o = opts.options[arg[i]]

        do
          local value

          if o.type == 'string' then
            i = i + 1
            if (i > #arg) then
              error('Option "'..name..'" requires a string', 2)
            end
            value = arg[i]
          elseif o.type == 'number' then
            i = i + 1
            if (i > #arg) then
              error('Option "'..name..'" requires a number', 2)
            end
            value = tonumber(arg[i])
          elseif o.type == 'boolean' then
            value = true
          elseif o.type == 'counter' then
            if not (counter_cache[name]) then
              counter_cache[name] = 1
              value = 1
            else
              counter_cache[name] = counter_cache[name] + 1
              value = counter_cache[name]
            end
          elseif o.type == 'table' then
            i = i + 1
            if not (table_cache[name]) then
              table_cache[name] = {arg[i]}
              value             = table_cache[name]
            else
              table.insert (table_cache[name], arg[i])
              value = table_cache[name]
            end
          else
            error('Invalid option type '..tostring(o.type)..' for option '..tostring(name), 2)
          end

          if o.call then
            result.opt [name] = o.call (value)
          else
            result.opt [name] = value
          end
        end

        goto continue
      end

      if (arg[i]:sub(1,1) == '-') or (arg[i]:sub(1,1) == '@') then
        if (#arg[i] > 1) and (arg[i]:sub(2,2) == '-') then
          -- only reached if "--help" is not defined
          if (arg[i] == '--help') then -- default "--help" {{{
            local format = require('string').format
            local output = opts.help_output or require('io').write

            if opts.help then
              output (opts.name or "" .. " " .. opts.version or "")
              output (opts.help)
              output ("\n" )
            end

            output("Options:\n")

            local longest_opt = 4
            local o = {}

            if (opts.flags) then
              for k,v in pairs(opts.flags) do
                o[#o + 1] =  {
                  name = k:len () == 1 and '  -'..k or '  --'..k,
                  desc = v.help or '?',
                }

                if (v.type == 'counter') then
                  o[#o].name = o[#o].name..' ...'
                end

                if (o[#o].name:len() > longest_opt) then
                  longest_opt = o[#o].name:len()
                end
              end
            end

            if (opts.options) then
              for k,v in pairs (opts.options) do
                local e = { 
                  desc = v.help_text or '(no help text)',
                }

                if (v.type == 'string') then
                  e.name = '  '..k..' <string>'
                elseif (v.type == 'number') then
                  e.name = '  '..k..' <number>'
                elseif (v.type == 'boolean') then
                  e.name = '  '..k
                elseif (v.type == 'counter') then
                  e.name = '  '..k..' ...'
                elseif (v.type == 'table') then
                  e.name = '  '..k..' ...'
                else
                  error('Invalid option type '..tostring(o.type)..' for option '..tostring(k), 2)
                end

                if (e.name:len() > longest_opt) then
                  longest_opt = e.name:len()
                end

                o[#o + 1] = e
              end
            end

            local fmtstr
            if (longest_opt > 20) then
              fmtstr = '%-20s'
            else
              fmtstr = '%-'..tostring(longest_opt)..'s'
            end

            for k,opt in pairs(o) do
              output(format(fmtstr, opt.name))
              if (opt.name:len() > 20) then
                output("\n                      ")
              else
                output('  ')
              end
              output(opt.desc)
              output("\n")
              o[k] = nil  
            end

            return 'help' 
          end -- }}}
        elseif (opts.flags) then
          local s = arg[i]:sub(2)

          for c = 1, #s, 1 do
            local f = s:sub(c,c)

            if (opts.flags[f]) then
              if (opts.flags[f].type == 'counter') then
                if not (result.opt[f]) then
                  result.opt[f] = 1
                else
                  result.opt[f] = result.opt[f] + 1
                end
              else
                result.opt[f] = true
              end 
            else
              return nil, 'invalid flag: '..f, i
            end  
          end
          goto continue
        end
      end
    end

    -- unknown argument if this is reached

    if not (result.unhandled) then
      result.unhandled = {}
    end

    result.unhandled[#result.unhandled + 1] = arg[i]

    ::continue::
  end

  return result
end
