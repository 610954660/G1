
local LanternShopModel = class("LanternShopModel",BaseModel)

function LanternShopModel:ctor()
    self.shopInfo = {}      -- 商品信息
    self.flagInfo = {}      -- 记录购买的次数
end

-- # 扭蛋商店
-- .PActivity_GashaponShop {
-- 	recvRecords		1:*PGashaponRecord(id)
-- }

-- # 扭蛋商店记录
-- .PGashaponRecord {
-- 	id 					1:integer	#奖励id
-- 	count 				2:integer   #数量
-- }

function LanternShopModel:initData(data)
    self.shopInfo = data.recvRecords or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.LanternShopView_refreshPanal)
end

-- 获取商品数据
function LanternShopModel:getShopData()
    local moduleId = self:getModuleId()
    local shopData = DynamicConfigData.t_LanternStore[moduleId]
    for k,v in pairs(shopData) do
        local data = self.shopInfo[v.id]
        if not  self.flagInfo[v.id] then
            self.flagInfo[v.id] = {}
        end
        if v.limit == 0 then
            self.flagInfo[v.id].buyTime = -1
        else
            self.flagInfo[v.id].buyTime = v.limit
        end
        if data and v.limit~=0 then
            data.count = data.count or 0
            self.flagInfo[v.id].buyTime = self.flagInfo[v.id].buyTime - data.count
            if self.flagInfo[v.id].buyTime < 0 then
                self.flagInfo[v.id].buyTime = 0
            end
        end
    end
    return shopData or {}
end

-- 获取模板id
function LanternShopModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.LanternShop)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end


-- 红点更新
function LanternShopModel:updateRed()

end


return LanternShopModel
