-- add by zn
-- 徽章选择

local MedalChooseView = class("MedalChooseView", Window)

function MedalChooseView:ctor()
    self._packName = "Player"
    self._compName = "MedalChooseView"
    self._rootDepth = LayerDepth.PopWindow
    self.exp = 0;
    self.pos = self._args.idx;
end

function MedalChooseView:_initUI()
    local root = self
    local rootView = self.view
        root.honorIcon = rootView:getChildAutoType("honorIcon");
        root.progress = rootView:getChildAutoType("progressBar");
        root.txt_honorName = rootView:getChildAutoType("txt_honorName");
        root.txt_honorExp = rootView:getChildAutoType("txt_honorExp");
        root.btn_up = rootView:getChildAutoType("btn_up");
        root.list_medal = rootView:getChildAutoType("list_medal");
        root.medalIcon = rootView:getChildAutoType("medalIcon");
        root.txt_medalName = rootView:getChildAutoType("txt_medalName");
        root.txt_medalExp = rootView:getChildAutoType("txt_medalExp");
        root.txt_desc = rootView:getChildAutoType("txt_desc");
        root.txt_attr = rootView:getChildAutoType("txt_attr");
        root.txt_time = rootView:getChildAutoType("txt_time");
        root.btn_change = rootView:getChildAutoType("btn_change"); -- 装备
        root.btn_unequip = rootView:getChildAutoType("btn_unequip"); -- 卸下

    self:showMedalList();
    self:showHonorInfo();
end

function MedalChooseView:HonorMedal_update()
    self:showMedalList();
    self:showHonorInfo();
end

function MedalChooseView:showHonorInfo()
    local lv = HonorMedalModel.honorLevel;
    local conf = DynamicConfigData.t_MedalOfHonor[lv]
    local nextConf = DynamicConfigData.t_MedalOfHonor[lv + 1]
    if (conf) then
        local needPoint = nextConf and nextConf.needPoint or 1
        self.honorIcon:setIcon(string.format("Icon/medal/%s.png", conf.icon));
        self.txt_honorName:setText(conf.title);
        self.progress:setMax(needPoint);
        self.progress:setValue(self.exp or 0);
        self.txt_honorExp:setText(string.format("%s/%s", self.exp or 0, needPoint == 1 and "MAX" or needPoint));
        self.btn_up:removeClickListener();
        self.btn_up:addClickListener(function()
            if (self.exp < needPoint) then
                RollTips.show(Desc.player_medalPoint2);
            else
                HonorMedalModel:upHonorLv();
            end
        end)
        -- local showFlag = (self.exp ~= 0 and lv == 1) or (lv ~= 1 and nextConf and self.exp >= needPoint)
        if (not nextConf) then
            self.btn_up:setVisible(false);
        else
            self.btn_up:setVisible(true);
            if (self.exp >= needPoint) then
                self.btn_up:setGrayed(false);
                -- self.btn_up:setTouchable(true);
            else
                self.btn_up:setGrayed(true);
                -- self.btn_up:setTouchable(false);
            end
        end
    end
end

function MedalChooseView:showMedalList()
    local bag = PackModel:getHonorMedalBag();
    local arr = {};
    local map = {};
    local items = bag.__packItems;
    local defaultPos = 0;
    self.exp = 0
    local conf = DynamicConfigData.t_MedalOfAchievement
    for _, d in pairs(items) do
        local code = d.__data.code;
        local c = conf[code];
        if (c) then
            self.exp = self.exp + c.point;
            local info = {
                code = code,
                have = true,
                equiped = HonorMedalModel:isEquiped(code),
            }
            map[code] = info
            table.insert(arr, info);
            if (info.equiped == self.pos) then
                defaultPos = #arr;
            end
        end
    end
    for code, c in pairs(conf) do
        if (not map[code]) then
            local info = {
                code = code,
                have = false
            }
            table.insert(arr, info);
        end
    end
    self.list_medal:setItemRenderer(function(idx, obj)
        local data = arr[idx + 1];
        local c = conf[data.code];
        if (c) then
            local c1 = obj:getController("c1");
            obj:setIcon(string.format("Icon/medal/%s.png", c.icon))
            c1:setSelectedIndex(data.equiped and 1 or 0);
            obj:setGrayed(not data.have)
        end
        obj:removeClickListener();
        obj:addClickListener(function()
            self:showMedalInfo(data)
            self.list_medal:setSelectedIndex(idx);
        end)
        RedManager.register("HonorMedal_New_"..data.code, obj:getChildAutoType("img_red"));
    end)
    self.list_medal:setNumItems(#arr);
    local c2 = self.view:getController("c2");
    if #arr > 0 then
        if (self.list_medal:getSelectedIndex() == -1) then
            local index = math.max(defaultPos, 1);
            self.list_medal:setSelectedIndex(index - 1);
            self:showMedalInfo(arr[index]);
            c2:setSelectedIndex(1);
        else
            local index = self.list_medal:getSelectedIndex()
            self:showMedalInfo(arr[index + 1]);
        end
    else
        c2:setSelectedIndex(0);
    end
end

function MedalChooseView:showMedalInfo(data)
    -- 点击新勋章红点消失
    local str = FileCacheManager.getStringForKey("HonorMedal_NewMedal", "");
    local arr = string.split(str, ",");
    local flag = false;
    for _, codeStr in ipairs(arr) do
        if (tonumber(codeStr) == data.code) then
            flag = true;
        end
    end
    if (not flag and HonorMedalModel:isInBag(data.code)) then
        table.insert(arr, tostring(data.code));
        FileCacheManager.setStringForKey("HonorMedal_NewMedal", table.concat(arr, ","));
        HonorMedalModel:checkRed()
    end


    local code = data.code
    local conf = DynamicConfigData.t_MedalOfAchievement[code];
    local c1 = self.view:getController("c1");
    if (conf) then
        local isEquiped = data.equiped or false
        c1:setSelectedIndex(1);
        self.medalIcon:setIcon(string.format("Icon/medal/%s.png", conf.icon));
        self.txt_medalName:setText(conf.name);
        self.txt_medalExp:setText(Desc.player_medalPoint..conf.point);
        self.txt_desc:setText(conf.unlockingConditions);
        self.txt_attr:setText(conf.attrType);
        self.txt_time:setText(conf.existTime == -1 and Desc.player_forever or conf.existTime);
        self.btn_change:removeClickListener();
        self.btn_change:addClickListener(function()
            HonorMedalModel:equipMedal(self.pos, code)
        end);
        self.btn_unequip:removeClickListener();
        self.btn_unequip:addClickListener(function()
            HonorMedalModel:equipMedal(isEquiped, 0)
        end)
        if (isEquiped) then
            self.btn_unequip:setVisible(true);
            self.btn_change:setVisible(false);
        else
            self.btn_unequip:setVisible(false);
            self.btn_change:setVisible(self._args.idx ~= 0 and data.have and not isEquiped);
        end
    else
        c1:setSelectedIndex(0);
    end
end

return MedalChooseView