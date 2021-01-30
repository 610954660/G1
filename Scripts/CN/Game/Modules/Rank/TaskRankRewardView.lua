--added by wyang 排行榜奖励预览窗口

local TaskRankRewardView,Super = class("TaskRankRewardView",Window)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
function TaskRankRewardView:ctor( data )
	self._packName = "Rank"
	self._compName = "TaskRankRewardView"
	self._rootDepth = LayerDepth.PopWindow
	self.preview = false
	self.closeBtn = false	
	self.btn_closeRank = false
	self._openType = data.type
	self._rewardData = false
	self._rewardConfig = DynamicConfigData.t_TaskRankReward[self._openType]
	self._configData = false
	self._needScrollTo = true --只有在打开的时候才需要滚动到指定的项

end

-------------------常用------------------------
--UI初始化
function TaskRankRewardView:_initUI( ... )
	self.list_reward = FGUIUtil.getChild(self.view, "list_reward", "GList")
	
	self.preview = self.view:getChildAutoType("preview")
	self.closeBtn = self.view:getChildAutoType("closeBtn")
	self.btn_closeRank = self.view:getChildAutoType("btn_closeRank")

	
	self.list_reward:setVirtual()
	self.list_reward:setItemRenderer(
			function(index, obj) 
				self:updateRankItem(index, obj)
			end
		)
	
	if self.closeBtn then
		self.closeBtn:addClickListener(function ( ... )
			self:closeView()
		end)
	end
	
	self:updateRewardData()
end

