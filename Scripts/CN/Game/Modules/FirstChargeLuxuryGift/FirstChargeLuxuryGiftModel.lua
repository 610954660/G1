-- 首充礼包
local FirstChargeLuxuryGiftModel = class("FirstChargeLuxuryGiftModel", BaseModel)

function FirstChargeLuxuryGiftModel:ctor()
    -- 当前档次礼包的数据
    self.currentGift = {}
    -- self:updataRed()
end

-- 获取当前档次礼包的数据 包含当前礼包累计充值数量和充值档次类型的表
function FirstChargeLuxuryGiftModel:getCurrentGiftData(data)
    self.currentGift = data
    self:updataRed()
end

function FirstChargeLuxuryGiftModel:updataRed()
    local itemData = DynamicConfigData.t_ChargeGift
    local dataCfg = self:getBtnRMB()
    local keyArr2 = {}
    for i = 1, 2 do
        local keyArr = {}
        for j = 1, #itemData[dataCfg[i]] do
            table.insert(keyArr, "V_ACTIVITY_" .. GameDef.ActivityType.SecordCharge .. i .. j)
        end
        table.insert(keyArr2, "V_ACTIVITY_" .. GameDef.ActivityType.SecordCharge .. i)
        RedManager.addMap("V_ACTIVITY_" .. GameDef.ActivityType.SecordCharge .. i, keyArr)
    end
    RedManager.addMap("V_ACTIVITY_" .. GameDef.ActivityType.SecordCharge, keyArr2)

    for i = 1, 2 do
        local isRed = false
        for j = 1, #itemData[dataCfg[i]] do
            local data = itemData[dataCfg[i]]
            if self.currentGift.accTypeMap[dataCfg[i]] ~= nil then
                local recvMark = self.currentGift.accTypeMap[dataCfg[i]].recvMark
                local flag = bit.band(recvMark, bit.lshift(1, j - 1)) > 0

                if (not flag) and data[j].dayIndex <= self.currentGift.accTypeMap[dataCfg[i]].dayIndex then
                    if not isRed then
                        isRed = true
                    end
                    RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.SecordCharge .. i .. j, true)
                else
                    RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.SecordCharge .. i .. j, false)
                end
            end
        end
    end
end

function FirstChargeLuxuryGiftModel:isShowCountDowm()
    local isclose = true
    local dataCfg = self:getBtnRMB()
    for key, rmb in pairs(dataCfg) do
        if self.currentGift.count and self.currentGift.count >= rmb then
            isclose = false
        end
    end
    return isclose
end

function FirstChargeLuxuryGiftModel:getBtnRMB()
    local itemData = DynamicConfigData.t_ChargeGift -- 礼包数据
    local dataCfg = {}
    for key, value in pairs(itemData) do
        table.insert(dataCfg, key)
    end
    table.sort(
        dataCfg,
        function(a, b)
            return a < b
        end
    )
    return dataCfg
end

return FirstChargeLuxuryGiftModel
