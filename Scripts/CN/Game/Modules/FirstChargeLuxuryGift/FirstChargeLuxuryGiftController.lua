local FirstChargeLuxuryGiftController = class("FirstChargeLuxuryGiftController", Controller)

function FirstChargeLuxuryGiftController:Activity_UpdateData(_, param)
    printTable(153, "首次充值豪礼", param)
    -- printTable(999,"Activity_UpdateData首充礼包",params)
    if param.type == GameDef.ActivityType.SecordCharge then
        if param.endState then
            ActivityModel:speDeleteSeverData(param.type)
        end
        FirstChargeLuxuryGiftModel:getCurrentGiftData(param.secordCharge)
        ModelManager.ActivityModel:refresh()
        Dispatcher.dispatchEvent(EventType.FirstChargeGift_upGiftData)
    end
end

function FirstChargeLuxuryGiftController:FirstChargeGift_upGiftclose(_, param)
    local serverInfo = FirstChargeLuxuryGiftModel.currentGift
    if serverInfo and serverInfo.isShow then
        local isclose = FirstChargeLuxuryGiftModel:isShowCountDowm()
        if isclose == true then
            serverInfo.isShow = false
        end
        ModelManager.ActivityModel:refresh()
    end
end

return FirstChargeLuxuryGiftController
