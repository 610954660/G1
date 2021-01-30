--added by wyang 排行榜窗口
local RankView,Super = class("RankView",Window)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
function RankView:ctor( data )
	self._packName = "Rank"
	self._compName = "RankView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.list_type = false
	self.list_rank = false
	self.myRankItem = false
	self.txt_noData = false
	self.rankHead = false
	self.closeBtn = false
	self.c1 = false
	
	self._data = data
	self._openType = data.type
	self._groupData = false
	self._currentIndex = 1
	self._rankData = false
	self._myRank = 0 --自己的名次
	self.changeFrameTitle = true;
end

-------------------常用------------------------
--UI初始化
function RankView:_initUI( ... )
--	local info=self.args[1];
	self.list_type = FGUIUtil.getChild(self.view, "list_type", "GList")
	self.list_rank = FGUIUtil.getChild(self.view, "list_rank", "GList")
	
	self.c1 = self.view:getController("c1")
	self.myRankItem = self.view:getChildAutoType("myRankItem")
	self.txt_noData = self.view:getChildAutoType("txt_noData")
	self.rankHead = self.view:getChildAutoType("rankHead")
	self.closeBtn = self.view:getChildAutoType("closeBtn")
	
	if self.myRankItem then
		self.myRankItem:getController("c2"):setSelectedIndex(1)
	end
	
	
	self.list_rank:setVirtual()
	self.list_rank:setItemRenderer(
			function(index, obj) 
				local info = self._rankData[index + 1]
				--obj:setTitle(info.groupTab);
				local rank = info.rank or (index + 1)
				self:updateRankItem(obj, rank, info, false)
			end
		)		

    
	 
	self._currentIndex = 1
	self._groupData = RankConfiger.getGroupByType(self._openType)
	if self.c1 then
		self.c1:setSelectedIndex(#self._groupData > 1 and 0 or 1)
	end
	
	for k,v in ipairs(self._groupData) do
		if(v.rankType == self._openType) then
			self._currentIndex = k
			break;
		end
	end
	
	
	if self.list_type then
		self.list_type:setItemRenderer(
			function(index, obj) 
				local info = self._groupData[index + 1]
				obj:setTitle(info.groupTab);
				if obj:getController("size") then
					obj:getController("size"):setSelectedIndex(1)
				end
				obj:setIcon(PathConfiger.getCardCategory(info.rankType - 6));
				
				obj:removeClickListener(100)
				obj:addClickListener(
					function(...)
						--local item=recommend[index+1];
						--ViewManager.open("GuildApplyView",{item})
						self:updateRankData()
					end,100
				)
			end
		)
		self.list_type:setData(self._groupData)
		self.list_type:setSelectedIndex(self._currentIndex - 1)
	end
	
	if self.closeBtn then
		self.closeBtn:addClickListener(function ( ... )
			--ViewManager.close("ViewPlayerView")
			self:closeView()
		end)
	end
	
	self:updateRankData()
end

--设置排行榜项的排行icon
function RankView:updateItemBaseInfo(obj, rank, info,isMine)
	local c1 = obj:getController("c1")
	local txt_rank = obj:getChildAutoType("txt_rank")
	local txt_myRank = obj:getChildAutoType("txt_myRank")
	local rankIcon = obj:getChildAutoType("rankIcon")
	
	
	if info then
		obj:removeClickListener(100)
		obj:addClickListener(
			function(...)
				
				local id = isMine and PlayerModel.userid or info.id;
				if self._openType == GameDef.RankType.CrossArenaScore then
					ViewManager.open("CrossArenaPVPPlayerInfoView",info)
				else
					ViewManager.open("ViewPlayerView",{playerId = id, rank = rank})
				end
				
			end,100
		)
	end
	if(rank == 0) then
		c1:setSelectedIndex(0)
	elseif(rank <= 3 ) then
		c1:setSelectedIndex(rank)
		if rankIcon then
			rankIcon:setURL(string.format("%s%s.png","UI/Rank/Rank_img_",rank))
		end
		txt_rank:setText(rank)
		if txt_myRank then txt_myRank:setText(rank) end
	else
		c1:setSelectedIndex(4)
		txt_rank:setText(rank)
		if txt_myRank then txt_myRank:setText(rank) end
	end
end

--设置玩家头像和名字
function RankView:updateItemPlayerHead(obj, rank, info, isMine)
	local headItem = obj:getChildAutoType("headItem")
	local txt_name = obj:getChildAutoType("txt_name")
	local txt_level = obj:getChildAutoType("txt_level")
	
	local config = self._groupData and self._groupData[self:getCruRankType()] or false;
	if(config and config.showHero == 1) then
		if headItem then headItem:setVisible(false) end
		return
	end
	if(info) then
		if headItem then
			headItem:setVisible(true)
			local hero = BindManager.bindPlayerCell(headItem)
			hero:setHead(info.head, info.level,nil,nil,info.headBorder)
		end
		
		if txt_level then txt_level:setText("Lv."..info.level) end
		if txt_name then
			txt_name:setVisible(true)
			txt_name:setText(info.name)
		end
	else
		if headItem then
			headItem:setVisible(false)
		end
		if txt_level then txt_level:setText("") end
		if txt_name then
			txt_name:setVisible(false)
		end
	end
end

--设置卡牌头像和名字
function RankView:updateItemHeroHead(obj, rank, info, isMine)
	local cardItem = obj:getChildAutoType("cardItem")
	local txt_name = obj:getChildAutoType("txt_name")
	local config = self._groupData and self._groupData[self:getCruRankType()] or false;
	if(config and config.showHero ~= 1) then
		if cardItem then
			cardItem:setVisible(false)
		end
		return
	end
	if(info) then
		if cardItem then
			local heroInfo = HeroConfiger.getHeroInfoByID(info.hero.code)
			if heroInfo then
				txt_name:setVisible(true)
				txt_name:setText(heroInfo.heroName)
			end
			if cardItem then
				cardItem:setVisible(true)
				local hero = BindManager.bindCardCell(cardItem)
				--local cardData = info.head
				hero:setData({heroId = info.hero.code, heroStar=info.hero.star,level=info.hero.level} , true)
			end
		end
		
		--if txt_name then
		--	txt_name:setText(info.name)
		--end
	else
		if cardItem then
			cardItem:setVisible(false)
		end
		
		if txt_name then
			txt_name:setVisible(false)
		end
	end
end

function RankView:updateItemAttr(obj, rank, info, isMine)
	local c3 = obj:getController("c3")
	local txt_attr1 = obj:getChildAutoType("txt_attr1")
	local txt_attr1_2 = obj:getChildAutoType("txt_attr1_2")
	local txt_attr2 = obj:getChildAutoType("txt_attr2")
	local txt_level = obj:getChildAutoType("txt_level")
	local txt_noData = obj:getChildAutoType("txt_noData")
		
	local config = self._groupData and self._groupData[self:getCruRankType()]
	if config and config.attrName3 ~= "" then
		if txt_level then txt_level:setVisible(false) end
		if txt_attr2 then txt_attr2:setVisible(true) end
	end
	if(info) then
		if txt_noData then txt_noData:setVisible(false) end
		if txt_attr1 then txt_attr1:setVisible(true) end		
		if txt_attr1_2 then txt_attr1_2:setVisible(true) end
		
		--种族榜的特殊处理
		local config = self._groupData and self._groupData[self:getCruRankType()] or false;
		if(config and config.showHero == 1) then
			if c3 then c3:setSelectedIndex(0) end
			if txt_attr2 then txt_attr2:setText(info.name) end
			
		else
			if c3 then c3:setSelectedIndex(1) end
			if txt_attr2 then txt_attr2:setText("") end
		end
		
	
		if(config and config.rankType == GameDef.RankType.Chapters) then
			local str = ""
			local layer = math.floor(info.value/1000000)
			local floor = math.floor(math.mod(info.value,1000000)/10000)
			local chapter = math.mod(info.value, 10000)
			
			if(layer > 0) then
				str = layer.."-"..floor.."-"..chapter
			else
				str = floor.."-"..chapter
			end
			if txt_attr1 then txt_attr1:setText(str) end
			if txt_attr1_2 then txt_attr1_2:setText(str) end
		else

			if config and config.attrName3 ~= "" then
				local value2 = info.value
				if self._openType ~= GameDef.RankType.BloodAbyssMultiple then
					value2 = StringUtil.transValue(info.value)
				end
				local attr2 = info.exParam and tonumber(info.exParam.param1) and StringUtil.transValue( info.exParam.param1) or "" 
				if txt_attr2 then txt_attr2:setText(string.format(config.attrShow,attr2 )) end
				if txt_attr1 then txt_attr1:setText(value2) end
				if txt_attr1_2 then txt_attr1_2:setText(value2) end
			elseif config then
				if txt_attr1 then txt_attr1:setText(StringUtil.transValue(info.value)) end
				if txt_attr1_2 then txt_attr1_2:setText(string.format(config.attrShow, StringUtil.transValue(info.value))) end
				if txt_attr2 then txt_attr2:setText("") end
			end
			
		end
	else
		if txt_noData then txt_noData:setVisible(true) end
		if c3 then c3:setSelectedIndex(1) end
		if txt_attr1 then txt_attr1:setVisible(false) end
		if txt_attr1_2 then txt_attr1_2:setVisible(false) end
		if txt_attr2 then txt_attr2:setVisible(false) end
	end
end

function RankView:getCruRankType()
	if self.list_type then
		return self.list_type:getSelectedIndex() + 1
	else
		return 1
	end
end


--这个方法给特殊排行榜继承后加需要特殊处理的内容
function RankView:updateItemSpec(obj, rank, info, isMine)
	
end

function RankView:updateRankItem(obj, rank, info, isMine)
	self:updateItemBaseInfo(obj, rank, info, isMine)
	self:updateItemPlayerHead(obj, rank, info, isMine)
	self:updateItemHeroHead(obj, rank, info, isMine)
	self:updateItemAttr(obj, rank, info, isMine)
	self:updateItemSpec(obj, rank, info, isMine)
end

function RankView:updateRankHead()
	if self.rankHead then
		local config = self._groupData[self:getCruRankType()]
		local txt_attrName1 = self.rankHead:getChildAutoType("txt_attrName1")
		local txt_attrName2 = self.rankHead:getChildAutoType("txt_attrName2")
		local txt_attrName3 = self.rankHead:getChildAutoType("txt_attrName3")
		if txt_attrName1 then txt_attrName1:setText(config.attrName1) end
		--如果config.attrName3为空，那么第二列是显示玩家等级
		if config.attrName3 ~= "" then
			if txt_attrName2 then txt_attrName2:setText(config.attrName2) end
			if txt_attrName3 then txt_attrName3:setText(config.attrName3) end
		else
			if txt_attrName2 then txt_attrName2:setText(Desc.Rank_PlayerLv) end
			if txt_attrName3 then txt_attrName3:setText(config.attrName2) end
		end
		--self.rankHead:getController("c1"):setSelectedIndex(config.showHero == 1 and 1 or 0)
	end
end


function RankView:updateRankData()
	local config = self._groupData[self:getCruRankType()]
	self._openType = config.rankType
	self:setWinTtile(config.name)
	self:updateRankHead(config.rankType)
	local params = {}
	if self._args.collectionId then
		params.collectionId = self._args.collectionId
	end
	params.rankType = config.rankType
	params.onSuccess = function (res )
		-- printTable(2233, res);
		printTable(1,"排行榜数据",self._openType,config.rankType,res)
		self._rankData = {}
		if not res.rankData then
			self:updateRankInfo(self._openType)
			self.list_rank:setNumItems(#self._rankData)
			self.list_rank:scrollToView(0)
			self:updateRankEnd(self._openType)
			self.txt_noData:setVisible(true)
			if self.myRankItem then
				self:updateMyRankItem(0)
			end
			return
		end
		for _,v in ipairs(res.rankData) do
			table.insert(self._rankData, v)
		end
		if tolua.isnull(self.view) then return end
		if (self.txt_noData) then
			self.txt_noData:setVisible(#self._rankData == 0)
		end
		if self.myRankItem then
			self.myRankItem:setVisible(#self._rankData ~= 0)
		end
		
		--找出自己的排名数据，找不到的话就是没上榜
		local myInfo = res.myRankData
		self._myRank = myInfo and myInfo.rank or 0
		local myRank = 0;
		for k,v in pairs(self._rankData) do
			if(v.id == ModelManager.PlayerModel.userid) then
				myRank = v.rank or k
				self._myRank = myRank
				myInfo = v
				break
			end
		end
		if self.myRankItem then
			self:updateMyRankItem(self._myRank, myInfo, true)
		end
		self:updateRankInfo(self._openType)
		self.list_rank:setNumItems(#self._rankData)
		self.list_rank:scrollToView(0)
		self:updateRankEnd(self._openType)
	end
	RPCReq.Rank_GetRankData(params, params.onSuccess)
	
end

function RankView:updateRankEnd(type)

end

function RankView:setWinTtile(title)
	if self.changeFrameTitle and self._frame then self._frame:setTitle(title) end
end

function RankView:updateMyRankItem(myRank, myInfo, isCamp)
	self:updateRankItem(self.myRankItem, myRank, myInfo, isCamp)
	if myInfo == nil then
		local c4 = self.myRankItem:getController("c4")
		if c4 then c4:setSelectedIndex(1) end
	end
end

--这个函数给特殊排行榜继承后重写用
function RankView:updateRankInfo(rankType)
	
end
--事件初始化
function RankView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function RankView:_enter( ... )
	print(1,"RankView _enter")
end


--页面退出时执行
function RankView:_exit( ... )

	print(1,"RankView _exit")
end

-------------------常用------------------------

return RankView