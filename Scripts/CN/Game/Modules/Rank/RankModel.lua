local BaseModel = require "Game.FMVC.Core.BaseModel"
local RankModel = class("PlayerModel", BaseModel)

function RankModel:ctor()
	print(33,"RankModel ctor")
	self.taskRankRewead = {} --���н���
	self.taskRankReweadStatus  = {} --���н�������״̬
	self.taskRankRewardInited = false --�Ƿ��ʼ����������
end

function RankModel:init()
	
end

function RankModel:initTaskRewardRed()
	if self.taskRankRewardInited then return end
	
	local redMap = {}
	for _,v in pairs(DynamicConfigData.t_TaskRankReward) do
		table.insert(redMap, "V_TASK_REWARD_"..v[1].rankType)
	end
	RedManager.addMap("M_TASK_REWARD", redMap)
	self.taskRankRewardInited = true
end

function RankModel:updateTaskRankReweadStatus(rankType, status)
	self.taskRankReweadStatus[rankType] = status
	RedManager.updateValue("V_TASK_REWARD_"..rankType, status)
end

return RankModel
