--道具tips
--added by wyang
local ItemTipsEquipSuitAttr = class("ItemTipsEquipSuitAttr", View)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsEquipSuitAttr:ctor(args)
    self._packName = "ToolTip"
	if args.winType == "itemTips" then
		self._compName = "ItemTipsEquipSuitAttr"
	else
		self._compName = "ItemTipsEquipSuitAttr_Bag"
	end
    self._isFullScreen = false
    self._data = args.data
end

function ItemTipsEquipSuitAttr:init(...)
    -- body
end

-- [子类重写] 初始化UI方法
function ItemTipsEquipSuitAttr:_initUI(...)
    local c1 = self.view:getController("c1")
    local list_attr = self.view:getChildAutoType("list_attr")
    local itemInfo = self._data:getItemInfo()
    local info = DynamicConfigData.t_equipEquipment[itemInfo.code]
    local taozhuang = DynamicConfigData.t_equipsuit[info.color]
    if taozhuang then
        taozhuang = taozhuang[info.staramount]
        if not taozhuang then
            taozhuang = {}
        end
    else
        taozhuang = {}
    end
    if #taozhuang > 0 then
        list_attr:setItemRenderer(
            function(index, obj)
                local tzInfo = taozhuang[index + 1]
                local suitName = obj:getChildAutoType("name")
                suitName:setVisible(true)
                suitName:setText(tzInfo.attrName .. tzInfo.show)
                local value = obj:getChildAutoType("value")
                local colorStr = Desc["common_toolColor" .. info.color]
                value:setText(Desc.equipment_taozhuang:format(colorStr, info.staramount, tzInfo.count))
            end
        )
    end
    list_attr:setNumItems(#taozhuang)
    list_attr:resizeToFit(#taozhuang)
end

-- [子类重写] 准备事件
function ItemTipsEquipSuitAttr:_initEvent(...)
end

-- [子类重写] 添加后执行
function ItemTipsEquipSuitAttr:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsEquipSuitAttr:_exit()
end

return ItemTipsEquipSuitAttr
