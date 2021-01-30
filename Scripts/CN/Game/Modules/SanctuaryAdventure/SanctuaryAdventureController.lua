

local SanctuaryAdventureController = class("SanctuaryAdventureController",Controller)

function SanctuaryAdventureController:Activity_UpdateData(_,params)
    if params.type == GameDef.ActivityType.StarTempleExpedition then
        printTable(8848,">>>>>>params.starTempleExpedition>>>>>",params.starTempleExpedition)
        ModelManager.SanctuaryAdventureModel:initData(params.starTempleExpedition)
    end
end
return SanctuaryAdventureController