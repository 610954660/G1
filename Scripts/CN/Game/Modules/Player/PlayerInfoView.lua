
local PlayerInfoView,Super = class("PlayerInfoView", Window)
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
function PlayerInfoView:ctor()
	LuaLogE("PlayerInfoView ctor")
	self._packName = "Player"
	self._compName = "PlayerInfoView"
	
	self._rootDepth = LayerDepth.Window
	
	self.headbtn = false
	
	self.name = false
	self.level = false
	self.userid = false
	self.exp = false
	self.address = false
	self.progress = false
	self.sex = false
	self.headCell = false;
	self.img_red_head = false
	
	-- self.closeBt = false
	
	self.addressList = false
	self.provinceList = false
	self.cityList = false
	
	self.editName = false
	self.editAddress = false
	self.editSex = false
	

	self.curProvince = false
	self.headframe = false
	
	self.sex_man = false
	self.sex_woman = false
	
	self.xzList = false
	self.zrList = false
	-- self.changeAccountBt = false
	self._isFullScreen = true
	
	self.rollingCityCom=false
	
	self.loader_category =  false
	self.loader_career =  false
	self.txt_name = false
	self.txt_category = false
	self.cardStar = false
	self.txt_career =  false
	self.shareBtn=false
	self.copyBtn=false
	self.guildName=false
	self.guildIcon=false
	
	self.txt_input=false


	self.palyerData=false
	
	self.badgeList=false
	self.arrayList=false
	self.pushCity=false
	self.pataFloor=false
	self.heroBagInfo=false
	self.geographicalBox=false
	self.txt_sign=false
	self.shareCtrl=false
	self.playerId=false
	self.mainModelShow=false
	
end



