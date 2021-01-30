--added by wyang
--道具框封裝

local MainModelShow,Super = class("MainModelShow",BindView)
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"

function MainModelShow:ctor(view, args)
	self.img_btnFrame = false
	self.btn_change = false
	self.btn_hero = false
	self.playerIcon = false
	self.btn_linking = false
	self.txt_msg = false
	self.spineMc = false
	self.hintMsg = false
	self.linkingEffect = false
	self.attrBoard = false
	self.bar_linking = false
	self.btn_attr = false
	
	
	self._isShowingMsg = false
	self._isShowingBtn = false
	self._showMsgTime = {3,5,8}
	self._showMsgTimer = false
	self._showButtonTimer = false
	self._showLikingTimer = false
	self._hideAttrTimer  = false
	self._timer = false
	self._isLongPress = false
	self._setBtnLinkState = true
	self.soundId = 0
	
	self.revCount = 0
	
	self._onlyShow = args and args.onlyShow or false --只是展示，不带更换、送礼等功能
	self.linkingState = 0 --0静态 1动态
	self.isCanClick = true
end


function MainModelShow:_initUI( ... )
	self.img_btnFrame = self.view:getChildAutoType("img_btnFrame")
	self.btn_change = self.view:getChildAutoType("btn_change")
	self.btn_hero = self.view:getChildAutoType("btn_hero")
	self.btn_linking = self.view:getChildAutoType("btn_linking")
	local playerIcon = self.view:getChildAutoType("playerIcon")
	self.hintMsg = self.view:getChildAutoType("hintMsg")
	self.txt_msg = self.view:getChildAutoType("txt_msg")
	self.spineMc = self.view:getChildAutoType("spineMc")
	self.attrBoard = self.view:getChildAutoType("attrBoard")
	self.bar_linking = self.view:getChildAutoType("bar_linking")
	self.btn_attr = self.view:getChildAutoType("btn_attr")
	
	self.spine = self.view:getChildAutoType("spine")
	
	self.playerIcon = BindManager.bindLihuiDisplay(playerIcon)
	self.playerIcon:setData(ModelManager.HandbookModel.heroOpertion, nil,nil, ModelManager.HandbookModel.fashionCode)
	
	self.btn_change:setVisible(not self._onlyShow)
	
	self.giftSpine = SpineUtil.createSpineObj(self.spine, {x = 0, y=0},"ui_hangandu_1", "Spine/ui/heroGift", "efx_haogandu", "efx_haogandu",false,true)
	self.giftSpine:setVisible(false)

	--self.skeletonNode =  SpineUtil.createSpineObj(self.spineMc, {x = 0, y=0},"hongxin_haogandu", PathConfiger.getSettlementRoot(), "Ef_haogan_hongxin", "Ef_haogan_hongxin")
	if not self.linkingEffect then
		self.linkingEffect = SpineUtil.createSpineObj(self.spineMc, {x = 0, y=0},"hongxin_weilingqu_loop", PathConfiger.getSettlementRoot(), "Ef_haogan_hongxin", "Ef_haogan_hongxin")
		self.linkingEffect:setVisible(false)
	end
			
	-- self.btn_hero:addLongPressListener(function (context)
	-- 			self._isLongPress = true
	-- 			self:showButton()
	-- 		end, 1)
	
	self.btn_hero:addClickListener(
		function()
			--[[if self._isLongPress then 
				self._isLongPress = false
				return
			end--]]
			self:showMsg()
--			self._isLongPress = true
			-- self:showButton()
			if not self.isCanClick then return end
			self.isCanClick = false
			self:showLinking(true)
			if self._timer then Scheduler.unschedule(self._timer) end
			self._timer = Scheduler.schedule(function()
				self.isCanClick = true
				self:showLinking(false)
			end,10,1)
		end
	)

	self.btn_change:addClickListener(
		function()
			ViewManager.open("MainHeroSetView")
		end
	)
	
	self.btn_linking:addClickListener(
		function()
			self:getLinking(true)
		end
	)

	self.btn_attr:addClickListener(
		function()
			if ModelManager.HandbookModel.heroOpertion ~= 0 then
				ModuleUtil.openModule(ModuleId.HeroDormitory.id,true)
			end
		end
	)
	
	self:checkShowLinking()
	self:showLinking(false)
end

--直接设设置code的数据
function MainModelShow:setData()
	
