local CrossPVPPlayerInfoView = class("CrossPVPPlayerInfoView", Window)

function CrossPVPPlayerInfoView:ctor()
    self._packName = "CrossPVP"
    self._compName = "CrossPVPPlayerInfoView"
    self._rootDepth = LayerDepth.PopWindow
    self.__reloadPacket = true

	self.blacklistBtn = false
    self.btn_call = false
    self.list_team = false
	self.name_label = false
	self.Guildtxt = false
	self.headBtn = false
	self.headIcon = false
	self.data = self._args
	
	self.heroItem = false
	self.ctrl1 = false

	self.data.playerId = self.data.playerId or self.data.id
end

function CrossPVPPlayerInfoView:_initUI( )
	self.blacklistBtn = self.view:getChildAutoType("btn_black") -- 拉黑
	self.addBtn = self.view:getChildAutoType("btn_add")
	self.addBtn:setVisible(false)
	self.list_team = self.view:getChildAutoType('list_team') -- 所有队伍
	self.name_label = self.view:getChildAutoType("name_label") --名称
	self.Guildtxt = self.view:getChildAutoType("Guildtxt") --工会

    self.txt_id = self.view:getChildAutoType('txt_id')
    self.btn_call = self.view:getChildAutoType("btn_call")

	self.serverName = self.view:getChildAutoType('serverName')
    self.rankIndex = self.view:getChildAutoType("rankIndex")
	self.txt_vip = self.view:getChildAutoType("vip")
	
	self.headBtn = self.view:getChildAutoType("heroCell") --头像
	self.heroItem = BindManager.bindPlayerCell(self.headBtn)
	
	self.myselfCtrl = self.view:getController("myselfCtrl")
    
	if PlayerModel.userid == self.data.playerId then
		self.myselfCtrl:setSelectedIndex(1)
	else
		self.myselfCtrl:setSelectedIndex(0)
    end
			
    self.heroItem:setHead(self.data.head, self.data.level, self.data.playerId,nil,self.data.headBorder)
	self.name_label:setText(self.data.name)
	local rankIndex = self.data.rankLevel or self.data.rankIndex
    local id = self.data.playerId < 0 and Desc.Friend_Text1 or self.data.playerId
    self.txt_id:setText(id)
    
    local isMyFriend = self.data and ModelManager.FriendModel:IsMyFriend(self.data.playerId)
    self.addBtn:setVisible(not isMyFriend)
    
	if (self.data.playerId > 0) then
		CrossPVPModel:getPlayerArray(self.data.playerId, self.data.serverId, GameDef.GamePlayType.HorizonPvp)
	else -- 机器人
		self:CrossPVP_teamInfo(false, self.robotData)
	end

	self.serverName:setText(CrossPVPModel:getSeverName(self.data.serverId))
	self.rankIndex:setText(self.data.rankIndex == 0 and "200+" or string.format(Desc.CrossPVPDesc14,self.data.rankIndex))

	local params = {}
	params.playerId = self.data.playerId
	params.serverId = self.data.serverId or LoginModel:getUnitServerId();
	params.arrayType = GameDef.BattleArrayType.ArenaDef
	RPCReq.Player_FindPlayer(params, function(data)
		self.txt_vip:setText("v"..data.playerInfo.vipLevel or "v0")
		self.view:getController('sex'):setSelectedIndex(tonumber(data.playerInfo.sex) - 1)
        self.Guildtxt:setText(data.playerInfo.guildName == "" and Desc.Friend_check_txt4 or data.playerInfo.guildName)
	end)

end

