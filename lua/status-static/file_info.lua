local M = {}

-- format print current file size
function M.format_file_size(file)
	local size = vim.fn.getfsize(file)
	if size == 0 or size == -1 or size == -2 then
		return ''
	end

	if size < 1024 then
		size = size .. 'b'
	elseif size < 1024 * 1024 then
		size = string.format('%.1f', size / 1024) .. 'k'
	elseif size < 1024 * 1024 * 1024 then
		size = string.format('%.1f', size / 1024 / 1024) .. 'm'
	else
		size = string.format('%.1f', size / 1024 / 1024 / 1024) .. 'g'
	end
	return size .. ' '
end

function M.get_file_size()
	local file = vim.fn.expand('%:p')
	if string.len(file) == 0 then
		return ''
	end
	return M.format_file_size(file)
end

function M.get_lsp_clien(msg)
	local hig_separate = '%#St_separate_lsp#' .. '|'
	local icon_lsp = '%#St_IconLsp#' .. '   '

	msg = msg or ''
	local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
	local clients = vim.lsp.get_active_clients()
	if next(clients) == nil then
		return msg
	end
	local lsps = ''
	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes
		if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
			if lsps == '' then
				lsps = client.name
			else
				if not string.find(lsps, client.name) then
					lsps = lsps .. ', ' .. client.name
				end
			end
		end
	end
	local hig_lsps = '%#St_LspServers#' .. lsps

	if lsps == '' then
		return msg
	else
		if vim.o.columns > 105 then
			return hig_separate .. icon_lsp .. hig_lsps .. ' '
		end
		return hig_separate .. icon_lsp
	end
end

return M
