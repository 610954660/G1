--投票面板
local VoteBoard = class("VoteBoard",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"
local BagType = GameDef.BagType
function VoteBoard:ctor(view,noClick)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	self.newsData = false
	self.playerList = false
end

function VoteBoard:init( ... )
	self.modelItem1 = self.view:getChildAutoType("modelItem1")
	self.modelItem2 = self.view:getChildAutoType("modelItem2")
	self.modelItem3 = self.view:getChildAutoType("modelItem3")
	self.img_title = self.view:getChildAutoType("img_title")
	
	
end

function VoteBoard:setTitle(titleId)
	self.img_title:setURL(PathConfiger.getEventBrocastTtitle(titleId))
end

function VoteBoard:setData(newsData)
	self.newsData = newsData 
	self.playerList = {}
	local myRecordInfo = EventBrocastModel.myRecordInfo.newsMap[newsData.id]
	for _,v in pairs(self.newsData.playerMap) do
		table.insert(self.playerList, v)
	end
	for i = 1,3 do
		local item = self.view:getChildAutoType("modelItem"..i)
		local btn = item:getChildAutoType("btn_vote")
		local txt_name = item:getChildAutoType("txt_name")
		local txt_level = item:getChildAutoType("txt_level")
		local txt_combat = item:getChildAutoType("txt_combat")
		
		
		local playerData = self.playerList[i]
		    --[[playerId        1:integer 
				index           2:integer  #排行榜名次 
				serverId        3:integer  #没有则为本服
				name            4:string
				level           5:integer
				head            6:integer
				guildName       7:string
				vip             8:integer
				headBorder      9:integer
				combat          10:integer--]]
		
		local lihui = item:getChildAutoType("lihui"):getChildAutoType("lihuiDisplay")
		local lihuiDisplay = BindManager.bindLihuiDisplay(lihui)
		if playerData then
			txt_name:setText(playerData.name)
			txt_level:setText(playerData.level)
			txt_combat:setText(StringUtil.transValue(playerData.combat))
			lihui:setVisible(true)
			btn:setVisible(true)
			lihuiDisplay:setData(playerData.head,nil,nil,nil, playerData.fashion or playerData.fashionCode)
		else
			lihui:setVisible(false)
			btn:setVisible(false)
		end
		
		if myRecordInfo and myRecordInfo.playerMap and myRecordInfo.playerMap[playerData.index] then
			btn:setGrayed(true)
			btn:setTouchable(false)
		else
			btn:setGrayed(false)
			btn:setTouchable(true)
		end
		btn:removeClickListener(88)
		btn:addClickListener(function( ... )
			EventBrocastModel:doAgree(self.newsData.id, playerData.index)
		end,88)
	end
end

function VoteBoard:EventBrocast_updateInfo()
	if not tolua.isnull(self.view) and self.newsData then
		self:setData(self.newsData)
	end
end
--退出操作 在close执行之前 

	
function VoteBoard:__onExit()
     print(086,"VoteBoard __onExit")
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return VoteBoard