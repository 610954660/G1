-- added by xhd
-- 神社祈福 本层奖励

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local ActCurRewardView = class("ActCurRewardView",Window)
local lastInterTime = 0.02
local maxInterTime = 0.5
function ActCurRewardView:ctor()
	self._packName 	= "ActShrineBless"
	self._compName 	= "ActCurRewardView"

	self.showRewards1 = false
	self.showRewards2 = false
	self._rootDepth  = LayerDepth.PopWindow
	self.scheduler = {}
	self.scheduler2 = {}
end


function ActCurRewardView:_initUI()
	self.awardList1 = self.view:getChildAutoType("awardList1")
	self.awardList2 = self.view:getChildAutoType("awardList2")

	self.awardList1:setVirtual()
	self.awardList1:setItemRenderer(function(idx,obj)
		local reward 	=self.showRewards2[idx+1].reward[1]
		local itemCellObj 	= BindManager.bindItemCell(obj)
		itemCellObj:setData(reward.code, reward.amount, reward.type)
		local interTime = maxInterTime/#self.showRewards2
		if interTime >= lastInterTime then
			interTime = lastInterTime
		end
		-- obj:setVisible(false)
		-- self.scheduler[idx+1] = Scheduler.scheduleOnce((idx+1)*interTime, function( ... )
		-- 	if obj and  (not tolua.isnull(obj)) then
		-- 		obj:setVisible(true)
		-- 		obj:getTransition("t0"):play(function( ... )
		-- 		end);
		-- 	end
		-- end)
	end)

	self.awardList2:setVirtual()
	self.awardList2:setItemRenderer(function(idx,obj)
		local spineParent = obj:getChildAutoType("spineParent")
		spineParent:displayObject():removeAllChildren()
		local reward 	= self.showRewards1[idx+1].reward[1]
		local itemCellObj 	= BindManager.bindItemCell(obj)
		itemCellObj:setData(reward.code, reward.amount, reward.type)
		if self.showRewards1[idx+1].id >=100000 then --如果是许愿的大奖
			obj.spineNode = SpineUtil.createSpineObj(spineParent, vertex2(0,0), "pingzhikuang_hong", "Spine/ui/item", "daojupinzhikuang", "daojupinzhikuang",true)
			obj.spineNode:setScale(0.72)
		end
		local interTime = maxInterTime/#self.showRewards1
		if interTime >= lastInterTime then
			interTime = lastInterTime
		end
		-- obj:setVisible(false)
		-- self.scheduler2[idx+1] = Scheduler.scheduleOnce((idx+1)*interTime, function( ... )
		-- 	if obj and  (not tolua.isnull(obj)) then
		-- 		obj:setVisible(true)
		-- 		obj:getTransition("t0"):play(function( ... )
		-- 		end);
		-- 	end
		-- end)
	end)

end

function ActCurRewardView:_initEvent( ... )
	self:initPanel()
end

function ActCurRewardView:initPanel( ... )
	local data = ActShrineBlessModel:getData(  )
	local bigConfig = false
	if data.wish ==0 and data.has then --已经抽中
		for k,v in pairs(data.reward) do
			if tonumber(v.id)>100000 then
				bigConfig = ActShrineBlessModel:getConfigChooseById(v.id)
				break
			end
		end
	end
    self.showRewards1,self.showRewards2 = ActShrineBlessModel:getRewardConfig(  ) --已抽  剩余
	self.awardList1:setData(self.showRewards2)
	if bigConfig then
		table.insert(self.showRewards1,1,bigConfig)
	end
	self.awardList2:setData(self.showRewards1)
	
end



function ActCurRewardView:updatePanel()
	
end



function ActCurRewardView:_exit()

end



return ActCurRewardView