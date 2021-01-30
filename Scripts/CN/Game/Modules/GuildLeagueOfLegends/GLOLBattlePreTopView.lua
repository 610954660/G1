--Date :2021-01-05
--Author : generated by FairyGUI
--Desc : 

local GLOLBattlePreTopView,Super = class("GLOLBattlePreTopView", Window)

function GLOLBattlePreTopView:ctor()
	--LuaLog("GLOLBattlePreTopView ctor")
	self._packName = "GuildLeagueOfLegends"
	self._compName = "GLOLBattlePreTopView"
	self._rootDepth = LayerDepth.WindowUI
	
end

function GLOLBattlePreTopView:_initEvent( )
	
end

function GLOLBattlePreTopView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:GuildLeagueOfLegends.GLOLBattlePreTopView
	self.c1 = viewNode:getController('c1')--Controller
	self.c2 = viewNode:getController('c2')--Controller
	self.list_team = viewNode:getChildAutoType('list_team')--GList
	--{autoFieldsEnd}:GuildLeagueOfLegends.GLOLBattlePreTopView
	--Do not modify above code-------------
end

function GLOLBattlePreTopView:_initListener( )
	
	self.list_team:addClickListener(function (idx)
		local select = self.list_team:getSelectedIndex() + 1
        if (select ~= GuildLeagueOfLegendsModel.curTeamIdx) then
            -- HigherPvPModel: saveTeamInfo()
            GuildLeagueOfLegendsModel.curTeamIdx = select;
			local teamArr = GuildLeagueOfLegendsModel:getBattleTeamType()
            Dispatcher.dispatchEvent("battle_GuildLegendsChangeTeamType", teamArr[GuildLeagueOfLegendsModel.curTeamIdx]);
        end
    end)

end

function GLOLBattlePreTopView:_initUI( )
	self:_initVM()
	self:_initListener()
	GuildLeagueOfLegendsModel.curTeamIdx = 1;

	local children = self.list_team:getChildren();
    for idx, obj in ipairs(children) do
        RedManager.register("GLOL_teamEmpty"..idx, obj:getChildAutoType("img_red"));
    end
end

function GLOLBattlePreTopView:battle_canCel()
    -- HigherPvPModel: clearTeamInfo()
    ViewManager.close("AddHPvPPrebattleView")
end

function GLOLBattlePreTopView:battle_begin()
    -- if HigherPvPModel:battleCheckTeam(false) then
    --     return;
    -- end
    -- HigherPvPModel: clearTeamInfo()
    ViewManager.close("AddHPvPPrebattleView")
end

return GLOLBattlePreTopView