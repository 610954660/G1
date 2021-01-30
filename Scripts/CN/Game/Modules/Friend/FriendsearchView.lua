--added by xhd
--发现好友
local FriendsearchView,Super = class("FriendsearchView", View)
local caozuoType = GameDef.FriendListType.RecommendedList
local TimeUtil= require "Game.Utils.TimeUtil"
function FriendsearchView:ctor()
	self._packName = "Friend"
	self._compName = "FriendsearchView"
	self._isFullScreen = false
	--	self.allAddBtn = false
	self.list = false
	self.reflashBtn = false
	self.searchTxt = false
	self.txt_hint = false
	self.searchBtn = false
	self.noControl = false
	self.btn_addAll = false
	self.data = false
	self.timer = false
	
	self._countDownTimerId = false --刷新按钮倒计时timerid
	self._refreshInterval = 10  --刷新最短时间间隔
end

function FriendsearchView:_initUI( )
	print(1,"FriendsearchView _initUI")
	--    self.allAddBtn = self.view:getChildAutoType("allAddBtn") --全部添加
	self.list = self.view:getChildAutoType("list")
	self.reflashBtn = self.view:getChildAutoType("reflashBtn") --刷新
	self.searchTxt = self.view:getChildAutoType("searchTxt")
	self.txt_hint = self.view:getChildAutoType("txt_hint")
	self.searchBtn = self.view:getChildAutoType("searchBtn") --搜索按钮
	self.noControl = self.view:getController("c1") --没有数据控制器
	self.btn_addAll = self.view:getChildAutoType('btn_addAll'); -- 全部添加
	
	self.searchTxt:onChanged(function (content)
		self.txt_hint:setVisible(#content == 0)
    end);
	self:init_listShow()
	-- self.searchTxt:setDefaultColor()
	-- self:startRefreshBtnCountdown()
	local params = {}
	params.type = caozuoType
	params.onSuccess = function (res )
		--printTable(1,res)
		self.data = res.list
		if (tolua.isnull(self.view)) then return end;
		self:update_list()
	end
	RPCReq.Friend_List(params, params.onSuccess)
end

function FriendsearchView:init_listShow( ... )
	self.list:setItemRenderer(function (index,obj)
		obj:getController('c1'):setSelectedPage('find');
		local name_label = obj:getChildAutoType("name_label") --名称
		-- local levi_label = obj:getChildAutoType("levi_label") --等级
		local warNum = obj:getChildAutoType("warNum") --战力
		local Guildtxt = obj:getChildAutoType("Guildtxt") --工会
		local genderControl = obj:getChildAutoType("gender"):getController("c1") --性别控制
		
		local applyBtn = obj:getChildAutoType("btn_add") --申请好友
		local headBtn = obj:getChildAutoType("headBtn") --头像
		--local headIcon = headBtn:getChildAutoType("icon")
		local curData = self.data[index+1]
		local headItem = BindManager.bindPlayerCell(headBtn)
		headItem:setHead(curData.head, curData.level, curData.playerId,nil,curData.headBorder)
		printTable(1,curData)
		
		name_label:setText(curData.name)
		-- levi_label:setText("等级："..curData.level)
		--headIcon:setURL(PlayerModel:getUserHeadURL(curData.head))
		warNum:setText(StringUtil.transValue(curData.tower))
		if curData.guild>0 and curData.guildName then
			Guildtxt:setText(curData.guildName)
		else
			Guildtxt:setText(Desc.Friend_check_txt4)
		end
		
		if curData.sex==1 then
			genderControl:setSelectedIndex(0)
		else
			genderControl:setSelectedIndex(1)
		end
		
		applyBtn:setGrayed(false)
		applyBtn:setTouchable(true)
		applyBtn:removeClickListener(333)
		applyBtn:addClickListener(function ( ... )
			local friendList = FriendModel:getData(GameDef.FriendListType.FriendList);
			if (friendList and #friendList > FriendModel.maxFriendLimit) then
				RollTips.show(Desc.Friend_maxFriend);
				return;
			end
			print(1,"申请添加好友")
			local params = {}
			params.type =0
			params.playerId =curData.playerId
			params.onSuccess = function (res )
				RollTips.show(Desc.Friend_send);
				--printTable(1,res)
				if (tolua.isnull(self.view)) then return end;
				applyBtn:setTouchable(false)
				applyBtn:setGrayed(true)
			end
			RPCReq.Friend_Apply(params, params.onSuccess)
		end,333)
	end)
end


--开始计时
function FriendsearchView:startRefreshBtnCountdown()
	if self._countDownTimerId then
		TimeLib.clearCountDown(self._countDownTimerId)
	end
	local lashTime  = ModelManager.FriendModel:getLastRefreshTime()
	local timePass = ServerTimeModel:getServerTime() - lashTime
	if (timePass < self._refreshInterval) then
		local timeLeft = self._refreshInterval - timePass
		
		self._countDownTimerId = TimeUtil.upCompEnable(self.reflashBtn , timeLeft ,DescAuto[116],  false ) -- [116]="%s秒"
		--[[local function onCountDown( time )
		local timeLeft = self._refreshInterval - (ServerTimeModel:getServerTime() - lashTime)
		if (timeLeft > 0) then
			self.reflashBtn:setTitle(timeLeft.."s")
		else
			self.reflashBtn:setTouchable(true)
			self.reflashBtn:setTitle(DescAuto[117]) -- [117]="刷新"
		end
	end
	local function onEnd( ... )
		self.reflashBtn:setTouchable(true)
		self.reflashBtn:setTitle(DescAuto[117]) -- [117]="刷新"
	end
	self.reflashBtn:setTouchable(false)
	onCountDown()
	self._countDownTimerId = TimeLib.newCountDown(timeLeft, onCountDown, onEnd, false, false)--]]
end
end


function FriendsearchView:update_list( ... )
	print("update_list")
	self.list:setData(self.data)
	if #self.data <= 0 then
		self.noControl:setSelectedIndex(1)
	else
		self.noControl:setSelectedIndex(0)
	end
end

function FriendsearchView:_initEvent( )
	self.reflashBtn:addClickListener(function ( ... )
		local lashTime  = ModelManager.FriendModel:getLastRefreshTime()
		local timePass = ServerTimeModel:getServerTime() - lashTime
		print(1,"FriendsearchView refresh ", timePass)
		if lashTime == -1 or timePass >= self._refreshInterval then
			local params = {}
			params.type = caozuoType
			params.onSuccess = function (res )
				RollTips.show(Desc.Friend_check_txt10);
				-- printTable(1,res)
				self.data = res.list
				if (tolua.isnull(self.view)) then return end;
				self:update_list()
			end
--			self.list:setData({})
			-- ModelManager.FriendModel:setLastRefreshTime(ServerTimeModel:getServerTime())
			-- self:startRefreshBtnCountdown()
			RPCReq.Friend_List(params, params.onSuccess)
			Dispatcher.dispatchEvent("flash_start_timer")
		else
			RollTips.show(Desc.Friend_check_txt5)
		end
	end)
	--[[ self.allAddBtn:addClickListener(function( ... )
	local params = {}
	params.type =1
	params.onSuccess = function (res )
		-- self.data = res.list
		-- self:update_list()
		print(1, "FriendsearchView apply all success")
	end
	RPCReq.Friend_Apply(params, params.onSuccess)
end)--]]

	self.searchBtn:addClickListener(function ( ... )
		print(1,self.searchTxt:getText())
		if StringUtil.trim(self.searchTxt:getText())== "" then
			RollTips.show(Desc.Friend_check_txt6)
			return
		end
		print(1,StringUtil.trim(self.searchTxt:getText()))
		-- print(1,StringUtil.trim(self.data.name))
		if self.searchTxt:getText()==ModelManager.PlayerModel.username then
			RollTips.show(Desc.Friend_check_txt7)
			return
		end
		local params = {}
		params.name = self.searchTxt:getText()
		params.onSuccess = function (res )
			--printTable(1,res)
			self.data = res.list
			if (tolua.isnull(self.view)) then return end;
			self:update_list()
		end
		RPCReq.Friend_Search(params, params.onSuccess)
	end)

	self.btn_addAll:addClickListener(function ()
		local items = self.list:getChildren();
		local applyList = {};
		local btnList = {};
		for k, obj in ipairs(items) do
			local btn_add = obj:getChildAutoType("btn_add");
			if (not btn_add:isGrayed()) then
				table.insert(applyList, self.data[k]);
				table.insert(btnList, btn_add);
			end
		end

		if (#applyList == 0) then
			RollTips.show(Desc.Friend_check_txt8);
		else
			local friendList = FriendModel:getData(GameDef.FriendListType.FriendList);
			if (friendList and #friendList > FriendModel.maxFriendLimit) then
				RollTips.show(Desc.Friend_maxFriend);
				return;
			end
			for k, d in ipairs(applyList) do
				local params = {}
				params.type =0
				params.playerId =d.playerId
				params.onSuccess = function (res )
					if (tolua.isnull(self.view)) then return end;
					btnList[k]:setTouchable(false)
					btnList[k]:setGrayed(true)
				end
				RPCReq.Friend_Apply(params, params.onSuccess)
			end
			RollTips.show(Desc.Friend_send);
		end
	end)
end


--页面退出时执行
function FriendsearchView:_exit( ... )
	print(1,"EmailView _exit")
	if self._countDownTimerId then
		--TimeLib.clearCountDown(self._countDownTimerId)
		TimeUtil.clearTime(self._countDownTimerId)
	end
end


return FriendsearchView