function TaskRankRewardView:updateRewardList()
	local configData = {}
	local firstShowIndex = -1
	for _,v in ipairs(self._rewardConfig) do
		local reward = self._rewardData[v.id]
		local canGet = (reward and reward.canRecv) and 1 or 0
		local hasGet = (reward and not reward.canRecv) and 1 or 0
		if firstShowIndex == -1 and canGet == 1 and hasGet == 0 then
			firstShowIndex = #configData
		elseif not reward and firstShowIndex == -1 and #configData > 0 then
			firstShowIndex = #configData - 1
		end
		table.insert(configData, {config = v, id = v.id, canGet = canGet, hasGet = hasGet })
	end
	TableUtil.sortByMap(configData, {{key = "id", asc = false}})
	self._configData = configData
	if firstShowIndex == -1 then firstShowIndex = #configData - 1 end
	self.list_reward:setNumItems(#self._configData)
	if self._needScrollTo then 
		self.list_reward:scrollToView(firstShowIndex, false)
	end
	self._needScrollTo = false
end

function TaskRankRewardView:updateRewardData()
	local params = {}
	params.rankType = self._openType

	params.onSuccess = function (res )
		self._rewardData = res.data
		if tolua.isnull(self.view) then return end
		self:updateRewardList()	
	end
	RPCReq.TaskRankReward_GetTaskInfo(params, params.onSuccess)
	
end

function TaskRankRewardView:updateRankItem(index, obj)
	local info = self._configData[index + 1].config
	local rewardData = self._rewardData[info.id]
	local txt_con = obj:getChildAutoType("txt_con")
	local txt_playerName = obj:getChildAutoType("txt_playerName")
	local playerCell = obj:getChildAutoType("playerCell")
	local itemCell = obj:getChildAutoType("itemCell")
	local btn_help = obj:getChildAutoType("btn_help")
	local img_red = obj:getChildAutoType("img_red")
	
	playerCell:removeClickListener(100)
	playerCell:addClickListener(
		function(...)
			ViewManager.open("ViewPlayerView",{playerId = rewardData.playerInfo.playerId})
			
		end,100
	)
	
	local itemcellObj = BindManager.bindItemCell(itemCell)
	local reward = info.reward[1]
	itemcellObj:setData(reward.code, reward.amount, reward.type)
	itemCell:getController("hook"):setSelectedIndex(0)
	img_red:setVisible(false)
	
	txt_con:setText(string.format(info.descStr, info.value))
	itemCell:removeClickListener()
	itemCell:addClickListener(function ( ... )
		if not rewardData then
			RollTips.show(Desc.Rank_canNotGet)
		elseif rewardData.canRecv then
				self:getReward(info,rewardData)
			end
		end)

	btn_help:removeClickListener()
	btn_help:addClickListener(function ( ... )
			self:updateRankData(info)
		end)
	
	if rewardData then
		local hasGet = not rewardData.canRecv
		obj:getController("c1"):setSelectedIndex(1)
		local head = BindManager.bindPlayerCell(playerCell)
		local playerInfo =rewardData.playerInfo
		head:setHead(playerInfo.head, playerInfo.level, playerInfo.playerId,playerInfo.name,playerInfo.headBorder)
		head:setShowName(false)
		txt_playerName:setText(playerInfo.name)
		itemCell:getController("hook"):setSelectedIndex(hasGet and 1 or 0)
		img_red:setVisible(not hasGet)
	else
		obj:getController("c1"):setSelectedIndex(0)
	end
end

function TaskRankRewardView:updatePreview(rankData)
	self.preview:setVisible(true)
	self.btn_closeRank:setVisible(true)
	
	self.btn_closeRank:removeClickListener()
	self.btn_closeRank:addClickListener(function ( ... )
			self.btn_closeRank:setVisible(false)
			self.preview:setVisible(false)
		end)
		
	local list_rank = self.preview:getChildAutoType("list_rank")

	list_rank:setItemRenderer(
			function(index, obj) 
				local info = rankData[index + 1]
				--self:updateRankItem(obj,info, (index + 1) == #self._rewardData )
				obj:getController("c1"):setSelectedIndex(index < 3 and (index + 1) or 4)
				local txt_playerName = obj:getChildAutoType("txt_playerName")
				local rankIcon = obj:getChildAutoType("rankIcon")
				local txt_date = obj:getChildAutoType("txt_date")
				local txt_rank = obj:getChildAutoType("txt_rank")
				local playerCell = obj:getChildAutoType("playerCell")
				local head = BindManager.bindPlayerCell(playerCell)
				playerCell:removeClickListener(100)
				playerCell:addClickListener(
					function(...)
						ViewManager.open("ViewPlayerView",{playerId = info.playerId})
						
					end,100
				)
	
				head:setHead(info.head, info.level, info.playerId,info.name,info.headBorder)
				head:setShowName(false)
				txt_rank:setText(index + 1)
				txt_playerName:setText(info.name)
				if index < 3 then
					rankIcon:setURL(string.format("%s%s.png","UI/Rank/Rank_img_",index + 1))
				end
				txt_date:setText(StringUtil.formatTime(math.floor(info.finishMs/1000), "y", "%Y-%m-%d"))
			end
		)		
	if rankData then
		local num = #rankData >= 5 and 5 or #rankData
		list_rank:setNumItems(num)
	else
		list_rank:setNumItems(0)
	end

end


function TaskRankRewardView:updateRankData(info)
	local params = {}
	params.rankType = info.rankType
	params.id = info.id
	params.onSuccess = function (res )
		self:updatePreview(res.data)
	end
	RPCReq.TaskRankReward_GetTaskPlayerInfo(params, params.onSuccess)
	
end


function TaskRankRewardView:getReward(info, rewardData)
	local params = {}
	params.rankType = info.rankType
	params.id = info.id
	params.onSuccess = function (res )
		rewardData.canRecv = false
		
		--刷新红点
		local hasCanGet = false
		for _,v in ipairs(self._rewardData) do
			if v.canRecv then
				hasCanGet  = true
				break
			end
		end
		if not hasCanGet then
			ModelManager.RankModel:updateTaskRankReweadStatus(info.rankType,false)
		end
		
		if tolua.isnull(self.view) then return end
		self:updateRewardList()	
	end
	RPCReq.TaskRankReward_RecvTaskReward(params, params.onSuccess)
	
end


--事件初始化
function TaskRankRewardView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function TaskRankRewardView:_enter( ... )
	print(1,"TaskRankRewardView _enter")
end


--页面退出时执行
function TaskRankRewardView:_exit( ... )

	print(1,"TaskRankRewardView _exit")
end

-------------------常用------------------------

return TaskRankRewardView