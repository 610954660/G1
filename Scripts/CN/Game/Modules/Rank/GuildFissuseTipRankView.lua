--added by wyang 排行榜窗口
local GuildFissuseTipRankView,Super = class("GuildFissuseTipRankView",Window)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local wzNumCount = 30
local __OMITNUM  = 5 
function GuildFissuseTipRankView:ctor( data )
	self._packName = "Rank"
	self._compName = "GuildFissuseTipRankView"
	-- self._rootDepth = LayerDepth.PopWindow
	self.rankData = self._args.data.rankData
	self.rankIndex = self._args.data.rankIndex
end


function GuildFissuseTipRankView:_initUI( )
   self.closeBtn = self.view:getChildAutoType("closeBtn")
   self.list_rank = self.view:getChildAutoType("list_rank")
   self.txt_omitNum = self.view:getChildAutoType("txt_omitNum")
end

--事件初始化
function GuildFissuseTipRankView:_initEvent( ... )
	local omitCtrl = self.view:getController("omitCtrl")
	local totalNum = self._args.data.totalNum
	local omitNum  = self._args.data.totalNum - __OMITNUM
	omitCtrl:setSelectedIndex(omitNum>0 and 0 or 1)
	self.txt_omitNum:setText(string.format(Desc.guild_omitNumStr,omitNum))
	self.list_rank:setVirtual()
	self.list_rank:setItemRenderer(function(index,obj)
		local tempIndex = index+ 1
		local dwLoader = obj:getChildAutoType("dwLoader")
		local dwtxt = obj:getChildAutoType("dwtxt")
		local headItem = obj:getChildAutoType("headItem")
		local txt_name = obj:getChildAutoType("txt_name")
		local txt_attr1 = obj:getChildAutoType("txt_attr1")
		local btn_record = obj:getChildAutoType("btn_record")
		local img_bg = obj:getChildAutoType("img_bg")
		local data = self.rankData[tempIndex]
		local rankLevel = data.extraData.guildWorldBoss.rankLevel
		local url = PathConfiger.getBossDw(rankLevel)
	    dwLoader:setURL(url)
	    local rankConfig = GuildModel:getBossRankConfigByIndexs(1,rankLevel )
	    dwtxt:setText(PathConfiger.getDwtxt(rankLevel+29))
		txt_name:setText(data.name)
		txt_attr1:setText(data.value)
		local hero = BindManager.bindPlayerCell(headItem)
		printTable(1,"data",data)
		hero:setHead(data.head, data.level,data.id,nil,data.headBorder)
		btn_record:removeClickListener(100)
		btn_record:addClickListener(
			function(...)
				local tempData = {}
				tempData.battleId = data.battleId
				tempData.gamePlayType = GameDef.GamePlayType.GuildWorldBoss
				tempData.serverId = data.serverId
				printTable(1,"data",data)
				BattleModel:requestBattleRecord(tempData.battleId,nil,tempData.gamePlayType,tempData.serverId)
			end,100)

		img_bg:removeClickListener(100)
		img_bg:addClickListener(
			function(...)
				ViewManager.open("ViewPlayerView",{playerId = data.id, rank = rankLevel})
			end,100)
	end)
	self.list_rank:setData(self.rankData)
end


--initEvent后执行
function GuildFissuseTipRankView:_enter( ... )
	print(1,"GuildFissuseTipRankView _enter")
end


--页面退出时执行
function GuildFissuseTipRankView:_exit( ... )

	print(1,"GuildFissuseTipRankView _exit")
end

-------------------常用------------------------

return GuildFissuseTipRankView