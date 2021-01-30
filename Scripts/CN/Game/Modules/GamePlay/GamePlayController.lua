

local GamePlayController = class('GamePlayController', Controller);

-- function GamePlayController: money_change()
--     LuaLogE("======================================================= GamePlay测试");
-- end

function GamePlayController:GamePlay_UpdateData(_, param)
    --LuaLogE("========= 玩法数据刷新 ===========");
    --printTable(1, param);
    GamePlayModel:upData(param);
end

return GamePlayController;