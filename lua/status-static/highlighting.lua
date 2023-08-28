-- Definir colores en una tabla
local cp = require('status-static.colors')

local group = {
   St_separate = { fg = cp.text1, bg = cp.base },
   StatusLine = { fg = cp.text1, bg = cp.base },   -- status line of current window
   StatusLineNC = { fg = cp.surface, bg = cp.base }, -- status lines of not-current windows Note: if this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.

   -- MODES
   St_NormalMode = { fg = cp.normal, bg = cp.base, bold = true },
   St_InsertMode = { fg = cp.insert, bg = cp.base, bold = true },
   St_VisualMode = { fg = cp.visual, bg = cp.base, bold = true },
   St_ReplaceMode = { fg = cp.replace, bg = cp.base, bold = true },
   St_TerminalMode = { fg = cp.blue_1, bg = cp.base, bold = true },
   St_NTerminalMode = { fg = cp.blue_1, bg = cp.base, bold = true },
   St_ConfirmMode = { fg = cp.teal_1, bg = cp.base, bold = true },
   St_CommandMode = { fg = cp.command, bg = cp.base, bold = true },
   St_SelectMode = { fg = cp.select, bg = cp.base, bold = true },

   -- File Name
   TS_File_name = { fg = cp.text1, bg = cp.base },

   -- File Zise
   ST_FileSize = { fg = cp.overlay, bg = cp.base },

   -- LSP
   St_IconLsp = { fg = cp.blue_1, bg = cp.base },
   St_LspServers = { fg = cp.blue_1, bg = cp.base, italic = true },
   St_LspProgress = { fg = cp.green, bg = cp.base }, -- por descubrir

   -- Git
   St_gitIcons = { fg = cp.git, bg = cp.base },
   St_GitNameBranch = { fg = cp.git, bg = cp.base },

   -- Unix
   St_IconFedora = { fg = cp.fedora, bg = cp.base },
   St_IconDebian = { fg = cp.debian, bg = cp.base },
   St_IconArch = { fg = cp.arch, bg = cp.base },
   St_IconUbuntu = { fg = cp.ubuntu, bg = cp.base },
   St_IconManjaro = { fg = cp.manjaro, bg = cp.base },
   St_IconLinuxMint = { fg = cp.linuxmint, bg = cp.base },
   St_IconPop = { fg = cp.pop, bg = cp.base },
   St_IconZorin = { fg = cp.zorin, bg = cp.base },
   St_IconCereus = { fg = cp.cereus, bg = cp.base },
   St_IconLinux = { fg = cp.text2, bg = cp.base },

   St_User = { fg = cp.text1, bg = cp.base },

   -- PWD Nombre del proyecto
   St_cwd_icon = { fg = cp.normal, bg = cp.base },
   St_cwd_text = { fg = cp.text1, bg = cp.base, bold = true },

   -- position
   St_Position = { fg = cp.text1, bg = cp.base, bold = true },
}

for hl, col in pairs(group) do
   vim.api.nvim_set_hl(0, hl, col)
end

-- usando link de otro themas
local git_groups = {
   -- de gitsigns
   { name = 'Git_Add',     hl = 'GitSignsAdd' },
   { name = 'Git_Delete',  hl = 'GitSignsDelete' },
   { name = 'Git_Change',  hl = 'GitSignsChange' },

   -- del lsp del sistema
   { name = 'Lsp_Error',   hl = 'DiagnosticError' },
   { name = 'Lsp_Warning', hl = 'DiagnosticWarn' },
   { name = 'Lsp_Hint',    hl = 'DiagnosticInfo' },
   { name = 'Lsp_Info',    hl = 'DiagnosticHint' },
}

for _, new_group in ipairs(git_groups) do
   local hl = vim.api.nvim_get_hl_by_name(new_group.hl, true)
   hl.bg = cp.base
   hl.italic = false
   hl.bold = false
   hl.underline = false

   vim.api.nvim_set_hl(0, new_group.name, hl)
end