function PlayerInfoView:_initUI()
	LuaLogE("PlayerInfoView _initUI")

    self:setBg("playerInfoBg.jpg")

	self.txt_career = self.view:getChild("txt_career")
	self.txt_category = self.view:getChild("txt_category")
	self.loader_category = self.view:getChild("loader_category")
	self.loader_career = self.view:getChild("loader_career")
	self.heroBagInfo=self.view:getChild("heroBagInfo")

	
	self.shareBtn=self.view:getChild("shareBtn")
	self.copyBtn=self.view:getChild("copyBtn")
	self.guildName=self.view:getChild("guildName")
	self.guildIcon=self.view:getChild("guildIcon")
	self.arenaRank=self.view:getChild("arenaRank")
	self.pushCity=self.view:getChild("pushCity")
	self.pataFloor=self.view:getChild("pataFloor")
	self.txt_sign=self.view:getChild("txt_sign")
	self.shareCtrl=self.view:getController("shareCtrl")
	
	
	self.badgeList=self.view:getChild("badgeList")
	self.arrayList=self.view:getChild("arrayList")
	self.geographicalBox=self.view:getChildAutoType("rollingCityCom")
	self.img_red_head =self.view:getChildAutoType("img_red_head")
	self.headbtn = self.view:getChildAutoType("heroCell")
	self.headCell = BindManager.bindPlayerCell(self.headbtn);
	self.headCell:showRelation(false);
	
	
	RedManager.register("M_HEAD", self.img_red_head)
	local modelShow = self.view:getChildAutoType("modelShow")
	self.mainModelShow=BindManager.bindClass("Game.Modules.MainUI.MainModelShow", modelShow, {onlyShow = true})
	self.mainModelShow:setBtnLinkState(false)

	local num = 1
	self.headbtn:addClickListener(function()
			ViewManager.open("PlayerHeadBaseView")
			print(33,"headbtn",num)
			num = num + 1
	end)
	self.shareBtn:setVisible(true)
	self.shareBtn:addClickListener(function()
		Dispatcher.dispatchEvent(EventType.update_chatClientRoleNameShare,{name=PlayerModel.username});
		self:closeView()
	end)
	self.copyBtn:addClickListener(function()
			RollTips.show("复制成功")
			gy.GYDeviceUtil:setClipboardStr(self.userid:getText())
			--print(086,self.userid:getText())
	end)
	
	self:player_headreset()
	
	self.name = self.view:getChildAutoType("name")
	self.name:setText(PlayerModel.username)
	self.level = self.view:getChildAutoType("level")
	self.level:setText(PlayerModel.level)
	self.userid = self.view:getChildAutoType("userid")
	self.userid:setText(PlayerModel.userid)
	

	self.progress = self.view:getChildAutoType("progress")
	
	self.txt_input=self.view:getChild("txt_input")
	self.txt_hint=self.view:getChild("txt_hint")
	self.txt_input:setMaxLength(20);
	local oldStr = self.txt_input:getText()
	
	
	if self.txt_input.setInputEventLister then
		self.txt_input:onChanged(function (content)
			local inputText = self.txt_input:getText()
			self.txt_input:setText(inputText)
			self.txt_hint:setVisible(#inputText == 0)
		end);
		self.txt_input:setInputEventLister(function (eventName)
				if eventName=="end" then
					local inputText = self.txt_input:getText()
					inputText=StringUtil.limitStringLen(inputText, 120)
					if (StringUtil.isOnlyNumberOrCharacter(inputText)) then
						RollTips.show(Desc.input_tips2);
						self.txt_input:setText(oldStr)
						return;
					end
					local newText=StringUtil.filterString(inputText)
					if newText ~= inputText then  
						self.txt_input:setText(oldStr)
						RollTips.show(Desc.input_tips3); 
						return 
					end
					inputText = newText
					self.txt_input:setText(inputText)
					self.txt_hint:setVisible(#inputText == 0)

					local requseInfo={
						signature=inputText,
					}
					oldStr = inputText
					local function success(data)
					end
					RPCReq.GamePlay_Modules_Rename_signature(requseInfo,success)
				end
				
		end);
	else
		self.txt_input:onChanged(function (content)
			local inputText = self.txt_input:getText()
			self.txt_input:setText(inputText)
			self.txt_hint:setVisible(#inputText == 0)
			local requseInfo={
				signature=inputText,
			}
			oldStr = inputText
			local function success(data)
			end
			RPCReq.GamePlay_Modules_Rename_signature(requseInfo,success)
		end);
	end
	
	
	local nextInfo = DynamicConfigData.t_roleAttr[PlayerModel.level+1]
	local nextExp = nextInfo and nextInfo.exp
	self:player_UpdateLevelInfo()
	
	
	self.editName = self.view:getChildAutoType("edname")
	self.editName:addClickListener(function()
			ViewManager.open("EditBoxView")
	end)
	
	self:moveTitleToTop()
	
	--self:mainui_showHeroChange()
	
    self:findPlayer(self._args.playerID,self._args.serverID)
end

function PlayerInfoView:player_closeGgraphBox(_,params)
    printTable(086,params)
	
	local requseInfo={
		province=params.cityId,--省份
		cityId=params.countyId --城市

	}
	local function success(data)
		printTable(086,data)
	end
	RPCReq.GamePlay_Modules_Rename_province(requseInfo,success)
end



function PlayerInfoView:setData()
	if GuildModel.guildHave then
		self.guildName:setText(GuildModel:getGuildName())
		self.guildIcon:setURL(GuildModel:getGuildHead(GuildModel.guildList.icon))
	else
		self.guildName:setText("")
		self.guildIcon:setURL("")
	end
end



function PlayerInfoView:findPlayer(playerId)
	print(096,"findPlayer")
	local params = {}
	params.playerId = playerId or  PlayerModel.userid
	self.playerId=params.playerId
	params.serverId=  LoginModel:getUnitServerId();
	params.arrayType=  GameDef.BattleArrayType.ArenaDef
	if PlayerModel.userid ~= params.playerId then
		self.shareBtn:setVisible(false)
		self.copyBtn:setVisible(false)
		self.editName:setVisible(false)
		self.geographicalBox:setVisible(false)
	end
	self.txt_input:setTouchable(PlayerModel.userid == params.playerId)
	self.headbtn:setTouchable(PlayerModel.userid == params.playerId)
	self.shareCtrl:setSelectedIndex(PlayerModel.userid == params.playerId and 0 or 1)
		--self.myselfCtrl:setSelectedIndex(0)
	--end
	params.onSuccess = function (res )
		self.palyerData = res.playerInfo
		if (tolua.isnull(self.view)) then return end;
		print(096,"findPlayer onSuccess")
		if res.playerInfo then
			
			if tolua.isnull(self.view) then return end
			local heroData = res.playerInfo
			self.headCell:setHead(heroData.head, heroData.level, heroData.playerId,nil, heroData.headBorder);
			self.name:setText(heroData.name)
			self.arenaRank:setText(string.format(Desc.Arena_DetailsStr5,heroData.arenaRank or 1000))
			local id = heroData.playerId < 0 and "无" or heroData.playerId
			self.userid:setText(id);
			self.level:setText(heroData.level)
			printTable(096,heroData.chapters)	

			if PushMapModel:checkChapterConfiger(heroData.chapters.city,heroData.chapters.point,heroData.chapters.level)  then
				local pushInfo=DynamicConfigData.t_chaptersPoint[heroData.chapters.city][heroData.chapters.point][heroData.chapters.level]
				self.pushCity:setText(pushInfo.sidname)
			end

			self.mainModelShow:setModelIcon(heroData.heroOpertion, heroData.fashionCode)
			self:mainui_showHeroChange("",heroData.heroOpertion)
			self.pataFloor:setText(heroData.towers)
			self:setExpProgressBar(heroData.exp,heroData.level)
			
			self:updateArrayList(heroData.array,heroData.heroRecordNum)
			self:updateBadgeList(heroData.honorMedalWall)
			--print(096,heroData.signature)
			
			self.txt_input:setText(heroData.signature)
			self.txt_sign:setText(heroData.signature)
			self.txt_hint:setVisible(#heroData.signature == 0)
			
			
	
			printTable(086,heroData)
			self.rollingCityCom=BindManager.bindGeographicalBox(self.geographicalBox)
			self.rollingCityCom:setData(heroData.province,heroData.cityId)
			if heroData.guildName and heroData.guildName ~= "" then
				self.guildName:setText(heroData.guildName)
				self.guildIcon:setURL(GuildModel:getGuildHead(heroData.guildIcon))
			else
				self.guildName:setText(Desc.Friend_check_txt4)
			end
		end
	end
	RPCReq.Player_FindPlayer(params, params.onSuccess)
end



function PlayerInfoView:mainui_showHeroChange(_,heroOpertion)
	local heroId=heroOpertion or ModelManager.HandbookModel.heroOpertion
	print(5656,heroId,"heroIdheroId")
	local HeroInfo=HeroConfiger.getHeroInfoByID(heroId)
	if HeroInfo then
		self.loader_category:setURL(PathConfiger.getCardCategory(HeroInfo.category))
		self.loader_career:setURL(PathConfiger.getCardProfessional(HeroInfo.professional))
		self.txt_category:setText(Desc["card_category"..HeroInfo.category])
		self.txt_career:setText(Desc["common_creer"..HeroInfo.professional])
	end
end



function PlayerInfoView:_initEvent( ... )
	self:addEventListener(RecvType.Attr_UpdateRoleInfo,self)
end

function PlayerInfoView:player_UpdateLevelInfo(_,nextExp)
	
	if not tolua.isnull(self.progress) then
		local nextInfo = DynamicConfigData.t_roleAttr[PlayerModel.level+1]
		local nextExp = nextInfo and nextInfo.exp
		if nextExp then
			self.progress:setMax(nextExp)
			self.progress:setValue(PlayerModel.exp)
		else
			self.progress:setMax(1)
			self.progress:setValue(1)
		end
	end
end



function PlayerInfoView:setExpProgressBar(exp,level)
	local nextInfo = DynamicConfigData.t_roleAttr[level+1]
	local nextExp = nextInfo and nextInfo.exp
	local ptitle = self.progress:getChildAutoType("title")
	if not nextExp then
		self.progress:setMax(1)
		self.progress:setValue(1)
		ptitle:setText(Desc.player_expStr3)
	else
		if not tolua.isnull(self.progress) then
			self.progress:setMax(nextExp)
			self.progress:setValue(exp)
		end

		local curStr = exp
		if exp >= 100000000 then
			curStr = Desc.player_expStr2:format(exp/100000000)
		elseif exp >= 10000 then
			curStr = Desc.player_expStr1:format(exp/10000)
		end
		local nextStr = nextExp
		if nextExp >= 100000000 then
			nextStr = Desc.player_expStr2:format(nextExp/100000000)
		elseif nextExp >= 10000 then
			nextStr = Desc.player_expStr1:format(nextExp/10000)
		end
		ptitle:setText(curStr.."/"..nextStr)
	end
end








function PlayerInfoView:updateArrayList(array,heroRecordNum)
    --printTable(096,array,"updateArrayList")
	self.arrayList:setItemRenderer(function(index,obj)
		local heroInfo=	array[index+1]
		local cardCell=	BindManager.bindHeroCell(obj)
		if  heroInfo then
			local cardCell=	BindManager.bindHeroCell(obj)
			local category = DynamicConfigData.t_hero[heroInfo.code].category or DynamicConfigData.t_monster[heroInfo.code].category;
			if (category) then
				heroInfo.category = category;
			end
			obj:addClickListener(function ()
				printTable(096,heroInfo.uuid,"heroInfo.uuid")
				if (heroInfo.uuid) then
				    printTable(5656,heroInfo,"heroInfo")
					heroInfo.playerId=self.playerId
					local data = {
								playerInfo = heroInfo,
								heroArray = { heroInfo.uuid},
								index = 1
							}
							Dispatcher.dispatchEvent(EventType.HeroInfo_Show, data);
						else
							RollTips.show(Desc.Friend_cant_show);
						end
					end)
			cardCell:setData(heroInfo)			
	    else
			cardCell:setEmptyData()
		end
	end)
	self.arrayList:setNumItems(8)
	--self.arrayList:setData(array)
	--print(096,#HandbookModel.heroData,#DynamicConfigData.t_hero)
	self.heroBagInfo:setText(heroRecordNum.."/"..table.nums(DynamicConfigData.t_hero))
end

function PlayerInfoView:updateBadgeList(honorMedalWall)
	if not honorMedalWall then return end
	local equipedInfo = honorMedalWall.loadAchievementMedal or {}--HonorMedalModel.equipedMedal;
	self.badgeList:setItemRenderer(function(idx,obj)
		local c1 = obj:getController("itemState");
		c1:setSelectedIndex(0);
		if (idx == 0) then
			local lv = honorMedalWall.honorCurLevel or 1--HonorMedalModel.honorLevel
			local conf = DynamicConfigData.t_MedalOfHonor[lv]
			if (conf) then
				c1:setSelectedIndex(1);
				obj:setIcon(string.format("Icon/medal/%s.png", conf.icon));
				obj:getChildAutoType("n0"):setVisible(false);
			end
		else
			if (equipedInfo[idx]) then
				local code = equipedInfo[idx].itemCode;
				local conf = DynamicConfigData.t_MedalOfAchievement[code]
				if (conf) then
					c1:setSelectedIndex(1);
					obj:setIcon(string.format("Icon/medal/%s.png", conf.icon))
				end
			end
		end
		if self.playerId == PlayerModel.userid then
			obj:removeClickListener();
			obj:addClickListener(function()
				ViewManager.open("MedalChooseView", {idx = idx});
			end)
			RedManager.register("HonorMedal_Equip_"..idx, obj:getChildAutoType("img_red"));
		end
	end)
	self.badgeList:setNumItems(6)
end

function PlayerInfoView:HonorMedal_update(_, honorMedalWall)
	if self.playerId == PlayerModel.userid then
		local data = {
			honorCurLevel = HonorMedalModel.honorLevel,
			loadAchievementMedal = HonorMedalModel.equipedMedal
		}
		self:updateBadgeList(data);
	end
end


function PlayerInfoView:player_headreset(_,id)
	print(33,"PlayerInfoView GamePlay_Modules_Rename_Succese")
	printTable(33,id)
	--if id then
	--	PlayerModel.head =id
	--end
	
	-- self.headbtn:setURL(PlayerModel:getUserHeadURL()) 
	self.headCell:setHead(PlayerModel.head, PlayerModel.level, PlayerModel.userid,nil,PlayerModel.headBorder);
	
end

function PlayerInfoView:player_rename_success(_,info)
	print(5656,"PlayerInfoView GamePlay_Modules_Rename_Succese")
	if not tolua.isnull(self.name) then
		self.name:setText(PlayerModel.username)
	end
end

return PlayerInfoView