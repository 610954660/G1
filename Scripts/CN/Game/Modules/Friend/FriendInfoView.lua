-- 原 FriendCheckView
--added by zn
--好友头像页面

local LoginModel = require "Game.Modules.Login.LoginModel"
local FriendCheckView,Super = class("FriendCheckView", Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function FriendCheckView:ctor()
	self._packName = "Friend"
    self._compName = "FriendInfoView"
	self._rootDepth = LayerDepth.PopWindow
    
	self.blacklistBtn = false
    self.deleteBtn = false
    self.btn_call = false;
	-- self.closeBtn2 = false
	-- self.firstList = false
    -- self.secondList = false
    self.list_team = false;
	self.name_label = false
	-- self.levi_label = false
	self.warNum = false
	self.Guildtxt = false
	-- self.gender = false
	self.headBtn = false
	self.headIcon = false
	self.data = self._args
	
	self.heroItem = false
	self.btn_fightMoney = false
	self.ctrl1 = false
end

function FriendCheckView:_initUI( )
	self.blacklistBtn = self.view:getChildAutoType("btn_black") -- 拉黑
	self.deleteBtn = self.view:getChildAutoType("btn_del")
	self.addBtn = self.view:getChildAutoType("btn_add")
	self.addBtn:setVisible(false)
	-- self.firstList = self.view:getChildAutoType("first") --主力阵容
	-- self.secondList = self.view:getChildAutoType("second") --替补阵容
	self.list_team = self.view:getChildAutoType('list_team'); -- 所有队伍
	self.name_label = self.view:getChildAutoType("name_label") --名称
	self.warNum = self.view:getChildAutoType("warNum") --战力
	self.Guildtxt = self.view:getChildAutoType("Guildtxt") --工会

    self.txt_id = self.view:getChildAutoType('txt_id');
    self.btn_call = self.view:getChildAutoType("btn_call");
	
	self.headBtn = self.view:getChildAutoType("heroCell") --头像
	self.heroItem = BindManager.bindPlayerCell(self.headBtn)
	self.txt_vip = self.view:getChildAutoType("txt_vip")
	self.txt_rank = self.view:getChildAutoType("rank");
	self.list_medat = self.view:getChildAutoType("list_medal");
	self.serverName = self.view:getChildAutoType("serverName");
	self.isLadders  = self.view:getController("isLadders") -- 0 不是天梯赛 1 是
	self.btn_quit 	= self.view:getChildAutoType("btn_quit")
	self.btn_fight 	= self.view:getChildAutoType("btn_fight")
	self.btn_fightMoney = self.view:getChildAutoType("btn_fightMoney")

	
	-- self.ctrl1 = self.view:getController("c1")
	self.myselfCtrl = self.view:getController("myselfCtrl")
    
	local params = {}
	params.playerId = self.data.playerId
	params.serverId= self.data.serverId or LoginModel:getUnitServerId();
	params.arrayType= self.data.arrayType or GameDef.BattleArrayType.ArenaDef
	if tonumber(PlayerModel.userid) == tonumber(params.playerId) or
		params.arrayType==GameDef.BattleArrayType.WorldArena or 
		params.arrayType==GameDef.BattleArrayType.WorldTeamArena or 
		params.arrayType==GameDef.BattleArrayType.SkyLadderDef or 
		params.arrayType==GameDef.BattleArrayType.SkyLadChampion or 
		(self.data.chatNeedBtn~=nil and self.data.chatNeedBtn==false) then
		self.myselfCtrl:setSelectedIndex(1)
	else
		self.myselfCtrl:setSelectedIndex(0)
	end
	-- 天梯赛特殊处理
	self.isLadders:setSelectedIndex((self.data.gamePlayType == GameDef.GamePlayType.SkyLadder) and 1 or 0)
	if (self.data.gamePlayType == GameDef.GamePlayType.SkyLadder) then
		CrossLaddersModel:initTeamInfo(self.data.playerId,self.data.serverId)
		local txt_ladderFightTimes = self.view:getChildAutoType("txt_ladderFightTimes")
		txt_ladderFightTimes:setText(string.format(Desc.CrossLadders_str14,self._args.haveTimes))
		self.btn_quit:addClickListener(function()  
			ViewManager.close("FriendCheckView")
		end)
		local checkHaveLaddersTime = self.view:getController("checkHaveLaddersTime")
		checkHaveLaddersTime:setSelectedIndex(self._args.haveTimes ~= 0 and 1 or 0 )
		local conf = DynamicConfigData.t_SkyLadder[1]
		local ticketCode = conf.ticketCode
		local costItem = BindManager.bindCostItem(self.view:getChildAutoType("costItem"))
		costItem:setGreenColor("#6aff60")
		costItem:setData(CodeType.ITEM,ticketCode,1,false,true)
		-- costItem:setGreenColor("#6aff60")
		local url = ItemConfiger.getItemIconByCode(ticketCode, CodeType.ITEM)
		self.btn_fightMoney:getChildAutoType("icon"):setURL(url)
		self.btn_fightMoney:getChildAutoType("title"):setText("x1")
		self.btn_fightMoney:removeClickListener(11)
		self.btn_fightMoney:addClickListener(function()
			local dayStr = DateUtil.getOppostieDays()
			local isfresh = FileCacheManager.getIntForKey("CrossLadders_isCheckTips" .. dayStr,0)
			if CrossLaddersModel:checkHaveFightItem() then
				local conf  = {
					playerId 	= self.data.playerId,
					rank 		= self._args.rank,      
					otherData   = self._args.otherData,
					myOldRank 	= self._args.myOldRank,
				}
				if isfresh then
					CrossLaddersModel:reqSkyLadder_ChallengeStart(self.data.playerId,self._args.rank,self._args.otherData,self._args.myOldRank)
				else
					ViewManager.open("CrossLaddersFightTipsView",conf)
				end
			else
				if not CrossLaddersModel:checkOpenState() then
					RollTips.show(Desc.CrossLadders_str27)
					return
				end
		
				local state = CrossLaddersModel:noQualif()
				if not state then
					return
				end
				ViewManager.open("CrossLaddersShopView")
				-- RollTips.show(Desc.CrossLadders_str26)
			end
		end,11)

		self.btn_fight:removeClickListener(11)
		self.btn_fight:addClickListener(function() 
			local state = CrossLaddersModel:noQualif()
			if not state then
				return
			end
			if (self._args.haveTimes ~= 0) or CrossLaddersModel:checkHaveFightItem() then
				-- if self._args.haveTimes ~= 0 then
					CrossLaddersModel:reqSkyLadder_ChallengeStart(self.data.playerId,self._args.rank,self._args.otherData,self._args.myOldRank)
				-- elseif CrossLaddersModel:checkHaveFightItem() then
				-- 	local conf  = {
				-- 		playerId 	= self.data.playerId,
				-- 		rank 		= self._args.rank,      
				-- 		otherData   = self._args.otherData,
				-- 		myOldRank 	= self._args.myOldRank,
				-- 	}
				-- 	ViewManager.open("CrossLaddersFightTipsView",conf)
				-- else
				-- 	RollTips.show(Desc.CrossLadders_str26)
				-- end
			else
				RollTips.show(Desc.CrossLadders_str25)
			end
		end,11)
	end

	printTable(2233, "================", params);
	params.onSuccess = function (res )
		if (res.playerInfo and not res.playerInfo.arenaRank and self._args.rank) then
			res.playerInfo.arenaRank = self._args.rank
		end
		self:updateInfo(res, params.arrayType);
	end
	if (params.arrayType == GameDef.BattleArrayType.WorldArena and params.playerId < 0) then
		local roboot = DynamicConfigData.t_ArenaRobot[math.abs(params.playerId)];
		local fightConf = DynamicConfigData.t_fight[roboot.fightId];
		if (fightConf) then
			roboot.combat = fightConf.monstercombat;
		end
		self:updateInfo({playerInfo = roboot}, params.arrayType);
	else
		RPCReq.Player_FindPlayer(params, params.onSuccess)
	end
end

function FriendCheckView:updateInfo(res, arrayType)
	-- printTable(1, params.playerId, res)
	self.data = res.playerInfo
	if (tolua.isnull(self.view)) then return end;
	if res.playerInfo then
		local heroData = res.playerInfo
		heroData.playerId = heroData.playerId or heroData.id or heroData.code;

		self.heroItem:setHead(heroData.head, heroData.level, heroData.playerId,nil,heroData.headBorder)
		self.name_label:setText(heroData.name)
		local combat = heroData.combat or heroData.fightCap;
		self.warNum:setText(StringUtil.transValue(combat or 0))
		self.Guildtxt:setText(heroData.guild)
		local id = heroData.playerId < 0 and Desc.Friend_Text1 or heroData.playerId
		self.txt_id:setText(id);
		self.txt_vip:setText(heroData.vipLevel or "0");
		if (heroData.arenaRank) then
			self.txt_rank:setText(string.format(Desc.Arena_DetailsStr5, heroData.arenaRank));
		else
			self.txt_rank:setText(Desc.Friend_robotRank);
		end
		self.view:getController('sex'):setSelectedIndex(tonumber(heroData.sex) - 1);
		if (heroData.playerId < 0) then
			self.serverName:setText(Desc.common_robotServerName);
		else
			local serverName = ""
			local serverGroup = LoginModel:getServerGroups()
			for _, d in pairs(serverGroup) do
				for _, info in pairs(d) do
					if (info.unit_server == res.playerInfo.serverId) then
						serverName = info.name;
					end
				end
			end
			if (serverName == "") then
				serverName = res.playerInfo.serverId
			end
			self.serverName:setText(serverName);
		end
		-- 是机器人自己组数据
		if (heroData.playerId < 0 and arrayType == GameDef.BattleArrayType.WorldArena) then
			local fightConf = DynamicConfigData.t_fight[heroData.fightId];
			-- local keys = fightConf.Fight_col;
			-- local data = fightConf.Fight_temp[heroData.fightId]
			heroData.array = {};
			local monsterStand = fightConf["monsterStand"]-- data[keys["monsterStand"]];
			for _, idx in ipairs(monsterStand) do
				local info = {};
				info.code = fightConf["monsterId"..idx]--keys["monsterId"..idx]
				if (idx < 4) then
					info.id = 10 + idx
				elseif idx < 7 then
					info.id = 20 + (idx - 3)
				else
					info.id = 30 + (id - 6)
				end
				info.type = 2;
				info.level = fightConf["level"..idx]--data[keys["level"..idx]];
				info.star = fightConf["star"..idx]--data[keys["star"..idx]];
				table.insert(heroData.array, info);
			end
		end
		
		local isMyFriend = self.data and ModelManager.FriendModel:IsMyFriend(self.data.playerId)
		self.deleteBtn:setVisible(isMyFriend)
		self.addBtn:setVisible(not isMyFriend)
		self:upMedalList();
		self:updateArenaInfo(heroData.array)
		if heroData.guildName and heroData.guildName ~= "" then
			self.Guildtxt:setText(heroData.guildName)
		else
			self.Guildtxt:setText(Desc.Friend_check_txt4)
		end
	end
end

function FriendCheckView:updateArenaInfo( heroInfos )
    local ctrl = self.view:getController("team");
    if (heroInfos and #heroInfos > 0) then
        ctrl:setSelectedIndex(1);
        self.list_team:setItemRenderer(function (idx, obj)
			local heroInfo = heroInfos[idx + 1]
			local category = self.data.playerId > 0 and DynamicConfigData.t_hero[heroInfo.code].category or DynamicConfigData.t_monster[heroInfo.code].category;
			if (category) then
				heroInfo.category = category;
			end
			local cardItem = BindManager.bindHeroCell(obj)
			cardItem:setBaseData(heroInfo)
			-- if (self.data.playerId < 1) then
			-- 	local icon = DynamicConfigData.t_monster[heroInfo.code].model
			-- 	cardItem:setIcon(PathConfiger.getHeroCard(icon))
			-- end
			obj:addClickListener(function ()
				if (heroInfo.uuid) then
					local data = {
						playerInfo = self.data,
						heroArray = self.data.array,
						index = idx + 1
					}
					Dispatcher.dispatchEvent(EventType.HeroInfo_Show, data);
				else
					RollTips.show(Desc.Friend_cant_show);
				end
			end)
        end)
        self.list_team:setNumItems(#heroInfos);
    else
        ctrl:setSelectedIndex(0);
    end
end


function FriendCheckView:upMedalList(medalData)
	self.list_medat:setNumItems(0);
end

function FriendCheckView:_initEvent( )
	
	self.blacklistBtn:addClickListener(function ( ... )
		
		if self.data then
			local info = {}
			info.text = string.format(Desc.Friend_check_txt2, self.data.name)
			info.yesText = Desc.common_sure
			info.noText = Desc.common_cancel
			info.type = "yes_no"
			info.mask = true
			info.onYes = function ()
				print(1,"self.data.playerId",self.data.playerId)
				local params = {}
				params.type =0
				params.playerId = self.data.playerId
				params.onSuccess = function (res )
					ModelManager.FriendModel:DeleteFriend(self.data)
					ModelManager.FriendModel:addBlack(self.data);
					ViewManager.close("FriendCheckView")
				end
				RPCReq.Friend_InsetBlack(params, params.onSuccess)
			end
			info.onNo = function ()
				print(5,"onNo")
			end
			Alert.show(info)
		end
		
		
	end)
	self.deleteBtn:addClickListener(function ( ... )
		local info = {
			text= Desc.Friend_delSure,
			type= "yes_no",
			onYes= function ()
				local params = {}
				params.type =0
				params.playerId = self.data.playerId
				params.onSuccess = function (res )
					ModelManager.FriendModel:DeleteFriend(self.data)
					if (tolua.isnull(self.view)) then return end;
					RollTips.show(Desc.Friend_delSuccess)
					self.addBtn:setVisible(true)
					self.deleteBtn:setVisible(false)
					self:closeView()
				end
				RPCReq.Friend_Delete(params, params.onSuccess)
			end
		}
		Alert.show(info);
	end)
	
	self.addBtn:addClickListener(function ( ... )
		local friendList = FriendModel:getData(GameDef.FriendListType.FriendList);
		if (friendList and #friendList > FriendModel.maxFriendLimit) then
			RollTips.show(Desc.Friend_maxFriend);
			return;
		end
		local params = {}
		params.type =0
		params.playerId =self.data.playerId
        params.onSuccess = function (res )
            RollTips.show(Desc.Friend_send);
			if (tolua.isnull(self.view)) then return end;
			self.deleteBtn:setVisible(false)
			self.addBtn:setVisible(false)
			self:closeView()
		end
		RPCReq.Friend_Apply(params, params.onSuccess)
    end)
    
	self.btn_call:addClickListener(function ()
		if (self.data.playerId > 0) then
			Dispatcher.dispatchEvent(EventType.update_chatClientPrivte, self.data);
			self:closeView();
		else
			RollTips.show(Desc.Friend_cant_show1);
		end
    end)
end

function FriendCheckView:check_update_panel( _,args )
	-- printTable(1,"check_update_panel",args)
	if args.playerId == self.data.playerId then
		self.data = args
	end
	local isMyFriend = self.data and ModelManager.FriendModel:IsMyFriend(self.data.playerId)
	self.deleteBtn:setVisible(isMyFriend)
	self.addBtn:setVisible(not isMyFriend)
end


--页面退出时执行
function FriendCheckView:_exit( ... )
	print(1,"EmailView _exit")
end


return FriendCheckView