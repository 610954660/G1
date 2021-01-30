local CrossArenaPVPSlectedView,Super = class("CrossArenaPVPSlectedView", Window)

function CrossArenaPVPSlectedView:ctor()
	self._packName = "CrossArenaPVP"
	self._compName = "CrossArenaPVPSlectedView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.challengeData = self._args.challengeList
end

function CrossArenaPVPSlectedView:_initEvent()
	
end

function CrossArenaPVPSlectedView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossArenaPVP.CrossArenaPVPSlectedView
	self.closeButton = viewNode:getChildAutoType('$closeButton')--GLabel
	self.addTicket = viewNode:getChildAutoType('addTicket')--GButton
	self.challengeList = viewNode:getChildAutoType('challengeList')--GList
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.leftTicket = viewNode:getChildAutoType('leftTicket')--GTextField
	self.refreshBtn = viewNode:getChildAutoType('refreshBtn')--GButton
	self.ticketIcon = viewNode:getChildAutoType('ticketIcon')--GLoader
	self.txt_myCombat = viewNode:getChildAutoType('txt_myCombat')--GTextField
	--{autoFieldsEnd}:CrossArenaPVP.CrossArenaPVPSlectedView
	--Do not modify above code-------------
end

function CrossArenaPVPSlectedView:_initUI()
	self:_initVM()
	local fight = ModelManager.CardLibModel:getFightVal() or 0
	self.txt_myCombat:setText(fight)
	local ticketCode = DynamicConfigData.t_CrossArenaConfig[1].ticketCode
	local url = ItemConfiger.getItemIconByCode(ticketCode, 3, false)
	self.ticketIcon:setURL(url)
	self.ticketIcon:addClickListener(function()
		local itemData = ItemsUtil.createItemData({data = {type = 3, code =  DynamicConfigData.t_CrossArenaConfig[1].ticketCode, amount = 1}})
		ViewManager.open("ItemTips", {codeType = 3, id = DynamicConfigData.t_CrossArenaConfig[1].ticketCode,data = itemData})
	end)

	self.refreshBtn:addClickListener(function()
		RPCReq.CrossArena_GetChallengeList({},function(data)
			if tolua.isnull(self.view)then return end
			if next(data.challengeList) then
				self.challengeData = data.challengeList
				self:_refreshView()
			end
		end)
	end)

	self.challengeList:setItemRenderer(function(index,obj)
		local data = self.challengeList._dataTemplate[index + 1]
		obj:getChild("name"):setText(data.name)
		obj:getChild("fightCap"):setText(data.fightCap)
		obj:getChild("heroCell"):addClickListener(function()
			if data.playerId < 0 then
				RollTips.show(Desc.Friend_cant_show1)
				return 
			end
			local rankData = CrossArenaPVPModel:getRankData()
			local rank = 0
			for key,value in pairs(rankData) do
				if value.playerId == data.enemyId then
					rank = key
				end
			end
			data.rankIndex = rank
			ViewManager.open("CrossArenaPVPPlayerInfoView",data)
		end,99)
		local hero = BindManager.bindPlayerCell(obj:getChild("heroCell"))
		hero:setHead(data.head, data.level,nil,nil,nil)
		obj:getChild("cosumBtn/itemIcon"):setURL(url)
		obj:getChild("cosumBtn"):addClickListener(function()
			if self:checkTicket() then
				CrossArenaPVPModel:fightBegin(data)
			else
				RollTips.show(Desc.Arena_DetailsStr1)
			end
		end,99)
		obj:getChild("score"):setText(data.score)
		if CrossArenaPVPModel:getUsedFreeTimes() == 0 then
			obj:getChild("cosumBtn"):setTitle("x1")
		end
	end)
	
	self:_refreshView()
	self.addTicket:addClickListener(function()
		if CrossArenaPVPModel.severData.buyTimes < DynamicConfigData.t_CrossArenaConfig[1].ticketLimit then
			ViewManager.open("CrossArenShopView")
		else
			RollTips.show(Desc.Arena_DetailsStr2)
		end
	end)
	self:pack_item_change()
end

--查看门票
function CrossArenaPVPSlectedView:checkTicket()
	if CrossArenaPVPModel:getUsedFreeTimes() > 0 then
		return true
	end
	local code = DynamicConfigData.t_CrossArenaConfig[1].ticketCode
	local tickNum= PackModel:getItemsFromAllPackByCode(code)
	if tickNum > 0 then 
		return true
	end

	return false
end

function CrossArenaPVPSlectedView:pack_item_change(_, param)
    local code = DynamicConfigData.t_CrossArenaConfig[1].ticketCode
    if (code) then
        self.leftTicket:setText(PackModel:getItemsFromAllPackByCode(code))
    end
	self:_refreshView()
end
function CrossArenaPVPSlectedView:refresh_crossArenaPVPSlectedView()
	self.challengeList:setData(self.challengeData)
end
function CrossArenaPVPSlectedView:_refreshView()
	self.challengeList:setData(self.challengeData)
end

function CrossArenaPVPSlectedView:onExit_()

end

return CrossArenaPVPSlectedView