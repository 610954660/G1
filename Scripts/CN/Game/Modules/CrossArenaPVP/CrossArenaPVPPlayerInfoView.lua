local CrossArenaPVPPlayerInfoView = class("CrossArenaPVPPlayerInfoView", Window)

function CrossArenaPVPPlayerInfoView:ctor()
    self._packName = "CrossArenaPVP"
    self._compName = "CrossArenaPVPPlayerInfoView"
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
	self.data.playerId = self.data.id or self.data.enemyId or self.data.playerId
end

function CrossArenaPVPPlayerInfoView:_initUI( )
	self.blacklistBtn = self.view:getChildAutoType("btn_black") -- ����
	self.addBtn = self.view:getChildAutoType("btn_add")
	self.addBtn:setVisible(false)
	self.list_team = self.view:getChildAutoType('list_team') -- ���ж���
	self.name_label = self.view:getChildAutoType("name_label") --����
	self.Guildtxt = self.view:getChildAutoType("Guildtxt") --����

    self.txt_id = self.view:getChildAutoType('txt_id')
    self.btn_call = self.view:getChildAutoType("btn_call")

	self.serverName = self.view:getChildAutoType('serverName')
    self.rankIndex = self.view:getChildAutoType("rankIndex")
	self.txt_vip = self.view:getChildAutoType("vip")
	
	self.headBtn = self.view:getChildAutoType("heroCell") --ͷ��
	self.heroItem = BindManager.bindPlayerCell(self.headBtn)
	
	self.myselfCtrl = self.view:getController("myselfCtrl")
    
	if PlayerModel.userid == self.data.playerId then
		self.myselfCtrl:setSelectedIndex(1)
	else
		self.myselfCtrl:setSelectedIndex(0)
    end
			
    self.heroItem:setHead(self.data.head, self.data.level, self.data.playerId,nil,self.data.headBorder)
	self.name_label:setText(self.data.name)
	local rankIndex =  self.data.rank or 0
    local id = self.data.playerId < 0 and Desc.Friend_Text1 or self.data.playerId
    self.txt_id:setText(id)
    
    local isMyFriend = self.data and ModelManager.FriendModel:IsMyFriend(self.data.playerId)
    self.addBtn:setVisible(not isMyFriend)
    
	if (self.data.playerId > 0) then
		CrossArenaPVPModel:getPlayerArray(self.data.playerId, self.data.serverId, GameDef.GamePlayType.CrossArena)
	else -- ������
		self:CrossPVP_teamInfo(false, self.robotData)
	end

	self.serverName:setText(self.data.serverId)
	self.rankIndex:setText(rankIndex == 0 and "200+" or string.format(Desc.CrossPVPDesc14,rankIndex))

	local params = {}
	params.playerId = self.data.playerId
	params.serverId = self.data.serverId or LoginModel:getUnitServerId()
	params.arrayType = GameDef.BattleArrayType.ArenaDef
	RPCReq.Player_FindPlayer(params, function(data)
		if tolua.isnull(self.txt_vip) then return end
		self.txt_vip:setText("v"..data.playerInfo.vipLevel or "v0")
		self.view:getController('sex'):setSelectedIndex(tonumber(data.playerInfo.sex) - 1)
        self.Guildtxt:setText(data.playerInfo.guildName == "" and Desc.Friend_check_txt4 or data.playerInfo.guildName)
	end)

end

function CrossArenaPVPPlayerInfoView:CrossPVP_teamInfo(_, param)
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
						local data = {
							playerInfo = self.data,
							heroArray = heroList,
							index = idx1 + 1
						}
						Dispatcher.dispatchEvent(EventType.HeroInfo_Show, data)
					else
						RollTips.show(Desc.Friend_cant_show)
					end
				end)
			end)
			if #heroList > 0 and heroList[1].isHide then
				obj:getController("c1"):setSelectedIndex(1)
				obj:getChildAutoType("txt_teamCombat"):setText("???")
			else
				list:setNumItems(#heroList)
			end
        end)
        self.list_team:setNumItems(#arrayInfo)
    else
        ctrl:setSelectedIndex(0)
    end
end

function CrossArenaPVPPlayerInfoView:_initEvent( )
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
					ViewManager.close("CrossArenaPVPPlayerInfoView")
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

function CrossArenaPVPPlayerInfoView:check_update_panel( _,args )
	if args.playerId == self.data.playerId then
		self.data = args
	end
	local isMyFriend = self.data and ModelManager.FriendModel:IsMyFriend(self.data.playerId)
	self.addBtn:setVisible(not isMyFriend)
end


--ҳ���˳�ʱִ��
function CrossArenaPVPPlayerInfoView:_exit( ... )
end

return CrossArenaPVPPlayerInfoView