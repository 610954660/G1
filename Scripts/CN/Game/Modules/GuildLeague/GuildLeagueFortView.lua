-- add by zn
-- 公会联赛据点

local FortList = require "Game.Modules.GuildLeague.GLFortListView";
local GuildLeagueFortView = class("GuildLeagueFortView", Window)

function GuildLeagueFortView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GuildLeagueFortView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.progValMap = {};
    self.isInited = false;
    self.actCD = false;
    self.guildId = false;
end

function GuildLeagueFortView:_initUI()
    local root = self
    local rootView = self.view
        root.fortList = FortList.new(rootView:getChildAutoType("fortList")); -- 据点
        root.btn_def = rootView:getChildAutoType("btn_def"); -- 我的防守
        root.progressItem = rootView:getChildAutoType("progress");
            root.bar = root.progressItem:getChildAutoType("gress");
            for i = 1, 6 do
                root["barFlag"..i] = root.progressItem:getChildAutoType("item"..i);
            end
        root.btn_award = rootView:getChildAutoType("btn_award"); -- 奖励
        root.btn_log = rootView:getChildAutoType("btn_log"); -- 日志
        root.btn_lib = rootView:getChildAutoType("btn_lib"); -- 宝库
        root.btn_self = rootView:getChildAutoType("btn_self");
        root.btn_enemy = rootView:getChildAutoType("btn_enemy");
        root.btn_rank = rootView:getChildAutoType("rankPanel"); -- 排行
        root.list_rank = self.btn_rank:getChildAutoType("list_rank");
        root.skillIcon = rootView:getChildAutoType("skillIcon"); -- 公会技能图标
        root.skillCount = rootView:getChildAutoType("skillCount");
        root.txt_cd = rootView:getChildAutoType("txt_cd");

        GuildLeagueModel:requestMatchInfo()
        self:initViewInfo();
end

function GuildLeagueFortView:_initEvent()
    self.btn_enemy:addClickListener(function()
        self.guildId = GuildLeagueModel.enemyGuildInfo and GuildLeagueModel.enemyGuildInfo.guildId or 0;
        self.fortList:refreashWithData(GuildLeagueModel:getEnemyGuildPlayerInfo());
        GuildLeagueModel:getScoreRank(self.guildId)
    end)
    self.btn_self:addClickListener(function()
        self.guildId = GuildLeagueModel.selfGuildInfo and GuildLeagueModel.selfGuildInfo.guildId or 0;
        self.fortList:refreashWithData(GuildLeagueModel:getSelfGuildPlayerInfo());
        GuildLeagueModel:getScoreRank(self.guildId)
    end)
    self.btn_award:addClickListener(function()
        if (GuildLeagueModel.boxInfos.rewardStatus == 1) then
            ViewManager.open("GuildLeagueAwardView", {page = 1});
        else
            ViewManager.open("GuildLeagueAwardView");
        end
    end)
    self.btn_log:addClickListener(function()
        ViewManager.open("GuildLeagueLogView");
    end)
    self.btn_rank:addClickListener(function()
        ViewManager.open("GuildLeagueHonorView");
    end)
    self.progressItem:addClickListener(function()
        ViewManager.open("GuildLeagueAwardView", {page = 2});
    end)
    self.btn_lib:addClickListener(function ()
        ViewManager.open("GuildLeagueTreasureView");
    end)

    self.btn_def:addClickListener(function()
        local baseInfo = GuildLeagueModel:getBaseInfo();
        local actStatus = baseInfo.actStatus or 0;
        if (actStatus ~= GameDef.GuildPvpActStatus.Prepare) then
            RollTips.show(Desc.GL_str1);
            return;
        end
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

    self.btn_help:removeClickListener();
    self.btn_help:addClickListener(function()
        local info={}
        info['title']=Desc["help_StrTitle"..ModuleId.GuildLeague.id]
        info['desc']=Desc["help_StrDesc"..ModuleId.GuildLeague.id]
        ViewManager.open("GetPublicHelpView",info) 
    end)

    
    RedManager.register("V_GuildLeague_def",self.btn_def:getChildAutoType("img_red"));
    RedManager.register("V_GuildLeague_award",self.btn_award:getChildAutoType("img_red"));


    self._closeBtn:removeClickListener();
    self._closeBtn:addClickListener(function()
        ViewManager.open("GuildLeagueMainView");
        self:closeView();
    end)
end

function GuildLeagueFortView:initViewInfo()
    -- self.fortList:refreashWithData(GuildLeagueModel:getSelfGuildPlayerInfo());
    self:initProgress();
    self:initGuildSkill();
end

function GuildLeagueFortView:initProgress()
    local conf = DynamicConfigData.t_GLRank;
    local infoArr = {1, 4, 7, 10, 13, 16}
    -- local max = 0;
    local len = #infoArr
    for i = 1, len do
        local id = infoArr[i];
        local c = conf[id];
        -- if (i == len) then
        --     max = c.min;
        -- end
        local min = c.min;
        local item = self["barFlag"..i];
        local height = item:getParent():getHeight()
        local y = height * ((len - i) / len);
        item:setY(y);
        item:setTitle(c.rank);
        item:setIcon(PathConfiger.getRankLevelIcon(c.res));
        item:getChildAutoType("value"):setText(min);
        table.insert(self.progValMap, min)
    end
    self.bar:setMax(1);
end

function GuildLeagueFortView:initGuildSkill()
    local conf = DynamicConfigData.t_GLConst[1];
    local skillId = conf.skillId;
    local skillConf = DynamicConfigData.t_skill[skillId];
    local url = PathConfiger.getEquipmentSkillIcon(skillConf.icon);
    self.skillIcon:setIcon(url);
    self.skillIcon:addClickListener(function()
        ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillId})
    end)