function CrossPVPPlayerInfoView:CrossPVP_teamInfo(_, param)
	local arrayInfo = {}
	for id, info in pairs(param.arrayInfo) do
		table.insert(arrayInfo, info)
	end
	TableUtil.sortByMap(arrayInfo, {{key = "arrayType", asc = false}})
    local ctrl = self.view:getController("team")
    if (arrayInfo and #arrayInfo > 0) then
        ctrl:setSelectedIndex(1)
		self.list_team:setItemRenderer(function (idx, obj)
			local info = arrayInfo[idx + 1]
			local heroList = info.heroInfos

			local combat = 0
			if (param.playerInfo.playerId > 0) then
				for _, h in pairs(heroList) do
					combat = combat + h.combat
				end
			else
				combat = info.combat
			end
            obj:getController("index"):setSelectedIndex(idx)
            obj:getChildAutoType("txt_teamCombat"):setText(combat)
			local list = obj:getChildAutoType("list_team")
			
            list:setItemRenderer(function (idx1, obj1)
                local heroInfo = heroList[idx1 + 1]
                heroInfo.category = heroInfo.code > 100000 and DynamicConfigData.t_monster[heroInfo.code].category or DynamicConfigData.t_hero[heroInfo.code].category
                local heroCell = BindManager.bindHeroCell(obj1)
				heroCell:setBaseData(heroInfo)
				obj1:addClickListener(function ()
					if (heroInfo.uuid) then
						local nheroList = {}
						for key,heroData in pairs(heroList) do
							local hero = CrossPVPModel:getTempHeroInfo(heroData)
							table.insert(nheroList,hero)
						end
						local data = {
							playerInfo = {},
							heroArray = nheroList,
							index = idx1 + 1,
						}
						Dispatcher.dispatchEvent(EventType.HeroInfo_Show, data)
					else
						RollTips.show(Desc.Friend_cant_show)
					end
				end)
            end)
            list:setNumItems(#heroList)
        end)
        self.list_team:setNumItems(#arrayInfo)
    else
        ctrl:setSelectedIndex(0)
    end
end

function CrossPVPPlayerInfoView:_initEvent( )
	self.blacklistBtn:addClickListener(function ( ... )
		if self.data then
			local info = {}
			info.text = string.format(Desc.Friend_check_txt2, self.data.name)
			info.yesText = Desc.common_sure
			info.noText = Desc.common_cancel
			info.type = "yes_no"
			info.mask = true
			info.onYes = function ()
				local params = {}
				params.type =0
				params.playerId = self.data.playerId
				params.onSuccess = function (res )
					ModelManager.FriendModel:DeleteFriend(self.data)
					ModelManager.FriendModel:addBlack(self.data)
					ViewManager.close("CrossPVPPlayerInfoView")
				end
				RPCReq.Friend_InsetBlack(params, params.onSuccess)
			end
			info.onNo = function ()
			end
			Alert.show(info)
		end
	end)
	
	self.addBtn:addClickListener(function ( ... )
		local friendList = FriendModel:getData(GameDef.FriendListType.FriendList)
		if (friendList and #friendList > FriendModel.maxFriendLimit) then
			RollTips.show(Desc.Friend_maxFriend)
			return
		end
		local params = {}
		params.type = 0
		params.playerId =self.data.playerId
        params.onSuccess = function (res )
            RollTips.show(Desc.Friend_send)
			if (tolua.isnull(self.view)) then return end
			self.addBtn:setVisible(false)
			self:closeView()
		end
		RPCReq.Friend_Apply(params, params.onSuccess)
    end)
    
	self.btn_call:addClickListener(function ()
		if (self.data.playerId > 0) then
			Dispatcher.dispatchEvent(EventType.update_chatClientPrivte, self.data)
			self:closeView()
		else
			RollTips.show(Desc.Friend_cant_show1)
		end
    end)
end

function CrossPVPPlayerInfoView:check_update_panel( _,args )
	if args.playerId == self.data.playerId then
		self.data = args
	end
	local isMyFriend = self.data and ModelManager.FriendModel:IsMyFriend(self.data.playerId)
	self.addBtn:setVisible(not isMyFriend)
end


--页面退出时执行
function CrossPVPPlayerInfoView:_exit( ... )
end

return CrossPVPPlayerInfoView