-- add by zn
-- 高阶竞技场
local RankView = require "Game.Modules.Rank.RankView"
local HigherPvPView, Super = class("HigherPvPView", RankView)

function HigherPvPView:ctor()
    self._packName = "HigherPvP";
    self._compName = "HigherPvPView";
	self._rootDepth = LayerDepth.Window
    self._openType = GameDef.RankType.HigherPvp;
    self.timer = false;
    self.spineNode = false;
    self.changeFrameTitle = false;
    -- self.particleNode = false;
end

function HigherPvPView:_initUI()
    local root = self;
    local rootView = self.view;
        -- root.txt_power = rootView:getChildAutoType("fightpower");
        root.txt_score = rootView:getChildAutoType("score");
        root.txt_rank = rootView:getChildAutoType("rank");
        root.txt_rankName = rootView:getChildAutoType("rankName");
        root.txt_rewardCount = rootView:getChildAutoType("leaveAward");
        root.btn_begin = rootView:getChildAutoType("begin");
        root.btn_defand = rootView:getChildAutoType("defand");
        root.btn_reward = rootView:getChildAutoType("reward");
        root.btn_record = rootView:getChildAutoType("record");
        root.btn_shop = rootView:getChildAutoType("shop");
        root.btn_help = rootView:getChildAutoType("btn_help");
        root.loader_rankIcon = rootView:getChildAutoType("rankIcon");
        root.loader_rankEffect = rootView:getChildAutoType("rankEffect");
    Super._initUI(self);
    self:setBg("HigherPvp.jpg");
    HigherPvPModel:getRoleInfo();
    self:upSeasonTime();
    HigherPvPModel:getHistoryList();
    self:addViewParticle();
end

function HigherPvPView: _initEvent()
    self.btn_begin:addClickListener(function ()
        local endTime = TimeLib.nextWeekBeginTime()
        local addtime = TimeLib.getOffsetTime(endTime);
        if (addtime < 7200) then
            RollTips.show(Desc.HigherPvP_seasonEnd);
            return;
        end
        ViewManager.open("HigherPvPMatchView");
    end)

    self.btn_shop:addClickListener(function()
        ModuleUtil.openModule( ModuleId.Shop.id , true,{shopType = 13} )
    end)

    self.btn_defand:addClickListener(function ()
        if (self.btn_defand:getChildAutoType("img_red"):isVisible()) then
            FileCacheManager.setBoolForKey("HigherPvp_def", true);
            HigherPvPModel:checkRed();
        end
        self:enterDefandView();
        -- ViewManager.open("AddHPvPPrebattleView");
    end)

    self.btn_reward:addClickListener(function ()
        ViewManager.open("HigherRewardView");
    end)

    self.btn_record:addClickListener(function ()
        if (self.btn_record:getChildAutoType("img_red"):isVisible()) then
            FileCacheManager.setStringForKey("HigherPvp_history", ServerTimeModel:getServerTimeMS().."");
            RedManager.updateValue("V_HIGHERPVP_HISTORY", false);
        end
        ViewManager.open("HigherPvPHistoryView");
    end)

    self.btn_help:addClickListener(function ()
        local info={}
        info['title']=Desc["help_StrTitle"..self._args.moduleId]
        info['desc']=Desc["help_StrDesc"..self._args.moduleId]
        ViewManager.open("GetPublicHelpView",info) 
    end)

    RedManager.register("V_HIGHERPVP_BEGIN", self.btn_begin:getChildAutoType("img_red"));
    RedManager.register("V_HIGHERPVP_DEF", self.btn_defand:getChildAutoType("img_red"));
    RedManager.register("V_HIGHERPVP_REWARD", self.btn_reward:getChildAutoType("img_red"));
    RedManager.register("V_HIGHERPVP_HISTORY", self.btn_record:getChildAutoType("img_red"));
end

