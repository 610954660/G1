---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: 资源找回次数界面
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local RetrieveChooseView, Super = class("RetrieveChooseView", Window)
function RetrieveChooseView:ctor()
    self._packName = "Retrieve"
    self._compName = "RetrieveChooseView"
    self._rootDepth = LayerDepth.PopWindow
    self.txt_allCost = false
    self.dslider = false
    self.txt_count = false
    self.btn_back = false
    self.btn_add = false
    self.btn_send = false
    self.curCount = 1
end

function RetrieveChooseView:_initUI()
    local viewRoot = self.view
    self.txt_allCost = viewRoot:getChild("txt_allCost")
    self.dslider = viewRoot:getChildAutoType("$dslider")
    self.txt_count = self.dslider:getChildAutoType("txt_count")
    self.btn_back = viewRoot:getChildAutoType("$btn_back")
    self.btn_add = viewRoot:getChildAutoType("$btn_add")
    self.btn_send = viewRoot:getChildAutoType("btn_send")
    local configType = DynamicConfigData.t_Retrieve
    local txt_name = viewRoot:getChildAutoType("txt_name")
    txt_name:setText(configType[self._args.taskType][1].name)
    local txt_desc = viewRoot:getChildAutoType("txt_desc")
    local servserInfo = RetrieveModel:getRetrieveInfo()
    local serVerItem = servserInfo[self._args.taskType]
    local rerwardNum = #serVerItem.ids
    local vipCount = rerwardNum - serVerItem.normalTimes
    if vipCount <= 0 then
        vipCount = 0
    end
    txt_desc:setText(
        string.format(
            DescAuto[231], -- [231]="(可找回%s次,VIP%s额外+%s次)"
            ColorUtil.formatColorString1(rerwardNum, "#119717"),
            serVerItem.vipLv,
            ColorUtil.formatColorString1(vipCount or 0, "#119717")
        )
    )
    self:showSlider()
end

function RetrieveChooseView:showSlider()
    local servserInfo = RetrieveModel:getRetrieveInfo()
    local serVerItem = servserInfo[self._args.taskType]
    local costInfo = RetrieveModel:getRetruveChooseCost(serVerItem.ids, self._args.costType, self.curCount) --当前选择的消耗
    local costType = 1
    if self._args.costType == 0 then --金币
        costType = 1
    else
        costType = 2
    end

    local isEnough =
        PlayerModel:checkCostEnough(
        {type = costInfo[1].type, code = costInfo[1].code, amount = costInfo[1].amount},
        false
    )
    local color = "#119717"
    if not isEnough then
        color = "#F43636"
    end
    local str =
        string.format(
        DescAuto[232], -- [232]="总价%s%s"
        GMethodUtil.getRichTextMoneyImgStr(costType),
        ColorUtil.formatColorString1(MathUtil.toSectionStr(costInfo[1].amount), color)
    )
    self.txt_allCost:setText(str)
    local max = #serVerItem.ids
    if self.curCount >= max then
        self.curCount = max
    end
    self.txt_count:setText(string.format(DescAuto[233], ColorUtil.formatColorString1(self.curCount, "#119717"))) -- [233]="找回%s次"
    local function onChanged(...)
        self.curCount = math.floor(self.dslider:getValue())
        if self.curCount >= max then
            self.curCount = max
        end
        self.dslider:setValue(self.curCount)
        self.txt_count:setText(string.format(DescAuto[233], ColorUtil.formatColorString1(self.curCount, "#119717"))) -- [233]="找回%s次"
        self:setAllcostText(serVerItem)
    end
    self.dslider:addEventListener(FUIEventType.Changed, onChanged, 100)
    self.dslider:setMax(max)
    self.dslider:setValue(self.curCount)
end

function RetrieveChooseView:_initEvent(...)
    local servserInfo = RetrieveModel:getRetrieveInfo()
    local serVerItem = servserInfo[self._args.taskType]
    local max = #serVerItem.ids
    if self.curCount >= max then
        self.curCount = max
    end
    self.btn_add:addClickListener(
        function()
            self.curCount = math.floor(self.dslider:getValue()) + 1
            if self.curCount >= max then
                self.curCount = max
            end
            self.dslider:setValue(self.curCount)
            self.txt_count:setText(string.format(DescAuto[233], ColorUtil.formatColorString1(self.curCount, "#119717"))) -- [233]="找回%s次"
            self:setAllcostText(serVerItem)
        end,
        99
    )
    self.btn_back:addClickListener(
        function()
            self.curCount = math.floor(self.dslider:getValue()) - 1
            if self.curCount <= 1 then
                self.curCount = 1
            end
            self.dslider:setValue(self.curCount)
            self.txt_count:setText(string.format(DescAuto[233], ColorUtil.formatColorString1(self.curCount, "#119717"))) -- [233]="找回%s次"
            self:setAllcostText(serVerItem)
        end,
        99
    )

    self.btn_send:addClickListener(
        function()
            local costType = false
            if self._args.costType == 0 then
                costType = true
            else
                costType = false
            end
            if #serVerItem.ids== self.curCount then
                if RetrieveModel.lastRewardMap[self._args.taskType]==nil then
                    RetrieveModel.lastRewardMap[self._args.taskType]={}
                end
                RetrieveModel.lastRewardMap[self._args.taskType]={}
                RetrieveModel.lastRewardMap[self._args.taskType]= RetrieveModel:LastsetRetrueveReward(serVerItem.ids, self._args.costType)
            end
            local costInfo = RetrieveModel:getRetruveChooseCost(serVerItem.ids, self._args.costType, self.curCount) --当前选择的消耗
            if next(costInfo) ~= nil then
                local isEnough =
                    PlayerModel:checkCostEnough(
                    {type = costInfo[1].type, code = costInfo[1].code, amount = costInfo[1].amount},
                    true
                )
                if isEnough then
                    RetrieveModel:RetrieveItem(self._args.taskType, costType, self.curCount)
                end
            else
                RetrieveModel:RetrieveItem(self._args.taskType, costType, self.curCount)
            end
            ViewManager.close("RetrieveChooseView")
        end,
        99
    )
end

function RetrieveChooseView:setAllcostText(serVerItem)
    local costType = 1
    if self._args.costType == 0 then --金币
        costType = 1
    else
        costType = 2
    end
    local costInfo = RetrieveModel:getRetruveChooseCost(serVerItem.ids, self._args.costType, self.curCount) --当前选择的消耗
    if next(costInfo) ~= nil then
        local isEnough =
            PlayerModel:checkCostEnough(
            {type = costInfo[1].type, code = costInfo[1].code, amount = costInfo[1].amount},
            false
        )
        local color = "#119717"
        if not isEnough then
            color = "#F43636"
        end
        local str =
            string.format(
            DescAuto[232], -- [232]="总价%s%s"
            GMethodUtil.getRichTextMoneyImgStr(costType),
            ColorUtil.formatColorString1(MathUtil.toSectionStr(costInfo[1].amount), color)
        )
        self.txt_allCost:setText(str)
    else
        local str = string.format(DescAuto[232], GMethodUtil.getRichTextMoneyImgStr(costType), MathUtil.toSectionStr(0)) -- [232]="总价%s%s"
        self.txt_allCost:setText(str)
    end
end

function RetrieveChooseView:_enter()
end

function RetrieveChooseView:_exit(...)
end

return RetrieveChooseView
