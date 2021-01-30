--added by xhd
--任务成就系统model层
local BaseModel = require "Game.FMVC.Core.BaseModel"
local EventBrocastModel = class("EventBrocastModel", BaseModel)
function EventBrocastModel:ctor()
	self.myRecordInfo = false
	self.newsData = false
end

function EventBrocastModel:init( ... )

end

--获取需要显示的播报消息列表（有些已经过时的就不显示了）
function EventBrocastModel:getShowNewList()
	local showList = {}
	for _,v in pairs(self.newsData) do
		table.insert(showList, v)
	end
	return showList
end

function EventBrocastModel:getInfo()
	local params = {}
	printTable(1,params)
	params.onSuccess = function (res )
		self.myRecordInfo = res.myRecordInfo
		self.newsData = res.newsData or false
		Dispatcher.dispatchEvent(EventType.EventBrocast_updateInfo)
		self:redCheck()
	end
	RPCReq.NewsBoard_GetInfo(params, params.onSuccess)
end


--id 	0:integer #点赞的新闻id
--		index 1:integer #点赞对应的玩家序号
function EventBrocastModel:doAgree(id, index)
	local params = {}
	params.id = id
	params.index = index
	printTable(1,params)
	params.onSuccess = function (res )
		self.myRecordInfo = res.myRecordInfo
		Dispatcher.dispatchEvent(EventType.EventBrocast_updateInfo)
		local config = DynamicConfigData.t_EventContent[id]
		if config then
			RollTips.show("获得"..ItemConfiger.getItemNameByCode(config.reward[1].code).."x"..config.reward[1].amount)
		end
		self:redCheck()
	end
	RPCReq.NewsBoard_DoAgree(params, params.onSuccess)
end


function EventBrocastModel:getReward()
	local params = {}
	printTable(1,params)
	params.onSuccess = function (res )
		self.myRecordInfo = res.myRecordInfo
		Dispatcher.dispatchEvent(EventType.EventBrocast_updateInfo)
		--self.newsData = {}
		ViewManager.close("EventBrocastView")
		self:redCheck()
	end
	RPCReq.NewsBoard_RecvDayReward(params, params.onSuccess)
end

function EventBrocastModel:redCheck()
	local newsList = self:getShowNewList()
	RedManager.updateValue("V_NEW_EVENT", self.newsData and #newsList > 0)
	local hasReward = false
	local canVote = false
	if self.myRecordInfo and not self.myRecordInfo.dayRecvState then
		hasReward = true
	end
	
	--[[if self.newsData then
		for _,v in pairs(self.newsData) do
			for index = 1,3 do
				if v.playerMap[index] and not (self.myRecordInfo.newsMap[v.id] and self.myRecordInfo.newsMap[v.id].playerMap[index]) then
					canVote = true
					break
				end
			end
		end
	end--]]
	
	RedManager.updateValue("V_NEW_EVENT_REWARD", hasReward)
	RedManager.updateValue("V_NEW_EVENT_VOTE", canVote)
end
--model清除
function EventBrocastModel:clear()

end

return EventBrocastModel