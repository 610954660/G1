-- add by zn
-- 公会联赛主界面

local GLNormalMainView = class("GLNormalMainView", Window)

function GLNormalMainView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GLNormalMainView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.actCD = false;
end

function GLNormalMainView:_initUI()
    local root = self
    local rootView = self.view
        root.txt_guildName = rootView:getChildAutoType("txt_guildName"); -- 公会名
        root.txt_rankName = rootView:getChildAutoType("txt_rankName"); -- 段位名
        root.txt_startCount = rootView:getChildAutoType("txt_startCount"); -- 星星数
        root.txt_rank = rootView:getChildAutoType("txt_rank"); -- 排名
        root.txt_normalCount = rootView:getChildAutoType("txt_normalCount"); -- 常规赛胜场
        root.txt_normalRate = rootView:getChildAutoType("txt_normalRate"); -- 常规赛胜率
        root.txt_legendCount = rootView:getChildAutoType("txt_legendCount"); -- 传奇赛胜场
        root.txt_legendRate = rootView:getChildAutoType("txt_legendRate"); -- 传奇赛胜率
        root.txt_cd = rootView:getChildAutoType("txt_cd"); -- 下场比赛CD
        root.txt_defCD = rootView:getChildAutoType("txt_defCD"); -- 我的防守CD
        root.txt_seasonTime = rootView:getChildAutoType("txt_seasonTime"); -- 赛季时间

        root.list_award = rootView:getChildAutoType("list_award"); -- 赛季奖励

        root.icon_guild = rootView:getChildAutoType("icon_guild"); -- 公会标志

        root.btn_check = rootView:getChildAutoType("btn_check");
        root.btn_honor = rootView:getChildAutoType("btn_honor");
        root.btn_award = rootView:getChildAutoType("btn_award");
        root.btn_battle = rootView:getChildAutoType("btn_battle");
        root.btn_rank = rootView:getChildAutoType("btn_rank");
        root.btn_def = rootView:getChildAutoType("btn_def");
        for i = 1, 3 do
            root["role"..i] = rootView:getChildAutoType("role"..i);
        end

        self:_refresh();
end

function GLNormalMainView:_refresh()
	GuildLeagueModel:requestBaseInfo();
end

function GLNormalMainView:_initEvent()
    self.btn_check:addClickListener(function()
        ViewManager.open("GuildLeagueRecordView", {})
    end)
    self.btn_honor:addClickListener(function()
        ViewManager.open("GuildLeagueHonorView")
    end)
    self.btn_award:addClickListener(function()
        if (GuildLeagueModel.boxInfos.rewardStatus == 1) then
            ViewManager.open("GuildLeagueAwardView", {page = 1});
        else
            ViewManager.open("GuildLeagueAwardView");
        end
    end)
    self.btn_battle:addClickListener(function()
        local baseInfo = GuildLeagueModel:getBaseInfo();
        local actStatus = baseInfo.actStatus or 0;
        if (actStatus == GameDef.GuildPvpActStatus.Closed) then
            RollTips.show(Desc.GL_actStatus0)
        else
            ViewManager.open("GuildLeagueFortView");
        end
    end)
    self.btn_rank:addClickListener(function()
        ViewManager.open("GuildLeagueRankView");
    end)
    self.btn_def:addClickListener(function()
        local battleCall = function (param)
            if (param == "begin") then
                local baseInfo = GuildLeagueModel:getBaseInfo();
                local actStatus = baseInfo.actStatus or 0;
                if (actStatus == GameDef.GuildPvpActStatus.Prepare) then
                    RollTips.show(Desc.HigherPvP_saveDefSuc);
                end
                ViewManager.close("BattlePrepareView");
            end
        end
        local fightId = DynamicConfigData.t_GLConst[1].fightId
        local args = {
            fightID = fightId,
            configType= GameDef.BattleArrayType.GuildPvpDef,
        }
        Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args);

        local nextSeasonStamp = GuildLeagueModel:getBaseInfo().nextActStamp or 0;
        local str = FileCacheManager.setStringForKey("GUildLeague_Def", tostring(nextSeasonStamp));
        GuildLeagueModel:checkRed();
    end)

    RedManager.register("V_GuildLeague_challenge",self.btn_battle:getChildAutoType("img_red"));
    RedManager.register("V_GuildLeague_def",self.btn_def:getChildAutoType("img_red"));
    RedManager.register("V_GuildLeague_award",self.btn_award:getChildAutoType("img_red"));
