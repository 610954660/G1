local NetworkConfiger = {}

local tError = false
local function getErrorDict()
	if not tError then
		tError = require "Configs.GameDef.ErrorCodeDict"
	end
	return tError
end

function NetworkConfiger.getErrorDescByCode(code)
	local temp = getErrorDict()[code]
	if temp then 
		return temp.desc
	end 
	return false
end

return NetworkConfiger