end

function MainModelShow:updateModel()
	--if ModelManager.HandbookModel.fashionCode then 
		self.playerIcon:setData(ModelManager.HandbookModel.heroOpertion,nil,nil,ModelManager.HandbookModel.fashionCode)
	--else
	--	self.playerIcon:setData(ModelManager.HandbookModel.heroOpertion)
	--end
end

function MainModelShow:setModelIcon(code, fashionId)
	self.playerIcon:setData(code,nil,nil,fashionId)
end

function MainModelShow:showButton()
	if self._isShowingBtn then return end
	self._isShowingBtn = true
	-- self.img_btnFrame:setAlpha(0)
	self.img_btnFrame:setVisible(true)
	-- local onComplete = function()
		self.img_btnFrame:setAlpha(1)
		--self.btn_change:setVisible(true)
	-- end
	-- TweenUtil.alphaTo(self.img_btnFrame, {from = 0, to = 1, time = 0.5, ease = EaseType.Linear, onComplete=onComplete})
	
	if self._showButtonTimer then Scheduler.unschedule(self._showButtonTimer) end
	self._showButtonTimer  = Scheduler.schedule(function()
		--self.btn_change:setVisible(false)
		if tolua.isnull(self.img_btnFrame) then return end
		self.img_btnFrame:setVisible(false)
		self._isShowingBtn = false
	end,3.5)
end

function MainModelShow:showMsg()
	if self._isShowingMsg  then return end
	local random = math.floor(math.random() * 3) + 1
	local time = self._showMsgTime[random]
	local info = DynamicConfigData.t_hero[ModelManager.HandbookModel.heroOpertion]
	if not info then return end
	local msg = info["tip"..random]
	--播放立绘的音效
	if self.soundId then
		SoundManager.stopSound(self.soundId)
	end
	if info.sound and #info.sound>0 then
		if info.sound[random] then
			self.soundId = SoundManager.playHeroSound(info.sound[random],false)
		end
	end
	
	self.txt_msg:setText(msg)
	self._isShowingMsg = true
	self.hintMsg:setVisible(true)
	if self._showMsgTimer then Scheduler.unschedule(self._showMsgTimer) end
	self._showMsgTimer  = Scheduler.schedule(function()
		if tolua.isnull(self.hintMsg) then return end
		self._isShowingMsg = false
		self.hintMsg:setVisible(false)
	end,time)
	
end

function MainModelShow:checkShowLinking()
	-- if self._showLikingTimer then Scheduler.unschedule(self._showLikingTimer) end
	-- if self._onlyShow then return end
	-- self._showLikingTimer  = Scheduler.schedule(function()
	-- 	if self._showLikingTimer then Scheduler.unschedule(self._showLikingTimer) end
	-- 	if tolua.isnull(self.btn_linking) then return end
	-- 		self.btn_linking:setVisible(self._setBtnLinkState)
	-- 		self.btn_linking:getController("c1"):setSelectedIndex(0)
	-- 		self._showLikingTimer  = Scheduler.schedule(function()
	-- 		if self._showLikingTimer then 
	-- 			Scheduler.unschedule(self._showLikingTimer) 
	-- 			self._showLikingTimer = false
	-- 		end
	-- 		if tolua.isnull(self.btn_linking) then return end
	-- 		self.btn_linking:getController("c1"):setSelectedIndex(1)
	-- 		self.linkingEffect:setAnimation(0, "hongxin_weilingqu_loop", true)
	-- 		self.linkingEffect:setVisible(true)
		
	-- 	end,60)
	-- end,0)
	self.linkingState = 0
	if self._showLikingTimer then Scheduler.unschedule(self._showLikingTimer) end
	self._showLikingTimer  = Scheduler.schedule(function()
		self.linkingState = 1
	end,60)
end

