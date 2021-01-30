--added by xhd 
--游戏好友
local caozuoType = GameDef.FriendListType.FriendList
local FriendView,Super = class("FriendView", View)
function FriendView:ctor()
	self._packName = "Friend"
	self._compName = "FriendView"
	self._isFullScreen = false
	self.lessnum = false
	self.totalnum = false
	self.btn_allSend = false
	self.btn_allGet = false;
	self.list = false
	self.onlinenum1 = false
	self.friendnum3 = false
	self.lessnum = false;
	self.onControl = false
	self.data = {}
end

function FriendView:_initUI( )
--    self.lessnum = self.view:getChildAutoType("lessnum")
   self.totalnum = self.view:getChildAutoType("totalnum") -- 好友币上限
   self.totalnum:setText("/"..FriendModel.maxFriendMoneyLimit);
   self.btn_allSend = self.view:getChildAutoType("btn_allSend")
   self.btn_allGet = self.view:getChildAutoType("btn_allGet");
   RedManager.register("V_FRIEND_MONEY", self.btn_allGet:getChildAutoType("img_red"));
   self.list = self.view:getChildAutoType("list")
   self.onlinenum1 = self.view:getChildAutoType("onlinenum1")
   self.friendnum3 = self.view:getChildAutoType("friendnum3") -- 好友数上限
   self.friendnum3:setText("/"..FriendModel.maxFriendLimit);
   self.lessnum = self.view:getChildAutoType("lessnum");
   self.noControl = self.view:getController("c1")
   self:init_listShow()
   local params = {}
   params.type = GameDef.FriendListType.FriendList
   params.onSuccess = function (res )
      if res.type == GameDef.FriendListType.FriendList then
		 self.data = res.list
         ModelManager.FriendModel:initData(GameDef.FriendListType.FriendList,res.list)
		 if (tolua.isnull(self.view)) then return end;
         self:update_list()
      end 
   end
   RPCReq.Friend_List(params, params.onSuccess)
end

