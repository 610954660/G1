--Name : EightDayActView.lua
--Author : generated by FairyGUI
--Date : 2020-5-29
--Desc :

local EightDayActView, Super = class("EightDayActView", Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local ItemCell = require "Game.UI.Global.ItemCell"

function EightDayActView:ctor()
    --LuaLog("EightDayActView ctor")
    self._packName = "OperatingActivities"
    self._compName = "EightDayActView"
    --self._rootDepth = LayerDepth.Window
    self.itemCom = {}
    self.com_model = false
    self.bossAnima={}
end

function EightDayActView:_initEvent()
end

function EightDayActView:_initVM()
    local vmRoot = self
    local viewNode = self.view
    ---Do not modify following code--------
    --{vmFields}:OperatingActivities.EightDayActView
    --{vmFieldsEnd}:OperatingActivities.EightDayActView
    --Do not modify above code-------------
end

function EightDayActView:_initUI()
    self:_initVM()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.EightDayLogin)
    if not actData then
        return
    end
    local bg = string.format( "%s%s","UI/activity/",actData.showContent.activeBg)
    local fullScreen = self.view:getChildAutoType("fullScreen")
    fullScreen:setIcon(bg)
    for i = 1, 8, 1 do
        local itemKey = "item_" .. i
        local item = self.view:getChildAutoType(itemKey)
        self.itemCom[i] = item
    end
    self:showItem()
end

function EightDayActView:showItem()
    -- local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.EightDayLogin)
    -- printTable(16,"八日登录",actData)
    for key, obj in pairs(self.itemCom) do
        local indexDay = tonumber(key)
        local configInfo = DynamicConfigData.t_EightdayLogin[1][indexDay]
        local stateInfo = self:getState(indexDay)
        local gctr = obj:getController("c1")
        gctr:setSelectedIndex(stateInfo)
        obj:setTitle(StringUtil.transNumToChnNum(configInfo.day))
        if indexDay == 8 then
            self.com_model = obj:getChildAutoType("com_mode")
            self.com_model = self.com_model:displayObject()
            local bossid = configInfo.drawshow
            local skeletonNode = SpineMnange.createSprineById(bossid)
            if not skeletonNode then
                return
            end
            self.com_model:addChild(skeletonNode)
            skeletonNode:setAnimation(0, "stand", true)
            if self.skeletonNode then
                self.skeletonNode:removeFromParent()
            end
            self.skeletonNode = skeletonNode
        else
            -- local txt_num = obj:getChildAutoType("txt_num")
            -- txt_num:setText("X" .. configInfo.reward[1].amount)
            local goodsItem = obj:getChildAutoType("itemCell")
            local itemcell = BindManager.bindItemCell(goodsItem)
            local award = configInfo.reward[1]
            itemcell:setData(award.code, award.amount, award.type)
            if stateInfo == 2 then
                itemcell:setIsHook(true)
            else
                itemcell:setIsHook(false)
            end
            --    itemcell:setFrameVisible(false)
            --    itemcell:setNoFrame(true)
            --    itemcell:setAmount( 0 )
            --    goodsItem:addClickListener(function( ... )
            -- 	   itemcell:onClickCell()
            --    end,100)
            local itemConfig = ItemConfiger.getInfoByCodeAndType(configInfo.reward[1].type, configInfo.reward[1].code)
            local txt_name = obj:getChildAutoType("txt_name")
            txt_name:setText(itemConfig.name)
        end
        local img_ani = obj:getChildAutoType("img_ani")
        if stateInfo == 1 then
            if not self.bossAnima[indexDay] then
                self.bossAnima[indexDay] = OperatingActivitiesModel:getEightDayAnim(img_ani)
                self.bossAnima[indexDay]:setScale(0.9,0.8)
            end
        else
            if self.bossAnima[indexDay] then
                SpineUtil.clearEffect(self.bossAnima[indexDay]) 
            end
        end
        local touch = obj:getChildAutoType("Btn_touch")
        touch:removeClickListener(101)
        if stateInfo == 1 then
            touch:addClickListener(
                function(...)
                    --RollTips.show("未达到领取条件11111111")
                    OperatingActivitiesModel:RecieveReward(indexDay)
                end,
                101
            )
        elseif stateInfo == 0 then
            touch:addClickListener(
                function(...)
                    RollTips.show(Desc.activity_txt8)
                end,
                101
            )
        elseif stateInfo == 2 then
            touch:addClickListener(
                function(...)
                    RollTips.show(Desc.activity_txt9)
                end,
                101
            )
        end
    end
end

function EightDayActView:getState(i)
    if not OperatingActivitiesModel.eightDayInfo or not OperatingActivitiesModel.eightDayInfo.dayCount then
        return 0
    end
    if i <= OperatingActivitiesModel.eightDayInfo.dayCount then
        local index = OperatingActivitiesModel:GetBitByIndex(OperatingActivitiesModel.eightDayInfo.recvMark, i)
        if index == 0 then
            --已开启未领取
            return 1
        else
            --已开启已领取
            return 2
        end
    else
        --未开启
        return 0
    end
end

--事件初始化
function EightDayActView:activity_eightdayActiveupdate(...)
    self:showItem()
end

--事件初始化
function EightDayActView:_initEvent(...)
    -- self.btn_rank:addClickListener(
    --     function(...)
    --     end
    -- )
end

--initEvent后执行
function EightDayActView:_enter(...)
    print(1, "EightDayActView _enter")
end

--页面退出时执行
function EightDayActView:_exit(...)
    SpineUtil.clearEffect(self.bossAnima)   
end

return EightDayActView