function HigherPvPView: HigherPvp_upSelfInfo(_, param)
    -- self.txt_power:setText(param.combat);
    local conf = DynamicConfigData.t_HPvPRank;
    local rankConf = conf[param.rankIndex];
    local nextRank = conf[param.rankIndex + 1]
    if (nextRank and nextRank.min > 0) then
        local str = string.format("%d/%d", param.score, nextRank.min);
        if (param.rankIndex == #conf - 1) then
            local const = DynamicConfigData.t_HPvPConst[1];
            local firstRank = const.firstRankNum;
            str = string.format(Desc.HigherPvP_rankStr, str, firstRank);
        end
        self.txt_score:setText(str);
    else
        self.txt_score:setText(param.score);
    end
    
    local rankName = HigherPvPModel:getRankName(param.rankIndex);
    if (rankName) then
        self.txt_rankName:setText(string.format(Desc["HigherPvP_rankColor"..rankConf.res], rankName));
        self:addEffect();
    else
        self.txt_rankName:setText(Desc.HigherPvP_rankColor0.format(Desc.HigherPvP_NoRankName));
    end

    if (rankConf) then
        self.loader_rankIcon:setIcon(string.format("Icon/rank/%s.png", rankConf.res));
    end
    self.txt_rewardCount:setText(string.format(Desc.HigherPvP_leaveReward, param.leftTimes));
    if (param.index) then
        local str = param.index > 1000 and "1000+" or param.index;
        self.txt_rank:setText(str);
    end
end

-- function HigherPvPView:updateRankInfo()
--     local str = self._myRank == 0 and Desc.HigherPvP_outRank or self._myRank;
--     self.txt_rank:setText(str)
-- end

function HigherPvPView: updateItemBaseInfo(obj, rankIndex, info, isMine)
    Super:updateItemBaseInfo(obj, rankIndex, info. isMine);
    obj:removeClickListener(100);
    obj:addClickListener(function(...)
        -- local id = isMine and PlayerModel.userid or info.id;
        -- HigherPvPModel:getPlayerArray(id);
        if (info) then
            info.rankLevel = HigherPvPModel:getRank(info.value, rankIndex);
        end
        ViewManager.open("HigherPvPPlayerInfoView", info)
    end,100)
end

function HigherPvPView: updateItemSpec(obj, rankIndex, info, isMine)
    -- printTable(2233, obj, rankIndex, info, isMine);
    obj:getController("c3"):setSelectedIndex(0);
    obj:getChildAutoType("txt_score"):setText(StringUtil.transValue(info.value));
    obj:getChildAutoType("txt_fightCap"):setText(StringUtil.transValue(info.combat));
    local rankIcon = obj:getChildAutoType("loader_rank");
    local rank = HigherPvPModel:getRank(info.value, rankIndex);
    local rankName = HigherPvPModel:getRankName(rank);
    local txtRank = obj:getChildAutoType("txt_rankName");
    local rankConf = DynamicConfigData.t_HPvPRank[rank];
    if (rankName) then
        rankIcon:setIcon(string.format("Icon/rank/%s.png", rankConf.res));
        txtRank:setText(string.format(Desc["HigherPvP_rankColor"..rankConf.res], rankName));
    else
        rankIcon:setIcon("");
        txtRank:setText(Desc.HigherPvP_rankColor0.format(Desc.HigherPvP_NoRankName));
    end
end

-- 进入布防界面
function HigherPvPView: enterDefandView()
    HigherPvPModel.battleTeamType = 0;
    local isClose = false;
    local battleCall = function (param)
        printTable(2233, "---- HigherPvPMatchView: battleBegin 备战界面 ---", param);
        if (param == "cancel") then
            HigherPvPModel:initTeamInfo();
        elseif (param == "begin") then
            if (isClose) then return end;
            isClose = true;
            RollTips.show(Desc.HigherPvP_saveDefSuc);
            ViewManager.close("BattlePrepareView");
        end
    end
    local const = DynamicConfigData.t_HPvPConst[1];
    local args = {
        fightID= const.fightId,
        configType= GameDef.BattleArrayType.HigherPvpDefOne,
        -- playerId= playerId
    }
    Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args);
end

function HigherPvPView: upSeasonTime()
    local endTime = TimeLib.nextWeekBeginTime()
    local addtime = TimeLib.getOffsetTime(endTime);
    local txt_title = self.view:getChildAutoType("seasontimet");
    local txt_time = self.view:getChildAutoType("seasontime");
    local onCount = function (time)
        if (tolua.isnull(txt_time) or tolua.isnull(txt_title)) then
            TimeLib.clearCountDown(self.timer)
            self.timer = false;
            return;
        end
        addtime = time;
        if (addtime > 7200) then
            txt_title:setText(Desc.HigherPvP_season1);
            txt_time:setText(StringUtil.formatTime((addtime - 7200), "d", Desc.HigherPvp_timeCount1));
        else
            txt_title:setText(Desc.HigherPvP_season2);
            self.btn_begin:setGrayed(true);
            txt_time:setText(StringUtil.formatTime(addtime, "d", Desc.HigherPvp_timeCount1));
        end
    end
    local function onEnd( ... )
        self:upSeasonTime();
    end
    if self.timer then
        TimeLib.clearCountDown(self.timer);
        self.timer = false;
    end
    self.timer = TimeLib.newCountDown(addtime, onCount, onEnd, false, false,false);
    onCount(addtime);
end

function HigherPvPView:addEffect()
    local x = self.loader_rankEffect:getWidth() / 2;
    local y = self.loader_rankEffect:getHeight() / 2;
    if (not self.spineNode) then
        self.spineNode = SpineUtil.createSpineObj(self.loader_rankEffect, cc.p(x, y), "qingtongduanwei_down_loop", "Effect/UI", "efx_gaojiejingjichang", "efx_gaojiejingjichang",true);
    end
    if (not self.loader_rankIcon.spine) then
        self.loader_rankIcon.spine = SpineUtil.createSpineObj(self.loader_rankIcon, cc.p(x, y), "qingtongduanwei_up_loop", "Effect/UI", "efx_gaojiejingjichang", "efx_gaojiejingjichang",true);
    end
end

function HigherPvPView: addViewParticle()
    -- local lineFrom = self.view:globalToLocal(self.loader_rankEffect:localToGlobal(cc.p(0, 0)));
    -- local lineEnd = cc.p(300, 300)
    -- local particleObj,particle=	ParticleUtil.createParticleObj(self.view,cc.p(lineFrom.x,lineFrom.y),"particle_texture")
    -- -- particle:setAngle()
    -- particle:setSpeed(1);
    -- particle:setRotatePerSecond(30);
    -- local _, particle = ParticleUtil.createParticleObj(self.view, cc.p(0, 0) ,"gaojiejingjichang_particle");
    -- ParticleUtil.residentParticle("gaojiejingjichang_particle", self.view)
    -- print(2233, "=====================particle getDuration", particle:getDuration());
end

function HigherPvPView:battle_end()
    self:updateRankData();
end

function HigherPvPView:_exit()
    if self.timer then
        TimeLib.clearCountDown(self.timer);
        self.timer = false;
    end
end

return HigherPvPView;