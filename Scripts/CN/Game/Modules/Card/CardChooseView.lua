---------------------------------------------------------------------
-- 卡牌先择窗口 
-- Created by:wyang
--使用方法	ViewManager.open("CardChooseView", {noBattle = true, callBack = function() end, caller = self})
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardChooseView, Super = class("CardChooseView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function CardChooseView:ctor(args)
    self._packName = "CardSystem"
    self._compName = "CardChooseView"
	self._rootDepth = LayerDepth.PopWindow
    self._cardLabelList = false
	self.categoryChoose = false
    self._listCard = false
    self._listCardBig = false
	self.tempInfo = false
	self.selectedInfo = false
	self.lastSelectedItem = false
	self.noLock = args.noLock ~= nil and args.noLock or false   --是否可以选择锁定英雄
	self.noBattleCard = args.noBattle ~= nil and args.noBattle or false   --是否可以选择出战英雄
	self.noHeroPalace = args.noHeroPalace ~= nil and args.noHeroPalace or false   --是否可以选择英雄谷中英雄
	self.callback = args.callback
	self.callbackCaller = args.caller
	self.excludeUuidList = args.excludeUuids
	self._minStar = args.minStar and args.minStar or 0
	self._minLevel = args.minLevel and args.minLevel or 0
	
	self._bigItem = args.bigItem or false
	self.funcStr = args.funcName and args.funcName or Desc.card_choose --功能名字，例如“重置”， 没有选择时，会提示“未选择重置探员哦”
end

function CardChooseView:_initUI()
    local viewRoot = self.view
    
    self.categoryChoose = viewRoot:getChild("categoryChoose")
    self._listCard = viewRoot:getChild("list_card")
    self._listCardBig = viewRoot:getChild("list_cardBig")
    
    self:setCardsByCategory(0)
	
	
	for i = 0,5,1 do 
		local btn = self.categoryChoose:getChild("category"..i)
		btn:addClickListener(function ()
			self:setCardsByCategory(i)
		end)
	end
  
    self:bindEvent()
end

function CardChooseView:setCardsByCategory(Category)
	self.tempInfo = ModelManager.CardLibModel:getCardByCategory(Category, self.excludeUuidList, self._minStar, self._minLevel)
	local idx = 1;
	local len = #self.tempInfo;
	while (idx < len) do
		local heroInfo = self.tempInfo[idx];
		if (CardLibModel:isActivateSegment(heroInfo)) then
			table.remove(self.tempInfo, idx)
			len = #self.tempInfo;
		else
			idx = idx + 1;
		end
	end
	TableUtil.sortByMap(self.tempInfo, {{key="star",asc=true},{key="level",asc=true}})
	--[[if not self.selectedInfo and #self.tempInfo > 0 then
		self.selectedInfo = self.tempInfo[1]
	end--]]
    self:setCardList()
end

--绑定事件
function CardChooseView:setCardList()
    local battle = ModelManager.BattleModel:getArrayInfo()
    local hasBattle = false
    if battle then
        hasBattle = battle.array
    end
	self._listCard:setVirtual()
    self._listCard:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    local cardItem = self.tempInfo[index + 1]
                    self:setChoose(obj, cardItem)
                end,
                100
            )
			local cardItem = BindManager.bindCardCell(obj)
			cardItem:setCardNameVis(true)
			cardItem:setData(self.tempInfo[index + 1],true)
		
            local chooseCtr = obj:getController("c1")
			local isLock = self.tempInfo[index + 1].locked
			if self.noLock and isLock then
				chooseCtr:setSelectedIndex(7)
			elseif self.noBattleCard and hasBattle and hasBattle[self.tempInfo[index + 1].uuid] ~= nil then
				chooseCtr:setSelectedIndex(4)
			elseif self.noHeroPalace and ModelManager.HeroPalaceModel:isInHeroPalace(self.tempInfo[index + 1].uuid) then
				chooseCtr:setSelectedIndex(6)
			elseif self.selectedInfo and self.tempInfo[index + 1].uuid == self.selectedInfo.uuid then
				self.lastSelectedItem = obj
                chooseCtr:setSelectedIndex(2)
            else
                chooseCtr:setSelectedIndex(1)
            end
        end
	)
	if self._listCardBig then
		self._listCardBig:setVirtual()
		self._listCardBig:setItemRenderer(
			function(index, itemObj)
				local obj = itemObj:getChildAutoType("cardItem")
				obj:removeClickListener(100)
				--池子里面原来的事件注销掉
				obj:addClickListener(
					function(context)
						local cardItem = self.tempInfo[index + 1]
						self:setChoose(obj, cardItem)
					end,
					100
				)
				local cardItem = BindManager.bindCardCell(obj)
				cardItem:setData(self.tempInfo[index + 1],false)
			
				local chooseCtr = obj:getController("c1")
				
				local isLock = self.tempInfo[index + 1].locked
				if self.noLock and isLock then
					chooseCtr:setSelectedIndex(7)
				elseif self.noBattleCard and hasBattle and hasBattle[self.tempInfo[index + 1].uuid] ~= nil then
					chooseCtr:setSelectedIndex(4)
				elseif self.noHeroPalace and ModelManager.HeroPalaceModel:isInHeroPalace(self.tempInfo[index + 1].uuid) then
					chooseCtr:setSelectedIndex(6)
				elseif self.tempInfo[index + 1].uuid == self.selectedInfo.uuid then
					self.lastSelectedItem = obj
					chooseCtr:setSelectedIndex(2)
				else
					chooseCtr:setSelectedIndex(1)
				end
			end
		)
		self._listCardBig:setVisible(self._bigItem)
	end
    --self._listCard:setNumItems(#self.tempInfo)
	self._listCard:setVisible(not self._bigItem)
	if self._bigItem then
		self._listCardBig:setNumItems(#self.tempInfo)
	else
		self._listCard:setNumItems(#self.tempInfo)
	end
end

function CardChooseView:setChoose(obj, materials)
    local chooseCtr = obj:getController("c1")
	local isLock = materials.locked
	if self.noLock and isLock then
		RollTips.show(Desc.card_isInLock)
		return
	end
	if self.noBattleCard then
		 local battle = ModelManager.BattleModel:getArrayInfo()
		local hasBattle = false
		if battle then
			hasBattle = battle.array
		end
		if hasBattle and hasBattle[materials.uuid] ~= nil then
			local arrayType = ModelManager.BattleModel:getArrayType(materials.uuid)
			local battleFunName = Desc["common_arrayType"..arrayType]
			RollTips.show(string.format(Desc.card_isInBattle,battleFunName, self.funcStr ))
			chooseCtr:setSelectedIndex(4)
			return
		end
	end
	
	if self.noHeroPalace then
		if ModelManager.HeroPalaceModel:isInHeroPalace(materials.uuid) then
			RollTips.show(string.format(Desc.card_isInHeroPalace, self.funcStr ))
			chooseCtr:setSelectedIndex(6)
			return
		end
	end
	
	if self.lastSelectedItem then
		self.lastSelectedItem:getController("c1"):setSelectedIndex(1)  --把其他的选中对象清掉
	end
	
	self.lastSelectedItem = obj
	self.selectedInfo = materials
	chooseCtr:setSelectedIndex(2)
end

--绑定事件
function CardChooseView:bindEvent()
    local viewRoot = self.view
    local btn_ok = viewRoot:getChild("btn_ok")
    btn_ok:addClickListener(
        function(context)
           if self.callback and self.selectedInfo then
				self.callback(self.callbackCaller, self.selectedInfo)
			end
			if not self.selectedInfo then
				RollTips.show(string.format(Desc.card_noChoosed, self.funcStr))
			end
			self:closeView()
        end
    )
end

function CardChooseView:_enter()
end

function CardChooseView:_exit()

end

return CardChooseView
