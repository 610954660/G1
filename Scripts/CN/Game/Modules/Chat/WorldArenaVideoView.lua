

local WorldArenaVideoView,Super = class("WorldArenaVideoView", Window)

function WorldArenaVideoView:ctor()
	--LuaLog("TwistRuneTaskView ctor")
	self._packName = "Chat"
	self._compName = "WorldArenaVideoView"
	--self._rootDepth = LayerDepth.Window
	self.curOpenType=1
	self.gamePlayType=GameDef.GamePlayType.WorldArena
end


function WorldArenaVideoView:_initUI( )

	self.list_sortType=self.view:getChildAutoType("list_sortType")
	self.recordList=self.view:getChildAutoType("recordList")
	self.noneData=self.view:getChildAutoType("noneData")
	--BindManager.bindRecordMenu(self.recordMenu)
	self.list_sortType:setSelectedIndex(0)
	ChatModel:requestTotalRecord(self.gamePlayType,function()self:setRecordData(self.curOpenType)end)
	self.list_sortType:regUnscrollItemClick(function (i)
			if i==2 then --标签2 在世界擂台赛没有变成标签3
				i=3 
			end
		self:setRecordData(i+1)
	end)
end

--竞技场录像数据
function WorldArenaVideoView:setRecordData(type)
	self.curOpenType=type
	local recordData=ChatModel:getVideoRecordData(self.gamePlayType)
	local records
	if recordData then
		records=recordData.records[type]
	end

	self.recordList:setVisible(records~=nil)
	self.noneData:setVisible(not records)
	if not  records then
		return
	end
	self.recordList:setVirtual()
	self.recordList:setItemRenderer(function(index,obj)
			local recordItem=BindManager.bindRecordCell(obj)
			local recordInfos=false
			if self.gamePlayType==GameDef.GamePlayType.WorldArena then
				recordInfos=recordData.arenaRecordings[records.recordIds[index+1]]
			else
				recordInfos=recordData.higherPvpRecordings[records.recordIds[index+1]]
			end
			if recordInfos then
				recordItem:setData(recordInfos,self.gamePlayType,type)
			else
				LuaLogE(records.recordIds[index+1],DescAuto[59]) -- [59]="找不到这条记录的信息"
			end

		end)
	
	self.recordList:setItemProvider(function(index)
			if self.gamePlayType==GameDef.GamePlayType.WorldSkyPvp then
				return "ui://Chat/higerRecordtem"
			else
				return "ui://Chat/arenaRecordItem"
			end
	end)
	self.recordList:setNumItems(#records.recordIds)

end

function WorldArenaVideoView:update_VideoTotalRecord( _, args )
	--ChatModel:requestWorldArenaTotalRecord()
	if args.secondPage then
		if args.secondPage==1 then
			self.gamePlayType=GameDef.GamePlayType.WorldArena
		elseif args.secondPage==2 then
			self.gamePlayType=GameDef.GamePlayType.WorldSkyPvp
		end
		print(5656,"世界擂台赛多页签切换"..args.secondPage)
		ChatModel:requestTotalRecord(self.gamePlayType,function()self:setRecordData(self.curOpenType)end)
	elseif args.gamePlayType==self.gamePlayType then
		print(5656,"世界擂台赛数据更新"..args.gamePlayType)
		ChatModel:requestTotalRecord(self.gamePlayType,function()self:setRecordData(self.curOpenType)end)
	end
	
end


return WorldArenaVideoView
