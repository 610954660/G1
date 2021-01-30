-- added by zn
-- 委托任务
local TimeLib = require "Game.Utils.TimeLib";
local BaseModel = require "Game.FMVC.Core.BaseModel";
local DelegateConfiger = require "Game.ConfigReaders.DelegateConfiger";
local DelegateModel = class("DelegateModel", BaseModel);

function DelegateModel:ctor()
    -- 任务列表
    self.taskList = false;
    -- 可上阵英雄列表
    self.heroList = false;
    -- 显示的英雄列表
    self.showHeroList = false;
    -- 显示的英雄种族
    self.category = false;
    -- 上阵位置列表
    self.waitList = {};
    -- 剩余免费次数
    self.freeCount = false;
    -- 任务选中位置
    self.curIdx = false;
    -- 记录位置
    self.preList = {};
    -- 防止弱网多次请求
    self.refreshFlag = false;
    
    self.timer = false;
    
    self:initListeners();
end
---------------------------------------------- 任务部分 ----------------------------------

function DelegateModel:getTaskData(cb)
    local function success(param) 
        self:setTaskData(param.data);
        if (cb) then cb() end;
    end
    RPCReq.Delegate_GetInfo({}, success);
end

-- 初始化委托信息  -- sortList 是否排序
function DelegateModel:setTaskData(data, sortList)
    sortList = sortList == nil and true or sortList;
    if (sortList) then
        self.taskList = data.taskRecord;
    else
        for idx in pairs(data.taskRecord) do
            local task = self.taskList[self:getCurIdx(idx)];
            local newTask = data.taskRecord[idx];
            if (task) then
                task.finishState = newTask.finishState;
                task.endTimeMs = newTask.endTimeMs;
                task.heroRecord = newTask.heroRecord;
            end
        end
    end
    self.freeCount = data.freeTimes;
    self:sortTaskList(sortList);
    local defaultIdx = self.taskList[1] and self.taskList[1].idx or 0;
    if (sortList) then
        self.curIdx = defaultIdx;
    else
        self.curIdx = self.taskList[self:getCurIdx()] and self.curIdx or defaultIdx;
    end
    self:checkTaskRed();
    self:money_change();
    Dispatcher.dispatchEvent("delegate_upTaskList", sortList);
end

-- 任务排序
function DelegateModel:sortTaskList(sort)
    -- 补充添加任务品质信息
    for idx in pairs(self.taskList) do
        local info = self.taskList[idx];
        local conf = DelegateConfiger.getConfByID(info.id);
        info.color = conf and conf.color or 0;
        info.idx = info.idx or idx;
    end
    self:upTaskStatus();
    if (sort) then
        self.taskList = TableUtil.sortByMap(self.taskList, {{key = "status", asc = true}, {key = "color", asc = true}, {key = "id", asc = false}});
    end
    -- 剔除已完成任务
    local idx = 1;
    self.preList = {};
    while idx <= #self.taskList do
        if (self.taskList[idx] and self.taskList[idx].finishState == true) then
            table.remove(self.taskList, idx);
        else
            self.preList[idx] = self.taskList[idx].idx;
            idx = idx + 1;
        end
    end
end

-- 根据数据获取任务状态  0 已完成已领取 2 未领取 1 进行中 3 可领奖 序号方便显示排序
function DelegateModel:upTaskStatus()
    local serverTime = ServerTimeModel:getServerTimeMS();
    local shortest = 0;
    for idx in pairs(self.taskList) do
        local info = self.taskList[idx];
        info.status = 0;
        if (info.endTimeMs == 0) then -- 任务未领取
            info.status = 2;
        elseif (info.endTimeMs > serverTime) then -- 进行中
            info.status = 1;
            if (shortest <= 0) then
                shortest = info.endTimeMs - serverTime;
            else
                shortest = math.min(info.endTimeMs - serverTime, shortest);
            end
        elseif info.finishState == false then -- 待领奖
            info.status = 3;
        end
    end

    if (shortest > 0) then
        if (self.timer) then
            TimeLib.clearCountDown(self.timer);
        end
        local function onEnd()
            self:upTaskStatus();
            self:checkTaskRed();
        end
        self.timer = TimeLib.newCountDown(shortest / 1000, function() end, onEnd)
    end
