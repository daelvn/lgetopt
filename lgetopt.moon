-- lgetopt.moon | 04.11.2018
-- By daelvn
-- Parses command-line arguments

-- On error, returns (nil, message, index)
-- If the default "--help" handler is run, returns 'help'

(arg, opts) ->
  skip_opts, result, counter_cache, table_cache, i = false, { opt: {} }, {}, {}, 0

  while i < #arg
    i += 1
    if (not skip_opts) and (#arg[i] > 0) then
      if arg[i] == "--"
        skip_opts = true
        continue

      if opts.options and opts.options[arg[i]]
        name = arg[i]
        o    = opts.options[arg[i]]
        do
          local value
          switch o.type
            when "string"
              i += 1
              if i > #arg then error "Option #{name} requires a string", 2
              value = arg[i]
            when "number"
              i += 1
              if i > #arg then error "Option #{name} requires a number", 2
              value = tonumber arg[i]
            when "boolean"
              value = true
            when "counter"
              if not counter_cache[name]
                counter_cache[name] = 1
                value               = 1
              else
                counter_cache[name] += 1
                value                = counter_cache[name]
            when "table"
              i += 1
              if not table_cache[name]
                table_cache[name] = {arg[i]}
                value             = table_cache[name]
              else
                table.insert table_cache[name], arg[i]
                value             = table_cache[name]
            else
              error "Invalid option type #{o.type} for option #{name}", 2

          if o.call
            result.opt[name] = o.call (value)
          else
            result.opt[name] = value
        continue

      if ((arg[i]\sub 1, 1) == "-") or ((arg[i]\sub 1, 1) == "@") then
        if (#arg[i] > 1) and ((arg[i]\sub 2,2) == "-")
          -- only reached if "--help" is not defined
          if arg[i] == "--help"
            import format from string
            output = opts.help_output or io.write

            if opts.help
              opts.name    = opts.name    or ""
              opts.version = opts.version or " "
              output "#{opts.name} #{opts.version}: "
              output opts.help
              output "\n"

            output "Options:\n"

            longest_opt, o = 4, {}

            if opts.flags
              for k, v in pairs opts.flags
                o[#o + 1] = {
                  name: (k\len! == 1) and "  -#{k}" or "  --#{k}"
                  desc: v.help or "?"
                }

                if v.type == "counter"
                  o[#o].name ..= " ..."
                if o[#o].name\len! > longest_opt
                  longest_opt = o[#o].name\len!
             
            if opts.options
              for k, v in pairs opts.options do
                e = {
                  desc: v.help or "?"
                }

                switch v.type
                  when "string"  then e.name = "  #{k} <string>"
                  when "number"  then e.name = "  #{k} <number>"
                  when "boolean" then e.name = "  #{k}"
                  when "counter" then e.name = "  #{k} ..."
                  when "table"   then e.name = "  #{k} ..."
                  else error "Invalid option type #{o.type} for option #{k}", 2

                if e.name\len! > longest_opt then longest_opt = e.name\len!

                o[#o + 1] = e

            local fmtstr
            if longest_opt > 20 then fmtstr = "%-20s" else fmtstr = "%-#{longest_opt}s"

            for k, opt in pairs o
              output format fmtstr, opt.name
              if opt.name\len! > 20
                output "\n                     "
              else
                output "  "
              output opt.desc
              output "\n"
              o[k] = nil
            return "help"

        elseif opts.flags
          s = arg[i]\sub 2

          for c = 1, #s, 1
            f = s\sub c,c

            if opts.flags[f]
              if opts.flags[f].type == "counter"
                if not result.opt[f]
                  result.opt[f] = 1
                else
                  result.opt[f] += 1
              else
                result.opt[f] = true
            else
              return nil, "invalid flag: #{f}", i
          continue

    -- unknown argument if this is reached
    if not result.unhandled then result.unhandled = {}
    result.unhandled[#result.unhandled + 1] = arg[i]

  result
