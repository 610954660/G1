
-- 帮助系统 (我要变强)
-- added by zn

local StrongItem = require "Game.Modules.HelpSystem.StrongItem";
local HelpSysStrongView, Super = class("HelpSysStrongView", Window);

function HelpSysStrongView:ctor ()
    self._packName = "HelpSystem";
    self._compName = "HelpSysStrongView";

    -- self.btn_help = false;
    -- 我的阵容
    self.list_myTeam = false;
    self.list_myTeamItems = {};
    -- 我要变强
    self.list_strong = false;
    self.list_strongItems = {};

    HelpSystemModel.selected = 1;
end

function HelpSysStrongView:_initUI()
    --self:setBg("bg_HelpSystem.png");

    -- self.btn_help = self.view:getChild("btn_help");

    self.list_myTeam = self.view:getChild("list_myTeam");
    -- self.list_myTeam:setVirtual();
    self.list_myTeam:setItemRenderer(function (idx, obj)
        if (not obj.lua_script) then
            obj.lua_script = BindManager.bindCardCell(obj)
        end
        self.list_myTeamItems[idx + 1] = obj.lua_script;
        obj:removeClickListener(22);
        obj:addClickListener(function ()
            local pre = self.list_myTeamItems[HelpSystemModel.selected];
            pre:setStatus(0);
            obj.lua_script:setStatus(2);
            if (HelpSystemModel.selected ~= idx + 1) then
                HelpSystemModel.selected = idx + 1;
                self:upStrongerItem(); 
            end
        end, 22)
    end)

    -- 我要变强
    self.list_strong = self.view:getChild("list_strong");
    self.list_strong:setVirtual();
    self.list_strong:setItemRenderer(function (idx, obj)
        if (not obj.lua_script) then
            obj.lua_script = StrongItem.new(obj, 0);
        end
        self.list_strongItems[idx + 1] = obj.lua_script;
        obj.lua_script:setIndex(idx + 1);
    end)

    HelpSystemModel:getHeroInfo(function ()
        self:initMyTeam();
        self:upStrongerItem();
    end);
end

function HelpSysStrongView:initMyTeam()
	if tolua.isnull(self.view) then return end
    local heroes = HelpSystemModel:getAllInBattle();
    self.list_myTeam:setNumItems(#heroes);
    -- LuaLogE("++++++++++++++++++++++", #heroes, #self.list_myTeamItems);
    for idx in ipairs(heroes) do
        local itemScript = self.list_myTeamItems[idx];
        local ctrl = itemScript.view:getController("c1");
        if (idx == HelpSystemModel.selected) then
            ctrl:setSelectedIndex(2);
        else
            ctrl:setSelectedIndex(0);
        end
        itemScript:setData(heroes[idx], true);
    end
end

-- 更新我要变强
function HelpSysStrongView: upStrongerItem()
    local ctrl = self.view:getController("c1");
    if (self.list_myTeam:getNumItems() == 0) then
        -- self.list_strong:setNumItems(0);
        ctrl:setSelectedIndex(0);
    else
        self.list_strong:setNumItems(#DynamicConfigData.t_Stronger);
        ctrl:setSelectedIndex(1);
    end
end

return HelpSysStrongView