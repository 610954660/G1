--added by wyang 排行榜窗口
local RankView = require "Game.Modules.Rank.RankView"
local HeroRankView,Super = class("HeroRankView",RankView)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
function HeroRankView:ctor( data )
	self._packName = "Rank"
	self._compName = "HeroRankView"
	self._rootDepth = LayerDepth.PopWindow
	--self._openType = GameDef.RankType.NormalTower
	self.btn_reward = false
end

-------------------常用------------------------
--UI初始化
function HeroRankView:_initUI( ... )
--	local info=self.args[1];
	local a = self.view
	Super._initUI(self, ... )
	self.btn_reward = self.view:getChild("btn_reward")
	self.btn_reward:addClickListener(function( ... )
		ViewManager.open("TaskRankRewardView", {type = self._openType})
	end)
end



--这个方法给特殊排行榜继承后加需要特殊处理的内容
function HeroRankView:updateItemSpec(obj, rank, info, isMine)
	if info then
		local txt_level = obj:getChildAutoType("txt_level")
		local cardStar = obj:getChildAutoType("cardStar")
		local txt_attr1 = obj:getChildAutoType("txt_attr1")
		local txt_attr2 = obj:getChildAutoType("txt_attr2")
		txt_attr1:setText(StringUtil.transValue(info.value))
		if txt_level then txt_level:setText("Lv."..info.hero.level) end
		if cardStar then
			local cardStarObj = BindManager.bindCardStar(cardStar)
			cardStarObj:setData(info.hero.star)
		end
		
		if txt_attr2 then txt_attr2:setText(info.name) end
		if txt_attr1 then txt_attr1:setText(StringUtil.transValue(info.value)) end
		--if txt_attr1_2 then txt_attr1_2:setText(StringUtil.transValue(info.value)) end
	end
	
	
	local hasReward = DynamicConfigData.t_TaskRankReward[self._openType] ~= nil
	self.btn_reward:setVisible(hasReward)
	RedManager.register("V_TASK_REWARD_"..self._openType, self.btn_reward:getChildAutoType("img_red"))
end



--事件初始化
function HeroRankView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function HeroRankView:_enter( ... )
	print(1,"HeroRankView _enter")
end


--页面退出时执行
function HeroRankView:_exit( ... )

	print(1,"HeroRankView _exit")
end

-------------------常用------------------------

return HeroRankView