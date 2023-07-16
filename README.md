# nvim-translator
A language translator for neovim written in Lua

## Requirements

- Neovim
neovim 0.8 or above 

- python3

- googletrans
install python3 library, i.e:

```shell
pip3 install googletrans==4.0.0rc1
```

## Installation 

### lazy as plugin manager

{
    "alix2013/nvim-translator",
    config = function()
        require("nvim-translator").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
}

### packer as plugin manager
use({
    "alix2013/nvim-translator",
    config = function()
        require("nvim-translator").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
})





