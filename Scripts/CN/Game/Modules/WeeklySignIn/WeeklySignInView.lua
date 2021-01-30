-- added by wyz
-- 每周签到活动

local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local WeeklySignInView = class("WeeklySignInView",Window)

function WeeklySignInView:ctor()
    self._packName  = "WeeklySignIn"
    self._compName  = "WeeklySignInView"
    -- self._rootDepth = LayerDepth.PopWindow

	self.list_reward    = false
	self.btn_sevenDay 	= false
    self.txt_countTimer = false
    self.timer      = false
    self.activityEnable = false
    self.animation      = false
end


function WeeklySignInView:_initUI()
	self.list_reward    = self.view:getChildAutoType("list_reward")
	self.btn_sevenDay 	= self.view:getChildAutoType("btn_sevenDay")
    self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
end


function WeeklySignInView:_initEvent()
    self:refreshPanal()
end

function WeeklySignInView:refreshPanal()
    local dayStr = DateUtil.getOppostieDays()
    FileCacheManager.setBoolForKey("WeeklySignInView_isShow" .. dayStr,true)
    ModelManager.WeeklySignInModel:redCheck()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.WeekLogin)
    if not actData then return end
    -- printTable(8848,"actData>>>",actData)
    local myData = {}
	myData = ModelManager.WeeklySignInModel:sortData()
	
    self.list_reward:setItemRenderer(function(idx,obj)
        local index     = idx + 1
        local signStateCtrl  = obj:getController("signStateCtrl")  -- 0 待签到  1可签到  2已签到
        local txt_day 	= obj:getChildAutoType("txt_day")
        local data      = myData[index]
        local img_red   = obj:getChildAutoType("img_red")
        RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.WeekLogin.. data.day, img_red)
		txt_day:setText(Desc["WeeklySignIn_day"..index])
		local reward = data.reward[1]
		local txt_name = obj:getChildAutoType("txt_name")
        txt_name:setText(ItemConfiger.getItemNameByCode(reward.code))
        
        local txt_num   = obj:getChildAutoType("txt_num")
        txt_num:setText("x"..reward.amount)
		
		local itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
		itemCell:setData(reward.code,reward.amount,reward.type)
        itemCell:setNoFrame(true)
        itemCell:removeAllEffect()
        itemCell.txtNum:setVisible(false)
		
		local flag = bit.band(ModelManager.WeeklySignInModel.state, bit.lshift(1, data.day - 1)) > 0
        -- if ModelManager.WeeklySignInModel.indexDay >= data.day then
        -- signStateCtrl:setSelectedIndex(0)
            local effect_box = obj:getChildAutoType("effect_box")
            local effect_btn = obj:getChildAutoType("effect_btn")
            print(8848,"flag>>>>>>>>",flag)
            print(8848,"indexDay>>>>>>>>",ModelManager.WeeklySignInModel.indexDay)
            print(8848,"data.day>>>>>>>>",data.day)
            if not flag and ModelManager.WeeklySignInModel.indexDay >= data.day then
                if not obj.effect_box then
                    obj.effect_box = SpineUtil.createSpineObj(effect_box, vertex2(effect_box:getWidth()/2,effect_box:getHeight()/2), "biankuang", "Effect/UI", "qiriqiandao_wupinkuang", "qiriqiandao_wupinkuang",true)
                end
                if not obj.effect_btn then
                    obj.effect_btn = SpineUtil.createSpineObj(effect_btn, vertex2(effect_btn:getWidth()/2,effect_btn:getHeight()/2), "saoguang", "Effect/UI", "qiriqiandao_wupinkuang", "qiriqiandao_wupinkuang",true)
                end
                signStateCtrl:setSelectedIndex(1)
            elseif flag then
                if obj.effect_box then 
                    SpineUtil.clearEffect(obj.effect_box)
                    obj.effect_box = nil;
                end
                if  obj.effect_btn then
                    SpineUtil.clearEffect(obj.effect_btn)
                    obj.effect_btn = nil;
                end
                signStateCtrl:setSelectedIndex(2)
            else
                if obj.effect_box then 
                    SpineUtil.clearEffect(obj.effect_box)
                    obj.effect_box = nil;
                end
                if  obj.effect_btn then
                    SpineUtil.clearEffect(obj.effect_btn)
                    obj.effect_btn = nil;
                end
                signStateCtrl:setSelectedIndex(0)
            end

        obj:removeClickListener(888)
        obj:addClickListener(function()
            if self.activityEnable then RollTips.show(Desc.TimeSummon_end); return end
            local reqInfo = {
                -- activityId = actData.id,
                index = data.day,
            }
			RPCReq.Activity_WeekLogin_Reward(reqInfo,function()
				ModelManager.WeeklySignInModel.takeIndex = false
			end)
        end,888)
        
    end)
	self.list_reward:setNumItems(#myData-1)
	
	local signStateCtrl = self.btn_sevenDay:getController("signStateCtrl")
	local itemCell = BindManager.bindItemCell(self.btn_sevenDay:getChildAutoType("itemCell"))
	local reward = myData[7].reward[1]
	local txt_name = self.btn_sevenDay:getChildAutoType("txt_name")
	txt_name:setText(ItemConfiger.getItemNameByCode(reward.code))
	itemCell:setData(reward.code,reward.amount,reward.type)
    itemCell:setNoFrame(true)
    itemCell:removeAllEffect()
    itemCell.txtNum:setVisible(false)

    local txt_num   = self.btn_sevenDay:getChildAutoType("txt_num")
    txt_num:setText("x"..reward.amount)
	if ModelManager.WeeklySignInModel.indexDay >= myData[7].day  then
        local flag = bit.band(ModelManager.WeeklySignInModel.state, bit.lshift(1, myData[7].day - 1)) > 0
        if not flag and ModelManager.WeeklySignInModel.takeIndex == myData[7].day then
			signStateCtrl:setSelectedIndex(1)
        else
			signStateCtrl:setSelectedIndex(2)
		end
    else
		signStateCtrl:setSelectedIndex(0)
	end

	self.btn_sevenDay:removeClickListener(888)
	self.btn_sevenDay:addClickListener(function()
		if self.activityEnable then RollTips.show(Desc.TimeSummon_end); return end
		local reqInfo = {
			-- activityId = actData.id,
			index = myData[7].day,
		}
		RPCReq.Activity_WeekLogin_Reward(reqInfo,function()
			ModelManager.WeeklySignInModel.takeIndex = false
		end)
	end,888)
    self:updateCountTimer()
end

function WeeklySignInView:WeeklySignInView_refreshPanal()
    self:refreshPanal()
end

function WeeklySignInView:updateCountTimer()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.WeekLogin)
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
                 self.txt_countTimer:setText(Desc.TimeSummon_end)
                end
            end
            if self.timer then
                TimeLib.clearCountDown(self.timer)
            end
            self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
        end
    end
end

function WeeklySignInView:_exit()
    TimeLib.clearCountDown(self.timer)
end

return WeeklySignInView