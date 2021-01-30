--added by xhd
--好友申请列表
local caozuoType = GameDef.FriendListType.ApplyList
local FriendapplyView,Super = class("FriendapplyView", View)
function FriendapplyView:ctor()
	self._packName = "Friend"
	self._compName = "FriendapplyView"
	self._isFullScreen = false
	self.allAgreeBtn = false
	self.AllIgnoreBtn = false
	self.list = false
	self.onControl = false
	self.data = false
	self.notAddPlayer = false
end


function FriendapplyView:_initUI( )
	self.allAgreeBtn = self.view:getChildAutoType("btn_allAgree") --全部统一
	self.AllIgnoreBtn = self.view:getChildAutoType("btn_allRefuse") --全部忽略
	self.list = self.view:getChildAutoType("list") --list
	self.noControl = self.view:getController("c1") --空的控制器
	
	self:init_listShow()
	local params = {}
	params.type = caozuoType
	params.onSuccess = function (res )
		-- printTable(1, "好友申请列表", res)
		self.data = res.list
		ModelManager.FriendModel:initData(caozuoType,res.list)
		if (tolua.isnull(self.view)) then return end;
		self:update_list()
	end
	RPCReq.Friend_List(params, params.onSuccess)
end

--检测是否是添加失败的好友
function FriendapplyView:checkNotAddPlayer(playerId)
	if self.notAddPlayer and #self.notAddPlayer>0 then
		return TableUtil.Exist(self.notAddPlayer,playerId)
	end
	return false
end

