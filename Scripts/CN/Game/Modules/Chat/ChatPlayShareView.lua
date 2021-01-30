---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local ChatPlayShareView, Super = class("ChatPlayShareView", Window)

function ChatPlayShareView:ctor()
    self._packName = "Chat"
    self._compName = "ChatPlayShareView"
    self._rootDepth = LayerDepth.FaceWindow
    self.allCard=false
    self.curCardItem=false
    self.closeBtn2=false;
    self.list_type=false;
    self.list_card=false;
    self.img_shardbg=false
    self.curCardUid={}
	self.gamePlayType=GameDef.GamePlayType.Arena
end

function ChatPlayShareView:_initUI()
    local viewRoot = self.view
    self.allCard=ChatModel:getShareAllCards();
    --self.img_shardbg=viewRoot:getChild("img_shardbg");
   -- self.img_shardbg:setURL("UI/Chat/ChatPlayShareBg.png")
    self.closeBtn2=viewRoot:getChild("closeBtn2");
    self.list_type=viewRoot:getChild("list_type");
    self.list_card=viewRoot:getChild("list_card");
	self.recordList=viewRoot:getChild("recordList");
	self.noneData=viewRoot:getChild("noneData");
	self.list_sortType=self.view:getChildAutoType("list_sortType")
	
    self.list_type:setItemRenderer(function(index,obj)
		obj:removeClickListener(100)--池子里面原来的事件注销掉
		obj:addClickListener(
			function(context) 
                if index==0 then
                    self:showCardList()
                end
			end
		,100)
		if index==0 then
            obj:setSelected(true)
            self:showCardList()
		else
			obj:setSelected(false)
		end
	end)
	self.list_type:setNumItems(2);
    self:bindEvent()
	self.list_sortType:setSelectedIndex(0)
	ChatModel:requestTotalRecord(GameDef.GamePlayType.Arena,function()self:shareRecordList(3)end)
	self.list_sortType:regUnscrollItemClick(function (i)
			if i==0 then
				self.gamePlayType=GameDef.GamePlayType.Arena
				ChatModel:requestTotalRecord(self.gamePlayType,function()self:shareRecordList(3)end)
			else
				self.gamePlayType=GameDef.GamePlayType.HigherPvp
				ChatModel:requestTotalRecord(self.gamePlayType,function()self:shareRecordList(3)end)
			end
	end)
	
end


function ChatPlayShareView:showCardList()
    self.list_card:setVirtual()
    self.list_card:setItemRenderer(function(index,obj)
        local heroItem=self.allCard[index+1]
        if index+1==1 then
            printTable(12,">>>>>dsafadsf",heroItem)
        end
        local cardItem = BindManager.bindCardCell(obj)
		local uniqueWeaponLevel = heroItem.uniqueWeapon and heroItem.uniqueWeapon.level or -1
        cardItem:setData(heroItem,true)--{heroId = heroItem.heroId, heroStar = heroItem.star,level=heroItem.level, fashion = heroItem.fashion, uniqueWeapon = uniqueWeaponLevel}, true)
        cardItem:setCardNameVis(true)
        if self.curCardItem==heroItem.uuid then
            cardItem:setSelected(2);
        else
            cardItem:setSelected(0);
        end
		obj:removeClickListener(100)--池子里面原来的事件注销掉
		obj:addClickListener(
            function(context) 
                -- if self.curCardItem then
                --     self.curCardItem:setSelected(0);
                -- end 
                self.curCardUid={}
                self.curCardUid={cardId=heroItem.heroId,cardUuid=heroItem.uuid,cardStar=heroItem.star}
                self.curCardItem=heroItem.uuid;
                cardItem:setSelected(2);
                self.list_card:setNumItems(#self.allCard);
			end
        ,100)
      
	end
)
	self.list_card:setNumItems(#self.allCard);
end


function ChatPlayShareView:bindEvent()
    local sendBtn=self.view:getChild("sendBtn")
    sendBtn:addClickListener(
        function()
            local uuid = self.curCardUid.cardUuid;
            local info = {
                serverId = LoginModel:getLoginServerInfo().unit_server,
                playerId = PlayerModel.userid,
                heroUuid = uuid
            }
            RPCReq.Player_FindPlayerHeroInfo(info, function (params)
                if (params.rank and params.rank > 0) then
                    self.curCardUid.rank = params.rank;
                end
                Dispatcher.dispatchEvent(EventType.update_chatClientCardShare,self.curCardUid);
                ViewManager.close("ChatPlayShareView")
            end, function (fail)
                Dispatcher.dispatchEvent(EventType.update_chatClientCardShare,self.curCardUid);
                ViewManager.close("ChatPlayShareView")
            end)
        end
    )
    self.closeBtn2:addClickListener(
        function()
            ViewManager.close("ChatPlayShareView")
        end
    )
end

function ChatPlayShareView:_enter()
	
end


function ChatPlayShareView:shareRecordList(type)
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
			local recordInfos=false
			if self.gamePlayType==GameDef.GamePlayType.Arena then
				if recordData.arenaRecordings then
					recordInfos=recordData.arenaRecordings[records.recordIds[index+1]]
				end
			else
				if recordData.higherPvpRecordings then
					recordInfos=recordData.higherPvpRecordings[records.recordIds[index+1]]
				end
			end
			
			if recordInfos then
				recordItem:setData(recordInfos,self.gamePlayType,type)
			end
	end)
	self.recordList:setItemProvider(function(index)		
			if self.gamePlayType==GameDef.GamePlayType.Arena then
				return "ui://Chat/arenaRecordItem"
			else
				return "ui://Chat/higerRecordtem"
			end
			
	end)
	self.recordList:setNumItems(#records.recordIds)
end

function ChatPlayShareView:update_VideoTotalRecord( _, args )
	if args.gamePlayType==self.gamePlayType then
		ChatModel:requestTotalRecord(self.gamePlayType,function ()self:shareRecordList(3)end)
	end
end




function ChatPlayShareView:_exit()
    self.curCardUid={}
end


return ChatPlayShareView
