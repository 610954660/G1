--Date :2020-12-31
--Author : generated by FairyGUI
--Desc : 

local GLLegendsGuessView,Super = class("GLLegendsGuessView", Window)

function GLLegendsGuessView:ctor()
	--LuaLog("GLLegendsGuessView ctor")
	self._packName = "GuildLeagueOfLegends"
	self._compName = "GLLegendsGuessView"
	self._rootDepth = LayerDepth.PopWindow
	self.viewType = self._args.type or (GuildLeagueOfLegendsModel.guessState - 1);
	self.round = GuildLeagueOfLegendsModel.matchRound
	local guessInfo = GuildLeagueOfLegendsModel.guessInfo;
	if (guessInfo and next(guessInfo)) then
		self.guessInfo = guessInfo
	else
		self.guessInfo = false;
	end
	self.actCD = false;
	self.battleSpine = false;
	-- print(2233, "------ 打开竞猜界面时比赛阶段", self.round, self.viewType)
end

function GLLegendsGuessView:_initEvent( )
	
end

function GLLegendsGuessView:_initVM( )
	local viewNode = self.view
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.c1 = viewNode:getController('c1')--Controller
	self.group = viewNode:getChildAutoType('group')--Component3
		self.btn_chat = viewNode:getChildAutoType('group/btn_chat')--btn_data
			self.btn_chat.img_red = viewNode:getChildAutoType('group/btn_chat/img_red')--GImage
		self.btn_check = viewNode:getChildAutoType('group/btn_check')--GButton
		self.btn_def = viewNode:getChildAutoType('group/btn_def')--btn_data
			self.btn_def.img_red = viewNode:getChildAutoType('group/btn_def/img_red')--GImage
		self.btn_guess1 = viewNode:getChildAutoType('group/btn_guess1')--btn_guest
		self.btn_guess2 = viewNode:getChildAutoType('group/btn_guess2')--btn_guest
		self.btn_log = viewNode:getChildAutoType('group/btn_log')--btn_data
			self.btn_log.img_red = viewNode:getChildAutoType('group/btn_log/img_red')--GImage
		self.closeButton = viewNode:getChildAutoType('group/closeButton')--GButton
		self.guild1 = viewNode:getChildAutoType('group/guild1')--com_guildGuest
			self.guild1.icon = viewNode:getChildAutoType('group/guild1/icon')--GLoader
			self.guild1.txt_combat = viewNode:getChildAutoType('group/guild1/txt_combat')--GTextField
			self.guild1.txt_name = viewNode:getChildAutoType('group/guild1/txt_name')--GTextField
			self.guild1.txt_sub = viewNode:getChildAutoType('group/guild1/txt_sub')--GTextField
			self.guild1.txt_team = viewNode:getChildAutoType('group/guild1/txt_team')--GTextField
		self.guild2 = viewNode:getChildAutoType('group/guild2')--com_guildGuest
			self.guild2.icon = viewNode:getChildAutoType('group/guild2/icon')--GLoader
			self.guild2.txt_combat = viewNode:getChildAutoType('group/guild2/txt_combat')--GTextField
			self.guild2.txt_name = viewNode:getChildAutoType('group/guild2/txt_name')--GTextField
			self.guild2.txt_sub = viewNode:getChildAutoType('group/guild2/txt_sub')--GTextField
			self.guild2.txt_team = viewNode:getChildAutoType('group/guild2/txt_team')--GTextField
		self.spine = viewNode:getChildAutoType('group/spine')--GLoader
		self.txt_cd = viewNode:getChildAutoType('group/txt_cd')--GTextField
		self.txt_guessRate1 = viewNode:getChildAutoType('group/txt_guessRate1')--GTextField
		self.txt_guessRate2 = viewNode:getChildAutoType('group/txt_guessRate2')--GTextField
		self.txt_matchStage = viewNode:getChildAutoType('group/txt_matchStage')--GTextField
		self.txt_matchStage1 = viewNode:getChildAutoType('group/txt_matchStage1')--GTextField
	self.guess = viewNode:getController('guess')--Controller
	self.status = viewNode:getController('status')--Controller
end

