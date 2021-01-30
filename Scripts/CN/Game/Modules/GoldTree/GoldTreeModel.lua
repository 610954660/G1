
-- added by zn

local BaseModel = require "Game.FMVC.Core.BaseModel";
local GoldTreeModel = class('GoldTreeModel', BaseModel);

function GoldTreeModel:ctor()
    self.refreshTime = false;
    -- 各档位数据
    self.dataList = false;

    self:initListeners();
end

function GoldTreeModel:GoldTree_InitData(_, param)
    --printTable(1, '======= 摇钱树数据====', param);
    local data = param.goldTree;
    self.refreshTime = data.refreshTimeMs / 1000;
    self.dataList = data.data;
    self:checkRed();
end 

function GoldTreeModel:GoldTree_UpData(_, param)
    -- printTable(1, "======= 摇钱树数据更新 ====", param);
    -- printTable(1, "======= 摇钱树数据更新 ====", param);
    local data = param.goldTree;
    self.refreshTime = data.refreshTimeMs / 1000;
    self.dataList = data.data;
    self:checkRed();
    Dispatcher.dispatchEvent("GoldTree_UpView");
end

-- 获取购买次数
function GoldTreeModel:getBuyCount(idx)
    local data = self.dataList[idx];
    local conf = DynamicConfigData.t_GoldTree[idx];
	if ActivityModel:getActityByType(GameDef.ActivityType.GoldMagic) then
		return (conf.activityNumber + data.storeTimes + (data.privilegeTimes or 0) - data.buyTimes);
	else
		return (conf.number + data.storeTimes + (data.privilegeTimes or 0)  - data.buyTimes);
	end
end

-- function GoldTreeModel:getTotalAward(idx)
--     local cityId,chapterId,pointId = PushMapModel:getMaxCityAndChapterAndPoint();
--     local curLv = DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId].fightfd;
--     -- curLv = math.max(tonumber(curLv) - 1, 0);
--     LuaLogE("==================== 当前关卡 ",cityId, chapterId, pointId, curLv);
--     local conf = DynamicConfigData.t_chaptersPointFightFd[curLv];
--     if (conf) then
--         local goldExpr = conf.greward[1].amount;
--         LuaLogE(goldExpr);
--         local award = goldExpr * DynamicConfigData.t_GoldTree[idx].time
--         return award;
--     end
--     return 0;
-- end

function GoldTreeModel:pushMap_getCurPassPoint(_, param)
    
end

function GoldTreeModel:checkRed()
    -- LuaLogE("========== 摇钱树红点 ============");
    -- print(1, self:getBuyCount(1) > 0);
    RedManager.updateValue("M_GOLDTREE", self:getBuyCount(1) > 0);
end

return GoldTreeModel;