--Date :2020-12-27
--Author : added by xhd
--Desc : 挑战奖励界面

local StrideRewardView,Super = class("StrideRewardView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function StrideRewardView:ctor()
	--LuaLog("StrideRewardView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideRewardView"
	self._rootDepth = LayerDepth.PopWindow
end

function StrideRewardView:_initEvent( )
	
end

function StrideRewardView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideRewardView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list = viewNode:getChildAutoType('list')--GList
	--{autoFieldsEnd}:StrideServer.StrideRewardView
	--Do not modify above code-------------
end

function StrideRewardView:_initUI( )
	self:_initVM()
	self.list:setItemRenderer(function(index, obj)
		local config = DynamicConfigData.t_TopArenaRankReward[index + 1]
		local awardList = obj:getChild("rewardList")
		awardList:setItemRenderer(function(index1, obj)
			local itemcell = BindManager.bindItemCell(obj)
			local itemData = ItemsUtil.createItemData({data = DynamicConfigData.t_TopArenaRankReward[index + 1].seasonRewardPre[index1 + 1]})
			itemcell:setItemData(itemData)
		end)
		awardList:setData(config.seasonRewardPre)
		local str =  config.clientShow
		str =  string.gsub(str, '"', "")
		obj:getChild("index"):setText(str)
		
		if index <= 2 then
			obj:getController("index"):setSelectedIndex(index)
		else
			obj:getController("index"):setSelectedIndex(3)
		end
	end)
	self.list:setData( DynamicConfigData.t_TopArenaRankReward)
end




return StrideRewardView