function FriendView:init_listShow( ... )
	self.list:setItemRenderer(function(index,obj)
		obj:getController('c1'):setSelectedPage('friend');
	   local name_label = obj:getChildAutoType("name_label") --名称
	   local dateLabel = obj:getChildAutoType("dateLabel") --在线
	--    local levi_label = obj:getChildAutoType("levi_label") --等级
	   local warNum = obj:getChildAutoType("warNum") --战力
	   local Guildtxt = obj:getChildAutoType("Guildtxt") --工会
	   local genderControl = obj:getChildAutoType("gender"):getController("c1") --性别控制
	--    local aixinControl = obj:getChildAutoType("n19"):getController("c1")--爱心控制
	   local labalControl = obj:getController("labelColorCtrl")--文本变灰控制
	   local sendBtn = obj:getChildAutoType("btn_heart") --爱心赠送
	   local talkBtn = obj:getChildAutoType("btn_chat") --聊天
	   local btn_gift = obj:getChildAutoType("btn_gift") --赠礼
	    local showCtrl = talkBtn:getController("color")
	   local watchBtn = obj:getChildAutoType("btn_fight") --对抗
	   local headBtn = obj:getChildAutoType("headBtn") --头像
		local headItem = BindManager.bindPlayerCell(headBtn)
	   --local headIcon = headBtn:getChildAutoType("icon")
		
       local curData = self.data[index+1]
		headItem:setHead(curData.head, curData.level, curData.playerId,nil,curData.headBorder)
       -- printTable(1,curData)
       name_label:setText(curData.name)
    --    levi_label:setText("等级："..curData.level)
       if curData.sex==1 then
       	genderControl:setSelectedIndex(0)
       else
       	genderControl:setSelectedIndex(1)
       end
       --headIcon:setURL(PlayerModel:getUserHeadURL(curData.head))
       warNum:setText(StringUtil.transValue(curData.tower))
       if curData.guild>0 and curData.guildName then
       	Guildtxt:setText(curData.guildName)
       else
       	Guildtxt:setText(Desc.Friend_check_txt4)
       end
       

	   if curData.online then
       	  dateLabel:setText(Desc.Friend_online)
       	  labalControl:setSelectedIndex(0)
          showCtrl:setSelectedPage('green')
       else
       	labalControl:setSelectedIndex(1)
       	showCtrl:setSelectedPage('green')
       	  local timeSecond = ModelManager.ServerTimeModel:getServerTime() - math.ceil(curData.logoutMS/1000)
       	  local showTime = 0
       	  if timeSecond/86400 >= 1 then
				showTime = timeSecond/(3600*24);
       	  	 dateLabel:setText(string.format("%s(%.1f%s)",Desc.Friend_outline,showTime,Desc.Friend_day))
       	  else
	       	  if  timeSecond/3600 >=1 then
	       	  	  showTime = math.ceil(timeSecond/3600)
	       	  	  local miu = timeSecond - math.ceil(timeSecond/3600) * 3600
	       	  	  print(1,"miu",miu)
	       	  	  if miu>= 1800 then
	       	  	  	showTime  = showTime + 0.5
	       	  	  end
	       	  	  dateLabel:setText(string.format("%s(%.1f%s)",Desc.Friend_outline,showTime,Desc.Friend_hour))
	       	  else
	       	  	  if timeSecond>= 1800 then
	       	  	  	showTime  = 1
	       	  	  	dateLabel:setText(string.format("%s(%d%s)",Desc.Friend_outline,showTime,Desc.Friend_hour))
	       	  	  else
	       	  	  	showTime  = 0.5
	       	  	  	dateLabel:setText(string.format("%s(%.1f%s)",Desc.Friend_outline,showTime,Desc.Friend_hour))
	       	  	  end
				 end
       	  end
       	  
       	 
       end
       
	   headBtn:removeClickListener(333)
       headBtn:addClickListener(function( ... )
			ViewManager.open("ViewPlayerView",{playerId = curData.playerId})
       end,333)
	
		watchBtn:removeClickListener(333)
        watchBtn:addClickListener(function( ... )
            local params = {}
			params.playerId = curData.playerId
			ModelManager.ElvesSystemModel:getMyElvesBattleInfo(GameDef.BattleArrayType.FriendPK,true)
			ModelManager.ElvesSystemModel:getOtherElvesBattleInfo(params.playerId,GameDef.BattleArrayType.FriendPK)
			params.onSuccess = function (res )
		    end
		    RPCReq.Friend_PK(params, params.onSuccess)
       end,333)
		
		talkBtn:removeClickListener(333)
        talkBtn:addClickListener(function( ... )
			print(1,"update_chatClientPrivte")
			Dispatcher.dispatchEvent(EventType.update_chatClientPrivte, curData)
			-- if curData.online then
			-- 	Dispatcher.dispatchEvent(EventType.update_chatClientPrivte, curData)
			-- else
			-- 	RollTips.show(Desc.Friend_check_txt11)
			-- end
		end,333)

		btn_gift:removeClickListener(333)
		btn_gift:addClickListener(function( ... )
			ChatModel:openGiftView(1,curData,curData.playerId)
		end,333)
		
		local ctrlSend = sendBtn:getController("c1");
		local status = FriendModel:getFriendMoneyStatus(curData.playerId);
		ctrlSend:setSelectedIndex(status);
		sendBtn:setTouchable(status ~= 2); -- 不是置灰
		sendBtn:removeClickListener(22)
		sendBtn:addClickListener(function ()
		   	if (status == 0) then
				local param = {
					type = false,
					playerid = curData.playerId
				}
				RPCReq.Friend_ForwardMoney(param, function (param)
					print(2233, "=== 赠送好友币成功 ===", param);
					--printTable(1, param)
					RollTips.show(Desc.Friend_sent_friendMoney);
					FriendModel:sendFriendMoney(param.playerIdn)
				end)
			elseif (status == 1) then
				if (FriendModel.firendMoneyReceiveTimes * 10 >= FriendModel.maxFriendMoneyLimit) then
					RollTips.show(Desc.Friend_maxFriendMoney);
					return;
				end
				local param = {
					type = false,
					playerid = curData.playerId
				}
				print(1, "领取好友币", curData.playerId)
				RPCReq.Friend_ReceiveFriendMoney(param, function (param)
					print(1, "=== 领取好友币成功 ===", param);
					FriendModel:acceptFriendMoney(param.playerIdn);
					RollTips.show(Desc.Friend_get_friendMoney);
				end)
		   	end
	   	end, 22)
	end)
