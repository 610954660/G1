-- add by zn
-- 整套镶嵌界面
local EmblemCell = require "Game.Modules.Emblem.EmblemCell";
local EmblemSuitSuggestView = class("EmblemSuitSuggestView", Window)

function EmblemSuitSuggestView:ctor()
    self._packName = "Emblem"
    self._compName = "EmblemSuitSuggestView"
    self._rootDepth = LayerDepth.PopWindow
    self._includeEquiped = true;
    self.timer = false;
end

function EmblemSuitSuggestView:_initUI()
    local root = self
    local rootView = self.view
        root.list_bag = rootView:getChildAutoType("list_bag");
        root.checkBox = rootView:getChildAutoType("checkBox");
        root.txt_name = rootView:getChildAutoType("infoPanel/txt_name");
        root.list_suit = rootView:getChildAutoType("infoPanel/list_suit");
        root.infoPanel = rootView:getChildAutoType("infoPanel");

    -- root.infoPanel:setPivot(1, 0.5, true);
    self.list_bag:setVirtual();
    self.checkBox:setSelected(not self._includeEquiped);
    self:_refreshBag();
end

function EmblemSuitSuggestView:_initEvent()
    self.checkBox:addClickListener(function ()
        self._includeEquiped = not self._includeEquiped;
        self:_refreshBag();
    end)

    self._closeBtn:removeClickListener();
    self._closeBtn:addClickListener(function ()
        self:closeView()
        Dispatcher.dispatchEvent("EmblemBagView_showBag");
    end)
end

