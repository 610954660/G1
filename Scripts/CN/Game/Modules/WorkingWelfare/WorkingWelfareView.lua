local V, Super = class("WorkingWelfareView", Window)
local WorkingWelfareConfiger = require "Game.ConfigReaders.WorkingWelfareConfiger"
local ItemCell = require "Game.UI.Global.ItemCell"

function V:ctor()
    self._packName = "WorkingWelfare"
    self._compName = "WorkingWelfareView"
    self.txt_countDown = false
    self.list_item = false
    self.timer = false

    self.__orders = {
        [1] = 3,
        [2] = -math.huge,
        [3] = -math.huge,
        [4] = -math.huge,
        [5] = -math.huge,
        [6] = 1,
        [7] = 2,
    }

    self.__giftNames = {
        [1] = DescAuto[349], -- [349]="一"
        [2] = DescAuto[350], -- [350]="二"
        [3] = DescAuto[351], -- [351]="三"
        [4] = DescAuto[352], -- [352]="四"
        [5] = DescAuto[353], -- [353]="五"
        [6] = DescAuto[354], -- [354]="六"
        [7] = DescAuto[355], -- [355]="日"
    }
end

function V:_initUI()
    --
    --self.treasureBoxList = self.view:getChildAutoType("treasureBoxList")
    --self.treasureBoxList:setItemRenderer(function(index, view)
    --    self:__renderItem(index+1, view)
    --end)
    --self.treasureBoxList:setVirtual()

    for index = 1, 3 do
        local key = string.format("gift%d", index)
        self.view[key] = self.view:getChildAutoType(key)
    end

    --
    self:update()
end

function V:setClickListenerFor(view, listener)
    view:removeClickListener(0)
    view:addClickListener(listener, 0)
end

function V:__renderItem(index, view)
    local config = WorkingWelfareConfiger:getCurrentConfig()
    local nowDayOfWeek = WorkingWelfareModel:getCurrentDayOfWeek()
    local dayOfWeek = config.week[index]

    -- 礼包名
    view:getChildAutoType("tvName"):setText(string.format(DescAuto[356], self.__giftNames[dayOfWeek])) -- TODO -- [356]="周%s礼包"

    -- 奖励道具
    local rewardList = config[string.format("reward%d", dayOfWeek)]
    for index, reward in ipairs(rewardList) do
        local itemCell = view:getChildAutoType(string.format("itemCell%d", index))
        itemCell = BindManager.bindItemCell(itemCell)
		itemCell:setNameTextField(view:getChildAutoType("txt_name"..index))
		itemCell:setSkipNameColor(true)
        local itemData = ItemsUtil.createItemData({data = reward})
        itemCell:setItemData(itemData)
    end

    -- 按钮
    self:setClickListenerFor(view, function()
    end)

    -- 状态
    local status = view:getController("status")
    local got = WorkingWelfareModel:getRewardStatus(dayOfWeek) == 1
    local nowOrder = self.__orders[nowDayOfWeek]
    local order = self.__orders[dayOfWeek]
    if order == nowOrder then
        if got then
            -- 已领取
            status:setSelectedPage("got")
        else
            -- 可领取
            status:setSelectedPage("canBeGot")
            self:setClickListenerFor(view, function()
                WorkingWelfareModel:getReward(nowDayOfWeek)
            end)
        end
    elseif order < nowOrder then
        if got then
            -- 已领取
            status:setSelectedPage("got")
        else
            -- 已过期
            status:setSelectedPage("outOfDate")
        end
    elseif order > nowOrder then
        -- 明日开启
        if order == nowOrder + 1 then
            status:setSelectedPage("tomorrowOpen")
        else
            status:setSelectedPage("afterTomorrowOpen")
        end
    end
end

function V:_initEvent( )
    -- TODO
end

function V:working_welfare_activity_update()
    self:update()
end

function V:update()
    --
    local config = WorkingWelfareConfiger:getCurrentConfig()
    --self.treasureBoxList:setNumItems(#config.week)

    for index = 1, #config.week do
        local key = string.format("gift%d", index)
        self:__renderItem(index, self.view[key])
    end
end


function V:_exit()
    -- TODO
end

return V
