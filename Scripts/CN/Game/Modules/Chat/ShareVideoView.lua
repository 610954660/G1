

local ShareVideoView,Super = class("ShareVideoView", Window)

function ShareVideoView:ctor()
	--LuaLog("TwistRuneTaskView ctor")
	self._packName = "Chat"
	self._compName = "ShareVideoView"
	self._rootDepth = LayerDepth.PopWindow
	self.recordInfo=false

end


function ShareVideoView:_initUI( )
	self.recordList=self.view:getChild("recordList");
	self:setData()
	
end

function ShareVideoView:setData( )

	printTable(5656,self._args)
	
	local paramas= {
		gamePlayType      = self._args.gamePlayType,
		serverId          = self._args.serverId,
		recordId          = self._args.recordId
	}
	ChatModel:requestOneRecordInfo(paramas,function (data)
			self._args=data or self._args
			self._args.gamePlayType=paramas.gamePlayType
			self._args.recordId=paramas.recordId
			self._args.windowType="share"
			self:shareRecordList()
	end)
	

end





function ShareVideoView:shareRecordList()

	self.recordList:setItemRenderer(function (index,obj)
			local recordItem=BindManager.bindRecordCell(obj)
			recordItem:setData(self._args,self._args.gamePlayType)
		end)
	self.recordList:setItemProvider(function(index)
			if self._args.gamePlayType==GameDef.GamePlayType.HigherPvp or self._args.gamePlayType==GameDef.GamePlayType.WorldSkyPvp then
				return "ui://Chat/higerRecordtem"
			else

				return "ui://Chat/arenaRecordItem"
			end

	end)
	self.recordList:setNumItems(1)
end


function ShareVideoView:update_VideoTotalRecord( _, args )
	local paramas= {
		gamePlayType      = self._args.gamePlayType,
		serverId          = self._args.serverId,
		recordId          = self._args.recordId
	}
	ChatModel:requestOneRecordInfo(paramas,function (data)
			self._args=data or self._args
			self._args.gamePlayType=paramas.gamePlayType
			self._args.recordId=paramas.recordId
			self._args.windowType="share"
			self:shareRecordList()
	end)
end


return ShareVideoView