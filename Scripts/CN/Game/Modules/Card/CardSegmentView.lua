-- add by zn
-- 星阶总览

local CardSegmentView = class("CardSegmentView", Window)

function CardSegmentView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardSegmentView"
    self._rootDepth = LayerDepth.PopWindow
    self.hero = self._args.hero
end

function CardSegmentView:_initUI()
    local root = self
    local rootView = self.view
        root.btn_close = rootView:getChildAutoType("btn_close");
        root.list_attr = rootView:getChildAutoType("list_attr");

    self:upListInfo();
end

function CardSegmentView:_initEvent()
    self.btn_close:addClickListener(function()
        self:closeView();
    end)
end

function CardSegmentView:upListInfo()
    local heroConf = DynamicConfigData.t_hero[self.hero.code];
    local category = (heroConf.category == 1 or heroConf.category == 2) and 2 or 1;
    local conf = DynamicConfigData.t_HeroSegmentAttr[category][self.hero.star];
    if (conf) then
        local starSegment = self.hero.starSegment and self.hero.starSegment[self.hero.star] or false
        local segment = starSegment and starSegment.starSegment or {};
        self.list_attr:setItemRenderer(function(idx, obj)
            local c = conf[idx + 1];
            local starItem = obj:getChildAutoType("starcell");
            starItem:setTitle(idx + 1);
            local data = c.addSpecialAttr[1]
            local attrConf = DynamicConfigData.t_combat[data.attrId];
            local val = data.attrId > 100 and string.format("+%s%%", data.val/100) or "+"..data.val;
            local attr = {
                string.format(Desc.card_segmentAttr1, c.addlevel),
                c.addnumericalShow,
                string.format(Desc.card_segmentAttr3, c.addattrPoint),
                attrConf.name..val
            }
            local active = segment[idx + 1] and segment[idx + 1].isActivate or false;
            if (active) then
                starItem:getController("c1"):setSelectedIndex(1);
            else
                starItem:getController("c1"):setSelectedIndex(0);
            end
            for i = 1, 4 do
                local attrLab = obj:getChildAutoType("attr"..i);
                attrLab:setText(attr[i]);
                if active then
                    attrLab:setColor(ColorUtil.itemTipsHeadColor[2]);
                    attrLab:setAlpha(1);
                else
                    attrLab:setColor(ColorUtil.itemTipsHeadColor[1]);
                    attrLab:setAlpha(0.6);
                end
            end
        end)
        self.list_attr:setNumItems(#conf);
    else
        self.list_attr:setNumItems(0);
    end
end

return CardSegmentView