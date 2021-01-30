
local EndlessRewardTipsView = class("EndlessRewardTipsView", Window)
function EndlessRewardTipsView:ctor()
	self._packName = "EndlessTrial"
	self._compName = "EndlessRewardTipsView"
	self._rootDepth = LayerDepth.PopWindow

	self.btn_ok 	= false
	self.txt_dec 	= false	
end

function EndlessRewardTipsView:_initUI( )
	self.btn_ok 	= self.view:getChildAutoType("btn_ok")
	self.txt_dec 	= self.view:getChildAutoType("txt_dec")
end


function EndlessRewardTipsView:_initEvent( )
	self:EndlessTrial_refreshRewardTipsView()
end

function EndlessRewardTipsView:EndlessTrial_refreshRewardTipsView()
	local trialType 	  = EndlessTrialModel:getTrialType()
	local firstRewardData = EndlessTrialModel:getTrialFirstRewardDataByType(trialType,true)
	local data 			  = firstRewardData[1].firstReward[1]
	local itemCell 		  = BindManager.bindItemCell(self.view:getChildAutoType("itemCell"))
	itemCell:setData(data.code, data.amount, data.type)

	local txt_dec 		 = self.view:getChildAutoType("txt_dec")
	txt_dec:setText(string.format(Desc.EndlessTrial_rewardTips,firstRewardData[1].level))

	self.btn_ok:removeClickListener(22)
	self.btn_ok:addClickListener(function()
		local level = firstRewardData[1].level
		local idList = {level}
		local reqInfo = {
			type = trialType,
			idList = idList,
		}
		RPCReq.TopChallenge_GetFirstReward(reqInfo,function(param)
			Dispatcher.dispatchEvent(EventType.EndlessTrial_refreshAddTopChallengeView)
			-- if toLua.isnull(self.view) then return end
			self:EndlessTrial_refreshRewardTipsView()
			if firstRewardData[1].finish>0 and firstRewardData[1].take < 1 then
			else
				ViewManager.close("EndlessRewardTipsView")
			end
		end)

	end,22)

	if firstRewardData[1].states == 3 then
		self.btn_ok:setTouchable(true)
		self.btn_ok:getController("button"):setSelectedIndex(0)
	else
		self.btn_ok:setTouchable(false)
		self.btn_ok:getController("button"):setSelectedIndex(2)
	end
end

function EndlessRewardTipsView:EndlessTrial_endRewardTipsView()
	ViewManager.close("EndlessRewardTipsView")
end



return EndlessRewardTipsView