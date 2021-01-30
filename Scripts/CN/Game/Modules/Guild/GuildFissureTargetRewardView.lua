--added by  公会次元裂缝段位奖励
local GuildFissureTargetRewardView, Super = class("GuildFissureTargetRewardView", Window)
function GuildFissureTargetRewardView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildFissureTargetRewardView"
    self._rootDepth = LayerDepth.PopWindow
    self.list_reward = false
end

-------------------常用------------------------
--UI初始化
function GuildFissureTargetRewardView:_initUI(...)
    self.list_reward = self.view:getChildAutoType("$list_reward")
    local config = GuildModel:getBossRankConfig(GuildModel.cylfBossData.levelId)
    self.list_reward:setItemRenderer(
        function(index, obj)
            --obj:removeClickListener(100) --池子里面原来的事件注销掉
            local itemMode = config[index + 1]
            local rewardList = itemMode.reward
            local img_duanwei = obj:getChildAutoType("img_duanwei")
            img_duanwei:setURL(PathConfiger.getBossDw(itemMode.rank))
            local txt_duanwei = obj:getChildAutoType("txt_duanwei")
            txt_duanwei:setText(itemMode.rankName)
            local rewardObj = obj:getChildAutoType("list_reward")
            rewardObj:setItemRenderer(
                function(rewardindex, rewardOj)
                    local itemcell = BindManager.bindItemCell(rewardOj)
                    local award = rewardList[rewardindex + 1]
                    itemcell:setData(award.code, award.amount, award.type)
                end
            )
            rewardObj:setNumItems(#rewardList)
        end
    )
    self.list_reward:setNumItems(#config)
end

--事件初始化
function GuildFissureTargetRewardView:_initEvent(...)
end

--initEvent后执行
function GuildFissureTargetRewardView:_enter(...)
end

--页面退出时执行
function GuildFissureTargetRewardView:_exit(...)
end

-------------------常用------------------------

return GuildFissureTargetRewardView