function GLLegendsGuessView:_initListener( )
	
	self.btn_check:addClickListener(function()
		if (self.guessInfo and self.viewType ~= 3 and self.viewType ~= 4) then
			local guildPosInfo = self.guessInfo.battlePosInfo;
			ViewManager.open("GLLegendsBattleTeamView", {info = guildPosInfo})
		elseif (self.viewType == 3 or self.viewType == 4) then
			ViewManager.open("GLLegendsBattleResultView", {round = self.round, battleInfo = self.guessInfo});
		end
	end)

	self.btn_guess1:addClickListener(function()
		ViewManager.open("GLLegendsBetView", {side = 1})
	end)

	self.btn_guess2:addClickListener(function()
		ViewManager.open("GLLegendsBetView", {side = 2})
	end)

	self.btn_log:addClickListener(function()
		ViewManager.open("GLLegendsGuestLogView")
	end)

	self.btn_def:addClickListener(function()
		ViewManager.open("GLLegendsDefPreView")
	end)

	self.btn_chat:addClickListener(function()
		ModuleUtil.openModule(ModuleId.Chat.id , true)
	end)

	self.closeButton:addClickListener(function()
		self:closeView();
	end)

	self.btn_def:setVisible(GuildLeagueOfLegendsModel.isInMatch)
end

function GLLegendsGuessView:_initUI( )
	self:_initVM()
	self:_initListener()
	self:upViewShow();
	local obj = self.group:displayObject();
	obj:setScaleX(0.1);
	obj:setScaleY(0.1);
	obj:runAction(cc.ScaleTo:create(0.25, 1))
	
	self.battleSpine = SpineUtil.createSpineObj(self.spine,{x=0,y=0},"animation","Spine/ui/GuildLeague","hunzhan_texiao","hunzhan_texiao",true, true)
end

function GLLegendsGuessView:upViewShow()
	-- 改变界面
	local ctrl = self.group:getController("status");
	if (ctrl) then
		ctrl:setSelectedIndex(self.viewType);
	end

	if (self.guessInfo) then
		local guildPosInfo = self.guessInfo.battlePosInfo;
		local totalCount = (guildPosInfo[1].count or 0) + (guildPosInfo[2].count or 0)
		local myGuess = GuildLeagueOfLegendsModel.myGuessInfo and GuildLeagueOfLegendsModel.myGuessInfo[self.round] or false
		for side, info in pairs(guildPosInfo) do
			local guildItem = self["guild"..side];
			local guildInfo = GuildLeagueOfLegendsModel.guildMap[info.guildId] or false;
			if (guildInfo) then
				guildItem.icon:setIcon(GuildModel:getGuildHead(guildInfo.guildIcon));
				guildItem.txt_name:setText(string.format("[S.%s]%s", guildInfo.serverId, guildInfo.guildName));
				guildItem.txt_combat:setText(StringUtil.transValue(guildInfo.combat));
				local teamCount = guildPosInfo[side].teamCount
				if (guildPosInfo[side].sub) then
					teamCount = teamCount - guildPosInfo[side].sub
				elseif (self.viewType == 3 or self.viewType == 4) then
					teamCount = guildPosInfo[side].teamCount - guildPosInfo[side].teamLose
				end
				print(2233, "========== team"..side, teamCount)
				guildItem.txt_team:setText(string.format(Desc.GLOL_str7, teamCount));
			end
			local txt_guess = self["txt_guessRate"..side];
			if (totalCount == 0) then
				txt_guess:setText("0%");
			else
				local rate = math.floor((info.count / totalCount) * 1000);
				txt_guess:setText((rate/10).."%");
			end
		end
		local guessCtrl = self.group:getController("guess");
		guessCtrl:setSelectedIndex(0)
		if (myGuess) then
			if (myGuess.side == 1) then
				guessCtrl:setSelectedIndex(1)
			elseif (myGuess.side == 2) then
				guessCtrl:setSelectedIndex(2)
			end
		end
		local key = GuildLeagueOfLegendsModel:getPosKey(self.round, self.guessInfo.battleIndex, 1);
		local k = string.split(key, "_");
		local group = k[1];
		local roundStr = Desc["GLOL_round"..self.round];
		local groupStr = string.format(Desc.GLOL_str4, group);
		if (group == "0") then
			self.txt_matchStage:setText(roundStr);
		else
			self.txt_matchStage:setText(roundStr.."-"..groupStr);
		end
	end

	-- 计时
	if (self.viewType ~= 3 and self.viewType ~= 4) then
		local roundState = GuildLeagueOfLegendsModel.roundState; -- 1、准备阶段  2、战斗阶段  3、结算阶段
		local stamp = GuildLeagueOfLegendsModel.stateStamp or 0;
		local time = math.ceil((stamp - ServerTimeModel:getServerTimeMS()) / 1000);
		if (time > 0) then
			self:starCD(time, Desc["GLOL_guessStatus"..GuildLeagueOfLegendsModel.guessState]);
		else
			self:stopCD();
			self.txt_cd:setText("");
		end
	else
		self:stopCD();
		self.txt_cd:setText("");
	end
