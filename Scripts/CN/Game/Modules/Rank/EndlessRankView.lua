--added by wyang 排行榜窗口
local RankView = require "Game.Modules.Rank.RankView"
local EndlessRankView,Super = class("EndlessRankView",RankView)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
function EndlessRankView:ctor( data )
	self._packName = "Rank"
	self._compName = "EndlessRankView"
	self._rootDepth = LayerDepth.Window
	--self._openType = GameDef.RankType.NormalTower
end

-------------------常用------------------------
--UI初始化
function EndlessRankView:_initUI( ... )
--	local info=self.args[1];
	local a = self.view
	Super._initUI(self, ... )
	
	if self.list_type then
		self.list_type:setItemRenderer(
			function(index, obj) 
				local info = self._groupData[index + 1]
				obj:setTitle(info.groupTab);
				obj:setIcon(PathConfiger.getEndLessRankBtnIcon(info.rankType - 20));
				obj:getController("size"):setSelectedIndex(0)
				obj:removeClickListener(100)
				obj:addClickListener(
					function(...)
						--local item=recommend[index+1];
						--ViewManager.open("GuildApplyView",{item})
						self:updateRankData()
					end,100
				)
			end
		)
		self.list_type:setData(self._groupData)
		self.list_type:setSelectedIndex(self._currentIndex - 1)
	end
	
end



--这个方法给特殊排行榜继承后加需要特殊处理的内容
function EndlessRankView:updateItemSpec(obj, rank, info, isMine)
	local img_bg = obj:getChild("img_bg")
	if rank >= 101 then 
		--obj:getController("c1"):setSelectedIndex(0)
	end
	if not isMine then
		local path = PathConfiger.getEndLessRankBg(rank)
		img_bg:setURL(path)
	else
		img_bg:setURL(PathConfiger.getEndLessRankBg(0))
	end
	
	local rewards,lastRank,nextRank = RankConfiger.getTopChallengeReward(self._openType - 20, rank)
	
	local txt_rank = obj:getChild("txt_rank")
	if txt_rank then 
		if (rank <= 20 and self._myRank <= 20 and self._myRank ~= 0) or 
			(rank == nextRank and self._myRank > nextRank and self._myRank ~= 0) or
			(rank == 100 and self._myRank == 0)or isMine then
			txt_rank:setText(rank)
		elseif rank == 101 then
			txt_rank:setText(Desc.Rank_notInRank) 
		else
			txt_rank:setText(lastRank.."-"..nextRank) 
		end
	end
	local rewardList = obj:getChild("list_reward")
	if isMine then
		local txt_noReward = obj:getChild("txt_noReward")
		txt_noReward:setVisible(info.value == 0)
		rewardList:setVisible(info.value > 0)
	end
	
	rewardList:setItemRenderer(
		function(index, obj) 
			local itemCell = BindManager.bindItemCell(obj)
			local data = rewards[index + 1]
			itemCell:setData(data.code, data.amount, data.type)
		end)
	rewardList:setNumItems(#rewards)
end



--事件初始化
function EndlessRankView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function EndlessRankView:_enter( ... )
	print(1,"EndlessRankView _enter")
end


--页面退出时执行
function EndlessRankView:_exit( ... )

	print(1,"EndlessRankView _exit")
end

-------------------常用------------------------

return EndlessRankView