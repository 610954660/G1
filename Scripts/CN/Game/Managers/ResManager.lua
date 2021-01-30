local ResManager = {}
local Resources = require "Configs.Handwork.Resources"
local resInstance = cc.ResourceManager:getInstance()

--[[
获取资源
@param	resType		[string]资源类型	(对应ResTypes中的项)
@param	resName		[string]资源名
@return 资源路径
]]
function ResManager.getRes(resType, resName)
	resInstance:getDefaultLoadingImage() -- 重置加载图

	local path = nil

	local t = Resources[resType]
	if t then
		return t[resName]
	end

	if not path then
		error(string.format("ResManager.getRes ERROR: can't found: %s.%s", tostring(resType), tostring(resName)))
	end

	return path
end

function ResManager.setResources(tb)
	Resources = tb
end

--------------------------
-- 多层资源获取
-- @param	resType		[string]	资源类型
-- @param	subType		[string]	子级资源类型
-- @param	resName		[string]	资源名
-- @return	资源路径
function ResManager.getResSub(resType, subType, resName)
	local path = nil

	local t = getRes(resType, subType)
	if t then
		return t[resName] or ""
	end

	if not path then
		error(string.format("ResManager.getResSub error: can't found: %s.%s.%s", tostring(resType), tostring(subType), tostring(resName)))
	end

	return path
end

--[[
获取组件资源
@param	uiType		[string]组件类型	(对应UIType中的项)
@param	resName		[string]资源名
@return 资源路径
--]]
function ResManager.getUIRes(uiType, resName)
	return getResSub(ResType.UI, uiType, resName)
end

--获取空图片的资源路径
function ResManager.getEmptyImg()
	resInstance:setDefaultLoadingImage("Default/empty.png")
	return "Default/empty.png"
end

--获取地图块资源
function ResManager.getMapBlockImg(mapId, row, col)
	local mapInfo = MapDefines.MapConfig.getMapInfoById(mapId)
	if not mapInfo then return "" end

	return string.format("Map/%s/%s_%d_%d%s", mapId, mapId, row, col, mapInfo.getSplitSuffix())
end

--获取地图块资源
function ResManager.getMapBgBlockImg(mapId, row, col)
	local mapInfo = MapDefines.MapConfig.getMapInfoById(mapId)
	if not mapInfo then return "" end
	if mapId == 1212001 then
		mapId = 1101001
	end
	return string.format("Map/%s/%s_bg_%d_%d%s", mapId, mapId, row, col, mapInfo.getBgSuffix())
end


--[[
获取货币图标资源路径
@EPriceUnit		[number]	货币类型，详细查看枚举:Message.Public.EPriceUnit
@return [string]	对应货币的图标路径
]]
local MONEYTYPE_DFR = false
function ResManager.getMoneyIcon(moneyType)
	if not MONEYTYPE_DFR then
		MONEYTYPE_DFR = {}
		for k, v in pairs(GameDef.MoneyType) do
			MONEYTYPE_DFR[v] = string.lower(k)
		end
	end
	return getRes(ResType.PUBLIC, "icon_money_"..MONEYTYPE_DFR[moneyType])
end


--[[从资源路径中获取资源文件名
@param 
	strurl  [string] 资源路径
	strchar [string] 路径分割符，默认为"/", 如果是"\",则传入"\\"
	bafter  [bool]   nil或fasle时取文件名，true时取目录路径
@return 截取后的字符串
@example
	getUrlFileName("UI/Button/jz2_btn_01.png")
	返回结果为jz2_btn_01.png
]]
function ResManager.getUrlFileName(strurl, strchar, bafter)
	strchar = strchar or "/"
	local ts = string.reverse(strurl)
	local param1, param2 = string.find(ts, strchar)
	if not param2 then
		return strurl
	end
	local m = string.len(strurl) - param2 + 1
	local result
    
	if bafter then
		result = string.sub(strurl, 1, m-1)
	else
		result = string.sub(strurl, m+1, string.len(strurl))
	end

	return result

end

function ResManager.getSceneEffect(name)
	return string.format("Effect/Scene/%s", name)
end

return ResManager