end

-- function GLLegendsGuessView:GLOL_MatchInfoUpdate()
-- 	local defShow = GuildLeagueOfLegendsModel.isInMatch and GuildLeagueOfLegendsModel.matchRound ~= GameDef.GuildLeagueRound.Seven and GuildLeagueOfLegendsModel.roundState == GameDef.GuildLeagueState.Pre
-- 	self.btn_def:setVisible(defShow);
-- end

function GLLegendsGuessView:GLOL_guessStatusUpdate()
	if (self.viewType ~= 3 and self.viewType ~= 4) then
		self.viewType = GuildLeagueOfLegendsModel.guessState - 1
		self:upViewShow();
	end
end

function GLLegendsGuessView:GLOL_guessResult(_, round, result, battleInfo)
	if (round == self.round) then
		print(2233, "------ 打开竞猜界面结算", self.round, self.viewType)
		self.viewType = result and 3 or 4;
		-- self.round = round;
		for side, info in pairs(battleInfo.battlePosInfo) do
			info.isWin = battleInfo.winSide and battleInfo.winSide == side or false;
			info.teamCount = (side == 1 and battleInfo.leftCount or battleInfo.rightCount) or 0;
			info.teamLose = (side == 1 and battleInfo.leftLoseCount or battleInfo.rightLoseCount) or 0;
		end
		self.guessInfo = battleInfo;
		self:upViewShow();
	end
end


function GLLegendsGuessView:stopCD()
	if (self.actCD) then
		TimeLib.clearCountDown(self.actCD);
		self.actCD = false;
	end
end

function GLLegendsGuessView:starCD(time, formatStr)
	if (not time) then
		return;
	end
	self:stopCD();
	formatStr = formatStr or "%s";
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

function GLLegendsGuessView:cloneLabel(label)
	local labelNode = label:displayObject()
	local lab = cc.Label:create();
	local color = clone(label:getColor())
	lab:setColor(color);
	local size = label:getFontSize()
	lab:setSystemFontSize(size);
	local x = labelNode:getPositionX()
	lab:setPositionX(x)
	local y = labelNode:getPositionY()
	lab:setPositionY(y)
	lab:setAnchorPoint(cc.p(0, 0.5))
	labelNode:getParent():addChild(lab);
	return lab;
end

function GLLegendsGuessView:GLOL_virtualFight1(_, sub)
	if (self.guessInfo) then
		local guildPosInfo = self.guessInfo.battlePosInfo;
		local guildItem = self.guild1;
		guildItem.txt_team:setText(string.format(Desc.GLOL_str7, guildPosInfo[1].teamCount - sub));
		local lab = self:cloneLabel(guildItem.txt_sub)
		lab:setString("-1")
		lab:runAction(cc.Sequence:create(
			cc.Spawn:create(
				cc.FadeOut:create(1.5),
				cc.MoveBy:create(0.7, cc.p(30, 0))
			),
			cc.RemoveSelf:create(true)
		))
	end
end

function GLLegendsGuessView:GLOL_virtualFight2(_, sub)
	if (self.guessInfo) then
		local guildPosInfo = self.guessInfo.battlePosInfo;
		local guildItem = self.guild2;
		guildItem.txt_team:setText(string.format(Desc.GLOL_str7, guildPosInfo[2].teamCount - sub));
		local lab = self:cloneLabel(guildItem.txt_sub)
		lab:setString("-1")
		lab:runAction(cc.Sequence:create(
			cc.Spawn:create(
				cc.FadeOut:create(1.5),
				cc.MoveBy:create(0.7, cc.p(30, 0))
			),
			cc.RemoveSelf:create(true)
		))
	end
end

function GLLegendsGuessView:GLOL_MatchInfoUpdate()
	self.btn_def:setVisible(GuildLeagueOfLegendsModel.isInMatch)
end

function GLLegendsGuessView:_exit()
	self:stopCD();
end

return GLLegendsGuessView