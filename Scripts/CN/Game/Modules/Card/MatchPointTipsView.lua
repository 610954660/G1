---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local FGUIUtil = require "Game.Utils.FGUIUtil"
local MatchPointTipsView, Super = class("MatchPointTipsView", Window)

function MatchPointTipsView:ctor(args)
    self._packName = "CardSystem"
    self._compName = "MatchPointTipsView"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = true
	self.heroInfo = args or false
    
end

function MatchPointTipsView:_initUI()
	local pointiInfo = DynamicConfigData.t_heroAttrPoint
	local addList = self.view:getChild("list_add")
	addList:setItemRenderer(
		function(index, obj)
			obj:removeClickListener()
			--池子里面原来的事件注销掉
			local value = pointiInfo[self.heroInfo.heroDataConfiger.pointId][index + 1]
			local attrName = ModelManager.CardLibModel.cardAttrName[value.attrId]
			local add = value.attrValue
			printTable(5, "配点>>>", attrName, add)
			local attrN = obj:getChild("txt_attrName")
			local attNum = obj:getChild("txt_cur")
			attrN:setText(string.format("%s   ", attrName))
			attNum:setText(string.format("%s", add))
		end
	)
	addList:setNumItems(#pointiInfo[self.heroInfo.heroDataConfiger.pointId])
end

--绑定事件
function MatchPointTipsView:bindEvent()

end

function MatchPointTipsView:_exit()

end

function MatchPointTipsView:_enter()
end

return MatchPointTipsView
