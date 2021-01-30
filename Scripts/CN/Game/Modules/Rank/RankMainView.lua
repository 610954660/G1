--added by wyang 排行榜窗口
local RankMainView,Super = class("RankMainView",Window)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"

function RankMainView:ctor( data )
	self._packName = "Rank"
	self._compName = "RankMainView"
	self._rootDepth = LayerDepth.Window
	
	self.list_type = false
	self.list_camp = false

	
	self._typeData = false
	self._campData = false
	
	self._rankTopData = false

end

-------------------常用------------------------
--UI初始化
function RankMainView:_initUI( ... )
--	local info=self.args[1];
	self:setBg("bg_generalB.jpg")
	self.list_type = FGUIUtil.getChild(self.view, "list_type", "GList")
	self.list_camp = FGUIUtil.getChild(self.view, "list_camp", "GList")


	self.list_camp:setVirtual()
	self.list_camp:setItemRenderer(
			function(index, obj) 
				local config = self._campData[index + 1]
				local topData = self:getTopDataByType(config.rankType)
				self:updateRankItem1(index, obj, topData, config, true)
			end
		)		
	
	self.list_type:setItemRenderer(
		function(index, obj) 
			local config = self._typeData[index + 1]
			
			
			local topData = self:getTopDataByType(config.rankType)
			self:updateRankItem(index, obj, topData, config)
		end
	)
	
	local params = {}
	params.onSuccess = function (res )
		--printTable(1,res)
		if tolua.isnull(self.view) then return end
		self._rankTopData = res.topData
		self._typeData = RankConfiger.getConfigExceptCamp()
		self.list_type:setData(self._typeData)
		
		self._campData = RankConfiger.getCampConfig()
		self.list_camp:setNumItems(#self._campData)
		end
	RPCReq.Rank_GetRankTopData(params, params.onSuccess)
	

--	self:updateRankData()
end


function RankMainView:updateRankItem1(index, obj, info, config, isCamp)
	local txt_name = obj:getChildAutoType("txt_name")
	local txt_attr = obj:getChildAutoType("txt_attr")
	local heroCell = obj:getChildAutoType("headItem")
	local colorCtrl = obj:getController("colorCtrl")
	RedManager.register("V_TASK_REWARD_"..config.rankType, obj:getChildAutoType("img_red"))
	
	colorCtrl:setSelectedIndex(index + 1)
	if(info and info.level) then
		txt_attr:setVisible(true)
		heroCell:setVisible(true)
		local hero = BindManager.bindPlayerCell(heroCell)
	
			hero:setHead(info.head, info.level)
			txt_name:setText(info.name)
			local str = config.attrName3 == "" and "" or config.attrName3..":"
			txt_attr:setText(str..string.format(config.attrShow, StringUtil.transValue(info.value)))
	else
		txt_attr:setVisible(false)
		heroCell:setVisible(false)
		txt_name:setText(Desc.Rank_empty)
	end
	
	obj:removeClickListener(100)
		obj:addClickListener(
			function(...)
				ViewManager.open("HeroRankView", {type = config.rankType})
			end,100
		)
end

function RankMainView:updateRankItem(index, obj, info, config, isCamp)
	local txt_name = obj:getChildAutoType("txt_name")
	local heroCell = obj:getChildAutoType("headItem")
	local mainAttr = obj:getChildAutoType("mainAttr")
	local img_attrBg = obj:getChildAutoType("img_attrBg")
	local txt_rankName = obj:getChildAutoType("txt_rankName")
	RedManager.register("V_TASK_REWARD_"..config.rankType, obj:getChildAutoType("img_red"))
	txt_rankName:setText(config.name)
	if(info and info.level) then
		mainAttr:setVisible(true)
		img_attrBg:setVisible(true)
		heroCell:setVisible(true)
		local hero = BindManager.bindPlayerCell(heroCell)
		--hero:clear()
		--[[if(config.showHero == 1) then
			--txt_attr2:setText(info.name)
			local heroInfo = HeroConfiger.getHeroInfoByID(info.hero.code)
			txt_name:setText(heroInfo.heroName)
			hero:setData(info.hero.code, info.hero.level, info.hero.star)
		else--]]
			--txt_attr2:setText("")
			hero:setHead(info.head, info.level,nil,nil,info.headBorder)
			txt_name:setText(info.name)
--		end

		if(config.rankType == GameDef.RankType.Chapters) then
			local str = ""
			local layer = math.floor(info.value/1000000)
			local floor = math.floor(math.mod(info.value,1000000)/10000)
			local chapter = math.mod(info.value, 10000)
			
			if(layer > 0) then
				str = layer.."-"..floor.."-"..chapter
			else
				str = floor.."-"..chapter
			end
			mainAttr:setTitle(str)
		else
			local str = config.attrName3 == "" and "" or config.attrName3..":"
			mainAttr:setTitle(str..string.format(config.attrShow, StringUtil.transValue(info.value)))
		end
		local attrWidth = mainAttr:getWidth()
		img_attrBg:setWidth(attrWidth > 171 and attrWidth or 171)
	else
		img_attrBg:setVisible(false)
		mainAttr:setVisible(false)
		heroCell:setVisible(false)
		txt_name:setText(Desc.Rank_empty)
	end
	local loader_bg = obj:getChildAutoType("loader_bg")
	local conerLoader = obj:getChildAutoType("conerLoader")
	
	loader_bg:setURL(PathConfiger.getRankTitleBg(index + 1))
	conerLoader:setURL(PathConfiger.getRankConnerBg(index + 1))
	mainAttr:setIcon(PathConfiger.getRankTypeIcon(config.rankType))
	--local txt_title = obj:getChildAutoType("txt_title")
	--if(isCamp) then
	--	txt_title:setText(config.groupTab)
	--else
	--	txt_title:setText(config.name)
	--end
			
	obj:removeClickListener(100)
		obj:addClickListener(
			function(...)
				--if config.rankType == GameDef.RankType.NormalTower then
				--	ViewManager.open("PataRankView")
				--else
				if isCamp then
					ViewManager.open("HeroRankView", {type = config.rankType})
				else
					ViewManager.open("PublicRankView", {type = config.rankType})
				end
				
			end,100
		)
end

function RankMainView:getTopDataByType(rankType)
	for _,v in ipairs(self._rankTopData) do
		if rankType == v.rankType then
			return v.rankData
		end
	end
end

--[[function RankMainView:updateRankItem(obj, rank, info, isMine)
	local c1 = obj:getController("c1")
	local c2 = obj:getController("c2")
	
	if(rank == 0) then
		c1:setSelectedIndex(0)
	end
	if(info) then
		local txt_rank = obj:getChildAutoType("txt_rank")
		local rankIcon = obj:getChildAutoType("rankIcon")
		local txt_name = obj:getChildAutoType("txt_name")
		local txt_attr1 = obj:getChildAutoType("txt_attr1")
		local heroCell = obj:getChildAutoType("heroCell")
		local txt_attr2 = obj:getChildAutoType("txt_attr2")
		local hero = HeroCell.new(heroCell)
		hero:clear()
		local config = self._groupData[self.list_type:getSelectedIndex() + 1]
		if(config.showHero == 1) then
			c2:setSelectedIndex(1)
			txt_attr2:setText(info.name)
			local heroInfo = HeroConfiger.getHeroInfoByID(info.hero.code)
			txt_name:setText(heroInfo.heroName)
			hero:setData(info.hero.code, info.hero.level, info.hero.star)
		else
			c2:setSelectedIndex(0)
			hero:setHead(info.head, info.level)
			txt_name:setText(info.name)
		end
		
		--local herolevel = obj:getChildAutoType("heroCell/level")
		--herolevel:setText(info.hero.level)
		
		
		
		
		txt_attr1:setText(string.format(config.attrShow, info.value))
		if(rank == 0) then
			c1:setSelectedIndex(0)
		elseif(rank <= 3 ) then
			c1:setSelectedIndex(1)
			rankIcon:setURL(string.format("%s%s.png","UI/Rank/Rank_img_",rank))
		else
			c1:setSelectedIndex(2)
			txt_rank:setText(rank)
		end
		obj:removeClickListener(100)
		obj:addClickListener(
			function(...)
				--local item=recommend[index+1];
				--ViewManager.open("GuildApplyView",{item})
				--self:updateRankData()
			end,100
		)
	end
end--]]

--[[function RankMainView:updateRankData()
	local config = self._groupData[self.list_type:getSelectedIndex() + 1]
	self._frame:setTitle(config.name)
	
	local params = {}
	params.rankType = config.rankType
	local txt_attrName1 = self.rankHead:getChildAutoType("txt_attrName1")
	local txt_attrName2 = self.rankHead:getChildAutoType("txt_attrName2")
	local txt_attrName3 = self.rankHead:getChildAutoType("txt_attrName3")
	txt_attrName1:setText(config.attrName1)
	txt_attrName2:setText(config.attrName2)
	txt_attrName3:setText(config.attrName3)
	self.rankHead:getController("c1"):setSelectedIndex(config.showHero == 1 and 0 or 1)
	params.onSuccess = function (res )
		printTable(1,res)
		self._rankData = res.rankData
		
		self.list_rank:setNumItems(#self._rankData)
		self.list_rank:scrollToView(0)
		self.txt_noData:setVisible(#self._rankData == 0)
		
		--找出自己的排名数据，找不到的话就是没上榜
		local myInfo = false
		local myRank = 0;
		for k,v in ipairs(self._rankData) do
			if(v.id == ModelManager.PlayerModel.userid) then
				myInfo = v
				myRank = k
				break
			end
		end
		--if (myInfo) then
			self:updateRankItem(self.myRankItem, myRank, myInfo)
		--end
	end
	RPCReq.Rank_GetRankData(params, params.onSuccess)
	
end--]]

--事件初始化
function RankMainView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function RankMainView:_enter( ... )
	print(1,"RankMainView _enter")
end


--页面退出时执行
function RankMainView:_exit( ... )

	print(1,"RankMainView _exit")
end

-------------------常用------------------------

return RankMainView