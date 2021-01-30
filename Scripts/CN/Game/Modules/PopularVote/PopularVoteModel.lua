--Date :2021-01-13
--Author : generated by FairyGUI
--Desc : 

local PopularVoteModel = class("PopularVote", BaseModel)

function PopularVoteModel:ctor()
	self.votesAll = {}
	self.votesPerson = {}
	self.reward = {}
	self.sale = {}
	self.taskState = {}
	self.rankData = {}
    self.giftInfo = {}
	self.popularHeroId = false
	self.popularHeroNum = 0
	self.loveHeroId = false
	self.loveHeroNum = 0
	self.votesPersonNum = 0
	self.moduleId = 1
	self.isSaleTime = false
    self:initListeners()
end

function PopularVoteModel:init()

end

function PopularVoteModel:setPopularVoteData(data)
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroVote)
	self.moduleId = actData and actData.showContent.moduleId or 1
	self.votesAll = {}
	for heroCode,v in pairs(data.votesAll or {}) do
		self.votesAll[heroCode] = v 
	end
	printTable(6,"全部探员self.votesAll",self.votesAll)
	self.votesPerson = {}
	self.votesPersonNum = 0
	for heroCode,v in pairs(data.votesPerson or {}) do
		self.votesPerson[heroCode] = v 
		self.votesPersonNum = self.votesPersonNum + v.votesNum 
	end
	printTable(6,"个人探员self.votesPerson",self.votesPerson)
	print(6,"个人投票数self.votesPersonNum",self.votesPersonNum)
	self.reward = {}
	for _,v in ipairs(data.reward or {}) do
		self.reward[v] = v 
	end
	printTable(6,"已领取奖励self.reward",self.reward)
	self.sale = {}
	for _,v in pairs(data.sale or {}) do
		self.sale[v.id] = v.times 
	end
	printTable(6,"已购买次数self.reward",self.sale)
	Dispatcher.dispatchEvent(EventType.PopularVote_updateData)
	self:checkPopularVoteRewardRedDot()
	if data.isSaleTime and self.isSaleTime ~= data.isSaleTime then 
		self.isSaleTime = data.isSaleTime 
		Dispatcher.dispatchEvent(EventType.PopularVote_refreshView)
		self:checkPopularVoteItemRedDot()
	end
end

function PopularVoteModel:initShopData(data)
	printTable(6,"探员投票商场数据",data)
    self.giftInfo = data
    self:checkPopularVoteShopRedDot()
    Dispatcher.dispatchEvent(EventType.PopularVoteShop_refreshView)
end

function PopularVoteModel:setRankData(data)
	printTable(6,"setRankData",data)
	for _,v in ipairs(data.rankData) do
		self.votesAll[v.heroCode] = v 
	end
	self.rankData = data.rankData
	printTable(6,"全部探员self.votesAll",self.votesAll)
	self.popularHeroId = self.rankData and self.rankData[1] and self.rankData[1].heroCode or false
	self.popularHeroNum = self.rankData and self.rankData[1] and self.rankData[1].votesNum or 0
	self.loveHeroId =  data.fancyHero or false
	self.loveHeroNum = data.votesNum or 0
	print(6,"心仪探员",self.loveHeroId,self.loveHeroNum)
end

function PopularVoteModel:initTaskData(data)
    self.taskState = data.gashaponTask.records or {}
	printTable(6,"登录探员投票任务数据",self.taskState)
    Dispatcher.dispatchEvent(EventType.PopularVoteTask_updateData)
    self:checkPopularVoteTaskRedDot()
end

function PopularVoteModel:updateStateFinishAndAcc(data)
	printTable(6,"更新探员投票任务数据updateStateFinishAndAcc",data)
    if data then
        if not self.taskState[data.recordId] then
            self.taskState[data.recordId]= {}
        end
        if data.finish then
            self.taskState[data.recordId].finish = data.finish
        end
        if data.acc then
            self.taskState[data.recordId].acc = data.acc
        end
    	Dispatcher.dispatchEvent(EventType.PopularVoteTask_updateData)
   		self:checkPopularVoteTaskRedDot()
    end
