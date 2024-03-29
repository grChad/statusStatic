local icons = require('i-nvim') -- plugin of icons
local fileInfo = require('status-static.file_info')

local hig_separate = '%#sS_separate#' .. icons.separators.line.H_Favorite

local modes = {
	['n'] = { 'NORMAL', 'sS_NormalMode' },
	['niI'] = { 'NORMAL i', 'sS_NormalMode' },
	['niR'] = { 'NORMAL r', 'sS_NormalMode' },
	['niV'] = { 'NORMAL v', 'sS_NormalMode' },
	['no'] = { 'N-PENDING', 'sS_NormalMode' },
	['i'] = { 'INSERT', 'sS_InsertMode' },
	['ic'] = { 'INSERT (completion)', 'sS_InsertMode' },
	['ix'] = { 'INSERT completion', 'sS_InsertMode' },
	['t'] = { 'TERMINAL', 'sS_TerminalMode' },
	['nt'] = { 'NTERMINAL', 'sS_NTerminalMode' },
	['v'] = { 'VISUAL', 'sS_VisualMode' },
	['V'] = { 'V-LINE', 'sS_VisualMode' },
	['Vs'] = { 'V-LINE (Ctrl O)', 'sS_VisualMode' },
	[''] = { 'V-BLOCK', 'sS_VisualMode' },
	['R'] = { 'REPLACE', 'sS_ReplaceMode' },
	['Rv'] = { 'V-REPLACE', 'sS_ReplaceMode' },
	['s'] = { 'SELECT', 'sS_SelectMode' },
	['S'] = { 'S-LINE', 'sS_SelectMode' },
	[''] = { 'S-BLOCK', 'sS_SelectMode' },
	['c'] = { 'COMMAND', 'sS_CommandMode' },
	['cv'] = { 'COMMAND', 'sS_CommandMode' },
	['ce'] = { 'COMMAND', 'sS_CommandMode' },
	['r'] = { 'PROMPT', 'sS_ConfirmMode' },
	['rm'] = { 'MORE', 'sS_ConfirmMode' },
	['r?'] = { 'CONFIRM', 'sS_ConfirmMode' },
	['!'] = { 'SHELL', 'sS_TerminalMode' },
}

local os_icons = {
	['fedora'] = '%#sS_IconFedora# ' .. icons.others.os.fedora .. ' ',
	['debian'] = '%#sS_IconDebian# ' .. icons.others.os.debian .. ' ',
	['arch'] = '%#sS_IconArch# ' .. icons.others.os.arch .. ' ',
	['ubuntu'] = '%#sS_IconUbuntu# ' .. icons.others.os.ubuntu .. ' ',
	['manjaro'] = '%#sS_IconManjaro# ' .. icons.others.os.manjaro .. ' ',
	['linuxmint'] = '%#sS_IconLinuxMint# ' .. icons.others.os.mint .. ' ',
	['pop'] = '%#sS_IconPop# ' .. icons.others.os.pop_os .. ' ',
	['zorin'] = '%#sS_IconZorin# ' .. icons.others.os.zorin .. ' ',
	['cereus'] = '%#sS_IconCereus# ' .. icons.others.os.cereus .. ' ',

	-- icono por defecto para sistemas operativos no reconocidos
	['default'] = '%#sS_IconLinux# ' .. icons.others.os.linux .. ' ',
}

local M = {}

-- TODO: --------------[Status Left]----------------
-- NOTE: mode
M.mode = function()
	local m = vim.api.nvim_get_mode().mode

	local current_mode = '%#' .. modes[m][2] .. '# ' .. modes[m][1]
	return current_mode .. ' '
end

-- NOTE: file name and file size
M.fileName = function()
	local icon = icons.others.mix.file
	local icon_color = '#A6D189'
	local filename = (vim.fn.expand('%') == '' and 'Empty ') or vim.fn.expand('%:t')
	local file_ext = vim.fn.expand('%:e')

	if filename ~= 'Empty ' then
		local devicons_present, devicons = pcall(require, 'nvim-web-devicons')

		if devicons_present then
			local ft_icon, ft_color = devicons.get_icon_color(filename, file_ext)
			icon = (ft_icon ~= nil and ft_icon) or ''
			icon_color = ft_color
		end
	end

	vim.api.nvim_set_hl(0, 'sS_iconColor', { fg = icon_color, bg = '#292C3C' })
	local hig_icon = ' %#sS_IconColor#' .. icon .. ' '

	local hig_file_name = '%#sS_FileName#' .. filename

	return hig_separate .. hig_icon .. hig_file_name .. M.file_size()
end

M.file_size = function()
	local file = vim.fn.expand('%:p')

	if #file == 0 or vim.o.columns < 90 then
		return ' '
	end

	return '%#sS_FileSize# ' .. fileInfo.format_file_size(file)
