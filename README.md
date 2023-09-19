<h1 align="center">statusStatic</h1>

<p align="center">
  <i>statusStatic</i> es un plugin de barra de estado que se caracteriza por ser <i>estática</i>. Esta opción fue elegida para proporcionar una barra de estado simple y rápida, sin necesidad de una configuración adicional.
</p>

![image01](https://github.com/GabrielRIP/my-assets/blob/main/plugs-lua/statusStatic/status01.png)
![image02](https://github.com/GabrielRIP/my-assets/blob/main/plugs-lua/statusStatic/status02.png)
![image03](https://github.com/GabrielRIP/my-assets/blob/main/plugs-lua/statusStatic/status03.png)
![image04](https://github.com/GabrielRIP/my-assets/blob/main/plugs-lua/statusStatic/status04.png)
![image05](https://github.com/GabrielRIP/my-assets/blob/main/plugs-lua/statusStatic/status05.png)

## ¿En qué se destaca?

statusStatic se destaca por las siguientes características:

1. Los colores utilizados para mostrar los diagnósticos lsp y git status se basan en los colores definidos por gitsigns y lsp del sistema, por lo que es compatible con temas que colorean estos dos. Esto proporciona una experiencia coherente y personalizada para el usuario.
2. Detecta automáticamente el nombre de usuario del sistema `whoami` y lo muestra junto al icono del sistema correspondiente. Esto hace que la barra de estado sea más informativa y personalizada.
3. El icono del sistema se adapta automáticamente a una lista de sistemas operativos populares, como Fedora, Debian, Arch, Ubuntu, Manjaro, Linux Mint, Pop Os y Zorin. En caso de no ser compatible con el sistema en uso, se muestra el icono de Linux por defecto.
4. El estilo de la barra de estado es simple y minimalista, proporcionando solo la información esencial que necesita el usuario. Esto hace que sea fácil de usar y visualmente atractiva.

## Uso

con [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'gr92/statusStatic',
    config = function()
        require('status-static').setup()
    end,
}
```

con [Lazy](https://github.com/folke/lazy.nvim)

```lua
{
  'grChad/statusStatic',
  lazy = false,
  config = function()
     require('status-static').setup()
  end,
},
```

## Pendiente

- [ ] Un tema claro.
