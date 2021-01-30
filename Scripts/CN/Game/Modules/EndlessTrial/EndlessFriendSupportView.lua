-- added by wyz
-- 无尽试炼 好友助阵

local HeroConfiger 	=	require "Game.ConfigReaders.HeroConfiger"

local EndlessFriendSupportView = class("EndlessFriendSupportView",Window)

function EndlessFriendSupportView:ctor()
	self._packName 	= "EndlessTrial"
	self._compName 	= "EndlessFriendSupportView"
	self._rootDepth = LayerDepth.PopWindow

	self.friendSupCtrl 	= false 	-- 好友的支援 控制器
	self.selfSupCtrl 	= false 	-- 自己的支援 控制器

	self.list_friendSup = false 	-- 好友的支援 列表
	self.list_selfSup 	= false 	-- 自己的支援 列表

	self.selfSupHeroCell = false 	-- 我选择提供去协助好友的英雄
	self.friendSupHeroCell = false 	-- 选择好友提供给我协助的英雄

	self.list_menu 		= false 	-- 菜单栏
end

function EndlessFriendSupportView:_initUI()
	self.friendSupCtrl 	= self.view:getController("friendSupCtrl")
	self.selfSupCtrl 	= self.view:getController("selfSupCtrl")

	self.list_friendSup	= self.view:getChildAutoType("list_friendSup")
	self.list_selfSup 	= self.view:getChildAutoType("list_selfSup")

	self.selfSupHeroCell 	= self.view:getChildAutoType("selfSupHeroCell")
	self.friendSupHeroCell 	= self.view:getChildAutoType("friendSupHeroCell")

	self.list_menu 			= self.view:getChildAutoType("list_menu")

end

function EndlessFriendSupportView:_initEvent()
	self:upDateList()
	self:upDatePanel()
end

-- 刷新面板
function EndlessFriendSupportView:EndlessTrial_refreshFriendPanel()
	self:upDateList()
	self:upDatePanel()
end

