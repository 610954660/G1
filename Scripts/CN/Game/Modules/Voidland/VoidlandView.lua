--[[
    name: VoidlandView
    author: zn
]]

local VoidlandView = class("VoidlandView", Window)

function VoidlandView:ctor()
    self._packName = "Voidland";
    self._compName = "VoidlandView";
    -- self._rootDepth = LayerDepth.PopWindow
    self.data = false; -- 一种模式下的所有配置
    self.curPointInfo = false; -- 当前关卡配置信息
    -- self.result = false; -- 战斗结果
    -- self.isFirst = false; -- 首通
    -- self.rewards = {}; -- 战斗奖励
    self.todayMode = VoidlandModel:todayMode();
    -- self.isFighting = false;
    -- self.needOutFight = false;
    VoidlandModel:getVoidlandInfo();
    
end

function VoidlandView:_initUI()
    local root = self;
    local rootView = self.view;
        root.list_mode = rootView:getChildAutoType("list_mode");
        root.list_checkPoints = rootView:getChildAutoType("list_checkPoints");
        root.btn_start = rootView:getChildAutoType("btn_start");
        root.btn_reward = rootView:getChildAutoType("btn_reward");
        root.btn_ass = rootView:getChildAutoType("btn_ass");
        root.btn_rank = rootView:getChildAutoType("btn_rank");
        root.btn_shop = rootView:getChildAutoType("btn_shop");
        root.btn_help = rootView:getChildAutoType("btn_help");
        root.txt_modeDesc = rootView:getChildAutoType("txt_modeDesc");
        root.txt_curPoint = rootView:getChildAutoType("txt_curPoint");
        for i = 1, 3 do
            root["btn_award"..i] = rootView:getChildAutoType("btn_award"..i);
        end
        root.progress = rootView:getChildAutoType("progress");
        root.txt_recom = rootView:getChildAutoType("txt_recom");
        root.txt_recomPower = rootView:getChildAutoType("txt_recomPower");
        root.list_recom = rootView:getChildAutoType("list_recom");
        root.list_rank = rootView:getChildAutoType("list_rank");

        self:setBg("voidlandbg.jpg");
end

function VoidlandView:_initEvent()
    VoidlandModel.modeType = VoidlandModel:todayMode()
    self.list_mode:setSelectedIndex(VoidlandModel.modeType - 1);
    self.list_mode:addClickListener(function()
        VoidlandModel.modeType = self.list_mode:getSelectedIndex() + 1;
        self:Voidland_infoUpdate();
        self:upRecomPanel();
    end)
    self.list_checkPoints:setItemRenderer(function(idx, obj)
        self:upCheckPoints(idx, obj);
    end)
    self.list_checkPoints:addClickListener(function ()
        self:upRightInfos();
        self:upRecomPanel();
    end)
    -- self.list_checkPoints:setVirtual();

    self.btn_start:addClickListener(function()
        if (self.todayMode ~= self.list_mode:getSelectedIndex() + 1) then -- 模式不一致
            RollTips.show(string.format(Desc.Voidland_errMode, Desc["Voidland_mode"..self.todayMode]));
        elseif (self.list_checkPoints:getSelectedIndex() + 1 < self.curPointInfo.nodeId 
                or (VoidlandModel:getCurModeData().id >= VoidlandModel:getAllWave())) then
            RollTips.show(Desc.Voidland_passed);
        elseif (self.list_checkPoints:getSelectedIndex() + 1 > self.curPointInfo.nodeId) then
            RollTips.show(Desc.Voidland_locked);
        else
            VoidlandModel:battleBegin();
        end
    end)

    self.btn_help:addClickListener(function ()
        RollTips.showHelp(Desc.help_StrTitle132, Desc.help_StrDesc132);
    end)

    self.btn_reward:addClickListener(function()
        ViewManager.open("VoidlandRewardView");
    end)

    self.btn_ass:addClickListener(function()
        ViewManager.open("VoidlandAssView");
    end)

    self.btn_rank:addClickListener(function()
        local type = VoidlandModel.modeType == 1 and GameDef.RankType.DreamLandSingle or GameDef.RankType.DreamLandMultiple
        ViewManager.open("VoidlandRankView", {type = type});
    end)

    self.btn_shop:addClickListener(function()
        -- VoidlandModel.eventId = 301
        -- VoidlandModel.skillSelect = {110001, 110002, 110002}
        -- ViewManager.open("VoidlandSkillView");
        -- local info = {
        -- 	result = true,
        -- 	rewardList = {},
        -- 	id = 6,
        -- 	-- isFirst = self.isFirst,
        -- }
        -- ViewManager.open("ReWardView",{page=6, data=info, isWin=info.result})
    end)

    self.list_rank:setItemRenderer(function(idx, obj)
        obj:getController("c2"):setSelectedIndex(0);
        obj:getController("c1"):setSelectedIndex(idx);
    end)
    self.list_rank:setNumItems(3);

    
    VoidlandModel:getRankInfo();
	VoidlandModel:checkEnterWindow();
