-- added by wyz
-- 圣所探险活动


local SanctuaryAdventureView = class("SanctuaryAdventureView",Window)

function SanctuaryAdventureView:ctor()
    self._packName  = "SanctuaryAdventure"
    self._compName  = "SanctuaryAdventureView"
    -- self._rootDepth = LayerDepth.PopWindow

    self.lihuiDisplayFlag = false
    self.lihuiDisplay     = false
    self.list_reward    = false
    self.txt_countTimer = false
    self.timer      = false
    self.txt_dec    = false
    self.activityEnable = false
end


function SanctuaryAdventureView:_initUI()
    self.lihuiDisplay     = self.view:getChildAutoType("lihuiDisplay")
    self.list_reward    = self.view:getChildAutoType("list_reward")
    self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
    self.txt_dec = self.view:getChildAutoType("txt_dec")
end


function SanctuaryAdventureView:_initEvent()
    self:refreshPanal()
end

function SanctuaryAdventureView:refreshPanal()
    local dayStr = DateUtil.getOppostieDays()
	FileCacheManager.setBoolForKey("SanctuaryAdventureView_isShow" .. dayStr,true)
    ModelManager. SanctuaryAdventureModel:redCheck()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.StarTempleExpedition)
    if not actData then return end
    printTable(8848,"actData>>>",actData)
    if self.lihuiDisplayFlag then self.lihuiDisplayFlag = false end
    self.lihuiDisplayFlag = BindManager.bindLihuiDisplay(self.lihuiDisplay)
    self.lihuiDisplayFlag:setData(actData.showContent.modelId, nil,nil, actData.showContent.fashionId)
    local myData = {}
    myData = ModelManager.SanctuaryAdventureModel:sortData()
    printTable(8848,"myData>>>>>>>>",myData)
    self.txt_dec:setText(DynamicConfigData.t_TempleActivity[actData.showContent.moduleId].desc)
    self.list_reward:setItemRenderer(function(idx,obj)
        local index     = idx + 1
        local takeCtrl  = obj:getController("takeCtrl")  -- 0可领取  1前往  2已领取
        local txt_title = obj:getChildAutoType("txt_title")
        local list_reward = obj:getChildAutoType("list_reward")
        local btn_take  = obj:getChildAutoType("btn_take")
        local btn_travel = obj:getChildAutoType("btn_travel")
        local txt_times  = obj:getChildAutoType("txt_times")
        local data      = myData[index]
        local img_red   = btn_take:getChildAutoType("img_red")
        RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.StarTempleExpedition.. data.id, img_red)
        
        local reward = data.reward
        list_reward:setItemRenderer(function(idx2,obj2)
            local itemCell = BindManager.bindItemCell(obj2)
            local rewardData = reward[idx2+1]
            itemCell:setData(rewardData.code,rewardData.amount,rewardData.type)
        end)
        list_reward:setData(reward)
        
        txt_title:setText(data.desc)
        txt_times:setText(string.format("[color=#0ea41d]%s[/color]/%s",ModelManager.SanctuaryAdventureModel.layer,data.times))

        if ModelManager.SanctuaryAdventureModel.layer >= data.times then
            local flag = bit.band(ModelManager.SanctuaryAdventureModel.state, bit.lshift(1, data.id - 1)) > 0
            if not flag then
                takeCtrl:setSelectedIndex(0)
            else
                takeCtrl:setSelectedIndex(2)
            end
        else
            takeCtrl:setSelectedIndex(1)
        end

        btn_travel:removeClickListener(888)
        btn_travel:addClickListener(function()
            if self.activityEnable then RollTips.show(DescAuto[237]); return end -- [237]="活动已结束！"
            local hasOpen = ModuleUtil.moduleOpen( ModuleId.PveStarTemple.id, true )
            if not hasOpen then return end
            Dispatcher.dispatchEvent(EventType.PveStarTemple_Start)
        end,888)

        btn_take:removeClickListener(888)
        btn_take:addClickListener(function()
            if self.activityEnable then RollTips.show(DescAuto[237]); return end -- [237]="活动已结束！"
            local reqInfo = {
                -- activityId = actData.id,
                index = data.id,
            }
            printTable(8848,"reqInfo>>>",reqInfo)
            RPCReq.Activity_StarTempleExpedition_Reward(reqInfo)
        end,888)
        
    end)
    self.list_reward:setData(myData)
    self:updateCountTimer()
end

function SanctuaryAdventureView:SanctuaryAdventureView_refreshPanal()
    self:refreshPanal()
end

function SanctuaryAdventureView:updateCountTimer()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.StarTempleExpedition)
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
                 self.txt_countTimer:setText(DescAuto[238]) -- [238]="活动已结束!"
                end
            end
            if self.timer then
                TimeLib.clearCountDown(self.timer)
            end
            self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
        end
    end
end

function SanctuaryAdventureView:_exit()
    TimeLib.clearCountDown(self.timer)
end



return SanctuaryAdventureView
