-- added by wyz
-- 升星觉醒活动


local LStarAwakeningView = class("LStarAwakeningView",Window)

function LStarAwakeningView:ctor()
    self._packName  = "LStarAwakening"
    self._compName  = "LStarAwakeningView"
    -- self._rootDepth = LayerDepth.PopWindow

    self.lihuiDisplayFlag     = false
    self.lihuiDisplay       = false
    self.list_reward    = false
    self.txt_countTimer = false
    self.timer  = false
    self.txt_dec = false
    self.activityEnable = false 
end


function LStarAwakeningView:_initUI()
    self.lihuiDisplay     = self.view:getChildAutoType("lihuiDisplay")
    self.list_reward    = self.view:getChildAutoType("list_reward")
    self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
    self.txt_dec = self.view:getChildAutoType("txt_dec")
end


function LStarAwakeningView:_initEvent()
    self:refreshPanal()
end

function LStarAwakeningView:refreshPanal()
    local dayStr = DateUtil.getOppostieDays()
    FileCacheManager.setBoolForKey("LStarAwakeningView_isShow" .. dayStr,true)
    ModelManager.LStarAwakeningModel:redCheck()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroStarLevel)
    if not actData then return end
    -- printTable(8848,"actData>>>",actData)
    -- local path,name = PathConfiger.getHeroDraw(actData.showContent.modelId)
    -- self.banner:setURL(path.."/"..name..".png")
    if  self.lihuiDisplayFlag then self.lihuiDisplayFlag = false end
    self.lihuiDisplayFlag = BindManager.bindLihuiDisplay(self.lihuiDisplay)
    self.lihuiDisplayFlag:setData(actData.showContent.modelId, nil, nil, actData.showContent.fashionId)
    local myData = {}
    myData = ModelManager.LStarAwakeningModel:sortData()
    self.txt_dec:setText(DynamicConfigData.t_UpStarActivity[actData.showContent.moduleId].desc)
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
        RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.HeroStarLevel.. data.id, img_red)
        
        local reward = data.reward
        list_reward:setItemRenderer(function(idx2,obj2)
            local itemCell = BindManager.bindItemCell(obj2)
            local rewardData = reward[idx2+1]
            itemCell:setData(rewardData.code,rewardData.amount,rewardData.type)
        end)
        list_reward:setData(reward)
        
        txt_title:setText(data.desc)
        -- txt_times:setText(string.format("[color=#0ea41d]%s[/color]/%s",ModelManager.LStarAwakeningModel.starLevel,data.task))
        txt_times:setText("")

        -- if ModelManager.LStarAwakeningModel.starLevel >= data.task then
        --     if  ModelManager.LStarAwakeningModel.data.recordMap[data.id].recvState then
        --         takeCtrl:setSelectedIndex(0)
        --     else
        --         takeCtrl:setSelectedIndex(2)
        --     end
        -- else
        --     takeCtrl:setSelectedIndex(1)
        -- end

        if ModelManager.LStarAwakeningModel.data.recordMap[data.id] then
            if  ModelManager.LStarAwakeningModel.data.recordMap[data.id].recvState then
                takeCtrl:setSelectedIndex(0)
            else
                takeCtrl:setSelectedIndex(2)
            end
        else
            takeCtrl:setSelectedIndex(1)
        end

        btn_travel:removeClickListener(888)
        btn_travel:addClickListener(function()
            if self.activityEnable then RollTips.show(Desc.activity_txt18); return end
            --没有英雄跳转到召唤界面
            -- if not LStarAwakeningModel:isHaveHero() then
            --     -- local actData2 = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.SpecialSummon)
            --     -- if not actData2 then return end
            --     ViewManager.close("ActivityFrame2View")
            --     ModuleUtil.openModule(ModuleId.UpGetCardActivity.id)
            -- else
            --有英雄打开卡牌界面
                ViewManager.open("CardBagView")
            -- end
        end,888)

        btn_take:removeClickListener(888)
        btn_take:addClickListener(function()
            if self.activityEnable then RollTips.show(Desc.activity_txt18); return end
            local reqInfo = {
                activityId = actData.id,
                id = data.id,
            }
            RPCReq.Activity_HeroStarLevel_GetReward(reqInfo)
        end,888)
        
    end)
    self.list_reward:setData(myData)
    self:updateCountTimer()
end

function LStarAwakeningView:LStarAwakeningView_refreshPanal()
    self:refreshPanal()
end

function LStarAwakeningView:updateCountTimer()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroStarLevel)
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

function LStarAwakeningView:_exit()
    TimeLib.clearCountDown(self.timer)
end



return LStarAwakeningView