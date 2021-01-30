--added by wyang
--排行榜控制器
local RankController = class("RankController",Controller)


function RankController:TaskRankReward_NoticeCanRecvIds(_,data)
	ModelManager.RankModel:updateTaskRankReweadStatus(data.rankType,true)
end


function RankController:TaskRankReward_CanRecvRankTypeList(_,data)
	ModelManager.RankModel:initTaskRewardRed()
	for _,v in pairs(data.rankTypeList) do
		ModelManager.RankModel:updateTaskRankReweadStatus(v,true)
	end
end

return RankController