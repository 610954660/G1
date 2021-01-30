--Date :2020-12-09
--Author : wyz
--Desc : 排行奖励

local CrossTeamPVPRewardView,Super = class("CrossTeamPVPRewardView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
local category = GameDef.TaskCategory.WorldTeamArena
local gamePlayType = GameDef.GamePlayType.TaskWorldTeamArena
local TaskConfiger = require "Game.ConfigReaders.TaskConfiger"


function CrossTeamPVPRewardView:ctor()
	--LuaLog("CrossTeamPVPRewardView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamPVPRewardView"
	self._rootDepth = LayerDepth.PopWindow
	self.taskData = false
end

function CrossTeamPVPRewardView:_initEvent( )
	
end

function CrossTeamPVPRewardView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPRewardView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list_reward = viewNode:getChildAutoType('list_reward')--GList
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamPVPRewardView
	--Do not modify above code-------------
end

function CrossTeamPVPRewardView:_initUI( )
	self:_initVM()
	self.taskData = ModelManager.TaskModel:getAllShowTask(category)
	local isInit = false
	for k,v in pairs(self.taskData) do
		v.sort = 2 -- 不可领取 
		local status = ModelManager.TaskModel:getRewardStatus(category,v.recordId,v.seq)
		if status == 2 then
			v.sort = 3 -- 已领取
		elseif status == 1 then -- 可领取
			v.sort = 1
		elseif status == 0 then -- 不可领取
			v.sort = 2
		end
	end
	local keys = {
		{key="sort",asc=false},
		{key="id",asc=false},
	}
	TableUtil.sortByMap(self.taskData,keys)

	self.list_reward:setItemRenderer(function(idx,obj)
		local index 		= idx + 1
		local data 		= self.taskData[index]
		local txt_title 	= obj:getChildAutoType("txt_title")
		local list_reward 	= obj:getChildAutoType("list_reward")
		local btn_take 		= obj:getChildAutoType("btn_take")
		local checkReward 	= obj:getController("checkReward") -- 0 不可领取 1 可领取 2 已领取
		local txt_times 	= obj:getChildAutoType("txt_times")

		local acc = ModelManager.TaskModel:getACCValue(category,data.recordId,data.seq)
		local curMax = data.count

		txt_title:setText(data.name)
		txt_times:setText(string.format("(%s/%s)",acc,curMax))

		local status = ModelManager.TaskModel:getRewardStatus(category,data.recordId,data.seq)
		checkReward:setSelectedIndex(status)

		local reward = data.reward
		list_reward:setItemRenderer(function(idx2,obj2)
			local rewardInfo = reward[idx2+1]
			local itemCell = BindManager.bindItemCell(obj2)
			itemCell:setData(rewardInfo.code,rewardInfo.amount,rewardInfo.type)
		end)
		list_reward:setData(reward)

		-- if status == 0 then 	--未完成
		-- elseif status == 1 then	--已完成未领取
		-- elseif status == 2 then --已领取
		-- end
		local img_red = btn_take:getChildAutoType("img_red")
		img_red:setVisible(status == 1 and true or false)
		btn_take:removeClickListener(11)
		btn_take:addClickListener(function( ... )
			if status ~= 1 then
				RollTips.show(Desc.CrossTeamPVP_notReached)
				return
			end
			print(8848,"领取奖励",data.id)
			local params = {}
			 params.id = data.id
			 params.category = category
			 params.onSuccess = function (res )
				if tolua.isnull(obj) then return end
				self:dailyTask_update()
			 end
			 RPCReq.Task_GetReward(params, params.onSuccess)
		end,11)
	end)
	self.list_reward:setData(self.taskData)

end

function CrossTeamPVPRewardView:task_update( _,gamePlayType, recordId, seq )
	self.taskData = ModelManager.TaskModel:getAllShowTask(category)
	self.list_reward:setData(self.taskData)
end

--任务列表刷新
function CrossTeamPVPRewardView:dailyTask_update( ... )
	self:task_update()
end




return CrossTeamPVPRewardView