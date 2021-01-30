local C = class("ItemTipsOptionalGiftBox", Window)
--local ItemCell = require "Game.UI.Global.ItemCell"

function C:ctor(args)
    self._packName = "ToolTip"
    self._compName = "ItemTipsOptionalGiftBox"
    self._rootDepth = LayerDepth.PopWindow
    self._itemData = args

    local info = self._itemData:getItemInfo()
    self.__itemList = info.effectEx
    self.__currentSelectedIndex = 1
    self._curCode = false
    self.useNum = 1
    self.allData = {}
    self.curCategory = 0
end

function C:init( ... )
    -- body
end

-- [子类重写] 初始化UI方法
function C:_initUI( ... )
    local viewRoot = self.view;
    local itemListView = viewRoot:getChildAutoType("itemList")
    self.itemListView = itemListView
    local btn_sub = viewRoot:getChildAutoType("btn_sub")
    local btn_add = viewRoot:getChildAutoType("btn_add")
    local txt_input = viewRoot:getChildAutoType("txt_input")
	local txt_num = BindManager.bindTextInput(txt_input)
    local btn_min = viewRoot:getChildAutoType("btn_min")
    local btn_max = viewRoot:getChildAutoType("btn_max")
    local btn_cancel = viewRoot:getChildAutoType("btn_cancel")
    local btn_use = viewRoot:getChildAutoType("btn_use")
    local heroName = viewRoot:getChildAutoType("heroName")
    local maxNum= self._itemData:getItemAmount()
    local categoryChoose = viewRoot:getChildAutoType("categoryChoose")
    local category0 = viewRoot:getChildAutoType("category0")
    self.heroName = viewRoot:getChildAutoType("heroName")
    self.typeCtrl = viewRoot:getController("typeCtrl")
	--值为1的，默认使用数量为1，否则为最大
	if self._itemData:getItemInfo().select == 1 then
		self.useNum = 1
		txt_num:setText(1)
	else
		self.useNum = maxNum
		txt_num:setText(maxNum)
	end
	txt_num:onInputEnd(
			function()
				local content = txt_num:getText()
				if not StringUtil.isdigit(content)  then content = "1" end
				local num = tonumber(content)
				local maxNum = self._itemData:getItemAmount()
				
				if num >= maxNum then
					self.useNum = maxNum
				elseif num < 1 then
					self.useNum = 1
				else
					self.useNum = num
				end
				txt_num:setText(self.useNum)
			end
		)


    itemListView:setItemRenderer(function(index, view)
        local itemCell = view:getChildAutoType("itemCell")
        local itemcell = BindManager.bindItemCell(itemCell)
        local award =  self.itemListView._dataTemplate[index+1]
        if  award.code then
            itemcell:setData(award.code, award.amount, award.type)
        end
        local selectedIndicator = view:getChildAutoType("n2")
        if self.showtype == GameDef.GameResType.Hero then 
            if not self._curCode then
                local visible = self.__currentSelectedIndex == index + 1
                if visible then
                    self._curCode = award.code
                    --默认
                    local heroConfig = DynamicConfigData.t_hero[self._curCode]
                    self.heroName:setText(heroConfig.heroName)
                end
                selectedIndicator:setVisible(visible)
            else
                selectedIndicator:setVisible(award.code == self._curCode)
                local heroConfig = DynamicConfigData.t_hero[self._curCode]
                self.heroName:setText(heroConfig.heroName)
            end

        else
            local visible = self.__currentSelectedIndex == index + 1
            local selectedIndicator = view:getChildAutoType("n2")
            selectedIndicator:setVisible(visible)
        end
    end)
    itemListView:setVirtual()

    --那一个奖励来看是英雄还是道具
    self.showtype = self.__itemList[1].type
    if self.showtype == GameDef.GameResType.Hero then 
        self.typeCtrl:setSelectedIndex(1)
        category0:addClickListener(function( ... )
            self.curCategory = 0
            self.itemListView:setData(self.__itemList)
        end)
        -- 种族切页
        local data = {}
        local categoryArr = {}
        local tempIndex = 0
        for idx = 1, 5 do
            data[idx] = {}
            for i,v in ipairs(self.__itemList) do
                if v.type == GameDef.GameResType.Hero then --卡牌英雄
                    local category = DynamicConfigData.t_hero[v.code].category
                    if idx == category then
                        if tempIndex ==0 then
                            tempIndex = idx
                        end
                        table.insert(data[idx],v)
                    end
                end
            end
        end
        for k,v in pairs(data) do
            if v[1] then
                table.insert(categoryArr,k)
            end
        end
        data[0] =  self.__itemList

        self.allData = data
                        
        local list  = categoryChoose:getChildAutoType("list")
        list:setItemRenderer(function(index,obj)
            local c1Ctrl = obj:getController("c1")
            local c2Ctrl = obj:getController("c2")
            c2Ctrl:setSelectedIndex(1)
            -- if index ==0 then
            --     obj:setSelected(true)
            -- end
            local tempData = list._dataTemplate[index+1]
            c1Ctrl:setSelectedIndex(tempData-1)
            obj:removeClickListener(11)
            obj:addClickListener(function( ... )
                self.curCategory = tempData
                self:changeCategory(tempData,data);
            end)
        end)

        list:setData(categoryArr)
    else
        self.typeCtrl:setSelectedIndex(0)
    end

    --默认
    itemListView:setData(self.__itemList)

    itemListView:addEventListener(FUIEventType.ClickItem, function(context)
        local item = context:getData()
        local index = itemListView:childIndexToItemIndex(itemListView:getChildIndex(item)) + 1
        self.__currentSelectedIndex = index
        itemListView:refreshVirtualList()
        if self.showtype == GameDef.GameResType.Hero then 
            local code = self.allData[self.curCategory][self.__currentSelectedIndex].code
            self._curCode = code
            local heroConfig = DynamicConfigData.t_hero[code]
            self.heroName:setText(heroConfig.heroName)
        end
    end)

    btn_add:addClickListener(function()
        if self.useNum >= self._itemData:getItemAmount() then return end
        self.useNum = self.useNum + 1
        txt_num:setText(self.useNum)
        --txt_goldNum:setText()
    end)

    btn_sub:addClickListener(function()
        if self.useNum <= 1 then return end
        self.useNum = self.useNum - 1
        txt_num:setText(self.useNum)
        --txt_goldNum:setText()
    end)

    -- 取消按钮
    btn_cancel:addClickListener(function()
        self:closeView()
    end)

    -- 使用按钮
    btn_use:addClickListener(function()
        local params = {}
        params.bagType = self._itemData:getBagType()
        params.itemId = self._itemData:getItemId()
        params.amount = self.useNum
        if self.showtype == GameDef.GameResType.Hero then 
             params.ex = self.allData[self.curCategory][self.__currentSelectedIndex].code
        else
             params.ex = self.__itemList[self.__currentSelectedIndex].code
        end
       
        RPCReq.Bag_UseItem(params, params.onSuccess)
        self:closeView()
    end)

    btn_min:addClickListener(function()
        self.useNum = 1
        txt_num:setText(self.useNum)
    end)

    btn_max:addClickListener(function()
        local maxNum = self._itemData:getItemAmount()
        self.useNum = maxNum
        if self.useNum >= maxNum then
            self.useNum = maxNum
        end
        txt_num:setText(self.useNum)
    end)
end

function C:changeCategory( idx,data)
    if self.showtype == GameDef.GameResType.Hero then 
        local category = DynamicConfigData.t_hero[self._curCode].category
        if category~=idx then
            self.__currentSelectedIndex = 1
            self._curCode = false
        end
        
    end
    self.itemListView:setData(data[idx])
end


-- [子类重写] 准备事件
function C:_initEvent( ... )

end

-- [子类重写] 添加后执行
function C:_enter()
    -- TODO
end

-- [子类重写] 移除后执行
function C:_exit()
    -- TODO
end

return C