end

-- 是否存在高级任务为领取 -紫色及以上 >= 4
function DelegateModel:existHighLvTask()
    for _, task in ipairs(self.taskList) do
        if ((task.color >= 4) and (task.status == 2)) then
            return true;
        end
    end
    return false;
end

---------------------------------------------- 派遣部分 ----------------------------------

-- 获取可派遣英雄
function DelegateModel:getHeroData()
    local function success(param)
        self:setHeroList(param.data);
    end
    RPCReq.Delegate_GetHero({}, success);
end

function DelegateModel:setHeroList(list)
    self.heroList = {};
    for _, v in pairs(list) do
        table.insert(self.heroList, v);
    end
    self:sortHeroList();
end

function DelegateModel:existInWait(data)
    for i = 1, 3 do
        if (self.waitList[i] and self.waitList[i].uuid == data.uuid) then
            return true;
        end
    end
    return false;
end

-- 添加待派遣 
function DelegateModel:addToWait(arg, showTips)
    showTips = showTips == nil and true or false;
    local data = false;
    if (type(arg) == "number") then
        data = self.showHeroList[arg];
    elseif (type(arg) == 'table') then
        data = arg;
    end
    local flag = false;
    for i = 1, 3 do
        if (self.waitList[i] and self.waitList[i].uuid == data.uuid) then
            flag = true;
            break;
        end
    end
    if (not flag) then
        local full = true;
        for i = 1, 3 do
            if (not self.waitList[i]) then
                full = false;
                self.waitList[i] = data;
                break;
            end
        end
        if full then
            RollTips.show(Desc.delegate_noPlace);
            return false;
        end
    end
    Dispatcher.dispatchEvent(EventType.delegate_upWaitList);
    return true;
end

-- 移除待派遣
function DelegateModel:removeFromWait(uuid)
    for idx = 1, 3 do
        if (self.waitList[idx] and self.waitList[idx].uuid == uuid) then
            self.waitList[idx] = nil;
            Dispatcher.dispatchEvent(EventType.delegate_upWaitList);
            -- table.remove(self.waitList, idx);
            return;
        end
    end
end

-- 清除待派遣
function DelegateModel:clearWait()
    self.waitList = {};
    Dispatcher.dispatchEvent(EventType.delegate_upWaitList);
end

-- 检查是否满足派遣要求
-- @return flag, starFlag , cateFlag
-- @desc flag -> boolean 是否满足条件总的结果; starFlag -> {true, false, ..} 配置中星级条件单项是否满足  cateFlag -> {true, false, ..} 同前，职业条件
function DelegateModel:checkCondition()
    -- 没有选择的直接返回
    if #self.waitList == 0 then
        return false, {}, {};
    end

    local task = self.taskList[self:getCurIdx()];
    local conf = DelegateConfiger.getConfByID(task.id);
    local starReqList = conf.starRequire;
    local categoryReqList = conf.categoryRequire;
    local starFlag = {};
    local cateFlag = {};
    local flag = true;
    -- 判断星级条件满足情况
    local copyArr = TableUtil.Clone(self.waitList);
    for _, c in ipairs(starReqList) do
        local count = c.amount;
        local f = false
        for idx, hero in pairs(copyArr) do
            if (hero.star >= c.param) then
                count = count - 1;
                table.remove(copyArr, idx);
            end
        end
        if (count <= 0) then
            table.insert(starFlag, true);
        else
            table.insert(starFlag, false);
            flag = false;
        end
    end
    -- 判断职业条件满足情况
    copyArr = TableUtil.Clone(self.waitList);
    for _, c in ipairs(categoryReqList) do
        local count = c.amount;
        for idx, hero in pairs(copyArr) do
            local category = hero.category;
            -- LuaLog("==========", category);
            if (not category) then
                category = DynamicConfigData.t_hero[hero.code].category;
            end
            if (category == c.param) then
                count = count - 1;
                table.remove(copyArr, idx);
            end
        end
        if (count <= 0) then
            table.insert(cateFlag, true);
        else
            table.insert(cateFlag, false);
            flag = false;
        end
    end
    return flag, starFlag, cateFlag;
