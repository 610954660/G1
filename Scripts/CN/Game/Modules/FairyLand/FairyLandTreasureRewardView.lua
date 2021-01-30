-- added by wyz
-- 秘境奖励界面

local FairyLandTreasureRewardView = class("FairyLandTreasureRewardView",Window)

function FairyLandTreasureRewardView:ctor()
	self._packName = "FairyLand"
	self._compName = "FairyLandTreasureRewardView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.list_reward = false
	self.txt_dec 	 = false
	self.progress 	 = false
	self.btn_take 	 = false
	self.data 		 = {}
end


function FairyLandTreasureRewardView:_initUI()
	self.list_reward 	= self.view:getChildAutoType("list_reward")
	self.txt_dec 		= self.view:getChildAutoType("txt_dec")
	self.progress 		= self.view:getChildAutoType("progress")
	self.btn_take 		= self.view:getChildAutoType("btn_take")
	self.data = self._args
end


function FairyLandTreasureRewardView:_initEvent()
	self:refreshPanal()
end 	

function FairyLandTreasureRewardView:refreshPanal()
	-- printTable(8848,"data>>>>>>>>>>",self.data)
	local data = self.data.data
	local sieveTimes = self.data.sieveTimes
	if not data then return end
	self.txt_dec:setText(string.format(Desc.fairyLand_rewardDec,data.timeslimit))
	self.progress:setMax(data.timeslimit)
	self.progress:setValue(sieveTimes)

	local ctrl = self.view:getController("c1")
	ctrl:setSelectedIndex(sieveTimes >= data.timeslimit and 1 or 0)

	if ModelManager.FairyLandModel.isGetSieveReward  or FileCacheManager.getBoolForKey("FairyLand_reward",false) then
		ctrl:setSelectedIndex(2)
	end
	local rewardData = data.show
	self.list_reward:setItemRenderer(function(idx,obj)
		local reward = rewardData[idx+1]
		local itemCell = BindManager.bindItemCell(obj)
		itemCell:setData(reward.code,reward.amount,reward.type)
	end)
	self.list_reward:setData(rewardData)

	self.btn_take:removeClickListener(22)
	self.btn_take:addClickListener(function()
		RPCReq.FairyLand_GetTimesReward({},function(param)
			ctrl:setSelectedIndex(2)
			FileCacheManager.setIntForKey("FairyLand_floor",ModelManager.FairyLandModel.floorFlag)
			FileCacheManager.setBoolForKey("FairyLand_reward",true)
		end)
	end,22)
end

function FairyLandTreasureRewardView:_exit()
	ViewManager.close("FairyLandTreasureRewardView")
end

return FairyLandTreasureRewardView