end

-- NOTE: Lsp
M.LSP_status = function()
	local icon_lsp = '%#sS_IconLsp# ' .. icons.others.mix.lsp .. '  '
	-- Obtenemos el tipo de archivo del buffer actual
	local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
	-- Con el paquete 'vim.lsp' listamos todos los clientes LSP activos en Nvim
	local clients = vim.lsp.get_active_clients()

	if not clients or #clients == 0 then
		return ''
	end

	local lsps = {}
	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes
		if filetypes and vim.tbl_contains(filetypes, buf_ft) then
			table.insert(lsps, client.name)
		end
	end

	if #lsps == 0 then
		return ''
	end

	local hig_lsps = '%#sS_LspServers#' .. table.concat(lsps, ', ')

	if vim.o.columns > 125 then
		return hig_separate .. icon_lsp .. hig_lsps .. ' '
	end

	return hig_separate .. icon_lsp
end

M.LSP_Diagnostics = function()
	if not rawget(vim, 'lsp') then
		return ''
	end

	local i_error = '%#DiagnosticSignError#' .. icons.diagnostic.error .. ' '
	local i_warn = '%#DiagnosticSignWarn#' .. icons.diagnostic.warning .. ' '
	local i_hint = '%#DiagnosticSignInfo#' .. icons.diagnostic.hint .. ' '
	local i_info = '%#DiagnosticSignHint#' .. icons.diagnostic.info .. ' '

	local messages = {
		{ severity = vim.diagnostic.severity.ERROR, hl = i_error },
		{ severity = vim.diagnostic.severity.WARN, hl = i_warn },
		{ severity = vim.diagnostic.severity.HINT, hl = i_hint },
		{ severity = vim.diagnostic.severity.INFO, hl = i_info },
	}

	local caret_right = '%#sS_IconLsp#' .. icons.separators.arrow.caret_right .. ' '
	local message_str = ''

	for _, message in ipairs(messages) do
		local count = #vim.diagnostic.get(0, { severity = message.severity })
		if count > 0 then
			message_str = message_str .. message.hl .. count .. ' '
		end
	end

	if #vim.diagnostic.get(0) == 0 then
		caret_right = ''
	end

	return caret_right .. message_str
end

-- TODO: --------------[Status Center]----------------

-- TODO: --------------[Status Right]----------------
-- NOTE: git
M.git = function()
	if not vim.b.gitsigns_head or vim.b.gitsigns_git_status then
		return ''
	end

	local git_status = vim.b.gitsigns_status_dict

	local i_add = ' ' .. icons.git.add .. ' '
	local i_remove = ' ' .. icons.git.remove .. ' '
	local i_change = ' ' .. icons.git.modifier .. ' '

	local added = (git_status.added and git_status.added ~= 0) and (i_add .. git_status.added) or ''
	local changed = (git_status.changed and git_status.changed ~= 0) and (i_change .. git_status.changed) or ''
	local removed = (git_status.removed and git_status.removed ~= 0) and (i_remove .. git_status.removed) or ''

	local caret_left = '%#sS_gitIcons# ' .. icons.separators.arrow.caret_left .. ' '

	local hig_add = '%#GitSignsAdd#' .. added
	local hig_delete = '%#GitSignsDelete#' .. removed
	local hig_change = '%#GitSignsChange#' .. changed

	if added == '' and changed == '' and removed == '' then
		caret_left = ''
	end

	local diagnistic_git = hig_add .. hig_change .. hig_delete .. caret_left
	local branch_name = '%#sS_gitIcons#' .. icons.git.branch .. ' %#sS_GitNameBranch#' .. git_status.head .. ' '
	if vim.o.columns < 85 then
		branch_name = '%#sS_gitIcons#' .. icons.git.branch .. ' '
	end

	return diagnistic_git .. branch_name .. hig_separate
end

-- NOTE: User
M.user = function()
	local system_name = fileInfo.getSystemName()
	local system_icon = os_icons[system_name] or os_icons['default']

	local system_user = '%#sS_User#' .. fileInfo.getNameUser() .. ' '
	local retorno = system_icon .. system_user .. hig_separate

	return (vim.o.columns > 105 and retorno) or ''
end

-- NOTE: cwd
M.cwd = function()
	local dir_icon = '%#sS_cwdIcon# ' .. icons.others.mix.directory .. ' '
	local dir_name = '%#sS_cwdText#' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t') .. ' ' .. hig_separate

	return dir_icon .. dir_name
end

-- NOTE: cursor position
M.cursor_position = function()
	local column = vim.fn.col('.')

	return '%#sS_Position# X: ' .. string.format('%2d', column) .. ' '
end

return M
