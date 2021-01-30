

local ActHeroGatherController = class("ActHeroGatherController",Controller)

function ActHeroGatherController:Activity_UpdateData(_,params)
    if params.type == GameDef.ActivityType.HeroCollection then
        printTable(1,">>>>>>ActHeroGatherController HeroCollection>>>>>",params.heroCollection)
        ModelManager.ActHeroGatherModel:initData(params.heroCollection)
    end
end
return ActHeroGatherController