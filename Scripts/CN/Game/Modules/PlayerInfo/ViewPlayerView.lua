-- 原 ViewPlayerView
--added by wyang
--好友头像页面

local LoginModel = require "Game.Modules.Login.LoginModel"
local ViewPlayerView,Super = class("ViewPlayerView", Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function ViewPlayerView:ctor()
	self._packName = "PlayerInfo"
    self._compName = "ViewPlayerView"
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
	self.list_guildSkill = false
	self.list_hallowSkill = false
	self.list_elves = false
	-- self.gender = false
	self.headBtn = false
	self.headIcon = false
	self.data = self._args
	
	self.heroItem = false
	self.btn_fightMoney = false
	self.ctrl1 = false
	
	self.btn_runeInfo = false
	
	self.guildSkillData = false
	self.hallowSkillData = false
	self.elvesData = false
	self.elvesFullData = false --精灵的总属性
end

function ViewPlayerView:_initUI( )
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
	self.txt_noGuildSkill = self.view:getChildAutoType("txt_noGuildSkill") --没有公会科研信息
	self.txt_noHallow = self.view:getChildAutoType("txt_noHallow") --没有圣器信息

    self.txt_id = self.view:getChildAutoType('txt_id');
    self.btn_call = self.view:getChildAutoType("btn_call");
	
	self.headBtn = self.view:getChildAutoType("heroCell") --头像
	self.heroItem = BindManager.bindPlayerCell(self.headBtn)
	self.txt_vip = self.view:getChildAutoType("txt_vip")
	self.txt_rank = self.view:getChildAutoType("rank");
	self.list_guildSkill = self.view:getChildAutoType("list_guildSkill");
	self.list_hallowSkill = self.view:getChildAutoType("list_hallowSkill");
	self.list_elves = self.view:getChildAutoType("list_elves");
	self.serverName = self.view:getChildAutoType("serverName");
	self.btn_quit 	= self.view:getChildAutoType("btn_quit")
	self.btn_fight 	= self.view:getChildAutoType("btn_fight")
	self.btn_fightMoney = self.view:getChildAutoType("btn_fightMoney")
	self.btn_fightMoney = self.view:getChildAutoType("btn_fightMoney")
	self.btn_runeInfo = self.view:getChildAutoType("btn_runeInfo")
	
	

	
	-- self.ctrl1 = self.view:getController("c1")
	self.myselfCtrl = self.view:getController("myselfCtrl")
    
	local params = {}
	params.playerId = self.data.playerId
	params.serverId= self.data.serverId or LoginModel:getUnitServerId();
	params.arrayType= self.data.arrayType or GameDef.BattleArrayType.ArenaDef
	if tonumber(PlayerModel.userid) == tonumber(params.playerId) or
		self._args.hideBtns == true or
		params.arrayType==GameDef.BattleArrayType.WorldArena or 
		params.arrayType==GameDef.BattleArrayType.WorldTeamArena or 
		params.arrayType==GameDef.BattleArrayType.SkyLadderDef or 
		-- params.arrayType==GameDef.BattleArrayType.SkyLadderAck or 
		(self.data.chatNeedBtn~=nil and self.data.chatNeedBtn==false) or
		(self.data.serverId and self.data.serverId  ~= LoginModel:getUnitServerId())	then
		self.myselfCtrl:setSelectedIndex(1)
	else
		self.myselfCtrl:setSelectedIndex(0)
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

function ViewPlayerView:updateInfo(res, arrayType)
	-- printTable(1, params.playerId, res)
	self.data = res.playerInfo
	if (tolua.isnull(self.view)) then return end;
	self:updateGuildSkill(self.data.guildSkillMap)
	self:updateHallowSkill(self.data.hallow)
	self:updateElves(self.data.godArms, self.data.elf,self.data.elfList)
	self:updateRune()
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
		self:updateArenaInfo(heroData.array)
		if heroData.guildName and heroData.guildName ~= "" then
			self.Guildtxt:setText(heroData.guildName)
		else
			self.Guildtxt:setText(Desc.Friend_check_txt4)
		end
	end
end

function ViewPlayerView:updateArenaInfo( heroInfos )
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

--更新公会技能
function ViewPlayerView:updateGuildSkill(guildSkill)
	
	self.list_guildSkill:setItemRenderer(function (idx, obj)
		local iconLoader = obj:getChildAutoType("iconLoader/iconLoader")
		local txt_level = obj:getChildAutoType("txt_level")
		local img_lvBg = obj:getChildAutoType("img_lvBg")
		local data = self.guildSkillData[idx + 1]
		txt_level:setText(data.level and "Lv."..data.level or "")
		img_lvBg:setVisible(data.level ~= nil)
		iconLoader:setURL(PathConfiger.getGuildTechnologyIcon(data.id))
		obj:removeClickListener(100)
		obj:addClickListener(function()
			ViewManager.open("ViewPlayerGuildSkillTipView", data)
		end,100)
	end)
	
	if guildSkill then
		self.guildSkillData = {}
		for _,v in pairs(guildSkill) do
			table.insert(self.guildSkillData, v)
		end
		--self.guildSkillData = guildSkill
		self.list_guildSkill:setNumItems(#self.guildSkillData);
		self.txt_noGuildSkill:setVisible(#self.guildSkillData == 0)
	else
		self.txt_noGuildSkill:setVisible(true)
	end
end

--更新圣器技能
function ViewPlayerView:updateHallowSkill(hallowData)
	if not hallowData then
		self.txt_noHallow:setVisible(true)
		return
	end
	self.txt_noHallow:setVisible(false)
	self.list_hallowSkill:setItemRenderer(function (idx, obj)
		local iconLoader = obj:getChildAutoType("iconLoader/iconLoader")
		local txt_level = obj:getChildAutoType("txt_level")
		local img_lvBg = obj:getChildAutoType("img_lvBg")
		local data = self.hallowSkillData[idx + 1]
		
		if data.id == 0 then
			local level = data.data.hallowBaseLevel or -1
			txt_level:setText(level >= 0 and "Lv."..level or "")
			img_lvBg:setVisible(level >= 0)
			iconLoader:setURL("UI/ElvesSystem/ElvesBase.png")
		else
			local level = hallowData.hallowTypeMap[data.id] and hallowData.hallowTypeMap[data.id].level or -1
			txt_level:setText(level >= 0 and "Lv."..level or "")
			img_lvBg:setVisible(level >= 0)
			iconLoader:setURL(PathConfiger.getCardCategory(data.id))
		end
		obj:removeClickListener(100)
		obj:addClickListener(function()
			if data.id == 0 then
				if data.data.hallowBaseLevel > 0 then
					ViewManager.open("ViewPlayerHallowBaseTipsView", data.data)
				else
				end
			else
				if hallowData.hallowTypeMap[data.id] then
					data.data = hallowData.hallowTypeMap[data.id]
					ViewManager.open("ViewPlayerHallowSkillTipView", data)
				end
			end
		end,100)
	end)
	
	local skillData = {}
	table.insert(skillData, {id = 0, data = hallowData})
	for i = 1,5 do
		table.insert(skillData, {id = i})
	end
	
	self.hallowSkillData = skillData
	self.list_hallowSkill:setNumItems(#skillData);
end

--更新精灵显示
function ViewPlayerView:updateElves(godArms, elves, elfList)
	if not elves then
		return 
	end
	self.list_elves:setItemRenderer(function (idx, obj)
		local iconLoader = obj:getChildAutoType("iconLoader/iconLoader")
		local txt_level = obj:getChildAutoType("txt_level")
		if self.elvesData[idx + 1].type and self.elvesData[idx + 1].type == "screetWeapon" then
			local data = self.elvesData[idx + 1].info
			txt_level:setText("Lv."..data.level)
			local equipurl = SecretWeaponsModel:getEquipById(data.curId)
			iconLoader:setURL(equipurl)
			obj:removeClickListener(100)
			obj:addClickListener(function()
				ViewManager.open("ViewPlayerScrectWeaponTipView", data)
			end,100)
		else
			local data = self.elvesData[idx + 1].info
			txt_level:setText("Lv."..data.level)
			local url = ItemConfiger.getItemIconByCode(data.id)
			iconLoader:setURL(url)
			obj:removeClickListener(100)
			obj:addClickListener(function()
				ViewManager.open("ViewPlayerElvesTipsView", {data = data, fullData = self.elvesFullData})
			end,100)
		end
	end)
	
	
	self.elvesFullData = {}
	
	
	local elvesData = {}
	local starAddAttr = {}
	local attrMap = {}
	if godArms and godArms.curId ~= 0 then
		table.insert(elvesData, {type = "screetWeapon", info = godArms})
	end
	for _,v in pairs(elves) do
		if v.info then
			local starConfig = DynamicConfigData.t_ElfStar[v.info.id][v.info.star]	
			local elfConfig = DynamicConfigData.t_ElfMain[v.info.id][v.info.level]
			local skinConfig = DynamicConfigData.t_ElfSkin[v.info.id] and DynamicConfigData.t_ElfSkin[v.info.id][v.info.skinId]
			--table.insert(starAddAttr, starConfig.desc)
			table.insert(elvesData, v)
			--[[for _,attr in pairs(elfConfig.attribute) do
				if not attrMap[attr.type] then
					attrMap[attr.type] = attr.value
				else
					attrMap[attr.type] = attrMap[attr.type] + attr.value
				end
			end
			
			if skinConfig then
				for _,attr in pairs(skinConfig.basicAttr) do
					if not attrMap[attr.type] then
						attrMap[attr.type] = attr.value
					else
						attrMap[attr.type] = attrMap[attr.type] + attr.value
					end
				end
			end--]]
		end
	end
	
	for _,v in pairs(elfList) do
		print(69,"t_ElfStar", v.id, v.star)
		if v.id then
			local starConfig = DynamicConfigData.t_ElfStar[v.id][v.star]	
			local elfConfig = DynamicConfigData.t_ElfMain[v.id][v.level]
			local skinConfig = DynamicConfigData.t_ElfSkin[v.id] and DynamicConfigData.t_ElfSkin[v.id][v.skinId]
			table.insert(starAddAttr, starConfig.desc)
			for _,attr in pairs(elfConfig.attribute) do
				if not attrMap[attr.type] then
					attrMap[attr.type] = attr.value
				else
					attrMap[attr.type] = attrMap[attr.type] + attr.value
				end
			end
			
			if skinConfig then
				for _,attr in pairs(skinConfig.basicAttr) do
					if not attrMap[attr.type] then
						attrMap[attr.type] = attr.value
					else
						attrMap[attr.type] = attrMap[attr.type] + attr.value
					end
				end
			end
		end
	end
	
	local attrList = {}
	for k,v in pairs(attrMap) do
		table.insert(attrList, {type = k, value = v})
	end
	elvesData['starAttr'] = starAddAttr
	elvesData['upgradeAttr'] = attrList
	self.elvesFullData = elvesData
	self.elvesData = elvesData
	self.list_elves:setNumItems(#elvesData);
end

function ViewPlayerView:updateRune()
	local heroInfo = self.data.array
	if not heroInfo or not self.data.heroRune then
		self.btn_runeInfo:setVisible(false)
		return
	end
	local hasRune = false
	for _,v in ipairs(heroInfo) do
		if self.data.heroRune[v.uuid] then
			hasRune = true
			break
		end
	end
	self.btn_runeInfo:setVisible(hasRune)
end

function ViewPlayerView:_initEvent( )
	
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
					ViewManager.close("ViewPlayerView")
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

	self.btn_runeInfo:addClickListener(function ()
		ViewManager.open("ViewPlayerRuneTipsView", self.data)
    end)
end

function ViewPlayerView:check_update_panel( _,args )
	-- printTable(1,"check_update_panel",args)
	if args.playerId == self.data.playerId then
		self.data = args
	end
	local isMyFriend = self.data and ModelManager.FriendModel:IsMyFriend(self.data.playerId)
	self.deleteBtn:setVisible(isMyFriend)
	self.addBtn:setVisible(not isMyFriend)
end


--页面退出时执行
function ViewPlayerView:_exit( ... )
	print(1,"EmailView _exit")
end


return ViewPlayerView