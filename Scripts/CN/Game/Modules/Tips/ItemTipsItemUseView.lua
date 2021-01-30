--道具tips
--added by wyang
local ItemTipsItemUseView = class("ItemTipsItemUseView",Window)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsItemUseView:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsItemUseView"
	self._rootDepth = LayerDepth.PopWindow

	self._data = args
	
	self.useNum = 1
	
	self.gainNum = false --使用后获得得数量（仅type27有用到）
end

function ItemTipsItemUseView:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsItemUseView:_initUI( ... )
	local viewRoot = self.view;
	local itemCell = viewRoot:getChildAutoType("itemCell")
    local btn_sub = viewRoot:getChildAutoType("btn_sub") 
    local btn_add = viewRoot:getChildAutoType("btn_add") 
    local txt_input = viewRoot:getChildAutoType("txt_input") 
	local txt_num = BindManager.bindTextInput(txt_input)
    local btn_use = viewRoot:getChildAutoType("btn_use") 
    local btn_max = viewRoot:getChildAutoType("btn_max") 
	
    local txt_effectNum = viewRoot:getChildAutoType("txt_effectNum") 
    local iconLoader = viewRoot:getChildAutoType("iconLoader") 
	
	
	txt_num:onInputEnd(
		function()
			local content = txt_num:getText()
			if not StringUtil.isdigit(content) then content = "1" end
			local num = tonumber(content)
			local maxNum = self._data:getItemAmount()
			
			if num >= maxNum then
				self.useNum = maxNum
			elseif num < 1 then
				self.useNum = 1
			else
				self.useNum = num
			end
			txt_num:setText(self.useNum)
			if self.gainNum then
				txt_effectNum:setText(StringUtil.transValue(self.gainNum * self.useNum))
			end
		end
	)
		

	local maxNum= self._data:getItemAmount()
    self.useNum = maxNum
	txt_num:setText(maxNum)
	local itemcellobj = BindManager.bindItemCell(itemCell)
	-- itemcellobj:setIsBig(true)
    itemcellobj:setItemData(self._data)
	
	local itemInfo 	= self._data:getItemInfo()
	
	--n小时收益礼包的收益需要根据推图层数不同的
	if itemInfo.type == 27 then
		viewRoot:getController("c1"):setSelectedIndex(1)
		local cityId = PushMapModel.curOnhookInfo.chapterCity or 1
		local chapterId = PushMapModel.curOnhookInfo.chapterPoint or 1
		local pointId = PushMapModel.curOnhookInfo.chapterLevel or 1
		local chapterInfo = DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
		if chapterInfo then
			local configInfo = DynamicConfigData.t_chaptersPointFightFd[chapterInfo.fightfd]
			local greward = configInfo.greward
			self.gainNum = 0
			for _,v in ipairs(greward) do
				for _,configReward in ipairs(itemInfo.effectEx) do
					if v.type == configReward.type and v.code == configReward.code then
						self.gainNum = v.amount * itemInfo.effect
						iconLoader:setURL(ItemConfiger.getItemIconByCode(v.code, v.type))
						break
					end
				end
				if self.gainNum ~= 0 then
					break
				end
			end
			txt_effectNum:setText(StringUtil.transValue(self.gainNum * self.useNum))
		end
	else
		viewRoot:getController("c1"):setSelectedIndex(0)
	end

	btn_add:addClickListener(function()
		if self.useNum >= self._data:getItemAmount() then return end
		self.useNum = self.useNum + 1
		txt_num:setText(self.useNum)
		if self.gainNum then
			txt_effectNum:setText(StringUtil.transValue(self.gainNum * self.useNum))
		end
		--txt_goldNum:setText()
	end)
	
	btn_sub:addClickListener(function()
		if self.useNum <= 1 then return end
		self.useNum = self.useNum - 1
		txt_num:setText(self.useNum)
		if self.gainNum then
			txt_effectNum:setText(StringUtil.transValue(self.gainNum * self.useNum))
		end
		--txt_goldNum:setText()
	end)

	btn_use:addClickListener(function()
		local params = {}
		params.bagType = self._data:getBagType()
		params.itemId = self._data:getItemId()
		params.amount = self.useNum
		params.onSuccess = function( res )
			print(1,res)
			if itemInfo.type ==  GameDef.ItemType.EvilMountainEnergy then -- 魔精能量
				RollTips.show(string.format(Desc.GuildMLSMain_useEvilMountainEnergy,itemInfo.effect * self.useNum))
			end
		end
		RPCReq.Bag_UseItem(params, params.onSuccess)
		self:closeView()
	end)

	btn_max:addClickListener(
        function(...)
            local maxNum= self._data:getItemAmount()
            self.useNum=maxNum;
            if self.useNum >=maxNum then
				self.useNum=maxNum;
			end
			txt_num:setText(self.useNum)
			if self.gainNum then
				txt_effectNum:setText(StringUtil.transValue(self.gainNum * self.useNum))
			end
        end
    )
end

-- [子类重写] 准备事件
function ItemTipsItemUseView:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsItemUseView:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsItemUseView:_exit()
end


return ItemTipsItemUseView