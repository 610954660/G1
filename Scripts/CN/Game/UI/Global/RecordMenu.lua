--added by wyang
--道具框封裝
local RecordMenu = class("RecordMenu")
function RecordMenu:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	self.data=false
end


function RecordMenu:init( ... )
	self.channelMenu= self.view:getChildAutoType("channelMenu")--
	self.btn_share= self.view:getChildAutoType("btn_share")--
	self.dataBtn= self.view:getChildAutoType("dataBtn")--
	self.saveBtn = self.view:getChildAutoType("saveBtn")--
	self.thumbupBtn = self.view:getChildAutoType("thumbupBtn")--
	self.likeNum=self.view:getChildAutoType("likeNum")
	self.shareListCtr=self.view:getController("button")
	
	--self.arrayCtr=self.view:getController("arrayType")
	
	self.seveDataCtr=self.saveBtn:getController("haveData")
	
	self.thumbImgred=self.thumbupBtn:getChildAutoType("img_red")
	
	self:_initEvent()
end


function RecordMenu:_initEvent()
	
	self.channelMenu:regUnscrollItemClick(function (i)
			print(5656,"分享按钮"..i)
			self.shareListCtr:setSelectedIndex(0)
			local chatType=false
			if i==0 then
				chatType=ChatModel.ChatType.World
			end
			if i==1  then
				if not GuildModel.guildHave then
					RollTips.show(Desc.Friend_check_txt4)
					return 
				end
				chatType=ChatModel.ChatType.Guild
			end
			if i==2 then
				chatType=ChatModel.ChatType.Crossrealm
			end
			if i==3 then
				chatType=ChatModel.ChatType.worldCross
			end
			self.data.chatType=chatType		
			local function success(serverInfo)
				Dispatcher.dispatchEvent(EventType.update_chatClientVideoShare,{recordInfo=self.data});		
			end
			local info={
				gamePlayType  =  self.data.gamePlayType ,
				recordId   =     self.data.recordId   ,
				fromBattleRecordType= self.data.fromBattleRecordType,
			}
			RPCReq.BattleRecord_Share(info, success)
			
	end)

    self.view:addClickListener(function ()
			self.shareListCtr:setSelectedIndex(0)
	end)
	self.btn_share:addClickListener(function (context)
			context:stopPropagation()
	end)
	
	self.saveBtn:addClickListener(function ()
		self:saveRecord()
	end)
	
	self.thumbupBtn:addClickListener(function ()
		self:addLikeRecord()
	end)
	
	self.dataBtn:addClickListener(function ()		
		local params={
			recordId =	self.data.recordId,
			gamePlayType	=self.data.gamePlayType,
		}
		local success=function(data)
				
		end	
	    local battleData=ChatModel:getBattleData(self.data.gamePlayType,params.recordId)	
		if battleData then
			ViewManager.open("BattledataView",{isWin=battleData.result,isRecord=true,battleData=battleData})
		else
			--BattleModel:requestBattleRecord(params.recordId,success,params.gamePlayType)
		end

	end)

end

function RecordMenu:saveRecord()
	local params={
		gamePlayType	=self.data.gamePlayType,
		recordId =	self.data.recordId,	
	}
	local function success(data)
		printTable(5656, "收藏记录返回", data)
		if data.succeed then
			if self.seveDataCtr:getSelectedIndex()==0 then
				self.seveDataCtr:setSelectedIndex(1)
			else
				self.seveDataCtr:setSelectedIndex(0)
			end			
			Dispatcher.dispatchEvent(EventType.update_VideoTotalRecord,{gamePlayType=self.data.gamePlayType});
		end
	end
	printTable(5656, "收藏记录请求", params)
	RPCReq.BattleRecord_Collect(params, success)
	
end


function RecordMenu:addLikeRecord()
	local params={
		gamePlayType	=self.data.gamePlayType,
		recordId =	self.data.recordId,
		serverId=self.data.serverId
	}
	local function success(data)
		printTable(5656, "点赞记录返回", data)
		self.data.curLikes=data.likesNum
		self.likeNum:setText("+"..data.likesNum)
		self.thumbupBtn:getController("haveData"):setSelectedIndex(1)--自己已经点赞改变颜色
		self.thumbImgred:setVisible(false)
		Dispatcher.dispatchEvent(EventType.update_VideoTotalRecord,{gamePlayType=self.data.gamePlayType});
	end
	printTable(5656, "点赞记录请求", params)
	RPCReq.BattleRecord_AddLikes(params, success)
end



function RecordMenu:setData(data)
    self.data=data
	local serverId=math.tointeger(LoginModel:getLoginServerInfo().unit_server)
	self.data.serverId=self.data.serverId or serverId
	if data.curLikes and data.curLikes>0 then
		self.likeNum:setText("+"..data.curLikes)
		self.view:getChildAutoType("showLikes"):setVisible(true)
	else
		self.view:getChildAutoType("showLikes"):setVisible(false)
	end
	
	local getAddLikeData=ChatModel:getAddLikeData() 
	printTable(565600,getAddLikeData,"getAddLikeData")
	self.seveDataCtr:setSelectedIndex(0)
	local recordData=ChatModel:getVideoRecordData(self.data.gamePlayType)
	if recordData and recordData.records and recordData.records[4] then
		for k, record in pairs(recordData.records[4].recordIds) do
			print(5656,record,self.data.recordId,"self.data.recordId")
			if self.data.recordId==record then
				self.seveDataCtr:setSelectedIndex(1)--自己已经收藏的改变颜色
				break;
			end
		end	
	end
	if data.curLikes and getAddLikeData[self.data.gamePlayType] and  getAddLikeData[self.data.gamePlayType].likeList[self.data.recordId] then
		self.thumbupBtn:getController("haveData"):setSelectedIndex(1)--自己已经点赞改变颜色
		self.thumbImgred:setVisible(false)
	else
		self.thumbupBtn:getController("haveData"):setSelectedIndex(0)--
		self.thumbImgred:setVisible(ChatModel:getAddLikeCount()<3)
	end
	if self.data.windowType=="share" then
		--self.arrayCtr:setSelectedPage("shareType")
		self.view:getController("windowType"):setSelectedIndex(1)
	end
end


--退出操作 在close执行之前
function RecordMenu:__onExit()
	print(1,"HeroCell __onExit")
end

return RecordMenu