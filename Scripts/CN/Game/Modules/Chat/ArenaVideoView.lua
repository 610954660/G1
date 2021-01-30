

local ArenaVideoView,Super = class("ArenaVideoView", Window)

function ArenaVideoView:ctor()
	--LuaLog("TwistRuneTaskView ctor")
	self._packName = "Chat"
	self._compName = "ArenaVideoView"
	--self._rootDepth = LayerDepth.Window
	self.showDataFunc=false
	self._tabBarName = "list_recordType"
	self.curOpenType=1
	self.gamePlayType=GameDef.GamePlayType.Arena
end


function ArenaVideoView:_initUI( )

	self.list_sortType=self.view:getChildAutoType("list_sortType")
	self.recordList=self.view:getChildAutoType("recordList")
	self.noneData=self.view:getChildAutoType("noneData")
	--BindManager.bindRecordMenu(self.recordMenu)
	self.list_sortType:setSelectedIndex(0)
	ChatModel:requestTotalRecord(self.gamePlayType,function()self:setRecordData(self.curOpenType)end)
	self.list_sortType:regUnscrollItemClick(function (i)
			self:setRecordData(i+1)
	end)
end

--竞技场录像数据
function ArenaVideoView:setRecordData(type)
	self.curOpenType=type
	local recordData=ChatModel:getVideoRecordData(self.gamePlayType)
	local records
	if recordData then
		records=recordData.records[type]
	end
	
	self.recordList:setVisible(records~=nil)
	self.noneData:setVisible(not records)
	if not records then
		return
	end
	
	--printTable(5656,recordData.recordings,"recordData.recordings")
	self.recordList:setVirtual()
	self.recordList:setItemRenderer(function(index,obj)
			local recordItem=BindManager.bindRecordCell(obj)
			local recordInfos=recordData.arenaRecordings[records.recordIds[index+1]]
			if recordInfos then
				recordItem:setData(recordInfos,GameDef.GamePlayType.Arena,type)
			else
				LuaLogE(records.recordIds[index+1],DescAuto[59]) -- [59]="找不到这条记录的信息"
			end
		end)
	self.recordList:setNumItems(#records.recordIds)

end

function ArenaVideoView:update_VideoTotalRecord( _, args )
	if args.gamePlayType==self.gamePlayType then
		ChatModel:requestTotalRecord(self.gamePlayType,function ()self:setRecordData(self.curOpenType)end)
	end
end



return ArenaVideoView
