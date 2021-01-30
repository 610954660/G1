local CrossArenaPVPHistoryView,Super = class("CrossArenaPVPHistoryView", Window)

function CrossArenaPVPHistoryView:ctor()
	self._packName = "CrossArenaPVP"
	self._compName = "CrossArenaPVPHistoryView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
end

function CrossArenaPVPHistoryView:_initEvent()
	
end

function CrossArenaPVPHistoryView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossArenaPVPHistoryView
	self.closeButton = viewNode:getChildAutoType('$closeButton')--GLabel
	self.noneData = viewNode:getChildAutoType('$noneData')--GGroup
	self.recordList = viewNode:getChildAutoType('$recordList')--GList
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.hasRecord = viewNode:getController('hasRecord')--Controller
	--{autoFieldsEnd}:CrossPVP.CrossArenaPVPHistoryView
	--Do not modify above code-------------
end

function CrossArenaPVPHistoryView:_initUI()
	self:_initVM()
	self.closeButton:addClickListener(function()
		self:closeView()
	end)
	self.recordList:setVirtual()
	self.recordList:setItemRenderer(function(index, obj)
		local data = self.recordList._dataTemplate[index + 1]
		obj:getChild("name"):setText(data.name)
		obj:getChild("txt_fightCap"):setText(CrossArenaPVPModel:getSeverName(data.serverId))
		obj:getChild("headItem"):addClickListener(function()
			if data.enemyId < 0 then
				return RollTips.show(Desc.Friend_cant_show1)
			end
			local rankData = CrossArenaPVPModel:getRankData()
			local rank = 0
			for key,value in pairs(rankData) do
				if value.id == data.enemyId then
					rank = key
				end
			end
			data.rankIndex = rank
			ViewManager.open("CrossArenaPVPPlayerInfoView",data)
		end,99)
		local hero = BindManager.bindPlayerCell(obj:getChild("headItem"))
		hero:setHead(data.head, data.level,nil,nil,nil)
		obj:getChild("score"):setText(data.addScore > 0 and "+"..data.addScore or data.addScore)
		obj:getChild("recordBtn"):addClickListener(function()
			local battleeUuid = {}
			for key,value in pairs(data.recordIds) do
				table.insert(battleeUuid,value.recordId)
			end
			data.battleeUuid = battleeUuid
			ViewManager.open("CrossArenaPVPResultView",data)
		end,99)
		if data.isAttack then
			if data.addScore > 0  then
				obj:getController("ackTyp"):setSelectedIndex(0)
			else
				if data.canRevenge then
					obj:getController("ackTyp"):setSelectedIndex(4)
					local ticketCode = DynamicConfigData.t_CrossArenaConfig[1].ticketCode
					local url = ItemConfiger.getItemIconByCode(ticketCode, 3, false)
					local battleBt = obj:getChild("battle")
					battleBt:getChild("itemIcon"):setURL(url)
					if CrossArenaPVPModel:getUsedFreeTimes() == 0 then
						battleBt:setTitle("x1")
					end
					battleBt:addClickListener(function()
						if self:checkTicket() then
							CrossArenaPVPModel:fightBegin({serverId = data.serverId,playerId = data.enemyId,logId = data.logId})
						else
							RollTips.show(Desc.Arena_DetailsStr1)
						end
					end,99)
				else
					obj:getController("ackTyp"):setSelectedIndex(1)
				end
				
			end
		else
			if data.addScore >= 0  then
				obj:getController("ackTyp"):setSelectedIndex(2)
			else
				if data.canRevenge then
					obj:getController("ackTyp"):setSelectedIndex(4)
					local ticketCode = DynamicConfigData.t_CrossArenaConfig[1].ticketCode
					local url = ItemConfiger.getItemIconByCode(ticketCode, 3, false)
					local battleBt = obj:getChild("battle")
					battleBt:getChild("itemIcon"):setURL(url)
					if CrossArenaPVPModel:getUsedFreeTimes() == 0 then
						battleBt:setTitle("x1")
					end
					battleBt:addClickListener(function()
						if self:checkTicket() then
							CrossArenaPVPModel:fightBegin({serverId = data.serverId,playerId = data.enemyId,logId = data.logId})
						else
							RollTips.show(Desc.Arena_DetailsStr1)
						end
					end,99)
				else
					obj:getController("ackTyp"):setSelectedIndex(3)
				end
			end
		end
		if data.fightMs then
			local lastTime = math.floor(ServerTimeModel:getServerTime() - data.fightMs/1000)
			if lastTime < 0 then lastTime = 0 end
			local desc = ""
			if lastTime >= 0 and lastTime <= 60 * 60 then
				desc = string.format(Desc.CrossPVPDesc15,math.floor(lastTime / 60))
			elseif lastTime >= 60 * 60 and lastTime <= 60 * 60 * 24 then
				desc = string.format(Desc.CrossPVPDesc16,math.floor(lastTime / 3600))
			elseif lastTime >= 60 * 60 * 24 then
				desc = string.format(Desc.CrossPVPDesc17,math.floor(lastTime / (3600 * 24)))
			end
			obj:getChild("time"):setText(desc)
		else
			obj:getChild("time"):setText("")
		end
	end)
	CrossArenaPVPModel:checkRecord(function(list)
		if tolua.isnull(self.view)then return end
		self.recordList:setData(list)
		self.hasRecord:setSelectedIndex(next(list) and 1 or 0)
	end)
	self:_refreshView()
end

--查看门票
function CrossArenaPVPHistoryView:checkTicket()
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
function CrossArenaPVPHistoryView:_refreshView()

end

function CrossArenaPVPHistoryView:onExit_()

end

return CrossArenaPVPHistoryView