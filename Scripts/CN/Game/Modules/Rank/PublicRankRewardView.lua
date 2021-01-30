--added by wyang 排行榜奖励预览窗口

local PublicRankRewardView,Super = class("PublicRankRewardView",Window)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
function PublicRankRewardView:ctor( data )
	self._packName = "Rank"
	self._compName = "PublicRankRewardView"
	self._rootDepth = LayerDepth.PopWindow
	self._rewardData = false
	self._myRank = 0
	self.args = data
	self._rewardData = data.rewardData or DynamicConfigData.t_ActivityRankReward[self.args.activityType][self.args.moduleId]
end

-------------------常用------------------------
--UI初始化
function PublicRankRewardView:_initUI( ... )
	self.list_rank = FGUIUtil.getChild(self.view, "list_rank", "GList")
	self.myRankItem = self.view:getChildAutoType("myRankItem")
	self.closeBtn = self.view:getChildAutoType("closeBtn")
	
	if self.myRankItem then
		self.myRankItem:getController("c2"):setSelectedIndex(1)
	end
	
	
	self.list_rank:setVirtual()
	self.list_rank:setItemRenderer(
			function(index, obj) 
				local info = self._rewardData[index + 1]
				self:updateRankItem(obj,info, (index + 1) == #self._rewardData )
			end
		)		
	self.list_rank:setNumItems(#self._rewardData)
	
	if self.closeBtn then
		self.closeBtn:addClickListener(function ( ... )
			--ViewManager.close("ViewPlayerView")
			self:closeView()
		end)
	end
	
	self:updateRankData()
end

function PublicRankRewardView:updateRankItem(obj, info, isMax)
	local list_reward = obj:getChildAutoType("list_reward")
	local rankIcon = obj:getChildAutoType("rankIcon")
	local txt_rank = obj:getChildAutoType("txt_rank")
	list_reward:setVirtual()
	list_reward:setItemRenderer(
			function(index, rewardObj) 
				local rewardItem = BindManager.bindItemCell(rewardObj)
				local reward = info.reward[index + 1]
				rewardItem:setData(reward.code, reward.amount, reward.type)
			end
		)
	list_reward:setNumItems(#info.reward)
	local rankMin  = info.min
	local rankMax  = info.max
	if rankMin == rankMax and rankMin <= 3 then
		obj:getController("c1"):setSelectedIndex(rankMin)
		rankIcon:setURL(string.format("%s%s.png","UI/Rank/Rank_img_",rankMin))
	else
		obj:getController("c1"):setSelectedIndex(4)	
		if isMax then
			txt_rank:setText(string.format("%s+", rankMin))
		else
			txt_rank:setText(string.format("%s-%s", rankMin, rankMax))
		end
	end
end

function PublicRankRewardView:updateMyRankItem()
	local obj = self.myRankItem
	local myReward
	for _,v in ipairs(self._rewardData) do
		if self._myRank >= v.min and self._myRank <= v.max then
			myReward = v.reward
			break
		end
	end
	
	local rankIcon = obj:getChildAutoType("rankIcon")
	local txt_myRank = obj:getChildAutoType("txt_myRank")
	txt_myRank:setText(self._myRank)
	if myReward then
		local list_reward = obj:getChildAutoType("list_reward")
		list_reward:setVirtual()
		list_reward:setItemRenderer(
				function(index, rewardObj) 
					local rewardItem = BindManager.bindItemCell(rewardObj)
					local reward = myReward[index + 1]
					rewardItem:setData(reward.code, reward.amount, reward.type)
				end
			)
		list_reward:setNumItems(#myReward)
	end
	
	if self._myRank <= 3 then
		obj:getController("c1"):setSelectedIndex(self._myRank)
		--rankIcon:setURL(string.format("%s%s.png","UI/Rank/Rank_img_",self._myRank))
	else
		obj:getController("c1"):setSelectedIndex(4)	
	end
end


function PublicRankRewardView:updateRankData()
	local params = {}
	params.rankType = self.args.rankType
	params.onSuccess = function (res )
		--找出自己的排名数据，找不到的话就是没上榜
		local myInfo = res.myRankData
		self._myRank = myInfo and myInfo.rank or 0
		if self._myRank == 0 and res.rankData then
			for k,v in pairs(res.rankData) do
				if(v.id == ModelManager.PlayerModel.userid) then
					self._myRank = v.rank or k
					myInfo = v
					break
				end
			end
		end
		if tolua.isnull(self.view) then return end
		if self.myRankItem then
			self:updateMyRankItem()
		end
	end
	RPCReq.Rank_GetRankData(params, params.onSuccess)
	
end


--事件初始化
function PublicRankRewardView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function PublicRankRewardView:_enter( ... )
	print(1,"PublicRankRewardView _enter")
end


--页面退出时执行
function PublicRankRewardView:_exit( ... )

	print(1,"PublicRankRewardView _exit")
end

-------------------常用------------------------

return PublicRankRewardView