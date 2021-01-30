local TimingPushView,Super = class("TimingPushView", Window)

function TimingPushView:ctor()
	self._packName = "TimingPush"
	self._compName = "TimingPushView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
end

function TimingPushView:_initEvent()
	
end

function TimingPushView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:TimingPush.TimingPushView
	self.awardList = viewNode:getChildAutoType('$awardList')--GList
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.btn_send = viewNode:getChildAutoType('btn_send')--GButton
	self.spine = viewNode:getChildAutoType('spine')--GLoader
	--{autoFieldsEnd}:TimingPush.TimingPushView
	--Do not modify above code-------------
end

function TimingPushView:_initUI()
	self:_initVM()
	self.blackbg:addClickListener(function()
		self:closeView()
		Dispatcher.dispatchEvent("update_Timing_reward")
	end)
	self.btn_send:addClickListener(function()
		if TimingPushModel:getState() == 1 then
			RPCReq.GamePlay_Modules_TimePush_GetReward({},function(data)
				self:closeView()
				TimingPushModel:setState(2)
				Dispatcher.dispatchEvent("update_Timing_reward")
			end)
		else
			TimingPushModel:setState(0)
			Dispatcher.dispatchEvent("update_Timing_reward")
			RollTips.show(Desc.TimingPushDesc1)
			self:closeView()
		end
	end)
	self.awardList:setItemRenderer(function (index, obj)
		local itemcell = BindManager.bindItemCell(obj)
		local itemData = ItemsUtil.createItemData({data = self.awardList._dataTemplate[index  + 1]})
		itemcell:setItemData(itemData)
	end)
	local config = DynamicConfigData.t_TimedReward[1]
	self.awardList:setData(config.reward)
	self:_refreshView()
end


function TimingPushView:_refreshView()
	local spineNode = SpineMnange.createByPath("Spine/ui/timingPush","guanaijumao","guanaijumao")
	spineNode:setAnimation(0,"animation",true)
	self.spine:displayObject():addChild(spineNode)
end

function TimingPushView:onExit_()

end

return TimingPushView