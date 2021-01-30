

local LStarAwakeningController = class("LStarAwakeningController",Controller)

function LStarAwakeningController:Activity_UpdateData(_,params)
    if params.type == GameDef.ActivityType.HeroStarLevel then
        printTable(1,">>>>>>params.heroStarLevel>>>>>",params.heroStarLevel)
        ModelManager.LStarAwakeningModel:initData(params.heroStarLevel)
    end
end
return LStarAwakeningController