end

function GLNormalMainView:GuildLeague_baseInfoUpdate()
    local baseInfo = GuildLeagueModel:getBaseInfo();
    -- 公会基础信息
    local guildInfo = GuildModel.guildList;
    self.txt_guildName:setText(guildInfo.name);
    -- 段位相关信息
    local glRankConf = DynamicConfigData.t_GLRank
    local conf = glRankConf[baseInfo.scoreRank];-- GuildLeagueModel:getRankConfByScore(baseInfo.score);
    if (conf) then
        -- 段位信息
        local iconUrl = PathConfiger.getRankLevelIcon(conf.res);
        self.icon_guild:setIcon(iconUrl);
        self.txt_rankName:setText(conf.rank);
        if (conf.index == #glRankConf) then
            self.txt_startCount:setText(string.format(Desc.GL_str3..Desc.GL_matchLogStar.."%s/MAX", baseInfo.score));
        else
            self.txt_startCount:setText(string.format(Desc.GL_str3..Desc.GL_matchLogStar.."%s/%s", baseInfo.score, conf.max));
        end
        -- 奖励列表
        local award = conf.seasonReward
        local c1 = self.view:getController("c1");
        c1:setSelectedIndex(#award > 0 and 1 or 0);
        self.list_award:setItemRenderer(function(idx, obj)
            if (not obj.cell) then
                obj.cell = BindManager.bindItemCell(obj);
            end
            local a = award[idx + 1];
            obj.cell:setData(a.code, a.amount, a.type);
        end)
        self.list_award:setNumItems(#award);
    else
        local firstConf = glRankConf[1];
        self.txt_startCount:setText(string.format("%s/%s", baseInfo.score, firstConf.min));
        self.icon_guild:setIcon("");
        self.list_award:setNumItems(0);
        self.txt_rankName:setText(Desc.HigherPvP_NoRankName);
    end
    -- 比赛记录信息
    self.txt_normalCount:setText(baseInfo.winCount); -- 常规赛胜场
    if (baseInfo.totalCount == 0) then
        self.txt_normalRate:setText("0%");
    else
        self.txt_normalRate:setText(string.format("%d%%", math.ceil(baseInfo.winCount / baseInfo.totalCount) * 100)); -- 常规赛胜率
    end
    self.txt_legendCount:setText("0"); -- 传奇赛胜场
    self.txt_legendRate:setText("0%"); -- 传奇赛胜率
    -- 赛季时间
    local seasonStart = baseInfo.seasonStamp;
    local seasonEnd = baseInfo.seasonEndStamp;
    local startMonth = TimeLib.getMonth(seasonStart);
    local startDay = TimeLib.getDay(seasonStart);
    local endMonth = TimeLib.getMonth(seasonEnd);
    local endDay = TimeLib.getDay(seasonEnd);
    self.txt_seasonTime:setText(string.format("%d.%d-%d.%d", startMonth, startDay, endMonth, endDay));

    self:upBtnStatus();
    GuildLeagueModel:getScoreRank(false, false, GameDef.RankType.GuildPvpMatchPlayer);
end

function GLNormalMainView:upBtnStatus()
    local baseInfo = GuildLeagueModel:getBaseInfo();
    local actStatus = baseInfo.actStatus or 0;
    local joinStatus = baseInfo.joinStatus or 0;
    -- 进入据点
    self.btn_battle:setGrayed(true);
    self.btn_battle:setTouchable(false);
    self.btn_battle:setTitle(Desc.GL_actStatus8);
    self.btn_def:setVisible(false);
    -- 倒计时
    if (actStatus ~= GameDef.GuildPvpActStatus.Closed) then -- 比赛当天 且匹配到对手
        if joinStatus == 0 then  -- 未达参赛条件
            self:stopCD();
            self.txt_cd:setText(Desc.GL_actStatus6);
            return;
        elseif joinStatus == 2 then -- 未匹配到选手
            self:stopCD();
            self.txt_cd:setText(Desc.GL_actStatus5);
            return;
        end

        if (actStatus == GameDef.GuildPvpActStatus.Prepare) then -- 准备
            local time = math.ceil(math.abs(baseInfo.statusEndStamp - ServerTimeModel:getServerTimeMS()) / 1000)
            self:starCD(time, Desc.GL_actStatus1);
            -- 我的阵容
            self.btn_def:setVisible(GuildModel.guildHave and GuildLeagueModel.haveQualif and true);
        elseif (actStatus == GameDef.GuildPvpActStatus.Battle) then -- 战斗
            self:stopCD();
            self.txt_cd:setText(Desc.GL_actStatus2);
        elseif (actStatus == GameDef.GuildPvpActStatus.End) then
            self:stopCD();
            self.txt_cd:setText(Desc.GL_actStatus3);
        end
        self.btn_battle:setGrayed(false);
        self.btn_battle:setTouchable(true);
        self.btn_battle:setTitle(Desc.GL_actStatus7);
    else
        local time = math.ceil(math.abs(baseInfo.nextActStamp - ServerTimeModel:getServerTimeMS()) / 1000)
        self:starCD(time, Desc.GL_actStatus4);
    end
end

function GLNormalMainView:starCD(time, formatStr)
    if (not time) then
        return;
    end
    if (self.actCD) then
        TimeLib.clearCountDown(self.actCD);
        self.actCD = false;
    end
    local fmat = function(t)
        if (t > 86400) then
            return TimeLib.GetTimeFormatDay(t);
        else
            return TimeLib.formatTime(t, true);
        end
    end
    local onCD = function(t)
        self.txt_cd:setText(string.format(formatStr, fmat(t)));
    end
    local onEnd = function()
        GuildLeagueModel:requestBaseInfo();
    end
    self.actCD = TimeLib.newCountDown(time, onCD, onEnd, false, false, false);
    self.txt_cd:setText(string.format(formatStr, fmat(time)));
end

function GLNormalMainView:stopCD()
    if (self.actCD) then
        TimeLib.clearCountDown(self.actCD);
        self.actCD = false;
    end
end

function GLNormalMainView:_exit()
    self:stopCD();
end

function GLNormalMainView:GuildLeague_scoreRankUpdate(_, param, extraData)
    local baseInfo = GuildLeagueModel:getBaseInfo();
    if (baseInfo.guildId ~= extraData.guildId or extraData.rankType ~= GameDef.RankType.GuildPvpMatchPlayer) then
        return;
    end
    local data = param and param.rankData or {};
    for i = 1, 3 do
        local obj = self["role"..i];
        local d = data[i];
        local c1 = obj:getController("c1");
        if (d) then
            c1:setSelectedIndex(1);
            local c2 = obj:getController("c2");
            c2:setSelectedIndex(i - 1);
            obj:getChildAutoType("txt_name"):setText(d.name);
            obj:getChildAutoType("txt_lv"):setText("Lv."..d.level);
            -- 模型
            local loader = obj:getChildAutoType("loader_role");
            local configItem=DynamicConfigData.t_hero[d.head]
			if not configItem then
				return
			end
			local  modeId= configItem.model	
			local skeletonNode = SpineMnange.createSprineById(modeId,true,nil,nil,d.fashionId)
			if not skeletonNode then
				return
			end
			loader:displayObject():addChild(skeletonNode);
			skeletonNode:setAnimation(0, "stand", true);
			if loader.spine then
                loader.spine:removeFromParent();
                loader.spine = false;
			end
            loader.spine = skeletonNode;
            local x = loader:getWidth() / 2;
            skeletonNode:setPosition(x, 0);
        else
            c1:setSelectedIndex(0);
        end
    end
end


return GLNormalMainView