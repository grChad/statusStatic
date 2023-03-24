<h1 align="center">statusStatic</h1>

Como su nombre lo indica es una _barra de estado estática_. La razón de ello es tener una barra simple, rápida y sin nada que configurar.

<p align="center"><img src="https://github.com/GabrielRIP/my-assets/blob/main/plugs-lua/statusStatic/image-1.png"</p>
<p align="center"><img src="https://github.com/GabrielRIP/my-assets/blob/main/plugs-lua/statusStatic/image-2.png"</p>
<p align="center"><img src="https://github.com/GabrielRIP/my-assets/blob/main/plugs-lua/statusStatic/image-3.png"</p>
<p align="center"><img src="https://github.com/GabrielRIP/my-assets/blob/main/plugs-lua/statusStatic/image-4.png"</p>
<p align="center"><img src="https://github.com/GabrielRIP/my-assets/blob/main/plugs-lua/statusStatic/image-5.png"</p>

## Uso

con [Packer](https://github.com/wbthomason/packer.nvim)

```lua
  use {'GabrielRIP/theme-custom'},

  use {
      'GabrielRIP/statusStatic',
      after = 'theme-nvim',
      config = function()
          require('status-static').setup()
      end,
  }
```
