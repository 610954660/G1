-- 装备升星活动
-- add by zn

local EquipChooseView = class("EquipChooseView", Window);

function EquipChooseView:ctor()
    self._packName = "EquipUpStar";
    self._compName = "EquipChooseView";
    self._rootDepth = LayerDepth.PopWindow;
    self.type = self._args.type;
    self.data = false;
    self.selected = false;
end

function EquipChooseView:_initUI()
    local root = self;
    local rootView = self.view;
        root.list_equip = rootView:getChildAutoType("list_equip");
        root.btn_ok = rootView:getChildAutoType("btn_ok");

    
end

function EquipChooseView:_initEvent()
    self.list_equip:setItemRenderer(function (idx, obj)
        self:upEquips(idx, obj);
    end)

    self.btn_ok:addClickListener(function ()
        local eqInfo = self.selected and self.data[self.selected] or false;
        --[[if (eqInfo and eqInfo.heroUuid) then
            local onYesFunc = function ()
                EquipUpStarModel:unEquip(eqInfo, function (newEqInfo)
                    self.data[self.selected] = newEqInfo;
                    if (tolua.isnull(self.view)) then return end;
                    self:upListInfo()
                end)
            end
            local alertInfo = {
                text = Desc.EquipUpStar_isEquiped,
                type = "yes_no",
                onYes = onYesFunc
            }
            Alert.show(alertInfo);
        else--]]
            EquipUpStarModel:selectEquip(self.type, eqInfo);
            self:closeView();
--        end
    end)
    self:upListInfo();
end

function EquipChooseView:upListInfo()
    self.data = EquipUpStarModel:getEquipList(self.type);
    local ctrl = self.view:getController("c1");
    ctrl:setSelectedIndex(#self.data > 0 and 1 or 0);
    self.list_equip:setNumItems(#self.data);
end

function EquipChooseView:upEquips(idx, obj)
    local data = self.data[idx + 1];
    local heroIcon = obj:getChildAutoType("heroIcon");
    if (not obj.itemCell) then
        obj.itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
        obj.itemCell:setIsMid(true);
    end
    local ctrl = obj:getController("c1");
    if (data.heroUuid) then
        ctrl:setSelectedIndex(1);
        local hero = CardLibModel:getHeroByUid(data.heroUuid);
        local url = PathConfiger.getHeroCard(hero.code);
        heroIcon:setIcon(url);
    else
        ctrl:setSelectedIndex(0);
    end
    obj.itemCell:setClickable(false);
    obj.itemCell:setData(data.code, 0, CodeType.ITEM);
    obj:removeClickListener();
    obj:addClickListener(function ()
        if (self.selected) then
            local children = self.list_equip:getChildren();
            children[self.selected].itemCell:setIsHook(false);
        end
        self.selected = idx + 1;
        obj.itemCell:setIsHook(true);
    end);
end

return EquipChooseView