end
--更新数据列表
function FriendView:update_list( ... )
	if (not self.data ) then
		self.data = {}
	end
	self:sortByOffline();
	self:upBtnStatus();
	
	-- printTable(1, "好友列表", self.data)
	self.list:setData(self.data)
	if #self.data <= 0 then
		self.noControl:setSelectedIndex(1)
	else
		self.noControl:setSelectedIndex(0)
	end
	self.onlinenum1:setText(#self.data)
	self.lessnum:setText(FriendModel.firendMoneyReceiveTimes * 10);
end

function FriendView:friend_update_list( ... )
    print(1,"friend_update_list")
	self.data = ModelManager.FriendModel:getData(caozuoType)
	self:update_list()
end

function FriendView:_initEvent( )
    self.btn_allSend:addClickListener(function( ... )
       	    local params = {}
		    params.type = true;
		    -- params.playerId = self.searchTxt:getText()
			params.onSuccess = function (res)
				print(2233, "=== 友情点一键赠送 ====")
				--printTable(1, res);
				FriendModel:sendFriendMoney(res.playerIdn)
				RollTips.show(Desc.Friend_sent_friendMoney);
		        -- if res.type == caozuoType then
		        --    self.data = res.list
		        --    self:update_list()
		        -- end 
		    end
		    RPCReq.Friend_ForwardMoney(params, params.onSuccess)
	end)
	
	self.btn_allGet:addClickListener(function ()
		if (FriendModel.firendMoneyReceiveTimes * 10 >= FriendModel.maxFriendMoneyLimit) then
			RollTips.show(Desc.Friend_maxFriendMoney);
			return;
		end
		local params = {}
		params.type = true;
		-- params.playerId = self.searchTxt:getText()
		params.onSuccess = function (res)
			print(1, "=== 友情点一键领取 ====")
			LuaLogE(table.concat(res.playerIdn));
			FriendModel:acceptFriendMoney(res.playerIdn);
			RollTips.show(Desc.Friend_get_friendMoney);
			-- if res.type == caozuoType then
			--    self.data = res.list
			--    self:update_list()
			-- end 
		end
		RPCReq.Friend_ReceiveFriendMoney(params, params.onSuccess)
	end)
end

function FriendView: upBtnStatus()
	local allGetFlag = TableUtil.GetTableLen(FriendModel.firendMoneyAcceptList) == 0-- == TableUtil.GetTableLen(FriendModel.firendMoneyReceiveList)
	self.btn_allGet:setGrayed(allGetFlag);
	self.btn_allGet:setTouchable(not allGetFlag);

	local allSendFlag = TableUtil.GetTableLen(self.data) <= TableUtil.GetTableLen(FriendModel.firendMoneyList);
	self.btn_allSend:setGrayed(allSendFlag);
	self.btn_allSend:setTouchable(not allSendFlag);
end

function FriendView: sortByOffline()
	for _, curData in ipairs(self.data) do
		if curData.online then
			curData.offlineTimeCount = 0;
		else
			local timeSecond = ModelManager.ServerTimeModel:getServerTime() - math.ceil(curData.logoutMS/1000)
			local showTime = 0
			if timeSecond/86400 >= 1 then
				showTime = timeSecond/(3600*24);
				curData.offlineTimeCount = showTime*24; -- 用于排序
			else
				if timeSecond/3600 >=1 then
					showTime = math.ceil(timeSecond/3600)
					local miu = timeSecond - math.ceil(timeSecond/3600) * 3600
					if miu>= 1800 then
						showTime  = showTime + 0.5
					end
				else
					if timeSecond>= 1800 then
						showTime  = 1
					else
						showTime  = 0.5
					end
				end
				curData.offlineTimeCount = showTime; -- 用于排序
			end
		end
	end
	TableUtil.sortByMap(self.data, {{key="offlineTimeCount", asc= false}, {key="tower",asc = true}, {key = "playerId", asc=false}});
end

--页面退出时执行
function FriendView:_exit( ... )
	print(1,"EmailView _exit")
	FriendModel:clear()
end


return FriendView