end

function GuildLeagueFortView: GuildLeague_guildInfoUpdate()
    local c1 = self.view:getController("arrayType");
    if not self.isInited then
        local baseInfo = GuildLeagueModel:getBaseInfo();
        local actStatus = baseInfo.actStatus or 0;
        if (actStatus == GameDef.GuildPvpActStatus.Prepare or actStatus == GameDef.GuildPvpActStatus.Closed) then
            c1:setSelectedIndex(0);
            self.guildId = GuildLeagueModel.selfGuildInfo and GuildLeagueModel.selfGuildInfo.guildId or 0;
            self.fortList:refreashWithData(GuildLeagueModel:getSelfGuildPlayerInfo());
        else
            c1:setSelectedIndex(1);
            self.guildId = GuildLeagueModel.enemyGuildInfo and GuildLeagueModel.enemyGuildInfo.guildId or 0;
            self.fortList:refreashWithData(GuildLeagueModel:getEnemyGuildPlayerInfo());
        end
        self.isInited = true;
    else
        local select = c1:getSelectedIndex();
        if select == 0 then
            self.guildId = GuildLeagueModel.selfGuildInfo and GuildLeagueModel.selfGuildInfo.guildId or 0;
            self.fortList:refreashWithData(GuildLeagueModel:getSelfGuildPlayerInfo());
        else
            self.guildId = GuildLeagueModel.enemyGuildInfo and GuildLeagueModel.enemyGuildInfo.guildId or 0;
            self.fortList:refreashWithData(GuildLeagueModel:getEnemyGuildPlayerInfo());
        end
    end
    self:changeProgress();
    self:changeSkillCount();
    self:changeBaseInfo();
    self:upMatchStatus();
    GuildLeagueModel:getScoreRank(self.guildId)
end

function GuildLeagueFortView:changeProgress()
    local curStar = GuildLeagueModel:getBaseInfo().score or 0;
    local val = 0;
    local len = #self.progValMap;
    local per = 1 / len;
    for i = 1, len do
        local max = self.progValMap[i];
        local min = i == 1 and 0 or self.progValMap[i - 1];
        if (curStar >= max) then
            val = val + per;
        elseif (curStar > min and curStar < max) then
            local rate = (curStar - min) / (max - min);
            val = val + rate * per;
        end
    end
    self.bar:setValue(val);
    self.bar:getChildAutoType("value"):setText(curStar);
end

function GuildLeagueFortView:changeSkillCount()
    local constConf = DynamicConfigData.t_GLConst[1];
    local totalCount = constConf.overlay;
    local cur = math.min(GuildLeagueModel:getTotalChase(), totalCount);
    self.skillCount:setText(string.format("%s/%s", cur, totalCount));
end

function GuildLeagueFortView:changeBaseInfo()
    for i = 1, 2 do
        local btn = i == 1 and self.btn_self or self.btn_enemy;
        local data = i == 1 and GuildLeagueModel.selfGuildInfo or GuildLeagueModel.enemyGuildInfo;
        btn:getChildAutoType("txt_name"):setText(data.guildName);
        btn:getChildAutoType("txt_star"):setText(data.score);
        local c1 = btn:getController("isWin");
        if (GuildLeagueModel.winGuildId and GuildLeagueModel.winGuildId == data.guildId) then
            c1:setSelectedIndex(1);
        else
            c1:setSelectedIndex(0);
        end
    end
end

function GuildLeagueFortView:upMatchStatus()
    local baseInfo = GuildLeagueModel:getBaseInfo();
    local actStatus = baseInfo.actStatus or 0;
    local joinStatus = baseInfo.joinStatus or 0;
    local time = math.ceil(math.abs(baseInfo.statusEndStamp - ServerTimeModel:getServerTimeMS()) / 1000)
    if (actStatus == GameDef.GuildPvpActStatus.Prepare) then -- 准备
        self:starCD(time, Desc.GL_actStatus9);
    elseif (actStatus == GameDef.GuildPvpActStatus.Battle) then -- 战斗
        self:starCD(time, Desc.GL_actStatus10);
    elseif (actStatus == GameDef.GuildPvpActStatus.End) then
        self:starCD(time, Desc.GL_actStatus11);
    else
        self:stopCD();
        self.txt_cd:setText(Desc.GL_actStatus0);
    end
    self.btn_def:setVisible(GuildModel.guildHave and GuildLeagueModel.haveQualif and joinStatus == 1 and actStatus == GameDef.GuildPvpActStatus.Prepare)
end

function GuildLeagueFortView:starCD(time, formatStr)
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
        GuildLeagueModel:requestMatchInfo()
    end
    self.actCD = TimeLib.newCountDown(time, onCD, onEnd, false, false, false);
    self.txt_cd:setText(string.format(formatStr, fmat(time)));
end

function GuildLeagueFortView:stopCD()
    if (self.actCD) then
        TimeLib.clearCountDown(self.actCD);
        self.actCD = false;
    end
end

function GuildLeagueFortView:_exit()
    self:stopCD();
end

function GuildLeagueFortView:GuildLeague_scoreRankUpdate(_, param, extraInfo)
    local rankData = param.rankData or {};
    if (extraInfo and extraInfo.guildId ~= self.guildId) then
        return;
    end
    self.list_rank:setItemRenderer(function(idx, obj)
        local d = rankData[idx + 1];
        local c1 = obj:getController("c1");
        c1:setSelectedIndex(idx);
        if (d) then
            obj:setTitle(d.name);
        else
            obj:setTitle(Desc.Rank_empty);
        end
    end)
    self.list_rank:setNumItems(3)
end

return GuildLeagueFortView