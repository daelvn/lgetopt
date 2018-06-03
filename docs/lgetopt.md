# lgetopt Documentation

## `getopt (arguments, options)`
##### Parameters
- `arguments`  
A list of arguments. (The `arg` variable, for example)
- `options`  
[The options definitions](#the-options-parameter)
##### Returns
A table of the options [described below](#).
`nil, msg, index` on error.

### The `options` parameter
It describes a table with the following structure
```lua
{
  name    = "",
  version = "",
  help    = "",
  options = {
    ["--version"] = {
      help = "",
      type = "", -- See below
      call = function (v) return v .. "." end
    },
    -- more options
  },
  flags   = {
    ["-v"] = {
      help = "",
      type = "",
    }
  }
}
```
All of the fields are optional (even though there is no point on calling getopt without arguments)
#### `options.help`
A string containing the text to be used with the `--help` flag that is automatically generated.
For example, for `rm` it might be `rm  Remove files or directories`
#### `options.options`
List of valid options with the form explained above. It doesn't have to start with two dashes, it can be anything.
#### Option help text
A string describing the usage of each option.
#### Option types
- `boolean`  
Can only be true or false. True if specified, nil otherwise.  
`--plain`
- `counter`  
Keeps the count of times the flag has been used. Useful for verbosity.  
`-vv`
- `number`  
Only accepts a number as the value.  
`-bsize 256`
- `string`  
Accepts a string as the value.  
`-o ../main.o`
- `table`
Collects arguments in a table.
`-i file1 -i file2 -i file3`
### Option callback
`.call` will be called if found with the value of the flag, and sets it to what the function returns.
### `options.flags`
Flags are one-character long options. They can only be of the type `boolean` or `counter`. If not specified, it defaults to `boolean`. It has the same structure as `options.options`

## Result structure
```
{
  opt = { -- always present
    [some_option_name] = value_of_some_option,
    [another_option_name] = value_of_another_option,
    ...
  },
  unhandled = { -- set to `nil` if empty
    first_unrecognized_option,
    second_unrecognized_option,
    ...
  },
}
```
The value of the option `--example` would be stored as `getopt (...).opt ["--example"]`
