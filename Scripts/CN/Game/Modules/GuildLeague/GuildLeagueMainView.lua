-- add by zn
-- 公会联赛主界面

local GuildLeagueMainView = class("GuildLeagueMainView", MutiWindow)

function GuildLeagueMainView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GuildLeagueMainView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.redArr = {
        "",
        "V_GLOL_enter",
    }
end

function GuildLeagueMainView:onShowPage(pageName)
    -- body
    if (pageName == "GLNormalMainView") then
        self:setBg("GuildLeague.jpg");
        self.btn_help:removeClickListener();
        self.btn_help:addClickListener(function()
            local info={}
            info['title']=Desc["help_StrTitle"..ModuleId.GuildLeague.id]
            info['desc']=Desc["help_StrDesc"..ModuleId.GuildLeague.id]
            ViewManager.open("GetPublicHelpView",info) 
        end)
    else

    end
end

return GuildLeagueMainView