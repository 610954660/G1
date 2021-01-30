--道具tips
--added by wyang
local ItemTipsJewelryAttr = class("ItemTipsJewelryAttr",View)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsJewelryAttr:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsJewelryAttr"
   self._isFullScreen = false

	self._data = args.data
end

function ItemTipsJewelryAttr:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsJewelryAttr:_initUI( ... )
    local list_attr = self.view:getChildAutoType("list_attr")
    -- 属性
    local conf = DynamicConfigData.t_combat;
    local d = self._data.attr
    if (d) then
        local attr = {};
        for _, v in pairs(d) do
            table.insert(attr, v);
        end
        list_attr:setItemRenderer(function(index,obj)
            local name = obj:getChildAutoType("title")
            local value = obj:getChildAutoType("value")
            local ctrl = obj:getController("c1");
            if (index == 0) then
                local combat = JewelryModel:calcCombat(self._data);
                name:setText(Desc.materialCopy_str5);
                value:setText(StringUtil.transValue(combat));
                ctrl:setSelectedIndex(0);
            else
                local id = attr[index].id;
                local sxInfo = conf[id];
                name:setText(sxInfo.name..":")
                if (id > 100) then
                    value:setText(string.format("%s%%", attr[index].value / 100))
                else
                    value:setText(attr[index].value)
                end
                
                ctrl:setSelectedIndex(1);
            end
        end)
        local len = #attr + 1
        list_attr:setNumItems(len)
        list_attr:resizeToFit(len)
    end
    -- 有属性加成
    local percent = self._data.percentageValue;
    local ctrl = self.view:getController("c1");
    if (percent and percent > 0) then
        ctrl:setSelectedIndex(1)
        local prog = self.view:getChildAutoType("progressBar");
        prog:setMax(10000);
        prog:setValue(percent);
        local val = (percent / 100).."%";
        prog:getChildAutoType("title"):setText(val);
    elseif (self._data.skill) then
        ctrl:setSelectedIndex(0)
        local list = self.view:getChildAutoType("list_skill");
        local dataArr = self._data.skill
        list:setItemRenderer(function (idx, obj)
            local skillId = dataArr[idx + 1];
            local skillCell = BindManager.bindSkillCell(obj)
            local ultSkillurl = CardLibModel:getItemIconByskillId(skillId);
            skillCell.iconLoader:setURL(ultSkillurl) --放了一张技能图片
            skillCell.iconLoader:setScale(1,1)
            obj:getChildAutoType("n29"):setVisible(false)
        end)
        list:setNumItems(#dataArr)
    end
end

-- [子类重写] 准备事件
function ItemTipsJewelryAttr:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsJewelryAttr:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsJewelryAttr:_exit()
end


return ItemTipsJewelryAttr