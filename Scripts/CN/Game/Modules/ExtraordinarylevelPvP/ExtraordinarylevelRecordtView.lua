local ExtraordinarylevelRecordtView,Super = class("ExtraordinarylevelRecordtView", Window)

function ExtraordinarylevelRecordtView:ctor()
	self._packName = "ExtraordinarylevelPvP"
	self._compName = "ExtraordinarylevelRecordtView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
end

function ExtraordinarylevelRecordtView:_initEvent()
	
end

function ExtraordinarylevelRecordtView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.ExtraordinarylevelRecordtView
	self.closeButton = viewNode:getChildAutoType('$closeButton')--GLabel
	self.noneData = viewNode:getChildAutoType('$noneData')--GGroup
	self.recordList = viewNode:getChildAutoType('$recordList')--GList
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.hasRecord = viewNode:getController('hasRecord')--Controller
	--{autoFieldsEnd}:CrossPVP.ExtraordinarylevelRecordtView
	--Do not modify above code-------------
end

function ExtraordinarylevelRecordtView:_initUI()
	self:_initVM()
	self.closeButton:addClickListener(function()
		self:closeView()
	end)
	self.recordList:setVirtual()
	self.recordList:setItemRenderer(function(index, obj)
		local data = self.recordList._dataTemplate[index + 1]
		obj:getChild("name"):setText(data.playerData.name)
		obj:getChild("txt_fightCap"):setText(CrossPVPModel:getSeverName(data.playerData.serverId))
		obj:getChild("headItem"):addClickListener(function()
			-- if data.playerData and data.playerData.playerId < 0 then
			-- 	return RollTips.show(Desc.Friend_cant_show1)
			-- end
			-- --local rankData = CrossPVPModel:getRankData()
			-- local rank = 0
			-- -- for key,value in pairs(rankData.rank) do
			-- -- 	if value.playerId == data.playerData.playerId then
			-- -- 		rank = key
			-- -- 	end
			-- -- end
			-- data.playerData.rankIndex = rank
			-- ViewManager.open("CrossPVPPlayerInfoView",data.playerData)
			-- printTable(159,"打印的记录数据",data)
		end,99)
		local hero = BindManager.bindPlayerCell(obj:getChild("headItem"))
		hero:setHead(data.playerData.head, data.playerData.level,nil,nil,nil)
		obj:getChild("score"):setText(data.score > 0 and "+"..data.score or data.score)
		obj:getChild("recordBtn"):addClickListener(function()
			ViewManager.open("ExtraordinaryleveResultView",data)
		end,99)
		
		if data.promotion~=nil then
			if data.promotion==0 then--#晋级赛 0 赢  1 输 nil没有加入
				obj:getController("ackTyp"):setSelectedIndex(5)
			else
				obj:getController("ackTyp"):setSelectedIndex(4)
			end
		else
			if data.ackType == 1 then
				if data.win ==true then
					obj:getController("ackTyp"):setSelectedIndex(0)
				else
					obj:getController("ackTyp"):setSelectedIndex(1)
				end
			else
				if data.win==true then
					obj:getController("ackTyp"):setSelectedIndex(2)
				else
					obj:getController("ackTyp"):setSelectedIndex(3)
				end
			end
		end

		if data.time then
			local lastTime = math.floor(ServerTimeModel:getServerTime() - data.time/1000)
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
	RPCReq.CrossSuperMundane_Record({},function(data)
		local list = {}
		for key,value in pairs(data.record) do
			table.insert(list,1,value)
		end
		TableUtil.sortByMap(list, { {key="time",asc=true}} )
		self.recordList:setData(list)
		self.hasRecord:setSelectedIndex(next(list) and 1 or 0)
	end)
	self:_refreshView()
end


function ExtraordinarylevelRecordtView:_refreshView()

end

function ExtraordinarylevelRecordtView:onExit_()

end

return ExtraordinarylevelRecordtView