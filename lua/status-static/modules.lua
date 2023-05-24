require('status-static.highlighting') -- groups highlighting

local icons = require('status-static.icons')
local colors = require('status-static.colors')
local fileInfo = require('status-static.file_info')

local hig_separate = '%#St_separate#' .. icons.separate

local modes = {
	['n'] = { 'NORMAL', 'St_NormalMode' },
	['niI'] = { 'NORMAL i', 'St_NormalMode' },
	['niR'] = { 'NORMAL r', 'St_NormalMode' },
	['niV'] = { 'NORMAL v', 'St_NormalMode' },
	['no'] = { 'N-PENDING', 'St_NormalMode' },
	['i'] = { 'INSERT', 'St_InsertMode' },
	['ic'] = { 'INSERT (completion)', 'St_InsertMode' },
	['ix'] = { 'INSERT completion', 'St_InsertMode' },
	['t'] = { 'TERMINAL', 'St_TerminalMode' },
	['nt'] = { 'NTERMINAL', 'St_NTerminalMode' },
	['v'] = { 'VISUAL', 'St_VisualMode' },
	['V'] = { 'V-LINE', 'St_VisualMode' },
	['Vs'] = { 'V-LINE (Ctrl O)', 'St_VisualMode' },
	[''] = { 'V-BLOCK', 'St_VisualMode' },
	['R'] = { 'REPLACE', 'St_ReplaceMode' },
	['Rv'] = { 'V-REPLACE', 'St_ReplaceMode' },
	['s'] = { 'SELECT', 'St_SelectMode' },
	['S'] = { 'S-LINE', 'St_SelectMode' },
	[''] = { 'S-BLOCK', 'St_SelectMode' },
	['c'] = { 'COMMAND', 'St_CommandMode' },
	['cv'] = { 'COMMAND', 'St_CommandMode' },
	['ce'] = { 'COMMAND', 'St_CommandMode' },
	['r'] = { 'PROMPT', 'St_ConfirmMode' },
	['rm'] = { 'MORE', 'St_ConfirmMode' },
	['r?'] = { 'CONFIRM', 'St_ConfirmMode' },
	['!'] = { 'SHELL', 'St_TerminalMode' },
}

local os_icons = {
	['fedora'] = '%#St_IconFedora# ' .. icons.os.fedora,
	['debian'] = '%#St_IconDebian# ' .. icons.os.debian,
	['arch'] = '%#St_IconArch# ' .. icons.os.arch,
	['ubuntu'] = '%#St_IconUbuntu# ' .. icons.os.ubuntu,
	['manjaro'] = '%#St_IconManjaro# ' .. icons.os.manjaro,
	['linuxmint'] = '%#St_IconLinuxMint# ' .. icons.os.linuxmint,
	['pop'] = '%#St_IconPop# ' .. icons.os.pop,
	['zorin'] = '%#St_IconZorin# ' .. icons.os.zorin,
	['cereus'] = '%#St_IconCereus# ' .. icons.os.cereus,

	-- icono por defecto para sistemas operativos no reconocidos
	['default'] = '%#St_IconLinux# ' .. icons.os.linux,
}

local M = {}

M.mode = function()
	local m = vim.api.nvim_get_mode().mode

	local current_mode = '%#' .. modes[m][2] .. '# ' .. modes[m][1]
	return current_mode .. ' '
end

M.file_size = function()
	local file = vim.fn.expand('%:p')

	if #file == 0 or vim.o.columns < 90 then
		return ' '
	end

	return '%#ST_FileSize# ' .. fileInfo.format_file_size(file)
end

M.fileName = function()
	local icon = icons.file
	local icon_color = colors.green
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

	vim.api.nvim_set_hl(0, 'TS_iconColor', { fg = icon_color, bg = colors.base })

	local hig_icon = ' %#TS_IconColor#' .. icon .. ' '

	local hig_file_name = '%#TS_File_name#' .. filename

	return hig_separate .. hig_icon .. hig_file_name .. M.file_size()
end

