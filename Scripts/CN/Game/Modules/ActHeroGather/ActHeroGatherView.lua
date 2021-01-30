-- added by wyz
-- 升星觉醒活动


local ActHeroGatherView = class("ActHeroGatherView",Window)

function ActHeroGatherView:ctor()
    self._packName  = "ActHeroGather"
    self._compName  = "ActHeroGatherView"
    -- self._rootDepth = LayerDepth.PopWindow

    self.lihuiDisplayFlag     = false
    self.lihuiDisplay       = false
    self.list_reward    = false
    self.txt_countTimer = false
    self.timer  = false
    self.txt_dec = false
    self.activityEnable = false 
end


function ActHeroGatherView:_initUI()
    self.lihuiDisplay     = self.view:getChildAutoType("lihuiDisplay")
    self.list_reward    = self.view:getChildAutoType("list_reward")
    self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
    self.txt_dec = self.view:getChildAutoType("txt_dec")
    self.btn_help = self.view:getChildAutoType("btn_help")
end


function ActHeroGatherView:_initEvent()
    self:refreshPanal()
    self.btn_help:removeEventListeners()
    self.btn_help:addClickListener(function( )
        local info={}
        info['title']=Desc["help_StrTitle199"]
        info['desc']=Desc["help_StrDesc199"]
        ViewManager.open("GetPublicHelpView",info) 
    end)
end

function ActHeroGatherView:refreshPanal()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroCollection)
    if not actData then return end
    if  self.lihuiDisplayFlag then self.lihuiDisplayFlag = false end
    self.lihuiDisplayFlag = BindManager.bindLihuiDisplay(self.lihuiDisplay)
    self.lihuiDisplayFlag:setData(actData.showContent.modelId, nil, nil, actData.showContent.fashionId)

    local rewardListData = ModelManager.ActHeroGatherModel:getShowConfig()
    self.txt_dec:setText(Desc.help_StrDescS199)
    self.list_reward:setItemRenderer(function(idx,obj)
        local index     = idx + 1
        local takeCtrl  = obj:getController("takeCtrl")  -- 0可领取  1前往  2已领取
        local txt_title = obj:getChildAutoType("txt_title")
        local list_reward = obj:getChildAutoType("list_reward")
        local btn_take  = obj:getChildAutoType("btn_take")
        local btn_travel = obj:getChildAutoType("btn_travel")
        local txt_times  = obj:getChildAutoType("txt_times")
        local curConfig      = rewardListData[index].config
        
        local reward = curConfig.reward
        list_reward:setItemRenderer(function(idx2,obj2)
            local itemCell = BindManager.bindItemCell(obj2)
            local rewardData = reward[idx2+1]
            itemCell:setData(rewardData.code,rewardData.amount,rewardData.type)
        end)
        list_reward:setData(reward)
        
        txt_title:setText(curConfig.desc)
        local count = ModelManager.ActHeroGatherModel:getCount( )
        txt_times:setText(count.."/"..curConfig.task)
        -- txt_times:setText(string.format("[color=#0ea41d]%s[/color]/%s",count,curConfig.task)) 
    
        if count>=curConfig.task then --满足
           if  rewardListData[index].hasGet == 1 then
               takeCtrl:setSelectedIndex(2)
           else
               takeCtrl:setSelectedIndex(0)
               btn_take:getChildAutoType("img_red"):setVisible(true)
           end
        else
            takeCtrl:setSelectedIndex(1)
        end

        btn_travel:removeClickListener(888)
        btn_travel:addClickListener(function()
            if self.activityEnable then RollTips.show(Desc.activity_txt18); return end
            ViewManager.open("GetCardsView",{page=2})
        end,888)

        btn_take:removeClickListener(888)
        btn_take:addClickListener(function()
            if self.activityEnable then RollTips.show(Desc.activity_txt18); return end
            local reqInfo = {
                activityId = actData.id,
                id = curConfig.id,
            }
            RPCReq.Activity_HeroCollection_GetRewardReq(reqInfo)
        end,888)
        
    end)
    self.list_reward:setData(rewardListData)
    self:updateCountTimer()
end

function ActHeroGatherView:ActHeroGatherView_refreshPanal()
    self:refreshPanal()
end

function ActHeroGatherView:updateCountTimer()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroCollection)
    -- printTable(8848,"actData>>>>>>>",actData)
    -- do return end
    if not actData then return end
    local actId   = actData.id
    local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
    if not addtime then return end

    if status == 2 and addtime == -1 then
        self.txt_countTimer:setText(Desc.activity_txt5)
    else
        local lastTime = addtime / 1000
        if lastTime == -1 then
            self.txt_countTimer:setText(Desc.activity_txt5)
        else
            if not tolua.isnull(self.txt_countTimer) then
                self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
            end
            local function onCountDown(time)
                if not tolua.isnull(self.txt_countTimer) then
                    self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(time, 2))
                end
            end
            local function onEnd(...)
                if not tolua.isnull(self.txt_countTimer) then
                 self.activityEnable = true
                 self.txt_countTimer:setText(Desc.activity_txt18)
                end
            end
            if self.timer then
                TimeLib.clearCountDown(self.timer)
            end
            self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
        end
    end
end

function ActHeroGatherView:_exit()
    TimeLib.clearCountDown(self.timer)
end



return ActHeroGatherView