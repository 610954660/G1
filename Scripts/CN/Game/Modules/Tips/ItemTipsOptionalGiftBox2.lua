local ItemTipsOptionalGiftBox2 = class("ItemTipsOptionalGiftBox2", Window)
--local ItemCell = require "Game.UI.Global.ItemCell"

function ItemTipsOptionalGiftBox2:ctor(args)
    self._packName = "ToolTip"
    self._compName = "ItemTipsOptionalGiftBox2"
    self._rootDepth = LayerDepth.PopWindow
    self._itemData = args

    local info = self._itemData:getItemInfo()
    self.groupList = info.para
    self.__currentSelectedIndex = 1

    self.useNum = 1
    self.allData = {}
    self.curCategory = 0
end

function ItemTipsOptionalGiftBox2:init( ... )
    -- body
end

function ItemTipsOptionalGiftBox2:getShowType()
    local gid = self.groupList[1]
    if gid and  DynamicConfigData.t_GiftGroupConfig[gid] then
        return DynamicConfigData.t_GiftGroupConfig[gid].reward[1].type
    end
    return 1
end

function ItemTipsOptionalGiftBox2:getRewardByIndex(index)
    if self.groupList and self.groupList[index] then
        local gid = self.groupList[index]  
        if gid and  DynamicConfigData.t_GiftGroupConfig[gid] then
            return DynamicConfigData.t_GiftGroupConfig[gid].reward
        end
    end
    return {}
end

-- [子类重写] 初始化UI方法
function ItemTipsOptionalGiftBox2:_initUI( ... )
    local viewRoot = self.view;
    local itemListView = viewRoot:getChildAutoType("itemList")
    self.itemListView = itemListView
    local btn_sub = viewRoot:getChildAutoType("btn_sub")
    local btn_add = viewRoot:getChildAutoType("btn_add")
    local txt_num = viewRoot:getChildAutoType("txt_num")
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

    itemListView:setItemRenderer(function(index, view)
        local itemList = view:getChildAutoType("itemList")
        local rewards = self:getRewardByIndex(index+1)
   
        itemList:setVirtual()
        itemList:setItemRenderer(function(index2, obj)
            local itemcell = BindManager.bindItemCell(obj)
            local award =  rewards[index2+1]
            if  award.code then
                itemcell:setData(award.code, award.amount, award.type)
            end
        end)
        itemList:setData(rewards)
        
        local visible = self.__currentSelectedIndex == index + 1
        local selectedIndicator = view:getChildAutoType("n2")
        selectedIndicator:setVisible(visible)
    end)
    itemListView:setVirtual()

    --那一个奖励来看是英雄还是道具
    self.showtype = self:getShowType()
    --分组的情势 暂时未支持英雄
    if self.showtype == GameDef.GameResType.Hero then 
        -- self.typeCtrl:setSelectedIndex(1)
        -- category0:addClickListener(function( ... )
        --     self.curCategory = 0
        --     self.itemListView:setData(self.groupList)
        -- end)
        -- -- 种族切页
        -- local data = {}
        -- local categoryArr = {}
        -- local tempIndex = 0
        -- for idx = 1, 5 do
        --     data[idx] = {}
        --     for i,v in ipairs(self.__itemList) do
        --         if v.type == GameDef.GameResType.Hero then --卡牌英雄
        --             local category = DynamicConfigData.t_hero[v.code].category
        --             if idx == category then
        --                 if tempIndex ==0 then
        --                     tempIndex = idx
        --                 end
        --                 table.insert(data[idx],v)
        --             end
        --         end
        --     end
        -- end
        -- for k,v in pairs(data) do
        --     if v[1] then
        --         table.insert(categoryArr,k)
        --     end
        -- end
        -- data[0] =  self.__itemList

        -- self.allData = data
                        
        -- local list  = categoryChoose:getChildAutoType("list")
        -- list:setItemRenderer(function(index,obj)
        --     local c1Ctrl = obj:getController("c1")
        --     local c2Ctrl = obj:getController("c2")
        --     c2Ctrl:setSelectedIndex(1)
        --     -- if index ==0 then
        --     --     obj:setSelected(true)
        --     -- end
        --     local tempData = list._dataTemplate[index+1]
        --     c1Ctrl:setSelectedIndex(tempData-1)
        --     obj:removeClickListener(11)
        --     obj:addClickListener(function( ... )
        --         self.curCategory = tempData
        --         self:changeCategory(tempData,data);
        --     end)
        -- end)

        -- list:setData(categoryArr)
        -- --默认
        -- local code = self.allData[0][1].code
        -- local heroConfig = DynamicConfigData.t_hero[code]
        -- self.heroName:setText(heroConfig.heroName)
    else
        self.typeCtrl:setSelectedIndex(0)
    end
    itemListView:setData(self.groupList)

    itemListView:addEventListener(FUIEventType.ClickItem, function(context)
        local item = context:getData()
        local index = itemListView:childIndexToItemIndex(itemListView:getChildIndex(item)) + 1
        self.__currentSelectedIndex = index
        itemListView:refreshVirtualList()
        if self.showtype == GameDef.GameResType.Hero then 
            local code = self.allData[self.curCategory][self.__currentSelectedIndex].code
            local heroConfig = DynamicConfigData.t_hero[code]
            self.heroName:setText(heroConfig.heroName)
        end
    end)

    -- 使用按钮
    btn_use:addClickListener(function()
        local params = {}
        params.bagType = self._itemData:getBagType()
        params.itemId = self._itemData:getItemId()
        params.amount = self.useNum
        if self.showtype == GameDef.GameResType.Hero then 
                -- params.ex = self.allData[self.curCategory][self.__currentSelectedIndex].code
        else
                params.ex = self.groupList[self.__currentSelectedIndex]
        end
        
        RPCReq.Bag_UseItem(params, params.onSuccess)
        self:closeView()
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

function ItemTipsOptionalGiftBox2:changeCategory( idx,data)
    self.itemListView:setData(data[idx])
end


-- [子类重写] 准备事件
function ItemTipsOptionalGiftBox2:_initEvent( ... )

end

-- [子类重写] 添加后执行
function ItemTipsOptionalGiftBox2:_enter()
    -- TODO
end

-- [子类重写] 移除后执行
function ItemTipsOptionalGiftBox2:_exit()
    -- TODO
end

return ItemTipsOptionalGiftBox2