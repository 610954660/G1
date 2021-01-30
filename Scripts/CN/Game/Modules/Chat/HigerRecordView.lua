

local HigerRecordView,Super = class("HigerRecordView", Window)

function HigerRecordView:ctor()
	--LuaLog("TwistRuneTaskView ctor")
	self._packName = "Chat"
	self._compName = "HigerRecordView"
	--self._rootDepth = LayerDepth.Window
	self.gamePlayType=GameDef.GamePlayType.HigherPvp
	self.curOpenType=1
end


function HigerRecordView:_initUI( )

	self.list_sortType=self.view:getChildAutoType("list_sortType")
	self.recordList=self.view:getChildAutoType("recordList")
	self.noneData=self.view:getChildAutoType("noneData")
	--BindManager.bindRecordMenu(self.recordMenu)

	self.list_sortType:setSelectedIndex(0)
	ChatModel:requestTotalRecord(self.gamePlayType,function ()self:setRecordData(self.curOpenType) end)
	self.list_sortType:regUnscrollItemClick(function (i)
			self:setRecordData(i+1)
	end)
end




--天竞赛录像数据
function HigerRecordView:setRecordData(type)
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
	
	self.recordList:setVirtual()
	self.recordList:setItemRenderer(function(index,obj)
			local recordItem=BindManager.bindRecordCell(obj)
			local recordInfos=recordData.higherPvpRecordings[records.recordIds[index+1]]
			if recordInfos then
				recordItem:setData(recordInfos,GameDef.GamePlayType.HigherPvp,type)
			else
				LuaLogE(records.recordIds[index+1],DescAuto[59]) -- [59]="找不到这条记录的信息"
			end
			
		end)
	self.recordList:setNumItems(#records.recordIds)
	--self.recordList:removeEventListener(FUIEventType.Scroll, 100)
	--self.recordList:addEventListener(
		--FUIEventType.Scroll,
		--function(context)
			--local y = self.recordList:getScrollPane():getPosY()
			----print(5656,y,"移动的距离")
			--if y>520 then
				
			--end
			
	--end,100)
	
end

function HigerRecordView:update_VideoTotalRecord( _, args )
	if args.gamePlayType==self.gamePlayType then
		ChatModel:requestTotalRecord(self.gamePlayType,function ()self:setRecordData(self.curOpenType)end)
	end
end


	

return HigerRecordView
