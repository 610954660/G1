--Name : HeroResetView.lua
--Author : wyang
--Date : 2020-5-21
--Desc :

local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local HeroResetView,Super = class("HeroResetView", Window)

function HeroResetView:ctor(args)
	self._packName = "HeroReset"
	self._compName = "HeroResetView"
	
	self.btn_reset = false
	self.btn_choose = false
	self.btn_choose2 = false
	self.playerIcon = false
	self.list_hero = false
	self.list_item = false
	self.txt_times = false
	self.costItem = false
	
	
	
	self.skeletonNode = false
	
	self._chooseUuid = false
	self._getHero = false
	self._getItem = false
	self._cost = {type =CodeType.MONEY, code = 2, amount = 20 }
	self._configInfo = false
	
	self.resetCardInfo = args and args.cardInfo or false
end

function HeroResetView:_initUI( )
	self:setBg("bg_generalA.jpg")
	self.btn_choose = self.view:getChildAutoType("btn_choose")
	self.btn_choose2 = self.view:getChildAutoType("btn_choose2")
	local playerIcon = self.view:getChildAutoType("playerIcon")
	self.playerIcon = BindManager.bindLihuiDisplay(playerIcon)
	self.list_hero = self.view:getChildAutoType("list_hero")
	self.list_item = self.view:getChildAutoType("list_item")
	self.txt_times = self.view:getChildAutoType("txt_times")
	local costItem = self.view:getChildAutoType("costItem")
	self.costItem = BindManager.bindCostItem(costItem)
	
	self.list_hero:setItemRenderer(function(index,obj)
		local heroCell = BindManager.bindCardCell(obj)
		local info = self._getHero[index + 1]
		heroCell:setData(info, true)
	end)
	
	self.list_item:setItemRenderer(function(index,obj)
		local itemCell = BindManager.bindItemCell(obj)
		local info = self._getItem[index + 1]
		itemCell:setIsBig(true)
		itemCell:setData(info.code, info.amount, info.type)
	end)
	
	self.btn_reset = self.view:getChildAutoType("btn_reset")
	--self.btn_reset = BindManager.bindCostButton(btn_reset)
	
	--self.btn_reset:setData(self._cost)
	
	self:updateBtn()
	
	if self.resetCardInfo then
		self._chooseUuid = self.resetCardInfo.uuid
		self:updateGet()
		self._configInfo = DynamicConfigData.t_hero[self.resetCardInfo.heroId]
		--ModelManager.HeroPalaceModel:doAddReq(pos, cardInfo.uuid)
		self.btn_choose:setVisible(false)
		self.btn_choose2:setVisible(true)
		self:changeHeroShow(self.resetCardInfo.heroId)
	end
end


function HeroResetView:_initEvent( )
	self.btn_choose:addClickListener(
		function(...)
			self:doChoose()
		end,100
	)
	self.btn_choose2:addClickListener(
		function(...)
			self:doChoose()
		end
	)
	
	self.btn_reset:addClickListener(
		function(...)
			 local battle = ModelManager.BattleModel:getArrayInfo()
			local hasBattle = false
			if battle then
				hasBattle = battle.array
			end
			--[[if hasBattle and hasBattle[self._chooseUuid] ~= nil then
				local arrayType = ModelManager.BattleModel:getArrayType(self._chooseUuid)
				local battleFunName = Desc["common_arrayType"..arrayType]
				
				local info = {}
				info.text = string.format(Desc.card_resetIsInBattle,battleFunName, self.funcStr )
				info.type = "yes_no"
				info.align = "left"
				info.mask = true
				info.onYes = function()
					ModelManager.CardLibModel:doQuitBattle(arrayType, self._chooseUuid)
				end
				Alert.show(info)
--			else--]]
				self:doReset()
--			end
		end, 99)
	
end



function HeroResetView:doReset()
	if self._chooseUuid then
		local info = {}
		info.text = string.format(Desc.card_resetHint, self._configInfo.heroStar)
		info.type = "yes_no"
		info.align = "left"
		info.mask = true
		info.onYes = function()
			if ModelManager.PlayerModel:isCostEnough(self._cost) then
				
				local params = {}
				params.uuid = self._chooseUuid
				params.onSuccess = function (res )
					--printTable(1, res)
					CardLibModel:UpCardHeroAttr(res)
					RollTips.show(DescAuto[169]) -- [169]="重置成功"
					self:closeView()
				end
				RPCReq.Hero_Reset(params, params.onSuccess)
			end
		end
		Alert.show(info)
	end
end

function HeroResetView:updateBtn()
	local freeTime = ModelManager.CardLibModel.freeResetHeroTimes
	if freeTime > 0 then
		--self.btn_reset.view:getController("cost"):setSelectedIndex(3)
		self.btn_reset:setTitle(Desc.card_resetFree)
		self.txt_times:setText(string.format(Desc.card_resetFreeTimes, freeTime))
		self.costItem:setVisible(false)
	else
		--self.btn_reset.view:getController("cost"):setSelectedIndex(1)
		self.btn_reset:setTitle(Desc.card_reset)
		self.txt_times:setText("")
		self.costItem:setVisible(true)
		self.costItem:setData(self._cost.type, self._cost.code, self._cost.amount)
	end
end

function HeroResetView:doChoose()
	local chooseUuids = {}
	ViewManager.open("CardChooseView", {noLock = true, noBattle = false, noHeroPalace = true, funcName = Desc.card_reset, minStar = 3, minLevel = 2, callback = function(self, cardInfo)   
		print(1, "CardChooseView.doChoose", cardInfo.uuid)
		self._chooseUuid = cardInfo.uuid
		self:updateGet()
		self._configInfo = DynamicConfigData.t_hero[cardInfo.heroId]
		--ModelManager.HeroPalaceModel:doAddReq(pos, cardInfo.uuid)
		self.btn_choose:setVisible(false)
		self.btn_choose2:setVisible(true)
		local fashionId = cardInfo.fashion and cardInfo.fashion.code
		self:changeHeroShow(cardInfo.heroId, fashionId)
	end, caller = self, excludeUuids = chooseUuids})
end

function HeroResetView:updateGet()
	self._getHero, self._getItem = HeroConfiger.getHeroResetReward(self._chooseUuid)
	
	self.list_hero:setNumItems(#self._getHero)
	self.list_item:setNumItems(#self._getItem)
end

--改变骨骼显示的动画
function HeroResetView:changeHeroShow(heroId,fashionId)
	self.playerIcon:setData(heroId, nil,nil, fashionId)
end

--改变骨骼显示的动画
function HeroResetView:cardView_freeResetTimesChange()
	self:updateBtn()
end

function HeroResetView:_exit()
	
end

return HeroResetView