function FriendapplyView:init_listShow( ... )
	self.list:setItemRenderer(function (index,obj)
		obj:getController('c1'):setSelectedPage('apply');
		local name_label = obj:getChildAutoType("name_label") --名称
		-- local levi_label = obj:getChildAutoType("levi_label") --等级
		local warNum = obj:getChildAutoType("warNum") --战力
		local Guildtxt = obj:getChildAutoType("Guildtxt") --工会
		local genderControl = obj:getChildAutoType("gender"):getController("c1") --性别控制
		
		local agreeBtn = obj:getChildAutoType("agreeBtn") --同意
		local refuseBtn = obj:getChildAutoType("refuseBtn") --拒绝
		local headBtn = obj:getChildAutoType("headBtn") --头像
		--local headIcon = headBtn:getChildAutoType("icon")
		local curData = self.data[index+1]
		local headItem = BindManager.bindPlayerCell(headBtn)
		headItem:setHead(curData.head, curData.level, curData.playerId,nil,curData.headBorder)
		
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
		agreeBtn:removeClickListener(333)
		agreeBtn:addClickListener(function ( ... )
			local firendList = ModelManager.FriendModel:getData(GameDef.FriendListType.FriendList) or {};
			local allFriendCount = TableUtil.GetTableLen(firendList)
			if (allFriendCount >= FriendModel.maxFriendLimit) then
				RollTips.show(Desc.Friend_maxFriend);
				agreeBtn:setGrayed(true)
			    agreeBtn:setTouchable(false)
				return;
			end
			local params = {}
			params.type =0
			params.playerId =curData.playerId
			params.onSuccess = function (res )
				print(1,"Friend_Agreed")
				printTable(1,res)
				if res.notAddPlayer and #res.notAddPlayer>0 then
					local friendList = ModelManager.FriendModel:getData(GameDef.FriendListType.FriendList) or {}
					local allFriendCount = TableUtil.GetTableLen(friendList);
					if (allFriendCount >= FriendModel.maxFriendLimit) then
						RollTips.show(Desc.Friend_maxFriend);
					else
						RollTips.show(Desc.Friend_maxFriend2);
					end
					if self.notAddPlayer and #self.notAddPlayer>0 then
						if not self:checkNotAddPlayer(res.notAddPlayer[1]) then
							table.insert(self.notAddPlayer,res.notAddPlayer[1])
						end
					else
						self.notAddPlayer =  res.notAddPlayer
					end
					if not(res.list and #res.list>0)  then
						if tolua.isnull(self.view) then
							return
						end
						self:update_list()
					end
				end
				--printTable(1,res)
				if res.list then
					ModelManager.FriendModel:DeleteApplyToFriend(res.list[1])
					ModelManager.FriendModel:JoinFriend(res.list[1])
				end
			end
			RPCReq.Friend_Agreed(params, params.onSuccess)
		end,333)

		if self:checkNotAddPlayer(curData.playerId) then
			agreeBtn:setGrayed(true)
			agreeBtn:setTouchable(false)
		else
			agreeBtn:setGrayed(false)
			agreeBtn:setTouchable(true)
		end
			
		refuseBtn:removeClickListener(333)
		refuseBtn:addClickListener(function ( ... )
			local params = {}
			params.type =0
			params.playerId =curData.playerId
			params.onSuccess = function (res )
				print(1,"Friend_RefusedApply")
				--printTable(1,res)
				if res.list then
					ModelManager.FriendModel:DeleteApplyToFriend(res.list[1])
				end
			end
			RPCReq.Friend_RefusedApply(params, params.onSuccess)
		end,333)
	end)
end
		
function FriendapplyView:update_list( ... )
	--[[ local friendList = ModelManager.FriendModel:getData(GameDef.FriendListType.FriendList) or {}
	local allFriendCount = TableUtil.GetTableLen(friendList); ]]
	if #self.data <= 0--[[  or allFriendCount >= FriendModel.maxFriendLimit ]] then
		self.noControl:setSelectedIndex(1)
	else
		self.list:setData(self.data)
		self.noControl:setSelectedIndex(0)
	end
end

function FriendapplyView:apply_update_list( ... )
	print(1,"apply_update_list")
	self.data = ModelManager.FriendModel:getData(caozuoType)
	self:update_list()
end

function FriendapplyView:_initEvent( )
	self.allAgreeBtn:addClickListener(function ( ... )
		local friendList = ModelManager.FriendModel:getData(GameDef.FriendListType.FriendList) or {}
		local allFriendCount = TableUtil.GetTableLen(friendList);
		if (allFriendCount >= FriendModel.maxFriendLimit) then
			RollTips.show(Desc.Friend_maxFriend);
		-- elseif (#self.data + allFriendCount > FriendModel.maxFriendLimit) then
		-- 	RollTips.show(Desc.Friend_willMaxFriend);
		else
			-- for i, d in ipairs(self.data) do
				local params = {}
				params.type =1
				-- params.playerId = d.playerId;
				params.onSuccess = function (res )
					printTable(1,res)
					if res.notAddPlayer and #res.notAddPlayer>0 then
						local friendList = ModelManager.FriendModel:getData(GameDef.FriendListType.FriendList) or {}
						local allFriendCount = TableUtil.GetTableLen(friendList);
						if (allFriendCount >= FriendModel.maxFriendLimit) then
							RollTips.show(Desc.Friend_maxFriend);
						else
							RollTips.show(Desc.Friend_maxFriend2);
						end
						self.notAddPlayer =  res.notAddPlayer
						
						-- RollTips.show(Desc.Friend_maxFriend);
						if not(res.list and #res.list>0)  then
							if tolua.isnull(self.view) then
								return
							end
							self:update_list()
						end
					end

					if res.list then
						for key, value in pairs(res.list) do
							ModelManager.FriendModel:DeleteApplyToFriend(value)
							ModelManager.FriendModel:JoinFriend(value)
						end
					end

				end
				RPCReq.Friend_Agreed(params, params.onSuccess)
			-- end
		end
	end)
	
	self.AllIgnoreBtn:addClickListener(function ( ... )
		for i, d in ipairs(self.data) do
			local params = {}
			-- params.type =1
			params.playerId = d.playerId;
			params.onSuccess = function (res )
				--printTable(1,res)
				if res.list then
					ModelManager.FriendModel:DeleteApplyToFriend(res.list[1])
				end
			end
			RPCReq.Friend_RefusedApply(params, params.onSuccess)
		end
	end)--
end


--页面退出时执行
function FriendapplyView:_exit( ... )
	print(1,"EmailView _exit")
end


return FriendapplyView