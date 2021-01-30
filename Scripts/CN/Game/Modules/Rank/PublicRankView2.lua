--added by wyang 排行榜窗口
local RankView = require "Game.Modules.Rank.RankView"
local PublicRankView2,Super = class("PublicRankView2",RankView)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
function PublicRankView2:ctor( data )
	self._packName = "Rank"
	self._compName = "PublicRankView2"
	self._rootDepth = LayerDepth.PopWindow
	--self._openType = GameDef.RankType.NormalTower
end

-------------------常用------------------------
--UI初始化
function PublicRankView2:_initUI( ... )
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
function PublicRankView2:updateItemSpec(obj, rank, info, isMine)
	local txt_fightPoint = obj:getChild("txt_fightPoint")
	local txt_attr1 = obj:getChild("txt_attr1")
	local iconLoader = obj:getChild("iconLoader")
	txt_fightPoint:setText(StringUtil.transValue(info and info.combat or 0))
	--txt_attr1:setText(info.value)
	if self._data.icon then
		iconLoader:setVisible(true)
		iconLoader:setURL(ItemConfiger.getItemIconByCode(self._data.icon.code, self._data.icon.type))
	else
		iconLoader:setVisible(false)
	end
	
end



--事件初始化
function PublicRankView2:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function PublicRankView2:_enter( ... )
	print(1,"PublicRankView2 _enter")
end


--页面退出时执行
function PublicRankView2:_exit( ... )

	print(1,"PublicRankView2 _exit")
end

-------------------常用------------------------

return PublicRankView2