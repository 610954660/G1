--章节奖励
local CohesionRewardView,Super = class("CohesionRewardView",View)
function CohesionRewardView:ctor( ... )
    print(152,"CohesionRewardView")
	self._packName = "PushMap"
	self._compName = "CohesionRewardView"
	self._rootDepth = LayerDepth.Message
end

-------------------常用------------------------
--UI初始化
function CohesionRewardView:_initUI( ... )
     -- self.view = UIPackageManager.createGComponent("PushMap", "CohesionRewardView")
    --
    local data = self._args.reward
    self.tvLeftLevel = self.view:getChildAutoType("tvLeftLevel")
    self.tvRightLevel = self.view:getChildAutoType("tvRightLevel")
    self.closeBtnView = self.view:getChildAutoType("closeBtnView")
    --
    for index = 1, 3 do
        local imgReward = string.format("imgReward%d", index)
        local tvLeftRewardValue = string.format("tvLeftRewardValue%d", index)
        local tvRightRewardValue = string.format("tvRightRewardValue%d", index)
        self[imgReward] = self.view:getChildAutoType(imgReward)
        self[tvLeftRewardValue] = self.view:getChildAutoType(tvLeftRewardValue)
        self[tvRightRewardValue] = self.view:getChildAutoType(tvRightRewardValue)
    end
    local width = self.view:getWidth()
    local height = self.view:getHeight()
    self.view:setPosition(display.cx - width / 2, display.cy - height / 2)
    -- local data = {
    --    leftLevelName = "",
    --    rightLevelName = "",
    --    rewardList = {
    --        {{type=2,code=2,amount=200,}, {type=2,code=2,amount=200,}},
    --        {{type=2,code=2,amount=200,}, {type=2,code=2,amount=200,}},
    --        {{type=2,code=2,amount=200,}, {type=2,code=2,amount=200,}},
    --    }
    -- }
    self:showListIcon(data)
end


function CohesionRewardView:showListIcon(data)
    self.tvLeftLevel:setText(data.leftLevelName or "")
    self.tvRightLevel:setText(data.rightLevelName or "")
    for index, rewards in ipairs(data.rewardList) do
        --
        local imgReward = string.format("imgReward%d", index)
        local tvLeftRewardValue = string.format("tvLeftRewardValue%d", index)
        local tvRightRewardValue = string.format("tvRightRewardValue%d", index)
        imgReward = self[imgReward]
        tvLeftRewardValue = self[tvLeftRewardValue]
        tvRightRewardValue = self[tvRightRewardValue]
        --
        local leftReward = rewards[1]
        local rightReward = rewards[2]
        --
        local iconUrl = ItemConfiger.getItemIconByCodeAndType(leftReward.type, leftReward.code)
        imgReward:setURL(iconUrl)
        tvLeftRewardValue:setText(string.format("%d%s", leftReward.amount,Desc.CohesionReward_str))
        tvRightRewardValue:setText(string.format("%d%s", rightReward.amount,Desc.CohesionReward_str))
    end

    -- local parentObj = ViewManager.getParentLayer(LayerDepth.Tips)
    -- parentObj:addChild(self.view)
    --
    self.view:setAlpha(0)
    TweenUtil.alphaTo(self.view, {from = 0, to = 1, time = 0.2, ease = EaseType.Linear})
    self._updateTimeId =
        Scheduler.scheduleOnce(
        1.8,
        function()
            TweenUtil.alphaTo(
                self.view,
                {
                    from = 1,
                    to = 0,
                    time = 0.3,
                    ease = EaseType.Linear,
                    onComplete = function()
                        -- parentObj:removeChild(self.view)
                        self:closeView()
                    end
                }
            )
        end
    )


end



--UI初始化
function CohesionRewardView:_initEvent(...)
    self.closeBtnView:addClickListener(
        function(...)
            self:closeView()
        end
    )
end


--initEvent后执行
function CohesionRewardView:_enter( ... )

end

--页面退出时执行
function CohesionRewardView:_exit( ... )
--	self.itemcellArrs = {}
    if self._updateTimeId then
        Scheduler.unschedule(self._updateTimeId)
    end
end

-------------------常用------------------------

return CohesionRewardView
