-- add by zn
-- 奖励

local GuildLeagueAwardView = class("GuildLeagueAwardView", MutiWindow)

function GuildLeagueAwardView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GuildLeagueAwardView"
    self._tabBarName = "list_page"
    self._rootDepth = LayerDepth.PopWindow
end

function GuildLeagueAwardView:_initUI()
    local root = self
    local rootView = self.view

end

function GuildLeagueAwardView:onShowPage(pageName)
    local view = self.ctlView[pageName];
    if (view and view.onShow) then
        view:onShow(self._preIndex)
    end
end

return GuildLeagueAwardView