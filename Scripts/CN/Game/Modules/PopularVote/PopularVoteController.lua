--Date :2021-01-13
--Author : generated by FairyGUI
--Desc : 

local PopularVoteController = class("PopularVote",Controller)

function PopularVoteController:init()
	
end

function PopularVoteController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.HeroVote then
		return 	
	end
	printTable(6,"探员投票Activity_UpdateData",params)
	ModelManager.PopularVoteModel:setPopularVoteData(params.heroVote or {})
end

return PopularVoteController