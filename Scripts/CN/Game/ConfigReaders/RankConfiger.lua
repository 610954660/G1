--道具配置读取器
--added by wyang
local RankConfiger = {}
local Category = GameDef.Category

local inited = false
local groupData = {}
local typeGroup = {}

local configExceptCamp = {}

local campTypes = {
	GameDef.RankType.FairyCobmat,
	GameDef.RankType.DemonCombat,
	GameDef.RankType.OrcsCombat,
	GameDef.RankType.HumanCombat,
	GameDef.RankType.MachineryCombat
}

function RankConfiger.initData()
	local configData = DynamicConfigData.t_rank
	for _,v in ipairs(configData) do
		local groupId = v.group
		if not groupData[groupId] then
			groupData[groupId] = {}
		end
		if not TableUtil.Exist(campTypes, v.rankType) and v.showInMain ~= 0 then
			table.insert(configExceptCamp, v)
		end
		table.insert(groupData[groupId], v)
		typeGroup[v.rankType] = groupData[groupId]
	end
	inited = true
end

--获取非种族战力榜的其他榜配置
function RankConfiger.getConfigExceptCamp()
	if not inited then
		RankConfiger.initData()
	end
	return configExceptCamp
end

--获取种族战力榜配置
function RankConfiger.getCampConfig()
	if not inited then
		RankConfiger.initData()
	end
	return RankConfiger.getGroupByType(GameDef.RankType.FairyCobmat)
end

function RankConfiger.getGroupByType(rankType)
	if not inited then
		RankConfiger.initData()
	end
	
	return typeGroup[rankType]
end

--获取无尽挑战排行榜奖励
function RankConfiger.getTopChallengeReward(type, rank)
	if rank == 0 then rank = 99999999 end
	local rankData = DynamicConfigData.t_TopChallengeRankReward[type]
	if not rankData then return {} end
	
	
	local rankConfig = {}
	for _,v in pairs(rankData) do
		table.insert(rankConfig, v)
	end
	local len = #rankConfig
	TableUtil.sortByMap(rankConfig, {{key = "rank"}})
	for i = len,1,-1 do 
		local config = rankConfig[i]
		if rank > config.rank then
			local index = i + 1
			if index > len then index = len end
			return rankConfig[index].rewardList, config.rank + 1, rankConfig[index].rank
		elseif rank == config.rank then
			return rankConfig[i].rewardList, (i == 1 and 2 or rankConfig[i - 1].rank + 1) ,rankConfig[i].rank
		end
	end
	
	return {},0,0
end

return RankConfiger
