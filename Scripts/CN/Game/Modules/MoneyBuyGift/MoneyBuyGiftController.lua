

local MoneyBuyGiftController = class("MoneyBuyGiftController", Controller)

function MoneyBuyGiftController:Activity_UpdateData(_, param)
    if param.type == GameDef.ActivityType.SaleGiftPack then
        MoneyBuyGiftModel:upBoughtData(param.saleGiftPack.giftPackList);
    end
end

return MoneyBuyGiftController;