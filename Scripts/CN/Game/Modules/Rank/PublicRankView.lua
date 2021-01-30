--added by wyang 排行榜窗口
local RankView = require "Game.Modules.Rank.RankView"
local PublicRankView,Super = class("PublicRankView",RankView)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
function PublicRankView:ctor( data )
	self._packName = "Rank"
	self._compName = "PublicRankView"
	self._rootDepth = LayerDepth.PopWindow
	--self._openType = GameDef.RankType.NormalTower
end

-------------------常用------------------------
--UI初始化
function PublicRankView:_initUI( ... )
--	local info=self.args[1];
	local a = self.view
	Super._initUI(self, ... )
	
	self.btn_reward = self.view:getChild("btn_reward")
	self.btn_reward:addClickListener(function( ... )
                ViewManager.open("TaskRankRewardView", {type = self._openType})
            end)
	local hasReward = DynamicConfigData.t_TaskRankReward[self._openType] ~= nil
	self.btn_reward:setVisible(hasReward)
	RedManager.register("V_TASK_REWARD_"..self._openType, self.btn_reward:getChildAutoType("img_red"))
end



--这个方法给特殊排行榜继承后加需要特殊处理的内容
function PublicRankView:updateItemSpec(obj, rank, info, isMine)

end



--事件初始化
function PublicRankView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function PublicRankView:_enter( ... )
	print(1,"PublicRankView _enter")
end


--页面退出时执行
function PublicRankView:_exit( ... )

	print(1,"PublicRankView _exit")
end

-------------------常用------------------------

return PublicRankView