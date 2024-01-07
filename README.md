filestack.nvim
==============
Navigate jumplist a file at a time

## Setup
You can customize the configuration by passing parameters to the `setup()` function. If no parameters are passed, the default key mappings (`<c-o>`, `<c-i>`, `<m-o>`, `<m-i>`) will be used. 

Here's how to set up without any parameters:
```lua
require("filestack").setup()
```

You can also set up with custom parameters like this:
```lua
require("filestack").setup({
    keymaps = {
        jump = { backward = '<c-o>', forward = '<c-i>' },
        navigate = { backward = '<m-o>', forward = '<m-i>' }
    }
})
```
Replace `<c-o>`, `<c-i>`, `<m-o>`, and `<m-i>` with your custom keys for both `jump` and `navigate` actions.

## Usage
Press the keys you've configured during the setup to navigate through the filestack. Use the `jump` key mappings to move forward and backward within a file, and the `navigate` key mappings to move between files.