function EmblemSuitSuggestView:_refreshBag()
    local hero = ModelManager.CardLibModel.curCardStepInfo;
    local allSuitInfo = EmblemModel:getSuggestSuit(hero, self._includeEquiped)
    self.list_bag:setVirtual();
    self.list_bag:setItemRenderer(function (idx, obj)
        local info = allSuitInfo[idx + 1];
        self:refreshBagItem(obj, info);
    end)
    self.list_bag:setNumItems(#allSuitInfo);
end

function EmblemSuitSuggestView:refreshBagItem(obj, info)
    local emblems = info.list;
    local equiped = {};
    local hero = ModelManager.CardLibModel.curCardStepInfo;
    local showEquipBtn = false;
    obj:getController("c1"):setSelectedIndex(info.suggest and 1 or 0);
    for i = 1, 4 do
        local item = obj:getChildAutoType("emblemPanel/emblem"..i);
        if (not item.cell) then
            item.cell = EmblemCell.new(item);
        end
        local ctrl = item:getController("c2");
        ctrl:setSelectedIndex(1)
        local d = emblems[i]
        item.cell:showFrame(false)
        item.cell:setGrayed(false)
        item.cell:setStarType(1)
        if (d) then
            if (d.heroUuid and d.heroUuid ~= hero.uuid) then
                table.insert(equiped, d);
            end
            -- ctrl:setSelectedIndex(1)
            item.cell:setData(d);
            item.cell:setGrayed(false);
            showEquipBtn = true
        else
            local defaultInfo = {
                code = info.suitId * 100 + 11,
                pos = i,
                color = 1
            }
            -- ctrl:setSelectedIndex(1)
            item.cell:setData(defaultInfo);
            item.cell:setGrayed(true);
            -- item.cell:setDefaultBg(i);
        end
    end
    local conf = DynamicConfigData.t_EmblemSuit[info.suitId];
    local txt_name = obj:getChildAutoType("txt_name");
    local list_suit = obj:getChildAutoType("list_suit");
    local btn_equip = obj:getChildAutoType("btn_equip");
    if (conf) then
        txt_name:setText(conf.suitName);
        list_suit:setItemRenderer(function (i, o)
            local idx = (i + 1) * 2;
            o:getChildAutoType("desc"):setText(conf["suitTag"..idx])
            o:getController("c1"):setSelectedIndex(info[idx] and 1 or 0);
        end)
        list_suit:setNumItems(2);
    end
    btn_equip:setVisible(showEquipBtn)
    btn_equip:removeClickListener();
    btn_equip:addClickListener(function (context)
        context:stopPropagation()
        local hero = ModelManager.CardLibModel.curCardStepInfo;
        local storage = FileCacheManager.getIntForKey("EmbelmEquipedTip", -1)
        local today =  TimeLib.getWeekDay()
        local storageCheck = storage == -1 and 1 or storage % 2   -- storage 存储为两位数如  31 3代表星期数做屏蔽弹窗  个位数上1代表默认确认 0代表默认取消
        if (#equiped > 0) then
            if (storage == -1 or math.floor(storage / 10) ~= today) then
                ViewManager.open("EmblemEquipedView", {unEquiplist = equiped, equipList = emblems});
                return;
            end
        end

        if (storageCheck == 1) then
            local list = {};
            for _, em in pairs(emblems) do
                if (em.heroUuid ~= hero.uuid) then
                    local info = {
                        heroUuid = hero.uuid,
                        heraldryUuid = em.uuid
                    }
                    table.insert(list, info);
                end
            end
            if (#list <= 0) then
                RollTips.show(Desc.Emblem_suitEquiped);
            elseif (#equiped > 0) then
                local otherList = {}
                for _, data in ipairs(equiped) do
                    local info = {
                        heroUuid = data.heroUuid,
                        heraldryUuid = data.uuid
                    }
                    table.insert(otherList, info);
                end
                EmblemModel:unequipWithList(otherList, function()
                    EmblemModel:equipWithList(list)
                end);
            else
                EmblemModel:equipWithList(list);
            end
        end
    end)

    local btn_check = obj:getChildAutoType("btn_check");
    btn_check:removeClickListener();
    btn_check:addClickListener(function(context)
        context:stopPropagation()
        Dispatcher.dispatchEvent("Emblem_changeSuitBag", info.suitId);
    end)

    obj:removeClickListener()
    obj:addClickListener(function ()
        local x, y = obj:displayObject():getPosition();
        local parent = obj:displayObject():getParent();
        local worldPos = parent:convertToWorldSpaceAR(cc.p(x, y))
        local ctrl = self.view:getController("c1");
        ctrl:setSelectedIndex(1);
        self:refreshInfoPanel(info, worldPos);
    end)
end

function EmblemSuitSuggestView:refreshInfoPanel(info, worldPos)
    local conf = DynamicConfigData.t_EmblemSuit[info.suitId];
    if (conf) then
        self.txt_name:setText(conf.suitName);
        -- local totalSuit = 0;
        -- if (info[2] and info[2] > 0) then
        --     totalSuit = totalSuit + 1
        -- end
        -- if (info[4] and info[4] > 0) then
        --     totalSuit = totalSuit + 1
        -- end
        self.list_suit:setItemRenderer(function (idx, obj)
            local i = (idx + 1) * 2;
            local desc = conf["suitDes"..i];
            desc = EmblemModel:suitStrToRich(desc, info[i] or 0)
            local str = string.format(Desc.Emblem_suit, i).."："..desc;
            obj:getChildAutoType("desc"):setText(str);
        end)
        self.list_suit:setNumItems(2)
        -- Scheduler.scheduleNextFrame(function()
            self.list_suit:resizeToFit(2);
        -- end)
    end

    local parent = self.infoPanel:displayObject():getParent();
    local localPos = parent:convertToNodeSpaceAR(worldPos);
    local x = localPos.x - self.infoPanel:getWidth();
    local y = -localPos.y - 33
    -- y = math.min(math.max(0, y), self.view:getHeight() - self.infoPanel:getHeight())
    -- print(2233, y);
    self.infoPanel:setPosition(x, y)
end

function EmblemSuitSuggestView:Emblem_emblemEquipChange()
    if (self.timer) then return end;
    self.timer = Scheduler.scheduleOnce(0.1, function ()
        self:_refreshBag();
        self.timer = false;
    end)
end

function EmblemSuitSuggestView:EmblemBagView_close()
    self:closeViewNextFrame()
end

function EmblemSuitSuggestView:cardView_updateInfo()
    self:_refreshBag();
end

return EmblemSuitSuggestView