local M = {}

-- Función que formatea el tamaño actual del archivo
function M.format_file_size(file)
	-- Verificamos si la entrada del archivo es un 'string' antes de procesar
	if type(file) ~= 'string' then
		return ''
	end

	local size = vim.fn.getfsize(file)
	if size <= 0 then
		return ''
	end

	local suffixes = { 'b', 'k', 'm', 'g' }
	local i = 1
	while size > 1024 and i < #suffixes do
		size = size / 1024
		i = i + 1
	end

	-- Formatea dando como resultado un numero con 1 decimal
	local size_float = string.format('%.1f', size)

	-- si el decimal termina en '.0' como en '345.0' devolvera '345'
	if size_float:sub(-2) == '.0' then
		return string.format('%d%s ', size, suffixes[i])
	end

	return size_float .. suffixes[i] .. ' '
end

function M.get_file_size()
	-- optiene la ruta del archivo que se esta editando, ejemplo:
	-- `/home/user/my_file.txt`
	local file = vim.fn.expand('%:p')
	if #file == 0 then
		return ''
	end

	return M.format_file_size(file)
end

function M.get_lsp_clien(msg)
	local hig_separate = '%#St_separate_lsp#' .. '|'
	local icon_lsp = '%#St_IconLsp#' .. '   '
	-- Obtenemos el tipo de archivo del buffer actual
	local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
	-- Con el paquete 'vim.lsp' listamos todos los clientes LSP activos en Nvim
	local clients = vim.lsp.get_active_clients()

	if not clients or #clients == 0 then
		return msg or ''
	end

	local lsps = {}
	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes
		if filetypes and vim.tbl_contains(filetypes, buf_ft) then
			table.insert(lsps, client.name)
		end
	end

	if #lsps == 0 then
		return msg or ''
	end

	local hig_lsps = '%#St_LspServers#' .. table.concat(lsps, ', ')
	if vim.o.columns > 105 then
		return hig_separate .. icon_lsp .. hig_lsps .. ' '
	end

	return hig_separate .. icon_lsp
end

return M