end

-- 获取快速上阵推荐列表
function DelegateModel:getRecomList()
    self:clearWait();
    -- 没有列表提示无推荐
    -- 有阵容依次调用addToWait();
    local task = self.taskList[self:getCurIdx()];
    local conf = DelegateConfiger.getConfByID(task.id);
    local starReqList = TableUtil.deepcopyForkeyValue(conf.starRequire);
    local categoryReqList = TableUtil.deepcopyForkeyValue(conf.categoryRequire);   -- 添加满足条件数量标签 倒序排序

    -- A、给待上阵英雄打上条件筛选标签
    local sortedList = self:addRecommendFlag(starReqList, categoryReqList);
    -- B、添加到推荐列
    

    for _, c in ipairs(starReqList) do -- 条件情况
        local arr = self:getHeroByLimit(sortedList, "star", c.param); -- 根据条件筛选出来的英雄
        TableUtil.sortByMap(arr, {{key = "recommend", asc = true}, {key = "category", asc = false}, {key = "star", asc = false}})
        for i = 1, c.amount do -- 该条件需要的数量
            if (#arr > 0) then
                local hero = table.remove(arr, 1);
                if (self:addToWait(hero, false) == false) then
                    self:clearWait();
                    return false;
                end
                if (hero.recommend == 2) then -- 另一个条件不用再添加
                    table.remove(categoryReqList, hero.categoryReq);
                end
            end
        end
    end

    for _, c in ipairs(categoryReqList) do -- 条件情况
        local arr = self:getHeroByLimit(sortedList, "category", c.param); -- 根据条件筛选出来的英雄
        TableUtil.sortByMap(arr, {{key = "recommend", asc = false}, {key = "category", asc = false}, {key = "star", asc = false}})
        for i = 1, c.amount do -- 该条件需要的数量
            if (#arr > 0) then
                local hero = table.remove(arr, 1);
                if (self:addToWait(hero, false) == false) then
                    self:clearWait();
                    return false;
                end
                -- if (hero.recommend == 2) then -- 另一个条件不用再添加
                    -- for i in ipairs(starReqList) do
                    --     if (starReqList[i].param == hero.star) then
                    --         starReqList[i].amount = starReqList[i].amount - 1;
                    --     end
                    -- end
                -- end
            end
        end
    end

    return self:checkCondition();
end

-- 添加推荐筛选标签(脚本内部使用)
function DelegateModel:addRecommendFlag(starReqList, categoryReqList)
    local list = TableUtil.Clone(self.heroList);
    TableUtil.sortByMap(starReqList, {{key = "param", asc = true}});
    for idx1 in ipairs(list) do
        local hero = list[idx1];
        local count = 0;
        -- A.1、满足的星级条件
        for idx2, c in ipairs(starReqList) do
            if (c.param <= hero.star) then
                hero.starReq = idx2;
                count = count + 1;
                break;
            end
        end
        -- A.2、满足的种族条件
        for idx2, c in ipairs(categoryReqList) do
            if (c.param == hero.category) then
                hero.categoryReq = idx2;
                count = count + 1;
                break;
            end
        end
        hero.recommend = count;
    end
    TableUtil.sortByMap(list, {{key = "recommend", asc = true}});
    return list;
end

-- 根据条件获取英雄
function DelegateModel:getHeroByLimit(list, limitKey, limitParam)
    local arr = {};
    for _, hero in ipairs(list) do
        if (limitKey == "star" and hero.star >= limitParam) then
            table.insert(arr, hero);
        elseif (limitKey == "category" and hero.category == limitParam) then
            table.insert(arr, hero);
        end
    end
    return arr;
end

-- 英雄上阵列表排序 -- 星级降序 种族升序 等级降序
function DelegateModel:sortHeroList()
    -- 给列表添加种族参数
    local conf = DynamicConfigData.t_hero;
    for idx in ipairs(self.heroList) do
        local hero = self.heroList[idx];
        hero.category = conf[hero.code].category;
    end
    TableUtil.sortByMap(self.heroList, {{key = "star", asc = true}, {key = "category", asc = false}, {key = "level", asc = true}});
end

-- 根据显示种类分类 0 显示全部
function DelegateModel:upShowListByCategory(category)
    self.category = category;
    if (category == 0) then
        self.showHeroList = self.heroList;
    else
        self.showHeroList = {};
        for _, hero in ipairs(self.heroList) do
            if (hero.category == category) then
                table.insert(self.showHeroList, hero);
            end
        end
    end
end

function DelegateModel:rebuildStruct(data)
    local conf = DynamicConfigData.t_hero[data.code];
    return {
        heroDataConfiger = {
            heroId = data.code,
            heroName = conf.name,
            category = conf.category
        },
        level = data.level,
        star = data.star,
    }
end

function DelegateModel:getCurIdx(index)
    index = index == nil and self.curIdx or index
    for i in pairs(self.taskList) do
        if (self.taskList[i].idx == index) then
            return i;
        end
    end
end

function DelegateModel:setCurIdx(showIdx)
    if (not self.taskList or #self.taskList == 0) then
        return;
    end
    self.curIdx = self.taskList[showIdx].idx;
    self:clearWait();
end

-- 开始派遣
function DelegateModel:starTask(cb)
    local count = ModelManager.PlayerModel:getMoneyByType(9);
    if (count < 1000) then
        ViewManager.open("ItemNotEnoughView", {type = CodeType.MONEY, code = 9, amount=1, callFunc = function ()
            ViewManager.close("DelegateView");
            if ViewManager.isShow("DelegateHeroChoseView") then
                ViewManager.close("DelegateHeroChoseView");
            end
        end})
    else
        local flag = self:checkCondition();
        if (flag ~= true) then
            RollTips.show(Desc.delegate_notSatisfied);
        else
            local heroList = {};
            for idx in pairs(self.waitList) do
                local d = self.waitList[idx];
                if (d) then
                    table.insert(heroList, d.uuid);
                end
            end
            local info = {
                index = self.curIdx,
                heroList = heroList,
            }
            local function success(param)
                self:setTaskData(param.data, false);
                self:getHeroData();
                if (cb) then cb() end;
            end
            RPCReq.Delegate_Start(info, success);
        end
    end
end

function DelegateModel:checkTaskRed()
    local map = {};
    for i = 1, #self.taskList do
        table.insert(map, "V_DELEGATETASK"..i);
    end
    RedManager.addMap("V_DELEGATE", map);
    for idx in ipairs(self.taskList) do
        RedManager.updateValue("V_DELEGATETASK"..idx, self.taskList[idx] and self.taskList[idx].status == 3);
    end
    self:upBtnRed();
end

function DelegateModel:upBtnRed()
    if (not self.taskList or (#self.taskList == 0)) then
        RedManager.updateValue("V_BTN_GETONE", false);
        return;
    end
    RedManager.updateValue("V_BTN_GETONE",self.taskList[self:getCurIdx()] and  self.taskList[self:getCurIdx()].status == 3);
end

function DelegateModel:money_change()
    local have = ModelManager.PlayerModel:getMoneyByType(9);
    local max = DelegateConfiger.getMaxPointByLevel(tonumber(PlayerModel.level));
    local flag = RedManager.getTips("V_DELEGATE");
    RedManager.updateValue("V_DELEGATE", (have >= max) or flag);
end

-- 是否超过上限  return false 没超过  number 超过的具体值
function DelegateModel:beyondPointMax(addVal)
    local have = ModelManager.PlayerModel:getMoneyByType(9);
    local max = DelegateConfiger.getMaxPointByLevel(tonumber(PlayerModel.level));
    return (have + addVal) > max and (have + addVal) - max or false;
end

return DelegateModel;

--[[ 
    1、根据种族获取  返回列表
    2、根据星级获取  返回列表
    3、
 ]]