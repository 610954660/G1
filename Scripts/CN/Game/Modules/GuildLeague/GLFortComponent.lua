-- add by zn
-- 据点组件

local GLFortComponent = class("GLFortComponent", View)

function GLFortComponent:ctor()
    self._packName = "GuildLeague";
    self._compName = "com_fort";
    self._isFullScreen = false;
    -- self.effect = false;
end

function GLFortComponent:_initUI()
    local root = self
    local rootView = self.view
        root.heroCell = BindManager.bindPlayerCell(rootView:getChildAutoType("heroCell"));
        root.txt_combat = rootView:getChildAutoType("txt_combat");
        root.txt_name = rootView:getChildAutoType("txt_name");
        root.com_star = rootView:getChildAutoType("com_star");
        root.txt_index = rootView:getChildAutoType("txt_index");

        local effect = rootView:getChildAutoType("effect");
        local pos = cc.p(effect:getWidth() / 2, effect:getHeight() / 2);
        SpineUtil.createSpineObj(effect, pos, "animation", "Spine/ui/GuildLeague", "efx_feixu", "efx_feixu", true)
end

function GLFortComponent:setData(data, idx)
    local isSelfGuild = GuildLeagueModel:getBaseInfo().guildId == data.guildId
    local guildInfo = isSelfGuild and GuildLeagueModel.selfGuildInfo or GuildLeagueModel.enemyGuildInfo;
    local serverId = guildInfo.serverId;
    -- local serverInfo = LoginModel:getServerInfoByServerId(serverId) or {};
    self.txt_combat:setText(data.combat);
    local name = serverId and string.format("[S.%s] %s", serverId, data.name) or data.name
    self.txt_name:setText(name);
    self.txt_index:setText(idx);
    self.heroCell:setHead(data.head, data.level);
    local c1 = self.view:getController("c1");
    c1:setSelectedIndex(isSelfGuild and 0 or 1);
    local c2 = self.view:getController("c2");
    c2:setSelectedIndex(data.health == 0 and 1 or 0);
    local starC1 = self.com_star:getController("c1");
    starC1:setSelectedIndex(3 - data.health);
    
    self.view:removeClickListener();
    self.view:addClickListener(function()
        ViewManager.open("GuildLeagueEnemyView", {data = data, idx = idx});
    end)
end

return GLFortComponent