
-- 虚空幻境战斗ui

local VoidlandBattleView = class("VoidlandBattleView", Window)

function VoidlandBattleView:ctor()
    self._packName = "Voidland";
    self._compName = "VoidlandBattleView";
    self._rootDepth = LayerDepth.PopWindow;
    self.awardList = false;
end

function VoidlandBattleView:_initUI()
    local root = self;
    local rootView = self.view;
        for i = 1, 2 do
            root["heroCell"..i] = BindManager.bindHeroCell(rootView:getChildAutoType("heroCell"..i));
        end
        root.btn_skill = rootView:getChildAutoType("btn_skill");
        root.itemCell = BindManager.bindItemCell(rootView:getChildAutoType("itemCell"));
        root.txt_point = rootView:getChildAutoType("txt_point");
        root.list_award = rootView:getChildAutoType("list_award");

        if (VoidlandModel.modeType == 2) then
            rootView:getController("c2"):setSelectedIndex(1);
        end

    self.list_award:setItemRenderer(function (idx, obj)
        local d = self.awardList[idx + 1];
        if (not obj.costItem) then
            obj.costItem = BindManager.bindCostItem(obj);
        end
        local url = ItemConfiger.getItemIconByCode(d.code, d.type, false);
        obj.costItem.iconLoader:setURL(url);
        obj.costItem.txt_num:setText(StringUtil.transValue(d.amount, 2));
    end)
    self:Voidland_infoUpdate();
end

function VoidlandBattleView:_initEvent()
    self.btn_skill:addClickListener(function()
        ViewManager.open("VoidlandSkillBagView");
    end)
    

    self.itemCell.view:removeClickListener(33);
    self.itemCell.view:addClickListener(function ()
        ViewManager.open("VoidlandRewardView", {modeType = VoidlandModel.modeType});
    end)
end

function VoidlandBattleView:Voidland_infoUpdate()
    local mapData = VoidlandModel:getCurModeData();
    local mapId = VoidlandModel.curMapId --math.max(mapData.id - 1, 1)
    local nearData = VoidlandModel:getNearFirstAward(mapId);
    if (nearData) then
        local award = nearData.passReward[1];
        self.itemCell:setData(award.code, award.amount, award.type);
    end
    local conf = VoidlandModel:getPointInfoById(mapId);
    local pointConf = VoidlandModel:getAllConfByPoint()[conf.nodeId];
    self.txt_point:setText(string.format(Desc.Voidland_battlePoint, conf.nodeId, conf.index, #pointConf));
    local ctrl = self.view:getController("c1");
    if (VoidlandModel.rewardList and next(VoidlandModel.rewardList)) then
        self.awardList = {}
        for _, data in pairs(VoidlandModel.rewardList) do
            table.insert(self.awardList, data);
        end
        self.list_award:setNumItems(#self.awardList);
        ctrl:setSelectedIndex(1);
    else
        ctrl:setSelectedIndex(0);
    end
    self:updateHeroShow();
end

function VoidlandBattleView:updateHeroShow()
    local heroData = {};
    local allHero = VoidlandModel.preHeroMap;--VoidlandModel:getCurModeData().heroMap;
    if (VoidlandModel.heroIndex) then
        for i = 1, 3 do
            if (VoidlandModel.heroIndex ~= i and VoidlandModel.singleList[i]) then
                table.insert(heroData, VoidlandModel.singleList[i]);
            end
        end
    else
        local flag = false;
        for i = 1, 3 do
            local uuid = VoidlandModel.singleList[i] and VoidlandModel.singleList[i].uuid or "";
            if (uuid ~= "" and #heroData < 2) then
                if (not allHero[uuid] or (allHero[uuid].hpPercent > 0 and not flag)) then
                    flag = true;
                else
                    table.insert(heroData, VoidlandModel.singleList[i]);
                end
            end
        end
    end

    for i = 1, 2 do
        local obj = self["heroCell"..i];
        local d = heroData[i]
        if (d) then
            obj.view:setVisible(true);
            local conf = DynamicConfigData.t_hero[d.code];
            local data = CardLibModel:getHeroByUid(d.uuid);
            local heroInfo = {
                category = conf.category,
                star = data.star,
                level = data.level,
                code = d.code,
                uuid = d.uuid,
            }
            obj:setBaseData(heroInfo);
            local ctrl = obj.view:getController("grayCtrl")
            if (allHero[d.uuid] and allHero[d.uuid].hpPercent <= 0) then
                ctrl:setSelectedIndex(1)
            else
                ctrl:setSelectedIndex(0)
            end
        else
            obj.view:setVisible(false)
        end
    end
end

return VoidlandBattleView;