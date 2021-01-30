-- add by zn
-- 高阶竞技场玩家信息
local HigherPvPPlayerInfoView = class("HigherPvPPlayerInfoView", Window)

function HigherPvPPlayerInfoView:ctor()
    self._packName = "HigherPvP";
    self._compName = "HigherPvPPlayerInfoView";
    self._rootDepth = LayerDepth.Window;
    
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
	self.rankIcon = false;
	self.data = self._args
	
	self.heroItem = false
	self.ctrl1 = false

	self.data.playerId = self.data.playerId or self.data.id;
	if (self.data.playerId < 0) then
		self.robotData = HigherPvPModel:getRobotInfo(self.data.playerId, self.data.rankIndex)
		self.data = self.robotData.playerInfo
	end
end

function HigherPvPPlayerInfoView:_initUI( )
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
	self.heroItem = BindManager.bindPlayerCell(self.headBtn);
	self.rankIcon = self.view:getChildAutoType("rankIcon");
	
	
	-- self.ctrl1 = self.view:getController("c1")
	self.myselfCtrl = self.view:getController("myselfCtrl")
    
	
	if (self.data.playerId > 0) then
		local gameType = self._args.fromView == "worldChallenge" and GameDef.GamePlayType.WorldSkyPvp or GameDef.GamePlayType.HigherPvp
		HigherPvPModel:getPlayerArray(self.data.playerId, self.data.serverId, gameType);
	else -- 机器人
		self:HigherPvP_teamInfo(false, self.robotData)
	end
end

function HigherPvPPlayerInfoView:setBaseInfo()
	if PlayerModel.userid == self.data.playerId then
		self.myselfCtrl:setSelectedIndex(1)
	else
		self.myselfCtrl:setSelectedIndex(0)
    end
			
    self.heroItem:setHead(self.data.head, self.data.level, self.data.playerId,nil,self.data.headBorder)
	self.name_label:setText(self.data.name)
	print(2233, self.data.score);
	local rankIndex = self.data.rankLevel or self.data.rankIndex;
	local conf = DynamicConfigData.t_HPvPRank[rankIndex];
	if (conf) then
		self.warNum:setText(conf.rank);
		self.rankIcon:setIcon(string.format("Icon/rank/%d.png", conf.res));
	else
		self.warNum:setText(Desc.HigherPvP_NoRankName);
		self.rankIcon:setIcon("");
	end
	
    local id = self.data.playerId < 0 and Desc.Friend_Text1 or self.data.playerId
    self.txt_id:setText(id);
    -- self.view:getController('sex'):setSelectedIndex(tonumber(self.data.sex) - 1);
    
    local isMyFriend = self.data and ModelManager.FriendModel:IsMyFriend(self.data.playerId)
    self.deleteBtn:setVisible(isMyFriend)
    self.addBtn:setVisible(not isMyFriend)
    
    if self.data.guildName and self.data.guildName ~= "" then
        self.Guildtxt:setText(self.data.guildName)
    else
        self.Guildtxt:setText(Desc.Friend_check_txt4)
	end
	if (self._args.fromView == "worldChallenge") then
		self.deleteBtn:setVisible(false)
		self.addBtn:setVisible(false)
		self.blacklistBtn:setVisible(false)
		self.btn_call:setVisible(false)
	end
end

function HigherPvPPlayerInfoView:HigherPvP_teamInfo(_, param)
	if param.playerInfo then
		local value = self.data.value
		local rankLevel = self.data.rankLevel
		self.data = param.playerInfo
		if (value) then
			self.data.value = value;
		end
		if (rankLevel) then
			self.data.rankLevel = rankLevel;
		end
		self.view:getController('sex'):setSelectedIndex(tonumber(param.playerInfo.sex) - 1);
	end
	if (param.gamePlayInfo) then
		self.data.rankLevel = param.gamePlayInfo.higherPvpRank or 0;
	end
	if (self.data) then
		self:setBaseInfo()
	end
	local arrayInfo = {}
	for id, info in pairs(param.arrayInfo) do
		table.insert(arrayInfo, info)
	end
	TableUtil.sortByMap(arrayInfo, {{key = "arrayType", asc = false}})
    local ctrl = self.view:getController("team");
    if (arrayInfo and #arrayInfo > 0) then
        ctrl:setSelectedIndex(1);
		self.list_team:setItemRenderer(function (idx, obj)
			local info = arrayInfo[idx + 1]
			local heroList = info.heroInfos;

			local combat = 0
			if (param.playerInfo.playerId > 0) then
				for _, h in pairs(heroList) do
					combat = combat + h.combat
				end
			else
				combat = info.combat
			end
            obj:getController("c1"):setSelectedIndex(idx);
            obj:getChildAutoType("txt_teamCombat"):setText(StringUtil.transValue(combat));
			local list = obj:getChildAutoType("list_team");
			
            list:setItemRenderer(function (idx1, obj1)
                local d = heroList[idx1 + 1];
                d.category = d.code > 100000 and DynamicConfigData.t_monster[d.code].category or DynamicConfigData.t_hero[d.code].category;
                local heroCell = BindManager.bindHeroCell(obj1);
				heroCell:setBaseData(d);
				obj1:addClickListener(function ()
					if (d.uuid) then
						local data = {
							playerInfo = self.data,
							heroArray = heroList,
							index = idx1 + 1
						}
						printTable(2233, data);
						Dispatcher.dispatchEvent(EventType.HeroInfo_Show, data);
					else
						RollTips.show(Desc.Friend_cant_show);
					end
				end)
            end)
            list:setNumItems(#heroList);
        end)
        self.list_team:setNumItems(#arrayInfo);
    else
        ctrl:setSelectedIndex(0);
    end
end

function HigherPvPPlayerInfoView:_initEvent( )
	
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
					ViewManager.close("HigherPvPPlayerInfoView")
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

function HigherPvPPlayerInfoView:check_update_panel( _,args )
	-- printTable(1,"check_update_panel",args)
	if args.playerId == self.data.playerId then
		self.data = args
	end
	local isMyFriend = self.data and ModelManager.FriendModel:IsMyFriend(self.data.playerId)
	self.deleteBtn:setVisible(isMyFriend)
	self.addBtn:setVisible(not isMyFriend)
	if (self._args.fromView == "worldChallenge") then
		self.deleteBtn:setVisible(false)
		self.addBtn:setVisible(false)
		self.blacklistBtn:setVisible(false)
		self.btn_call:setVisible(false)
	end
end


--页面退出时执行
function HigherPvPPlayerInfoView:_exit( ... )
	print(1,"EmailView _exit")
end

return HigherPvPPlayerInfoView