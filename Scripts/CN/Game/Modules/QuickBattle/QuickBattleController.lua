

local QuickBattleController = class("QuickBattleController",Controller)

function QuickBattleController:Activity_UpdateData(_,params)
    if params.type == GameDef.ActivityType.QuickBattle then
        printTable(1,">>>>>>QuickBattleController QuickBattle>>>>>",params.goldMagic)
        ModelManager.QuickBattleModel:initData(params.goldMagic)
    end
end
return QuickBattleController