end

function PopularVoteModel:updateStateGot(data)
	printTable(6,"更新探员投票任务数据updateStateGot",data)
    if data then
        if not self.taskState[data.recordId] then
            self.taskState[data.recordId]= {}
        end
        if data.got then
            self.taskState[data.recordId].got = data.got
        end
    	Dispatcher.dispatchEvent(EventType.PopularVoteTask_updateData)
   		self:checkPopularVoteTaskRedDot()
    end
end

--获取种族列表数据
function PopularVoteModel:getPopularVoteTabInfo()
	local popularVoteTabInfo = {}
	local temp = {}
	table.insert(popularVoteTabInfo,0) --全部
	for _,v in ipairs(DynamicConfigData.t_HeroVoteTable[self.moduleId]) do
		if v.saleType == 1 then 
			local cardInfo = DynamicConfigData.t_hero[v.heroCode]
			if not temp[cardInfo.category] then
				table.insert(popularVoteTabInfo,cardInfo.category)
				temp[cardInfo.category] = cardInfo.category
			end
		end
	end
	table.sort( popularVoteTabInfo, function (a,b)
		return a < b
	end )
	return popularVoteTabInfo
end

--获取探员列表数据
function PopularVoteModel:getPopularVoteCardInfo(category)
	local popularVoteCardInfo = {}
	for _,v in ipairs(DynamicConfigData.t_HeroVoteTable[self.moduleId]) do
		if v.saleType == 1 then
			local cardInfo = DynamicConfigData.t_hero[v.heroCode]
			if category == cardInfo.category then 
				table.insert(popularVoteCardInfo,v)
			end
		end
	end
	table.sort( popularVoteCardInfo, function (a,b)
		return a.id < b.id
	end )
	return popularVoteCardInfo
end

function PopularVoteModel:getPopularVoteAllCardInfo()
	local allCardInfo = {}
	for _,v in ipairs(DynamicConfigData.t_HeroVoteTable[self.moduleId]) do
		if v.saleType == 1 then
			table.insert(allCardInfo,v)
		end
	end
	table.sort(allCardInfo, function (a,b)
			return a.id < b.id
		end )
	return allCardInfo
end

--获取探员数据
function PopularVoteModel:getHeroVoteTableInfo(heroId,saleType)
	print(6,"获取探员数据",heroId,saleType)
	local info = DynamicConfigData.t_HeroVoteTable[self.moduleId]
	for i,v in pairs(info) do
		if v.heroCode == heroId and v.saleType == saleType then 
			return v
		end
	end
	return false
end

--获取人气最高的探员
function PopularVoteModel:getHeroVotePopularHeroId()
	local num = 0
	local heroId = false
	for _,v in pairs(self.votesAll) do
		if  v.votesNum > self.popularHeroNum then 
			heroId = v.heroCode
			num = v.votesNum
			break
		end
	end
	if not heroId then 
		heroId = self.popularHeroId
		num = self.popularHeroNum
	end
	return heroId, num
end

--获取心仪最高的探员
function PopularVoteModel:getHeroVoteLoveHeroId()
	local num = 0
	local heroId = false
	for _,v in pairs(self.votesPerson) do
		if v.votesNum > self.loveHeroNum then 
			heroId = v.heroCode
			num = v.votesNum
		end
	end
	if not heroId then 
		heroId = self.loveHeroId
		num = self.loveHeroNum
	end
	return heroId, num
end

--获取探员列表数据按人气排行
function PopularVoteModel:getHeroVotePopularHeroData()
	return self.rankData
end

--获取投票道具
function PopularVoteModel:getPopularVoteItem()
	return DynamicConfigData.t_HeroVoteBasic[self.moduleId].costItem[1].code
end

