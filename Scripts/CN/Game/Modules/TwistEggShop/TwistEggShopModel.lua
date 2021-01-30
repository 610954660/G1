
local TwistEggShopModel = class("TwistEggShopModel",BaseModel)

function TwistEggShopModel:ctor()
    self.shopInfo = {}     -- 商品信息
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

function TwistEggShopModel:initData(data)
    self.shopInfo = data.recvRecords or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.TwistEggShop_refreshPanal)
end

-- 获取商品数据
function TwistEggShopModel:getShopData()
    local moduleId = self:getModuleId()
    local shopData = DynamicConfigData.t_CapsuleToysStore[moduleId]
    for k,v in pairs(shopData) do
        local data = self.shopInfo[v.id]
        if v.limit == 0 then
            v.buyTime   =  -1
        else
            v.buyTime   = v.limit
        end
        if data and v.limit~=0 then
            data.count = data.count or 0
            v.buyTime = v.buyTime - data.count
            if v.buyTime < 0 then
                v.buyTime = 0
            end
        end
    end
    return shopData or {}
end

-- 获取模板id
function TwistEggShopModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GashaponShop)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end


-- 红点更新
function TwistEggShopModel:updateRed()

end


return TwistEggShopModel
