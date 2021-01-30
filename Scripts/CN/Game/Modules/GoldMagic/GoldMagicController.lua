

local GoldMagicController = class("GoldMagicController",Controller)

function GoldMagicController:Activity_UpdateData(_,params)
    if params.type == GameDef.ActivityType.GoldMagic then
        printTable(1,">>>>>>GoldMagicController GoldMagic>>>>>",params.goldMagic)
        ModelManager.GoldMagicModel:initData(params.goldMagic)
    end
end
return GoldMagicController