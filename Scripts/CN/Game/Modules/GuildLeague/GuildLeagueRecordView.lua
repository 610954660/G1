-- add by zn
-- 赛季统计

local GuildLeagueRecordView = class("GuildLeagueRecordView", MutiWindow)

function GuildLeagueRecordView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GuildLeagueRecordView"
    self._rootDepth = LayerDepth.PopWindow
end

function GuildLeagueRecordView:_initUI()
    local root = self
    local rootView = self.view

end

function GuildLeagueRecordView:_initEvent()

end

return GuildLeagueRecordView