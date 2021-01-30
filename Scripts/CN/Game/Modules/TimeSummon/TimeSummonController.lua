

local TimeSummonController = class("TimeSummonController",Controller)

function TimeSummonController:Activity_UpdateData(_,params)
    if params.type == GameDef.ActivityType.HeroSummon then
        printTable(8848,">>>>>>params.heroSummon>>>>>",params.heroSummon)
        ModelManager.TimeSummonModel:initData(params.heroSummon)
    end
end
return TimeSummonController