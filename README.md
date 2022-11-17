<h2 align="center">statusStatic</h2>

<p align="center">
    Como su nombre lo indica es una <strong>barra de estado estática</strong>. La razón de ello es tener una barra simple, rápida y sin nada que configurar.
</p>

<p align="center"><img src="./assets/image-1.png"</p>
<p align="center"><img src="./assets/image-2.png"</p>
<p align="center"><img src="./assets/image-3.png"</p>
<p align="center"><img src="./assets/image-4.png"</p>
<p align="center"><img src="./assets/image-5.png"</p>

### Uso

con [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {'GabrielRIP/theme-custom'},
use {
    'GabrielRIP/statusStatic',
    alter = 'theme-nvim',
    config = function()
        require('status-static').setup()
    end,
}
```
