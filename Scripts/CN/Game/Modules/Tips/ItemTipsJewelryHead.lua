--道具tips
--added by wyang
local ItemTipsJewelryHead = class("ItemTipsJewelryHead",View)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsJewelryHead:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsJewelryHead_Bag"
   self._isFullScreen = false

	self._data = args.data
end

function ItemTipsJewelryHead:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsJewelryHead:_initUI( ... )
    local itemCell = BindManager.bindItemCell(self.view:getChildAutoType("itemCell"));
    local code = self._data:getItemCode();
    itemCell:setIsBig(true);
    itemCell:setData(code, 0, GameDef.GameResType.Item);
    local nameLab = self.view:getChildAutoType("nameLabel");
    local name = self._data:getName();
    nameLab:setText(name);
    local color = self._data:getColor();
    nameLab:setColor(color);
    local desc = self.view:getChildAutoType("Desc");
    local descStr = self._data:getDescStr();
    desc:setText(descStr);
    local flag = self.view:getChildAutoType("n25");
    -- Scheduler.scheduleNextFrame(function ()
        local h = desc:getTextSize().height;
        -- local y = desc:getY();
        flag:setY(h + desc:getY() + 5)
    -- end)
end

-- [子类重写] 准备事件
function ItemTipsJewelryHead:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsJewelryHead:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsJewelryHead:_exit()
end


return ItemTipsJewelryHead