-- LSP STUFF
M.LSP_progress = function()
	if not rawget(vim, 'lsp') then
		return ''
	end

	local Lsp = vim.lsp.util.get_progress_messages()[1]

	if vim.o.columns < 120 or not Lsp then
		return ''
	end

	local msg = Lsp.message or ''
	local percentage = Lsp.percentage or 0
	local title = Lsp.title or ''
	local spinners = { '', '' }
	local ms = vim.loop.hrtime() / 1000000
	local frame = math.floor(ms / 120) % #spinners
	local content = string.format(' %%<%s %s %s (%s%%%%) ', spinners[frame + 1], title, msg, percentage)

	return ('%#St_LspProgress#' .. content) or ''
end

M.LSP_Diagnostics = function()
	if not rawget(vim, 'lsp') then
		return ''
	end

	local i_error = '%#Lsp_Error#' .. icons.diagnostic.error
	local i_warn = '%#Lsp_Warning#' .. icons.diagnostic.warning
	local i_hint = '%#Lsp_Hint#' .. icons.diagnostic.hint
	local i_info = '%#Lsp_Info#' .. icons.diagnostic.info

	local messages = {
		{ severity = vim.diagnostic.severity.ERROR, hl = i_error },
		{ severity = vim.diagnostic.severity.WARN, hl = i_warn },
		{ severity = vim.diagnostic.severity.HINT, hl = i_hint },
		{ severity = vim.diagnostic.severity.INFO, hl = i_info },
	}

	local arrow_left = '%#St_IconLsp#' .. icons.caret_right
	local message_str = ''

	for _, message in ipairs(messages) do
		local count = #vim.diagnostic.get(0, { severity = message.severity })
		if count > 0 then
			message_str = message_str .. message.hl .. count .. ' '
		end
	end

	if #vim.diagnostic.get(0) == 0 then
		arrow_left = ''
	end

	return arrow_left .. message_str
end

M.LSP_status = function()
	return fileInfo.get_lsp_clien()
end

-- TODO: Status Right

M.git = function()
	if not vim.b.gitsigns_head or vim.b.gitsigns_git_status then
		return ''
	end

	local git_status = vim.b.gitsigns_status_dict

	local i_add = icons.git.add
	local i_remove = icons.git.remove
	local i_change = icons.git.modifier

	local added = (git_status.added and git_status.added ~= 0) and (i_add .. git_status.added) or ''
	local changed = (git_status.changed and git_status.changed ~= 0) and (i_change .. git_status.changed) or ''
	local removed = (git_status.removed and git_status.removed ~= 0) and (i_remove .. git_status.removed) or ''

	local arrow_right = '%#St_gitIcons#' .. icons.caret_left

	local hig_add = '%#Git_Add#' .. added
	local hig_delete = '%#Git_Delete#' .. removed
	local hig_change = '%#Git_Change#' .. changed

	if added == '' and changed == '' and removed == '' then
		arrow_right = ''
	end

	local diagnistic_git = hig_add .. hig_change .. hig_delete .. arrow_right
	local branch_name = '%#St_gitIcons#' .. icons.git.icon_branch .. '%#St_GitNameBranch#' .. git_status.head .. ' '
	if vim.o.columns < 85 then
		branch_name = '%#St_gitIcons#' .. icons.git.icon_branch
	end

	return diagnistic_git .. branch_name .. hig_separate
end

M.user = function()
	local system_name = fileInfo.getSystemName()
	local system_icon = os_icons[system_name] or os_icons['default']

	local system_user = '%#St_User#' .. fileInfo.getNameUser() .. ' '
	local retorno = system_icon .. system_user .. hig_separate

	return (vim.o.columns > 105 and retorno) or ''
end

M.cwd = function()
	local dir_icon = '%#St_cwd_icon# ' .. icons.folder
	local dir_name = '%#St_cwd_text#' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t') .. ' ' .. hig_separate

	return dir_icon .. dir_name
end

M.cursor_position = function()
	-- local line = vim.fn.line('.')
	local column = vim.fn.col('.')

	-- return '%#St_Position#' .. string.format('%3d :%2d ', line, column)
	return '%#St_Position# X: ' .. column .. ' '
end

return M
