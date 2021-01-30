-- add by zn
-- 已经装备的
local EmblemCell = require "Game.Modules.Emblem.EmblemCell";
local EmblemEquipedView = class("EmblemEquipedView", Window)

function EmblemEquipedView:ctor()
    self._packName = "Emblem"
    self._compName = "EmblemEquipedView"
    self._rootDepth = LayerDepth.PopWindow
    self.data = self._args.unEquiplist;
    self.equipList = self._args.equipList;
end

function EmblemEquipedView:_initUI()
    local root = self
    local rootView = self.view
        root.list_item = rootView:getChildAutoType("list_item");
        root.btn_sure = rootView:getChildAutoType("btn_sure");
        root.btn_cancel = rootView:getChildAutoType("btn_cancel");
        root.btn_check = rootView:getChildAutoType("btn_check");

    self.list_item:setItemRenderer(function (idx, obj)
        local d = self.data[idx + 1];
        if (not obj.hero) then
            obj.hero = BindManager.bindHeroCell(obj:getChildAutoType("playerCell"));
        end
        local heroData = CardLibModel:getHeroByUid(d.heroUuid);
        obj.hero:setBaseData(heroData);

        if (not obj.starCell) then
            obj.starCell = BindManager.bindCardStar(obj:getChildAutoType("cardStar"));
        end
        obj.starCell:setData(d.star)

        local item = obj:getChildAutoType("emblem");
        if (not obj.emblem) then
            obj.emblem = EmblemCell.new(item);
        end
        obj.emblem:showFrame(false)
        obj.emblem:setStarType(0)
        obj.emblem:setData(d)
    end)
    self.list_item:setNumItems(#self.data);
end

function EmblemEquipedView:_initEvent()
    self.btn_cancel:addClickListener(function ()
        -- self:saveNoTips(0);
        self:closeView();
    end)
    self.btn_sure:addClickListener(function ()
        local list = {}
        for _, data in pairs(self.data) do
            local info = {
                heroUuid = data.heroUuid,
                heraldryUuid = data.uuid
            }
            table.insert(list, info);
        end

        local hero = ModelManager.CardLibModel.curCardStepInfo;
        local equipList = {}
        for _, data in pairs(self.equipList) do
            local info = {
                heroUuid = hero.uuid,
                heraldryUuid = data.uuid
            }
            table.insert(equipList, info);
        end
        -- printTable(2233, list)
        -- printTable(2233, equipList)
        EmblemModel:unequipWithList(list, function()
            EmblemModel:equipWithList(equipList)
        end);
        self:saveNoTips(1);
        self:closeView();
        -- RollTips.show(Desc.Emblem_unequip)
    end)
    self._closeBtn:removeClickListener()
    self._closeBtn:addClickListener(function()
        -- self:saveNoTips(0);
        self:closeView();
    end)

    self.btn_check:addClickListener(function()
        self.btn_cancel:setVisible(not self.btn_check:isSelected())
    end)
end

-- isSure 1 是点击确认关闭  0 是点击取消 或空白关闭
function EmblemEquipedView:saveNoTips(isSure)
    local check = self.btn_check:isSelected();
    if (check) then
        local today =  TimeLib.getWeekDay()
        local val = today * 10 + isSure
        FileCacheManager.setIntForKey("EmbelmEquipedTip", val)
    end
end

return EmblemEquipedView