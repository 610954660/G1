-- add by zn
-- description

local DressRechargeModel = class("DressRechargeModel", BaseModel)

function DressRechargeModel:ctor()
    self:initListeners()
    self.data = false;
end

function DressRechargeModel:Activity_UpdateData(_, params)
    if params.type ~= GameDef.ActivityType.FashionCharge then
        return;
    end
    self.data = params
end

return DressRechargeModel