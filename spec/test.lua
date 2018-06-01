-- Tests the getopt module.
-- Mostly just prints different things depending on the arguments.

assert(arg ~= nil, 'Lua interpreter does not support command-line arguments')

local getopt = require('lgetopt')
local write = require('io').write

local opts
do -- process arguments
  local args = getopt(arg, {
    help_text = 'test.lua -- getopt test script',
    flags = {
      ['c'] = {
        help_text = 'Make the fox a cat.',
      },
      ['v'] = {
        help_text = 'Increase verbosityness.',
        type = 'counter',
      },
    },
    options = {
      ['--breed'] = {
        help_text = 'The type of dog.',
        type = 'string',
      },
      ['--name'] = {
        help_text = "The dog's name.",
        type = 'string',
        callback = function(name)
          return name:upper()
        end,
      },
      ['--version'] = {
        help_text = 'Display version information.',
        type = 'boolean',
        callback = function()
          write("getopt test script v42\n")
          require('os').exit(0)
        end,
      },
    },
  })

  if (args == 'help') then -- help argument recieved, help text printed, exit
    require('os').exit(0)
  end

  -- display all option values
  write("Options:\n")
  for option_name,value in pairs(args.opt) do
    write("\t")
    write('"'..option_name..'"')
    write(' = ')

    if (type(value) == 'string') then
      write('"'..value..'"')
    else
      write(tostring(value))
    end

    write("\n")
  end

  write("\n")

  if (args.unhandled) then
    write("Unhandled arguments:\n")
    for k,value in ipairs(args.unhandled) do
      write("\t\""..value.."\"\n")
    end

    write("\n")

    -- exit with error (unknown arguments)
    error('Unknown argument: '..args.unhandled[1], 0)
  end

  opts = args.opt
end

-- do whatever the options say

local verbosity = opts['v'] or 0
local dog_breed = opts['--breed'] or 'labradoodle'
local is_cat = opts['c']

write('The quick brown ')

if (is_cat) then
  write('cat')
else
  write('fox')
end

write(' jumped over the lazy ')

if (verbosity >= 1) then
  write(dog_breed)
else
  write('dog')
end

if (opts['--name']) then
  write(' called '..opts['--name'])
end

if (verbosity >= 2) then
  write(" by bending it's legs, then straightening them quickly")
end

write(".\n")
