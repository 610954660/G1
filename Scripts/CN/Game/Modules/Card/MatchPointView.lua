---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local FGUIUtil = require "Game.Utils.FGUIUtil"
local MatchPointView, Super = class("MatchPointView", Window)

function MatchPointView:ctor(args)
    self._packName = "CardSystem"
    self._compName = "MatchPointView"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = true
	
    self.heroInfo = args or false
end

function MatchPointView:_initUI()
	local matchPointBoard = self.view:getChild("matchPointBoard")
	local MatchPointBoard=BindManager.bindMatchPointBoard(matchPointBoard)
	if self.heroInfo then
		MatchPointBoard:setData(self.heroInfo)
	end
	self.matPointHelp = self.view:getChildAutoType("btn_matPointHelp")
	self.matPointHelp:addClickListener(
        function(context)
			ViewManager.open("MatchPointTipsView", self.heroInfo)
		end)
	
end

--保存后关闭窗口
function MatchPointView:cardView_configurationPoint()
	--self:closeView()
end

function MatchPointView:_exit()

end

function MatchPointView:_enter()
end

return MatchPointView
