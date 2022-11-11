-- aplicar el thema
require('theme-nvim').load_highlight('statusline')
local colors = require('theme-nvim.palletes.frappe')

local fileInfo = require('status-static.file_info')
local fn = vim.fn

local hig_separate = '%#St_separate_center#' .. '|'

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
	local icon = '  '
	local icon_color = '#A6D189'
	local filename = (fn.expand('%') == '' and 'Empty ') or fn.expand('%:t')
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
		local icon_linux = '%#' .. modes[m][2] .. '#  '
		local name_sistem = '%#St_Sistem#Linux '
		return icon_linux .. name_sistem .. hig_separate
	end

	local git_status = vim.b.gitsigns_status_dict

	local added = (git_status.added and git_status.added ~= 0) and ('  ' .. git_status.added) or ''
	local changed = (git_status.changed and git_status.changed ~= 0) and ('  ' .. git_status.changed) or ''
	local removed = (git_status.removed and git_status.removed ~= 0) and ('  ' .. git_status.removed) or ''

	local arrow_left = '%#St_ArrowLeftGit#' .. ''
	local arrow_right = '%#St_ArrowRightGit#' .. ' '
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

	errors = (errors and errors > 0) and ('%#St_lspError#' .. ' ' .. errors .. ' ') or ''
	warnings = (warnings and warnings > 0) and ('%#St_lspWarning#' .. '  ' .. warnings .. ' ') or ''
	hints = (hints and hints > 0) and ('%#St_lspHints#' .. ' ' .. hints .. ' ') or ''
	info = (info and info > 0) and ('%#St_lspInfo#' .. ' ' .. info .. ' ') or ''

	local arrow_left = '%#St_ArrowLeftLsp#' .. ' '
	local arrow_right = '%#St_ArrowRightLsp#' .. ''
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
	local dir_icon = '%#St_cwd_icon#' .. '  '
	local dir_name = '%#St_cwd_text#' .. fn.fnamemodify(fn.getcwd(), ':t') .. ' '

	return (vim.o.columns > 85 and (dir_icon .. dir_name .. hig_separate)) or ''
end

M.cursor_position = function()
	local m = vim.api.nvim_get_mode().mode
	local line = vim.fn.line('.')
	local column = vim.fn.col('.')

	return '%#St_Position#' .. string.format('%3d :%2d ', line, column)
end

return M
