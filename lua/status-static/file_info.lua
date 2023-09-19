local M = {}

function M.getNameUser()
   local user = os.getenv('USER') -- obtener el usuario del sistema

   if user ~= nil then
      return string.gsub(user, '^%l', string.upper)
   end

   return 'Linux'
end

function M.getSystemName()
   local file = io.open('/etc/os-release', 'r')
   if not file then
      return nil
   end

   local content = file:read('*all')
   file:close()

   local nameId = content and content:match('ID=(%w+)')
   return nameId
end

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
      return ' ' .. string.format('%d%s ', size, suffixes[i])
   end

   return ' ' .. size_float .. suffixes[i] .. ' '
end

return M
