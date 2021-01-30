

local VoidlandOpenView = class("VoidlandOpenView", Window)

function VoidlandOpenView:ctor()
    self._packName = "Voidland";
    self._compName = "VoidlandOpenView";
    self._rootDepth = LayerDepth.PopWindow;
end

function VoidlandOpenView:_initUI()
    local root = self;
    local rootView = self.view;
        root.list_reward = rootView:getChildAutoType("list_reward");
        root.btn_mode1 = rootView:getChildAutoType("btn_mode1");
        root.btn_mode2 = rootView:getChildAutoType("btn_mode2");
        root.btn_help = rootView:getChildAutoType("btn_help");
    
    local mapData = VoidlandModel:getCurModeData()
    local conf = VoidlandModel:getPointInfoById(mapData.maxId)
    local data = VoidlandModel:getPassRewardByPoint(conf.nodeId);

    self.view:getController("c1"):setSelectedIndex(VoidlandModel:todayMode() - 1);

    self.list_reward:setItemRenderer(function(idx, obj)
        local itemCell = BindManager.bindItemCell(obj);
        local d = data[idx + 1].passReward;
        itemCell:setData(d.code, d.amount, d.type);
    end)
    self.list_reward:setNumItems(#data)

    self.btn_mode1:addClickListener(function()
        -- ModuleUtil.openModule(ModuleId.Voidland.id);
        self:closeView();
    end)
    self.btn_mode2:addClickListener(function()
        -- ModuleUtil.openModule(ModuleId.Voidland.id);
        self:closeView();
    end)

    self.btn_help:removeClickListener();
    self.btn_help:addClickListener(function ()
        RollTips.showHelp(Desc.help_StrTitle132, Desc.help_StrDesc132);
    end)
end

return VoidlandOpenView