end

function VoidlandView:_addRed()
    -- body
    RedManager.register("V_VOIDLAND_AWARD", self.btn_reward:getChildAutoType("img_red"));
end

function VoidlandView:Voidland_infoUpdate(_, param)
    -- if (param == "CrossDay" and VoidlandModel.isFighting) then
    --     VoidlandModel.needOutFight = true;
    -- end
    self.todayMode = VoidlandModel:todayMode(); -- 今日开启的模式
    self.curPointInfo = VoidlandModel:getPointInfoById();
    self.data = VoidlandModel:getAllConfByPoint();
    if (not self.curPointInfo) then
        self.curPointInfo = self.data[1][1];
    end
    self.list_checkPoints:setNumItems(#self.data);
    if (param ~= "award" and self.todayMode == self.list_mode:getSelectedIndex() + 1) then
        self.list_checkPoints:setSelectedIndex(self.curPointInfo.nodeId - 1);
        self.list_checkPoints:scrollToView(self.curPointInfo.nodeId - 1, true);
        self:upRecomPanel();
    end
    VoidlandModel:getRankInfo();
    self:upRightInfos();
end

-- 更新关卡列表
function VoidlandView:upCheckPoints(idx, obj)
    local ctrl = obj:getController("c1");
    local txt_point = obj:getChildAutoType("point");
    local txt_curWave = obj:getChildAutoType("curWave");
    local curPointConf = self.data[idx + 1];
    local allWave = #curPointConf;
    local npc = false;
    if (curPointConf[1].nodeId == self.curPointInfo.nodeId) then
        npc = self.curPointInfo.npc
    elseif (curPointConf[1].nodeId < self.curPointInfo.nodeId) then
        npc = curPointConf[allWave].npc;
    else
        npc = curPointConf[1].npc;
    end
    local npcHead = obj:getChildAutoType("head/icon");
    npcHead:setIcon(PathConfiger.getHeroCardex(npc));
    txt_point:setText(string.format(Desc.Voidland_lv, idx + 1));
    
    if (self.curPointInfo.nodeId > idx + 1) then  -- 已通关
        ctrl:setSelectedIndex(2);
        txt_curWave:setText(string.format("%d/%d", allWave, allWave));
    elseif (VoidlandModel.modeType ~= self.todayMode) then  -- 未开启
        ctrl:setSelectedIndex(3);
    elseif (self.curPointInfo.nodeId == idx + 1) then  -- 当前挑战
        local curId = VoidlandModel:getCurModeData().id;
        if (VoidlandModel:getCurModeData().id >= VoidlandModel:getAllWave()) then
            ctrl:setSelectedIndex(2);
        else
            ctrl:setSelectedIndex(1);
        end
        txt_curWave:setText(string.format("%d/%d", self.curPointInfo.index, allWave));
    else  -- 未解锁
        ctrl:setSelectedIndex(0);
    end

    local img_red = obj:getChildAutoType("img_red");
    local str = "V_VOIDLAND_AWARD_"..VoidlandModel.modeType..(idx+1);
    RedManager.register("V_VOIDLAND_AWARD_"..VoidlandModel.modeType..(idx+1), img_red);
end

-- 更新右侧信息
function VoidlandView:upRightInfos()
    local idx = self.list_checkPoints:getSelectedIndex() + 1
    local mode = VoidlandModel.modeType
    self.txt_modeDesc:setText(Desc["Voidland_modeDesc"..mode]);
    self.txt_curPoint:setText(idx);
    self:upRewardPanel();
end

function VoidlandView: upRewardPanel()
    local idx = self.list_checkPoints:getSelectedIndex() + 1
    local mode = VoidlandModel.modeType
    -- local maxId = VoidlandModel:getCurModeData().maxId;
    -- local pointConf = VoidlandModel:getAllConfByPoint()[idx];
    local awardConf = VoidlandModel:getPassRewardByPoint(idx);
    local finishCount = 0;
    if (awardConf) then
        -- 更新奖励
        for i = 1, 3 do
            local obj = self["btn_award"..i];
            if (not obj.itemCell) then
                obj.itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
            end
            local data = awardConf[i];
            local award = data.passReward;
            obj.itemCell.frameLoader:setVisible(false);
            obj.itemCell:setAmountVisible(false);
            obj.itemCell:setData(award.code, award.amount, award.type);
            obj:getChildAutoType("txt_num"):setText(award.amount);
            local state = VoidlandModel:getPassRewardState(data.id);
            obj.itemCell:setReceiveFrame(state == 1)
            obj.itemCell:setIsHook(state == 2)
            obj.itemCell:setClickable(state == 0);
            if (state ~= 0) then
                finishCount = finishCount + 1;
            end
            obj:getChildAutoType("point"):setText(string.format(Desc.Voidland_point3, data.index));
            obj:removeClickListener(222)
            obj:addClickListener(function()
                if (state == 1) then
                    VoidlandModel:getPassReward(data.id, mode);
                end
            end, 222)
        end
    end
    self.progress:setMax(3);
    self.progress:setValue(finishCount);
    -- local first = pointConf[1];
    -- local last = pointConf[#pointConf];
    -- self.progress:setMax(last.id - first.id + 1);
    -- self.progress:setValue(math.min(maxId - first.id, last.id - first.id + 1));
end

function VoidlandView: upRecomPanel()
    local idx = self.list_checkPoints:getSelectedIndex() + 1
    -- local curPointConf = VoidlandModel:getAllConfByPoint()[idx];
    local curPointConf = self.data[idx];
    local allWave = #curPointConf;
    local conf = false;
    if (curPointConf[1].nodeId == self.curPointInfo.nodeId) then
        conf = self.curPointInfo
    elseif (curPointConf[1].nodeId < self.curPointInfo.nodeId) then
        conf = curPointConf[allWave];
    else
        conf = curPointConf[1];
    end
    if (conf) then
        local pointConf = conf;
        local team = pointConf.team;
        self.txt_recom:setText(pointConf.desc);
        self.txt_recomPower:setText(StringUtil.transValue(pointConf.combat or 0));

        -- 展示英雄图鉴配置
        local heroList = {};
        local arr = {};
        for idx, code in ipairs(team) do
            arr[code] = {idx = idx, code = code};
        end
        for _, heroArr in pairs(DynamicConfigData.t_HeroTotems) do
            for _, d in pairs(heroArr) do
                local c = arr[d.hero]
                if (c) then
                    heroList[c.idx] = d;
                end
            end
        end

        self.list_recom:setItemRenderer(function(idx, obj)
            if (not obj.heroCell) then
                obj.heroCell = BindManager.bindHeroCell(obj);
            end
            local code = team[idx + 1]
            local conf = DynamicConfigData.t_hero[code];
            local info = {
                code = code,
                star = conf.heroStar,
                category = conf.category,
                level = 1
            }
            obj.heroCell:setBaseData(info);
            obj.heroCell.level:setVisible(false);
            obj:getChildAutoType("n56"):setVisible(false);
            obj:removeClickListener();
            obj:addClickListener(function ()
                ViewManager.open("HeroInfoView",{index = idx+1,heroId = code,heroList = heroList})
            end)
        end)
        self.list_recom:setNumItems(#team);
    end
end

function VoidlandView:voidland_updateRank(_, data)
    local rankData = data or {};
    local children = self.list_rank:getChildren();
    -- printTable(2233, "============voidland_updateRank", rankData);
    for i = 1, 3 do
        local obj = children[i];
        local ctrl = obj:getController("c2")
        local d = rankData[i]
        if (not d) then
            ctrl:setSelectedIndex(0);
        else
            ctrl:setSelectedIndex(1);
            obj:getChildAutoType("txt_name"):setText(d.name);
            local conf = VoidlandModel:getPointInfoById(d.value);
            obj:getChildAutoType("txt_point"):setText(string.format(Desc.Voidland_point2, conf.nodeId, conf.index))
        end
    end
end

function VoidlandView:_exit()
    -- body
end

return VoidlandView