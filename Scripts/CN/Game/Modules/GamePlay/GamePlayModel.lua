

local GamePlayMap = require "Game.Modules.GamePlay.GamePlayMap";
local GamePlayModel = class ('GamePlayModel', BaseModel);

function GamePlayModel:initData(param)
    -- LuaLogE("=================== 玩法数据");
    -- printTable(1, param);
    -- if (param.goldTree) then
        -- GoldTreeModel:GoldTree_InitData(param.goldTree);
        -- Dispatcher.dispatchEvent("GoldTree_InitData", param);
    -- end
    local map = GamePlayMap.IDMap;
    for id in pairs(map) do
        Dispatcher.dispatchEvent(map[id].."_InitData", param);
    end
end

function GamePlayModel:upData(param)
    local map = GamePlayMap.IDMap;
    -- LuaLogE("========= 玩法数据刷新 ===========");
    -- printTable(1, param);
    for id in pairs(map) do
        if (id == param.gamePlayType) then
            -- GoldTreeModel:GoldTree_InitData(param.GoldTree_UpData);
            Dispatcher.dispatchEvent(map[id].."_UpData", param.gp);
        end
    end
end

return GamePlayModel;