function EndlessFriendSupportView:upDateList()

	-- 好友提供给我的英雄协助列表
	local friendHelpList = {}
	if self._args.helperList and #self._args.helperList > 0 then
		friendHelpList = self._args.helperList 
		friendHelpList = EndlessTrialModel:initFriendHelpHero(friendHelpList,true)
	end
	local friendHelp = EndlessTrialModel:getFriendHelpHero()
	if (friendHelpList and #friendHelpList >0) or (friendHelp and #friendHelp>0) then
		self.friendSupCtrl:setSelectedIndex(1)
	else
		self.friendSupCtrl:setSelectedIndex(0)
	end


	-- printTable(999,"friendHelpList",friendHelpList)
	-- self.list_friendSup:setVirtual()
	self.list_friendSup:setItemRenderer(function(idx,obj)
		local data 			= friendHelpList[idx+1].hero
		local txt_heroName  = obj:getChildAutoType("txt_heroName")
		local txt_heroPower = obj:getChildAutoType("txt_heroPower")
		local btn_select 	= obj:getChildAutoType("btn_select")
		local iconCtrl 		= obj:getController("icon")
		iconCtrl:setSelectedIndex(data.professional)

		local heroCell 		= BindManager.bindHeroCell(obj:getChildAutoType("heroCell"))
		heroCell:setData(data)

		local btnStateCtrl 	= obj:getController("btnState")
		if data.outPower then  	-- 对方实力过强
			btnStateCtrl:setSelectedIndex(2)
		end

  
		txt_heroName:setText(string.format("[%s] %s",data.protext,data.heroName))
		txt_heroPower:setText(string.format(Desc.EndlessTrial_friendPower,StringUtil.transValue(data.combat)))


		btn_select:removeClickListener(666)
		btn_select:addClickListener(function()
			local info = {
				index = 1,
				data = friendHelpList[idx+1],
			}
			ViewManager.open("EndlessFriendSupportTipsView",info)
		end,666)

		if friendHelp and #friendHelp > 0 then
			btn_select:getController("button"):setSelectedIndex(2)
			btn_select:setTouchable(false)
		else
			btn_select:getController("button"):setSelectedIndex(0)
			btn_select:setTouchable(true)
		end
		
	end)
	self.list_friendSup:setNumItems(#friendHelpList)


	-- 我可以提供协助的英雄列表
	local myHelpList 	= EndlessTrialModel:getAllCards()
	local myHelpHeroId 	= EndlessTrialModel:getHelpHeroUid()

	if( myHelpList ~= nil and #myHelpList > 0) or (myHelpHeroId and myHelpHeroId ~= "") then
		self.selfSupCtrl:setSelectedIndex(1)
	else
		self.selfSupCtrl:setSelectedIndex(0)
	end

	self.list_selfSup:setVirtual()
	self.list_selfSup:setItemRenderer(function(idx,obj)
		local data = myHelpList[idx + 1]
		local txt_heroName  = obj:getChildAutoType("txt_heroName")
		local txt_heroPower = obj:getChildAutoType("txt_heroPower")
		local btn_select 	= obj:getChildAutoType("btn_select")
		local iconCtrl 		= obj:getController("icon")
		iconCtrl:setSelectedIndex(data.heroDataConfiger.professional)

		local heroCell 		= BindManager.bindHeroCell(obj:getChildAutoType("heroCell"))
		heroCell:setData(data)

		txt_heroName:setText(string.format("[%s] %s",data.heroDataConfiger.protext,data.heroDataConfiger.heroName))
		txt_heroPower:setText(string.format(Desc.EndlessTrial_friendPower,StringUtil.transValue(data.combat)))
		btn_select:removeClickListener(666)
		btn_select:addClickListener(function()
			local info = {
				index = 0,
				data  = data,
			}
			ViewManager.open("EndlessFriendSupportTipsView",info)
		end,666)

		-- if myHelpHeroId and myHelpHeroId ~="" then
		if ModelManager.EndlessTrialModel.helpHeroState then
			btn_select:getController("button"):setSelectedIndex(2)
			btn_select:setTouchable(false)
		else
			btn_select:getController("button"):setSelectedIndex(0)
			btn_select:setTouchable(true)
		end
	end)
	self.list_selfSup:setNumItems(#myHelpList)
end

function EndlessFriendSupportView:upDatePanel()
	-- 选择好友提供给我协助的英雄
	local showCtrl 	= self.friendSupHeroCell:getController("showCtrl")
	local btnState 	= self.friendSupHeroCell:getController("btnState")
	local noSelectHero 	= self.friendSupHeroCell:getController("noSelectHero")
	showCtrl:setSelectedIndex(1)
	noSelectHero:setSelectedIndex(0)

	local friendHelpList = EndlessTrialModel:getFriendHelpHero()
	if friendHelpList and #friendHelpList > 0 then
		local hero 			= friendHelpList[1].hero
		showCtrl:setSelectedIndex(0)
		btnState:setSelectedIndex(1)
		-- printTable(999,"hero",hero)
		local txt_heroName  = self.friendSupHeroCell:getChildAutoType("txt_heroName")
		local txt_heroPower = self.friendSupHeroCell:getChildAutoType("txt_heroPower")
		local iconCtrl 		= self.friendSupHeroCell:getController("icon")
		iconCtrl:setSelectedIndex(hero.professional)

		local heroCell 		= BindManager.bindHeroCell(self.friendSupHeroCell:getChildAutoType("heroCell"))
		heroCell:setData(hero)

		txt_heroName:setText(string.format("[%s] %s",hero.protext,hero.heroName))
		txt_heroPower:setText(string.format(Desc.EndlessTrial_friendPower,StringUtil.transValue(data.combat)))
	end


	-- 我选择提供去协助好友的英雄
	local showCtrl 	= self.selfSupHeroCell:getController("showCtrl")
	local btnState 	= self.selfSupHeroCell:getController("btnState")
	local noSelectHero 	= self.selfSupHeroCell:getController("noSelectHero")
	showCtrl:setSelectedIndex(1)
	noSelectHero:setSelectedIndex(1)
	local myHelpHeroId 	= EndlessTrialModel:getHelpHeroUid()
	-- print(999,"myHelpHeroId",type(myHelpHeroId))
	if  myHelpHeroId and myHelpHeroId ~= "" then
		print(8848,"myHelpHeroId",myHelpHeroId)
		local hero 			= CardLibModel:getHeroByUid(myHelpHeroId)
		showCtrl:setSelectedIndex(0)
		btnState:setSelectedIndex(1)
		-- printTable(999,"hero",hero)
		local txt_heroName  = self.selfSupHeroCell:getChildAutoType("txt_heroName")
		local txt_heroPower = self.selfSupHeroCell:getChildAutoType("txt_heroPower")
		local iconCtrl 		= self.selfSupHeroCell:getController("icon")
		iconCtrl:setSelectedIndex(hero.heroDataConfiger.professional)

		local heroCell 		= BindManager.bindHeroCell(self.selfSupHeroCell:getChildAutoType("heroCell"))
		heroCell:setData(hero)

		txt_heroName:setText(string.format("[%s] %s",hero.heroDataConfiger.protext,hero.heroDataConfiger.heroName))
		txt_heroPower:setText(string.format(Desc.EndlessTrial_friendPower,StringUtil.transValue(data.combat)))
	elseif ModelManager.EndlessTrialModel.helpHeroState then
		noSelectHero:setSelectedIndex(2)
	end
end

return EndlessFriendSupportView