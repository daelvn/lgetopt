# lgetopt
lgetopt is a fork of [bcnjr5/lua-getopt](https://github.com/bcnjr5/lua-getopt) with slight changes to the code. It's a command-line argument parser for Lua 5.3.

## Features
- GNU-style flag handling (-rsv -> -r -s -v), but only for flags that don't accept values
- D-style option definitions (more or less)

## Usage
You can require the module which will return a function. The function takes the first argument as the list of arguments and the second as the option definitions.
```lua
local getopt = require "getopt"
getopt (arg, {})
```

## Documentation
You can find the documentation for the function [here](lgetopt.md)

## Changelog
### v1.2.2 - 3 Jun 2018
Improved the help flag
### v1.2.1 - 3 Jun 2018
Improved some error messages
### v1.2 - 3 Jun 2018
Added the `table` type to options! Now you can collect a list of arguments like this:
```lua
local getopt = require "lgetopt"
local opts   = {
  options = {
    ["+i"] = {
      help = "Collect inputs",
      type = "table"
    }
  }
}

local argl = getopt (arg, opts)
for k,v in pairs (argl.opt["+i"]) do print (k,v) end
```
Then call this script like `lua example.lua +i file1 +i file2 +i file3` to get this result:
```
1    file1
2    file2
3    file3
```

## License
As the original code was unlicensed, I don't really see a reason to license it, since most of the changes are minimal.

[lgetopt](http://lgetopt.daelvn.ga/) is a command-line argument parser for Lua 5.3
Made by [bcnjr5](https://github.com/bcnjr5)
