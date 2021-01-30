local CrossPVPRewardView,Super = class("CrossPVPRewardView", Window)

function CrossPVPRewardView:ctor()
	self._packName = "CrossPVP"
	self._compName = "CrossPVPRewardView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
end

function CrossPVPRewardView:_initEvent()
	
end

function CrossPVPRewardView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossPVPRewardView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list = viewNode:getChildAutoType('list')--GList
	--{autoFieldsEnd}:CrossPVP.CrossPVPRewardView
	--Do not modify above code-------------
end

function CrossPVPRewardView:_initUI()
	self:_initVM()
	self.t_HorizonpvpLevel = DynamicConfigData.t_HorizonpvpLevel
	self.list:setItemRenderer(function(index, obj)
		local config = self.t_HorizonpvpLevel[index + 1]
		local awardList = obj:getChild("rewardList")
		awardList:setItemRenderer(function(index1, obj)
			local itemcell = BindManager.bindItemCell(obj)
			local itemData = ItemsUtil.createItemData({data = self.t_HorizonpvpLevel[index + 1].reward[index1 + 1]})
			itemcell:setItemData(itemData)
		end)
		awardList:setData(config.reward)
		obj:getChild("index"):setText(config.name)
		local mark = index == 0 and config.min.."+" or config.min.. "-"..config.max
		obj:getChild("mark"):setText(mark)
		obj:getController("index"):setSelectedIndex(3)
		if index <= 2 then
			obj:getController("index"):setSelectedIndex(index)
		end
	end)
	self.list:setData(self.t_HorizonpvpLevel)
	self:_refreshView()
end


function CrossPVPRewardView:_refreshView()

end

function CrossPVPRewardView:onExit_()

end

return CrossPVPRewardView