-- add by zn
-- 推荐组合
local HelpGroupPanel = require "Game.Modules.HelpSystem.HelpGroupPanel";
local HelpRestraintPanel = require "Game.Modules.HelpSystem.HelpRestraintPanel";
local HelpSysGroupView = class("HelpSysGroupView", Window)

function HelpSysGroupView:ctor()
    self._packName = "HelpSystem"
    self._compName = "HelpSysGroupView"
    self._rootDepth = LayerDepth.PopWindow
end

function HelpSysGroupView:_initUI()
    local root = self
    local rootView = self.view
        root.list_group = rootView:getChildAutoType("list_group");
        root.groupPanel = HelpGroupPanel.new(rootView:getChildAutoType("groupPanel"));
        root.restraintPanel = HelpRestraintPanel.new(rootView:getChildAutoType("restraintPanel"));

        local conf = DynamicConfigData.t_Recommendset;
        self.list_group:setItemRenderer(function (idx, obj)
            local c = conf[idx + 1];
            obj:setTitle(c.name);
            obj:removeClickListener();
            obj:addClickListener(function ()
                self:changePanelShow(c);
                self.list_group:setSelectedIndex(idx);
            end)
            RedManager.register("V_HELP_GROUP"..(idx+1), obj:getChildAutoType("img_red"));
        end)
        self.list_group:setNumItems(#conf);
        self:changePanelShow(conf[1]);
        self.list_group:setSelectedIndex(0);
end

function HelpSysGroupView:changePanelShow(conf)
    local ctrl = self.view:getController("typeCtrl");
    ctrl:setSelectedIndex(conf.type and conf.type - 1 or 0)
    if (conf.type == 1) then
        self.groupPanel:setData(conf);
    elseif (conf.type == 2) then
        self.restraintPanel:setData(conf);
    end
end

return HelpSysGroupView