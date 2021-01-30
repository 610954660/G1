-- add by zn
-- 装备礼包

local EquipGiftModel = class("EquipGiftModel", BaseModel)

function EquipGiftModel:ctor()
    self:initListeners()
    self.statusList = {};
end

function EquipGiftModel:Activity_UpdateData(_, params)
    if params.type ~= GameDef.ActivityType.EquipGift then
		return
	end
	if params.endState then --如果是true 直接结束
		ModelManager.ActivityModel:speDeleteSeverData(params.type)
		return
    end
    self.statusList = params.weekGift.giftStatus or {};
	Dispatcher.dispatchEvent(EventType.EquipGift_refreashData)
end

function EquipGiftModel:sortDataList()
	local moduleId = ActivityModel:getModuleIdByActivityType( GameDef.ActivityType.EquipGift )
    local conf = DynamicConfigData.t_EquipmentGift[moduleId];
    local data = {};
    for id, d in ipairs(conf) do
        data[id] = d;
        if (not self.statusList[d.giftId]) or (d.buyTimes > self.statusList[d.giftId].buyTimes) then
            data[id].status = 0;
        else
            data[id].status = 2;
        end
    end
    TableUtil.sortByMap(data, {{key = "status", asc = false}, {key = "price", asc = false}});
    return data;
end

-- function EquipGiftModel: buyGift(giftId)
--     local info = {
--         id = giftId,
--         ActivityType = GameDef.StatFuncType.SFT_EquipGift
--     }
--     if data.price == 0 then
--         RPCReq.Activity_WeekGift_Reward{id = data.giftId}
--     else
--         ModelManager.RechargeModel:directBuy(data.price,  GameDef.StatFuncType.SFT_WeekGift, data.giftId, data.name, data.showName1)
--     end
--     -- ModelManager.RechargeModel:directBuy(price, GameDef.StatFuncType.SFT_NewWeekCard,gear,Desc.NewWeekCard_name)
--     RPCReq.Activity_WeekGift_Reward(info, function (params)
--         Dispatcher.dispatchEvent(EventType.EquipGift_refreashData)
--     end)
-- end

return EquipGiftModel