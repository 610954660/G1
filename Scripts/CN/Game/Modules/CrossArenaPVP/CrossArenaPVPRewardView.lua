local CrossArenaPVPRewardView,Super = class("CrossArenaPVPRewardView", Window)

function CrossArenaPVPRewardView:ctor()
	self._packName = "CrossArenaPVP"
	self._compName = "CrossArenaPVPRewardView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
end

function CrossArenaPVPRewardView:_initEvent()
	
end

function CrossArenaPVPRewardView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossArenaPVP.CrossArenaPVPRewardView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list = viewNode:getChildAutoType('list')--GList
	--{autoFieldsEnd}:CrossArenaPVP.CrossArenaPVPRewardView
	--Do not modify above code-------------
end

function CrossArenaPVPRewardView:_initUI()
	self:_initVM()
	
	
	self.t_CrossArenaRankReward = DynamicConfigData.t_CrossArenaRankReward
	self.list:setItemRenderer(function(index, obj)
		local config = self.t_CrossArenaRankReward[index + 1]
		local awardList = obj:getChild("rewardList")
		awardList:setItemRenderer(function(index1, obj)
			local itemcell = BindManager.bindItemCell(obj)
			local itemData = ItemsUtil.createItemData({data = self.t_CrossArenaRankReward[index + 1].seasonRewardPre[index1 + 1]})
			itemcell:setItemData(itemData)
		end)
		awardList:setData(config.seasonRewardPre)
		obj:getChild("index"):setText(config.clientShow)
		obj:getController("index"):setSelectedIndex(3)
		if index <= 2 then
			obj:getController("index"):setSelectedIndex(index)
		end
	end)
	self.list:setData(self.t_CrossArenaRankReward)
	
	self:_refreshView()
end


function CrossArenaPVPRewardView:_refreshView()

end

function CrossArenaPVPRewardView:onExit_()

end

return CrossArenaPVPRewardView