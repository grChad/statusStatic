-- aplicar el thema
require('theme-nvim').load_highlight('statusStatic')

local colors = require('theme-nvim.palletes.frappe')
local icons = require('theme-nvim.icons')

local fileInfo = require('status-static.file_info')
local hig_separate = '%#St_separate_center#' .. icons.separators.line.favorite

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

local M = {}

M.mode = function()
	local m = vim.api.nvim_get_mode().mode

	local current_mode = '%#' .. modes[m][2] .. '# ' .. modes[m][1]
	return current_mode .. '  '
end

M.file_size = function()
	local file = vim.fn.expand('%:p')

	if string.len(file) == 0 then
		return ''
	end

	local hig_fileInfo = '%#ST_FileSize# ' .. fileInfo.format_file_size(file)
	if vim.o.columns < 90 then
		hig_fileInfo = ''
	end

	return hig_fileInfo
end

M.fileName = function()
	local icon = ' ' .. icons.lspkind.File
	local icon_color = colors.green
	local filename = (vim.fn.expand('%') == '' and 'Empty ') or vim.fn.expand('%:t')
	local file_ext = vim.fn.expand('%:e')

	if filename ~= 'Empty ' then
		local devicons_present, devicons = pcall(require, 'nvim-web-devicons')

		if devicons_present then
			local ft_icon, ft_color = devicons.get_icon_color(filename, file_ext)
			icon = (ft_icon ~= nil and ' ' .. ft_icon) or ''
			icon_color = ft_color
		end

		filename = ' ' .. filename .. ' '
	end

	local hig_icon = '%#TS_IconColor' .. '#' .. icon
	vim.api.nvim_set_hl(0, 'TS_iconColor', { fg = icon_color, bg = colors.mantle })

	local hig_file_name = '%#TS_File_name' .. '#' .. filename

	return hig_separate .. hig_icon .. hig_file_name
end

M.git = function()
	local m = vim.api.nvim_get_mode().mode

	if not vim.b.gitsigns_head or vim.b.gitsigns_git_status then
		local icon_linux = '%#St_IconLinux#' .. icons.others.so.fedora .. ' '
		local name_sistem = '%#St_Sistem#Linux '
		return icon_linux .. name_sistem .. hig_separate
	end

	local git_status = vim.b.gitsigns_status_dict
	local i_add = ' ' .. icons.git.add .. ' '
	local i_change = ' ' .. icons.git.modifier .. ' '
	local i_remove = ' ' .. icons.git.remove .. ' '

	local added = (git_status.added and git_status.added ~= 0) and (i_add .. git_status.added) or ''
	local changed = (git_status.changed and git_status.changed ~= 0) and (i_change .. git_status.changed) or ''
	local removed = (git_status.removed and git_status.removed ~= 0) and (i_remove .. git_status.removed) or ''

	local arrow_left = '%#St_ArrowLeftGit#' .. icons.separators.arrow.caret_right .. icons.separators.arrow.chervon_right
	local arrow_right = '%#St_ArrowRightGit#'
		.. ' '
		.. icons.separators.arrow.chevron_left
		.. icons.separators.arrow.caret_left
	local hig_add = '%#Git_Add#' .. added
	local hig_change = '%#Git_Changed#' .. changed
	local hig_remove = '%#Git_removed#' .. removed

	if added == '' and changed == '' and removed == '' then
		arrow_left = ''
		arrow_right = ''
	end

	local diagnistic_git = arrow_left .. hig_add .. hig_change .. hig_remove .. arrow_right
	local branch_name = '%#St_gitIcons#  ' .. '%#St_GitNameBranch#' .. git_status.head .. ' '
	if vim.o.columns < 85 then
		branch_name = '%#St_gitIcons#  '
	end

	return diagnistic_git .. branch_name .. hig_separate
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

	local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
	local info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })

	local i_error = '%#St_lspError#' .. icons.diagnostic.error .. ' '
	local i_warn = '%#St_lspWarning#' .. icons.diagnostic.warning .. ' '
	local i_hint = '%#St_lspHints#' .. icons.diagnostic.hint .. ' '
	local i_info = '%#St_lspInfo#' .. icons.diagnostic.info .. ' '

	errors = (errors and errors > 0) and (i_error .. errors .. ' ') or ''
	warnings = (warnings and warnings > 0) and (i_warn .. warnings .. ' ') or ''
	hints = (hints and hints > 0) and (i_hint .. hints .. ' ') or ''
	info = (info and info > 0) and (i_info .. info .. ' ') or ''

	local arrow_left = '%#St_ArrowLeftLsp#'
		.. icons.separators.arrow.caret_right
		.. icons.separators.arrow.chervon_right
		.. ' '
	local arrow_right = '%#St_ArrowRightLsp#' .. icons.separators.arrow.chevron_left .. icons.separators.arrow.caret_left
	if #vim.diagnostic.get(0) == 0 then
		arrow_left = ''
		arrow_right = ''
	end

	return arrow_left .. errors .. warnings .. hints .. info .. arrow_right
end

M.LSP_status = function()
	return fileInfo.get_lsp_clien()
end

M.cwd = function()
	local dir_icon = '%#St_cwd_icon#' .. ' ' .. icons.lspkind.Folder
	local dir_name = '%#St_cwd_text#' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t') .. ' '

	return (vim.o.columns > 85 and (dir_icon .. dir_name .. hig_separate)) or ''
end

M.cursor_position = function()
	local line = vim.fn.line('.')
	local column = vim.fn.col('.')

	return '%#St_Position#' .. string.format('%3d :%2d ', line, column)
end

return M
