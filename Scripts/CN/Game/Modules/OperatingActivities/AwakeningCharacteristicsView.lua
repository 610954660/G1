--Name : AwakeningCharacteristicsView.lua
--Author : generated by FairyGUI
--Date : 2020-7-8
--Desc : --特性觉醒

local AwakeningCharacteristicsView, Super = class("AwakeningCharacteristicsView", Window)
function AwakeningCharacteristicsView:ctor()
    LuaLog("AwakeningCharacteristicsView ctor")
    self._packName = "OperatingActivities"
    self._compName = "AwakeningCharacteristicsView"
    --self._rootDepth = LayerDepth.Window
    self.viewIndexTag = GameDef.ActivityType.Features
    self.starInfo = false
    self.bannerUrl = false
	self.calltimer = false
end

function AwakeningCharacteristicsView:_initEvent()
end

function AwakeningCharacteristicsView:_initVM()
    local vmRoot = self
    local viewNode = self.view
    ---Do not modify following code--------
    --{vmFields}:OperatingActivities.AwakeningCharacteristicsView
    vmRoot.txt_clientDesc = viewNode:getChildAutoType("txt_clientDesc")  
    vmRoot.list_item = viewNode:getChildAutoType("$list_item")
    --list
    vmRoot.txt_countDown = viewNode:getChildAutoType("$txt_countDown")
    --text
    vmRoot.img_banner = viewNode:getChildAutoType("$img_banner")
    --loader
    --{vmFieldsEnd}:OperatingActivities.AwakeningCharacteristicsView
    --Do not modify above code-------------
end

function AwakeningCharacteristicsView:setActType(_args)
end

function AwakeningCharacteristicsView:_initUI()
    self:_initVM()
    local dayStr = DateUtil.getOppostieDays()
    FileCacheManager.setBoolForKey("AwakeningCharacteristics_isShow" .. dayStr, true)
    OperatingActivitiesModel:AwakeningCharacteristicsred()
    self.txt_clientDesc:setText(Desc.activity_txt22)
    self.lihuiDisplay = BindManager.bindLihuiDisplay(self.img_banner)
    local actData = ModelManager.ActivityModel:getActityByType(self.viewIndexTag)
    if not actData then
        return
    end
    self.lihuiDisplay:setData(actData.showContent.modelId, nil, true, actData.showContent.fashionId)
    self:showView()
end

function AwakeningCharacteristicsView:showCountTime()
    local actData = ModelManager.ActivityModel:getActityByType(self.viewIndexTag)
    if not actData then
        return
    end
    local actId = actData.id
    local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
    if not addtime then
        return
    end
    if status == 2 and addtime == -1 then
        self.txt_countDown:setText(Desc.activity_txt5)
    else
        local lastTime = addtime / 1000
        if lastTime == -1 then
            self.txt_countDown:setText(Desc.activity_txt5)
        else
            if not tolua.isnull(self.txt_countDown) then
                self.txt_countDown:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
            --TimeLib.formatTime(addtime,true,false)
            end
            local function onCountDown(time)
                if not tolua.isnull(self.txt_countDown) then
                    self.txt_countDown:setText(TimeLib.GetTimeFormatDay(time, 2))
                --TimeLib.formatTime(time,true,false)
                end
            end
            local function onEnd(...)
                if not tolua.isnull(self.txt_countDown) then
                    self.txt_countDown:setText(Desc.activity_txt13)
                end
            end
            if self.calltimer then
                TimeLib.clearCountDown(self.calltimer)
				self.calltimer = false
            end
            self.calltimer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
        end
    end
end

function AwakeningCharacteristicsView:showView()
    self.starInfo = OperatingActivitiesModel:getAwakeningCharacteristicsInfo(true)
    self:showCountTime()
    self.list_item:setVirtual()
    self.list_item:setItemRenderer(
        function(index, obj)
            local starInfo = self.starInfo
            local itemInfo = starInfo[index + 1]
            local money = OperatingActivitiesModel:getAwakeningCharacterCount(itemInfo.id)
            obj:getChild("$txt_desc"):setText(itemInfo.desc)
            obj:getChild("$txt_num"):setText(ColorUtil.formatColorString1(money, "#0ea41d") .. "/" .. itemInfo.number)
            local ctrl = obj:getController("c1")
            local lingqu = OperatingActivitiesModel:getAwakeningCharacterLingqu(itemInfo.id)
            local red = false
            local state = 0
            obj:getChild("$txt_num"):setVisible(true)
            if money < itemInfo.number then --无法领取
                state = 1
                ctrl:setSelectedIndex(1)
                red = false
            elseif money >= itemInfo.number and lingqu == false then --可领取
                obj:getChild("$txt_num"):setVisible(false)
                state = 2
                ctrl:setSelectedIndex(0)
                red = true
            elseif money >= itemInfo.number and lingqu == true then --已领取
                state = 3
                ctrl:setSelectedIndex(2)
                red = false
            end
            local btn = obj:getChild("$btn_get")
            local img_red = btn:getChild("img_red")
            img_red:setVisible(red)
            local list_prop = obj:getChild("$list_prop")
            list_prop:setItemRenderer(
                function(idx2, obj2)
                    local itemcell = BindManager.bindItemCell(obj2)
                    local award = itemInfo.reward[idx2 + 1]
                    itemcell:setData(award.code, award.amount, award.type)
                    itemcell:setIsHook(state == 3)
                end
            )
            list_prop:setNumItems(#itemInfo.reward) -- 领取按钮
            btn:removeClickListener(100)
            btn:addClickListener(
                function()
                    OperatingActivitiesModel:FeaturesRecieveReward(itemInfo.id)
                end,
                100
            )
            local enterbtn = obj:getChild("$btn_enter")
            -- 前往按钮
            enterbtn:removeClickListener(100)
            enterbtn:addClickListener(
                function()
                    ModuleUtil.openModule(ModuleId.Hero.id, true)
                end,
                100
            )
        end
    )
    self.list_item:setNumItems(#self.starInfo)
end

function AwakeningCharacteristicsView:activity_AwakeningCharacterisUpdate(...)
    self.starInfo = OperatingActivitiesModel:getAwakeningCharacteristicsInfo(true)
    self.list_item:setNumItems(#self.starInfo)
end

function AwakeningCharacteristicsView:_exit()
	if self.calltimer then
		TimeLib.clearCountDown(self.calltimer)
	end
end


return AwakeningCharacteristicsView