function MainModelShow:getLinking(isClick)
	self.linkingState = 0
	self.btn_linking:getController("c1"):setSelectedIndex(0)
	self.btn_linking:setVisible(false)
	self.linkingEffect:setVisible(false)
	if isClick then
		--播放动画
		-- self.linkingEffect:setAnimation(0, "hongxin_haogandu", false)
		self.giftSpine:setAnimation(0, "ui_hangandu_1", false)
		self.giftSpine:setVisible(true)
		local params = {}
		params.onSuccess = function (res )
			if tolua.isnull(self.view) then return end
			--printTable(1,res)
			--local hcf = HandbookModel.heroData[ModelManager.HandbookModel.heroOpertion]
			--if hcf then
				--[[local nextNeed = DynamicConfigData.t_HeroTotemsHeroFavor[hcf.likingLevel+1]
				if not nextNeed then
					nextNeed = DynamicConfigData.t_HeroTotemsHeroFavor[hcf.likingLevel]
				end
				local curFavor = hcf.likingExp
				if curFavor > nextNeed.needFavor then
					curFavor = nextNeed.needFavor
				end--]]
				self.bar_linking:setMax(res.maxPoint)
				self.bar_linking:setValue(res.curPoint)
			--end
			self.attrBoard:setVisible(true)
			-- self._hideAttrTimer  = Scheduler.schedule(function()
			-- 	if self._hideAttrTimer then Scheduler.unschedule(self._hideAttrTimer) end
			-- 	if tolua.isnull(self.attrBoard) then return end
			-- 	self.attrBoard:setVisible(false)
			-- 	self:checkShowLinking()
			-- end,5)
			self:checkShowLinking()
		end
		RPCReq.HeroTotems_ReceiveHeroHang(params, params.onSuccess)
	else
		self:checkShowLinking()
	end
	
end

function MainModelShow:setBtnLinkState(show)
	self._setBtnLinkState=show
end

function MainModelShow:mainui_showHeroChange()
	--暂时
	self.revCount = self.revCount + 1
	if self.revCount < 2 then return end
	if ModelManager.HandbookModel.heroOpertion then
		self:checkExist()
	else
		self:updateModel()
	end
	self:getLinking()
end

function MainModelShow:checkExist()
	--如果当前展示的英雄被分解了，要重新选一个好感度最高的英雄展示
	--ModelManager.HandbookModel.heroOpertion= FileCacheManager.getIntForKey(FileDataType.MAIN_HERO_SHOW, 0, nil, true)
	
	if not ModelManager.CardLibModel:isHeroGot(ModelManager.HandbookModel.heroOpertion) then 
		local checkedId = {}
		local linkingExp = 0
		local bestCode = -1
		local allHero = ModelManager.CardLibModel:getAllCards()
		for _,v in pairs(allHero) do
			local config = DynamicConfigData.t_hero[v.code]
			if not checkedId[v.code] and config.exhibit == 1 then
				checkedId[v.code] = true
				local linkingInfo =  ModelManager.HandbookModel.heroData[v.code]
				if (linkingInfo and linkingInfo.likingExp > linkingExp) or bestCode == -1 then
					linkingExp = linkingInfo and linkingInfo.likingExp or linkingExp
					bestCode = v.code
				end
			end
		end
		--ModelManager.HandbookModel.heroOpertion= bestCode
		if bestCode ~= -1 then
			ModelManager.HandbookModel:setMainHero(bestCode)
		end
		--FileCacheManager.setIntForKey(FileDataType.MAIN_HERO_SHOW, bestCode, nil, true)
		--self:updateModel()
	else
		self:updateModel()
	end

end

function MainModelShow:cardView_CardAddAndDeleInfo()
	if ModelManager.CardLibModel.dataInited and ModelManager.HandbookModel.dataInited then
		self:checkExist()
	end
end

function MainModelShow:showLinking(isShow)
	if tolua.isnull(self.btn_linking) then return end
	if isShow then 
		self.btn_linking:setVisible(true)
		self.btn_change:setVisible(true)
		if self.linkingState == 0 then
			self.btn_linking:getController("c1"):setSelectedIndex(0) 
			self.linkingEffect:setVisible(false)
		elseif self.linkingState == 1 then 
			self.btn_linking:getController("c1"):setSelectedIndex(1)
			self.linkingEffect:setVisible(true)
		end
	else
		self.btn_linking:setVisible(false)
		self.btn_change:setVisible(false)
		self.linkingEffect:setVisible(false)
		self.attrBoard:setVisible(false)
	end
end

--退出操作 在close执行之前 
function MainModelShow:_onExit()
    print(1,"MainModelShow __onExit")
	if self._showButtonTimer then Scheduler.unschedule(self._showButtonTimer) end
	if self._showMsgTimer then Scheduler.unschedule(self._showMsgTimer) end
	if self._showLikingTimer then Scheduler.unschedule(self._showLikingTimer) end
end

return MainModelShow