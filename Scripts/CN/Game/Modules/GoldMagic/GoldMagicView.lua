-- added by wyz
-- 升星觉醒活动


local GoldMagicView = class("GoldMagicView",Window)

function GoldMagicView:ctor()
    self._packName  = "GoldMagic"
    self._compName  = "GoldMagicView"
    -- self._rootDepth = LayerDepth.PopWindow

    self.lihuiDisplayFlag     = false
    self.lihuiDisplay       = false
    self.list_reward    = false
    self.txt_countTimer = false
    self.timer  = false
    self.txt_dec = false
    self.activityEnable = false 
	self.btn_help = false
	self.txt_dec = false
end


function GoldMagicView:_initUI()
    self.lihuiDisplay     = self.view:getChildAutoType("lihuiDisplay")
    self.list_reward    = self.view:getChildAutoType("list_reward")
    self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
    self.txt_dec = self.view:getChildAutoType("txt_dec")
	self.btn_help = self.view:getChildAutoType("btn_help")
	self.btn_rankReward = self.view:getChildAutoType("btn_rankReward")
	self.btn_rank = self.view:getChildAutoType("btn_rank")
	self.txt_dec = self.view:getChildAutoType("txt_dec")
	
	self.txt_dec:setText(Desc.help_StrDescS201)
end


function GoldMagicView:_initEvent()
    self:refreshPanal()
	self.btn_help:removeEventListeners()
    self.btn_help:addClickListener(function( )
        local info={}
        info['title']=Desc["help_StrTitle201"]
        info['desc']=Desc["help_StrDesc201"]
        ViewManager.open("GetPublicHelpView",info) 
    end)
	
	self.btn_rankReward:removeEventListeners()
    self.btn_rankReward:addClickListener(function( )
		local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GoldMagic)
		if not actData then return {} end
        ViewManager.open("PublicRankRewardView", {activityType = GameDef.ActivityType.GoldMagic, moduleId = actData.showContent.moduleId, rankType = GameDef.RankType.GoldMagic})
    end)
	
	self.btn_rank:removeEventListeners()
    self.btn_rank:addClickListener(function( )
        ViewManager.open("PublicRankView", {type = GameDef.RankType.GoldMagic})
    end)
end

function GoldMagicView:refreshPanal()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GoldMagic)
    if not actData then return end
    if  self.lihuiDisplayFlag then self.lihuiDisplayFlag = false end
    self.lihuiDisplayFlag = BindManager.bindLihuiDisplay(self.lihuiDisplay)
    self.lihuiDisplayFlag:setData(actData.showContent.modelId,nil,nil,actData.showContent.fashionId)

    local rewardListData = ModelManager.GoldMagicModel:getShowConfig()
    --self.txt_dec:setText("精英召唤UP探员升星领豪礼")
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
        local count = ModelManager.GoldMagicModel:getCount( )
        txt_times:setText(count.."/"..curConfig.task)
    
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
            ViewManager.open("GoldTreeView")
        end,888)

        btn_take:removeClickListener(888)
        btn_take:addClickListener(function()
            if self.activityEnable then RollTips.show(Desc.activity_txt18); return end
            local reqInfo = {
                activityId = actData.id,
                id = curConfig.id,
            }
            RPCReq.Activity_GoldMagic_GetRewardReq(reqInfo)
        end,888)
        
    end)
    self.list_reward:setData(rewardListData)
    self:updateCountTimer()
end

function GoldMagicView:GoldMagicView_refreshPanal()
    self:refreshPanal()
end

function GoldMagicView:updateCountTimer()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GoldMagic)
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

function GoldMagicView:_exit()
    TimeLib.clearCountDown(self.timer)
end



return GoldMagicView