--获取返场天数
function PopularVoteModel:getPopularVoteEncoreTime()
	local encoreTime = DynamicConfigData.t_HeroVoteBasic[self.moduleId].encoreTime[1]
	local startTimer = encoreTime.startTimer
	local endTimer = encoreTime.endTimer
	return endTimer - startTimer + 1
end

--商城
-- 获取礼包数据
function PopularVoteModel:getShopData()
    local giftData = DynamicConfigData.t_HeroVoteShop[self.moduleId]
    for k,v in pairs(giftData) do
        local data = self.giftInfo[v.id]
        v.buyTime = v.limit
        if data then
            data.times = data.times or 0
            v.buyTime = v.buyTime - data.times
            v.buyTime = v.buyTime < 0 and 0 or v.buyTime
        end
        v.state = 0 -- 没卖完
        if v.buyTime == 0 then
            v.state = 1 -- 卖完了
        end
    end
    local keys = {
        {key = "state",asc=false},
        {key = "id",asc=false},
    }
    TableUtil.sortByMap(giftData,keys)
    return giftData or {}
end

--红点
--登录游戏检查红点
function PopularVoteModel:public_enterGame() 
	self:checkPopularVoteItemRedDot()
	self:checkPopularVoteLoginRedDot()
end

--投票券红点
function PopularVoteModel:pack_item_change(_,data)
	local voteItemCode = self:getPopularVoteItem()
	if data[1] and data[1].itemCode and data[1].itemCode==voteItemCode then	
		self:checkPopularVoteItemRedDot()
		Dispatcher.dispatchEvent(EventType.PopularVote_updateItemNum)
	end
end

function PopularVoteModel:checkPopularVoteItemRedDot()
	if not self.isSaleTime then 
		local voteItemCode = self:getPopularVoteItem()
		local haveNum = ModelManager.PackModel:getItemsFromAllPackByCode(voteItemCode) 
		RedManager.updateValue("V_POPULAR_VOTE_ITEM",haveNum > 0)
		print(6,"********************投票券红点",haveNum > 0)
	else
		print(6,"********************投票券红点",false)
		RedManager.updateValue("V_POPULAR_VOTE_ITEM",false)
	end
end

--奖励红点
function PopularVoteModel:checkPopularVoteRewardRedDot()
	local redDot = false
	for _,v in pairs(DynamicConfigData.t_HeroVoteReward[self.moduleId]) do
		if (self.votesPersonNum >= v.times) and not self.reward[v.times] then 
			redDot = true
			break
		end
	end
	print(6,"********************奖励红点",redDot)
	RedManager.updateValue("V_POPULAR_VOTE_REWARD",redDot)
end

--任务红点
function PopularVoteModel:checkPopularVoteTaskRedDot()
	local redDot = false
	for _,v in pairs(self.taskState) do
		if v.finish and not v.got then 
			redDot = true
			break
		end
	end
	print(6,"****************任务红点",redDot)
	RedManager.updateValue("V_POPULAR_VOTE_TASK",redDot)
end

--每日登录红点
function PopularVoteModel:checkPopularVoteLoginRedDot()
	local dayStr = DateUtil.getOppostieDays()
	local isShow = FileCacheManager.getBoolForKey("PopularVoteLoginRedDot" .. dayStr,false)
	print(6,"****************每日登录红点",not isShow)
	RedManager.updateValue("V_POPULAR_VOTE_LOGIN",not isShow)
end

--商城红点
function PopularVoteModel:checkPopularVoteShopRedDot()
    local giftData = self:getShopData()
    local keyArr = {}
    for k,v in pairs(giftData) do
        if v.buyType == 1 and v.price == 0 then
            table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.HeroVoteShop..v.id)
            break
        end
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.HeroVoteShop, keyArr)
    for k,v in pairs(giftData) do
        if  v.buyType == 1 and v.price == 0 then
            RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroVoteShop..v.id , v.buyTime > 0)
            break
        end
    end
end

return PopularVoteModel