-- added by wyz
-- 无尽试炼 首通奖励

local EndlessFirstRewardView = class("EndlessFirstRewardView",Window)

function EndlessFirstRewardView:ctor()
	self._packName = "EndlessTrial"
	self._compName = "EndlessFirstRewardView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.list_firstPass = false
	self.txt_hightPass 	= false 	-- 当前最高通关数

end

function EndlessFirstRewardView:_initUI()
	self.list_firstPass 	= self.view:getChildAutoType("list_firstPass")
	self.txt_hightPass 		= self.view:getChildAutoType("txt_hightPass")
end

function EndlessFirstRewardView:_initEvent()
	self:refrshPanel()
end


function EndlessFirstRewardView:refrshPanel()
	local trialType  		= self._args.type
	local rewardData 		= {}
	local trialData 		= {}
	rewardData 				= EndlessTrialModel:getTrialFirstRewardDataByType(trialType)
	trialData  				= EndlessTrialModel:getTrialDataByType(trialType)
	local firstRewardNum 	= EndlessTrialModel:getFirstRewardNum()

	self.txt_hightPass:setText(string.format(Desc.EndlessTrial_curFirstPassNum,trialData.maxLevel))
	self.list_firstPass:setVirtual()
	self.list_firstPass:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local firstData 	= rewardData[index]
		local stateCtrl 	= obj:getController("stateCtrl")
		local btn_take 		= obj:getChildAutoType("btn_take")
		local txt_passDec 	= obj:getChildAutoType("txt_passDec")

		-- 进度条
		local progressBar 	= obj:getChildAutoType("progressBar")
		local proVal 		= progressBar:getChildAutoType("val")
		local proLine 		= progressBar:getChildAutoType("n9")
		local proCount 		= progressBar:getChildAutoType("count")
		local proText 		= progressBar:getChildAutoType("n10")
		proText:setPosition(101,-25)
		progressBar:setMax(firstData.level)
		progressBar:setValue(trialData.maxLevel)
		proVal:setText(trialData.maxLevel)
		proCount:setText(firstData.level)

		-- 通关数
		txt_passDec:setText(firstData.level)
		
		-- 奖励列表
		local list_reward 	= obj:getChildAutoType("list_reward")
		local firstReward 	= firstData.firstReward
		list_reward:setItemRenderer(function(idx2,obj2)
			local data 	= firstReward[idx2+1]
			local itemCell = BindManager.bindItemCell(obj2)
			itemCell:setData(data.code,data.amount,data.type)
		end)
		list_reward:setData(firstReward)

		-- 按钮显示 
		if firstData.take > 0 then 	-- 存在 则已领取
			stateCtrl:setSelectedIndex(2)
		elseif firstData.finish>0 then 	-- 可领取
			stateCtrl:setSelectedIndex(1)
		else
			stateCtrl:setSelectedIndex(0)
		end

		-- 领取按钮
		btn_take:removeClickListener(555)
		btn_take:addClickListener(function()
			local num = firstData.level
			local idList = {num}
			local reqInfo = {
				type = trialType,
				idList = idList,
			}
			RPCReq.TopChallenge_GetFirstReward(reqInfo,function(param)
				self:refrshPanel()
			end)
		end,555)
	end)
	self.list_firstPass:setNumItems(firstRewardNum)
end



return EndlessFirstRewardView
