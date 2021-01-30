---@class PackConfiger
--背包配置读取器 added by xhd
local PackConfiger = {}

local BagType = GameDef.BagType

local _bagDict = nil
local _capacityDict = nil

local function getDict()
    if not _bagDict then
        _bagDict = require "Configs.Generate.t_bagConfig"
    end
    return _bagDict
end

--获取某个背包最大容量
function PackConfiger.getPackInfoByType(bagType)
    return getDict()[bagType] or { type = bagType, capacity = 0, maxCapacity = 0 }
end

return PackConfiger
