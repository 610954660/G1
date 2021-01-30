
-- added by wyz 
-- 精灵召唤

local ElvesSummonView = class("ElvesSummonView",Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

local __ColorCfg = {
    [1] ="jlzh_lan",
    [2] ="jlzh_lan",
    [3] ="jlzh_lan",
    [4] ="jlzh_zi",
    [5] ="jlzh_cheng",
    [6] ="jlzh_hong",
}

function ElvesSummonView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesSummonView"

    self.txt_CumulateTimesTitle  = false
    self.txt_CumulateTimes  = false     -- 累计召唤次数
    self.progressBar        = {}
    self.item               = {}
    self.txt_itmeNum        = {}
    self.btn_oneTime        = false     -- 抽一次
    self.btn_tenTime        = false     -- 抽十次
    self.costItem_one       = false
    self.costItem_ten       = false 
    self.txt_haveTitle      = false
    self.itemIcon           = false
    self.txt_itemNum        = false
    self.txt_limitNum           = false
    self.effect_summon      = false
    self.lightSpine = false
    self.changjingSpineAct  = false
    self.eggSpineAct    = false
    self.changjingSpineStand    = false
    self.eggSpineStand  = false
end

function ElvesSummonView:_initUI()
    for i=1,3 do
        self.item[i]              = self.view:getChildAutoType("item"..i)
        self.progressBar[i]       = self.view:getChildAutoType("progressBar" ..i)     
        self.txt_itmeNum[i]       = self.view:getChildAutoType("txt_itmeNum" ..i)
    end

    self.txt_itemNum              = self.view:getChildAutoType("txt_itemNum")
    local itemIcon                 = self.view:getChildAutoType("itemIcon")
	self.itemIcon = BindManager.bindCostIcon(itemIcon)
    self.txt_haveTitle            = self.view:getChildAutoType("txt_haveTitle")
    self.txt_CumulateTimesTitle   = self.view:getChildAutoType("txt_CumulateTimesTitle")
    self.txt_CumulateTimes        = self.view:getChildAutoType("txt_CumulateTimes")
    self.btn_oneTime              = self.view:getChildAutoType("btn_oneTime")
    self.btn_tenTime              = self.view:getChildAutoType("btn_tenTime")
    self.costItem_one             = self.view:getChildAutoType("costItem_one")
    self.costItem_ten             = self.view:getChildAutoType("costItem_ten")
    self.txt_limitNum             = self.view:getChildAutoType("txt_limitNum")
    self.effect_summon            = self.view:getChildAutoType("effect_summon")

end

function ElvesSummonView:_initEvent()
    self.txt_CumulateTimesTitle:setText(Desc.ElvesSystem_cumulateTimesTitle)
    self.txt_haveTitle:setText(Desc.ElvesSystem_summonProHaveTitle) 
    self:playStand()
end

-- 播放抽奖特效
function ElvesSummonView:playLuckyDrawEffect(color)
    local colorName = __ColorCfg[color]
    -- 激光动画
    local effect_summon   = self.view:getChildAutoType("effect_summon")
    local x1 = effect_summon:getWidth() / 2;
    local y1 = effect_summon:getHeight() / 2;
    effect_summon:displayObject():removeAllChildren()
    self.lightSpine = SpineUtil.createSpineObj(effect_summon, cc.p(x1, y1), colorName, "Effect/UI", "jinglingzhaohuan_texiao", "jinglingzhaohuan_texiao", false);
    

     -- 蛋的动画
    local effect_egg_act    = self.view:getChildAutoType("effect_egg_act")
    x1 = effect_egg_act:getWidth() / 2;
    y1 = effect_egg_act:getHeight() / 2;
    effect_egg_act:displayObject():removeAllChildren()
    self.eggSpineAct = SpineUtil.createSpineObj(effect_egg_act, cc.p(x1, y1), "animation", "Effect/UI", "jinglingzhaohuan_dan", "jinglingzhaohuan_dan", false);

    -- 手臂的动画
    local effect_changjing_act = self.view:getChildAutoType("effect_changjing_act")
    local x1 = effect_changjing_act:getWidth() / 2;
    local y1 = effect_changjing_act:getHeight() / 2;
    effect_changjing_act:displayObject():removeAllChildren()
    self.changjingSpineAct = SpineUtil.createSpineObj(effect_changjing_act, cc.p(x1, y1), "animation", "Effect/UI", "jinglingzhaohuan_changjing", "jinglingzhaohuan_changjing", false);
    
end

function ElvesSummonView:removeDrawEffect()
    local effect_summon   = self.view:getChildAutoType("effect_summon")
    local effect_egg_act    = self.view:getChildAutoType("effect_egg_act")
    effect_summon:displayObject():removeAllChildren()
    effect_egg_act:displayObject():removeAllChildren()
    SpineUtil.clearEffect(self.eggSpineAct)
    SpineUtil.clearEffect(self.changjingSpineAct)
    SpineUtil.clearEffect(self.lightSpine)
end


-- 待机动画
function ElvesSummonView:playStand()
    -- 手臂待机动画
    local effect_changjing_stand = self.view:getChildAutoType("effect_changjing_stand")
    local x1 = effect_changjing_stand:getWidth() / 2;
    local y1 = effect_changjing_stand:getHeight() / 2;
    effect_changjing_stand:displayObject():removeAllChildren()
    self.changjingSpineStand = SpineUtil.createSpineObj(effect_changjing_stand, cc.p(x1, y1), "stand", "Effect/UI", "jinglingzhaohuan_changjing", "jinglingzhaohuan_changjing", true);

    -- 蛋待机动画
    local effect_egg_stand    = self.view:getChildAutoType("effect_egg_stand")
    x1 = effect_egg_stand:getWidth() / 2;
    y1 = effect_egg_stand:getHeight() / 2;
    effect_egg_stand:displayObject():removeAllChildren()
    self.eggSpineStand = SpineUtil.createSpineObj(effect_egg_stand, cc.p(x1, y1), "stand", "Effect/UI", "jinglingzhaohuan_dan", "jinglingzhaohuan_dan", true);
end

-- 隐藏待机动画
function ElvesSummonView:removeStand()
    local effect_changjing_stand = self.view:getChildAutoType("effect_changjing_stand")
    local effect_egg_stand    = self.view:getChildAutoType("effect_egg_stand")
    effect_egg_stand:displayObject():removeAllChildren()
    effect_changjing_stand:displayObject():removeAllChildren()
    SpineUtil.clearEffect(self.eggSpineStand)
    SpineUtil.clearEffect(self.changjingSpineStand)
end




function ElvesSummonView:ElvesSummonView_refreshPanal(_,params)
    local haveLimitNum      = ElvesSystemModel:getResidueNum()
    local limitMaxNum       = ElvesSystemModel.limitMaxNum
    local maxHistoryTimes = ModelManager.ElvesSystemModel.maxHistoryTimes
    local maxTimes     = ModelManager.ElvesSystemModel:getCumulateRewardMaxTimes()
    if haveLimitNum > 0 then
        self.txt_limitNum:setText(string.format(Desc.ElvesSystem_limitNum1,haveLimitNum,limitMaxNum))
    else
        self.txt_limitNum:setText(string.format(Desc.ElvesSystem_limitNum2,haveLimitNum,limitMaxNum))
    end

    local rewardData    = ModelManager.ElvesSystemModel:getCumulateReward(false)
    for i = 1,3 do
        local data1 = rewardData[i]
        if i == 1 then
            self.progressBar[i]:setMax(data1.times)
        else
            local data2 = rewardData[i-1]
            self.progressBar[i]:setMax(data1.times - data2.times)
        end
    end
    self:setProgress(maxHistoryTimes)
    

    print(8848,">>>maxHistoryTimes>>>",maxHistoryTimes)
    self:refreshCumulate()
    self.txt_CumulateTimes:setText(maxHistoryTimes)
    local img_redOne = self.btn_oneTime:getChildAutoType("img_red")
    RedManager.register("V_ELVES_SUMMOM".."_ONE", img_redOne)

    local summonPro    = DynamicConfigData.t_ElfSummonCost
    if summonPro then 
        summonPro = summonPro[1]
    end
    
    -- Desc.ElvesSystem_summonShopTips
    local costItem = summonPro.costItem
    local costDiamond = summonPro.costDiamond
    local buyExp   = summonPro.buyExp
    local summonFuncOne = function()
        local reqInfo = {
            type    = 1,
            num     = 1,
        }
        RPCReq.Elf_Summon(reqInfo,function(data)
            printTable(8848,">>>>>召唤一次的数据>>>>",data)
            ModelManager.ElvesSystemModel.summonElves = data.elf or {}
            ModelManager.ElvesSystemModel.summonReward = data.summon or {}
            ModelManager.ElvesSystemModel:setSummonData(data)
            -- self.progressBar:setValue(data.historyTimes)
            self.txt_CumulateTimes:setText(ModelManager.ElvesSystemModel.maxHistoryTimes)
            self:setProgress(ModelManager.ElvesSystemModel.maxHistoryTimes)
            self:refreshCumulate()
            ModelManager.ElvesSystemModel.summonElvesNum = #ModelManager.ElvesSystemModel.summonElves
            
            local viewInfo = ViewManager.getViewInfo("ElvesSystemBaseView")
            local elvesInfo = viewInfo.window.elvesInfo
            local list_page = viewInfo.window.list_page
            local Click     = viewInfo.window.Click
            elvesInfo:setTouchable(false)
            list_page:setTouchable(false)
            Click:setVisible(true)
            local color = ElvesSystemModel:getElvesColor()
            self:playLuckyDrawEffect(color)
            self:removeStand()
            Scheduler.scheduleOnce(3.5,function() 
                if ModelManager.ElvesSystemModel.summonElvesNum > 0 then
                    ViewManager.open("ElvesGetView",{type = 1})
                elseif #ModelManager.ElvesSystemModel.summonReward > 0 then
                    RollTips.showReward(ModelManager.ElvesSystemModel.summonReward)
                    ModelManager.ElvesSystemModel.summonReward = {}
                end
                self:playStand()
                self:removeDrawEffect()
                elvesInfo:setTouchable(true)
                list_page:setTouchable(true)
                Click:setVisible(false)
            end)
        end)
    end

    local summonFuncTen = function()
        local reqInfo = {
            type    = 1,
            num     = 10,
        }
        RPCReq.Elf_Summon(reqInfo,function(data)
            -- printTable(8848,">>>>>召唤十次的数据>>>>",data)
            ModelManager.ElvesSystemModel:setSummonData(data)
            -- self.progressBar:setValue(data.historyTimes)
            ModelManager.ElvesSystemModel.summonElves = data.elf or {}
            ModelManager.ElvesSystemModel.summonReward = data.summon or {}
            self.txt_CumulateTimes:setText(data.maxHistoryTimes)
            self:setProgress(ModelManager.ElvesSystemModel.maxHistoryTimes)
            self:refreshCumulate()
            ModelManager.ElvesSystemModel.summonElvesNum = #ModelManager.ElvesSystemModel.summonElves
           
            local viewInfo = ViewManager.getViewInfo("ElvesSystemBaseView")
            local elvesInfo = viewInfo.window.elvesInfo
            local list_page = viewInfo.window.list_page
            local Click     = viewInfo.window.Click
            elvesInfo:setTouchable(false)
            list_page:setTouchable(false)
            Click:setVisible(true)
            local color = ElvesSystemModel:getElvesColor()
            self:playLuckyDrawEffect(color)
            self:removeStand()
            Scheduler.scheduleOnce(3.5,function() 
                if ModelManager.ElvesSystemModel.summonElvesNum > 0 then
                    for k,v in pairs(data.elf) do
                        local reward = {
                            type = 3,
                            code = v,
                            amount = 1,
                        }
                        table.insert(ModelManager.ElvesSystemModel.summonReward,reward)
                    end
                    ViewManager.open("ElvesGetView",{type = 1})
                elseif #ModelManager.ElvesSystemModel.summonReward > 0 then
                    RollTips.showReward(ModelManager.ElvesSystemModel.summonReward)
                    ModelManager.ElvesSystemModel.summonReward = {}
                end
                self:playStand()
                self:removeDrawEffect()
                elvesInfo:setTouchable(true)
                list_page:setTouchable(true)
                Click:setVisible(false)
            end)
        end)
    end

     -- 背包中物品数量
	local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(costItem[1].code)
    self.btn_oneTime:removeClickListener(888)
    self.btn_oneTime:addClickListener(function()
        if hasNum < 1 and haveLimitNum > 0  then
            local costList ={
                {type = GameDef.GameResType.Money, code = 2, amount=1*costDiamond[1].amount}
            }
            if not PlayerModel:isCostEnough(costList, false) then
                RollTips.show(Desc.ElvesSystem_limitNum4)
                return
            end
            local info = {}
            info.text = string.format(Desc.ElvesSystem_summonShopTips,costDiamond[1].amount*1,buyExp[1].amount*1,1)
            info.type = "yes_no"
            info.onYes = summonFuncOne
            Alert.show(info);
        else
            if hasNum < 1 then
                RollTips.show(Desc.ElvesSystem_limitNum3)
                return
            end
            summonFuncOne()
        end
    end,888)

    local img_redTen = self.btn_tenTime:getChildAutoType("img_red")
    RedManager.register("V_ELVES_SUMMOM".."_TEN", img_redTen)

    self.btn_tenTime:removeClickListener(888)
    self.btn_tenTime:addClickListener(function()
        if hasNum < 10 and haveLimitNum >= 10 then
            local costList ={
                {type = GameDef.GameResType.Money, code = 2, amount=10*costDiamond[1].amount}
            }
            if not PlayerModel:isCostEnough(costList, false) then
                RollTips.show(Desc.ElvesSystem_limitNum4)
                return
            end
            local info = {}
            info.text = string.format(Desc.ElvesSystem_summonShopTips,costDiamond[1].amount*10,buyExp[1].amount*10,10)
            info.type = "yes_no"
            info.onYes = summonFuncTen
            Alert.show(info);
        else
            if hasNum < 10 then
                RollTips.show(Desc.ElvesSystem_limitNum3)
                return
            end
            summonFuncTen()
        end
    end,888)
end

function ElvesSummonView:setProgress(maxHistoryTimes)
    local rewardData        = ModelManager.ElvesSystemModel:getCumulateReward(false)
    local canRewardTimes    = ModelManager.ElvesSystemModel.summonCanRewardTimes
    local historyTimes      = ModelManager.ElvesSystemModel.summonHistoryTimes
    for i = 1,3 do
        local data1 = rewardData[i]
        if i == 1 then
            if canRewardTimes > 0 then
                self.progressBar[i]:setValue(data1.times)
            else
                if historyTimes >= data1.times then
                    self.progressBar[i]:setValue(data1.times)
                else
                    self.progressBar[i]:setValue(historyTimes)
                end
            end
        else
            local data2 = rewardData[i-1]
            if canRewardTimes > 0 then
                self.progressBar[i]:setValue(data1.times)
            else
                if (historyTimes-data2.times) >= data1.times then
                    self.progressBar[i]:setValue(data1.times)
                else
                    self.progressBar[i]:setValue(historyTimes - data2.times)
                end
            end
        end
    end
end

function ElvesSummonView:refreshCumulate()
    local summonPro    = DynamicConfigData.t_ElfSummonCost
    if summonPro then 
        summonPro = summonPro[1]
    end
    local haveLimitNum      = ElvesSystemModel:getResidueNum()
    local limitMaxNum       = ElvesSystemModel.limitMaxNum
    
    local costItem = summonPro.costItem
    local costDiamond = summonPro.costDiamond
     -- 背包中物品数量
	local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(costItem[1].code)
	self.txt_itemNum:setText("X" .. hasNum)
   -- local url 			= ItemConfiger.getItemIconByCode(costItem[1].code, costItem[1].type)
    self.itemIcon:setData(costItem[1].type, costItem[1].code)

    local costItem_one = BindManager.bindCostItem(self.costItem_one)
    if hasNum < 1 and haveLimitNum > 0 then
        costItem_one:setData(costDiamond[1].type,costDiamond[1].code,costDiamond[1].amount * 1,true)
    else
        costItem_one:setData(costItem[1].type,costItem[1].code,costItem[1].amount,true)
    end

    local costItem_ten = BindManager.bindCostItem(self.costItem_ten)
    if hasNum < 10 and haveLimitNum >=10 then
        costItem_ten:setData(costDiamond[1].type,costDiamond[1].code,costDiamond[1].amount * 10,true)
    else
        costItem_ten:setData(costItem[1].type,costItem[1].code,costItem[1].amount * 10,true)
    end

    
    local maxHistoryTimes   = ModelManager.ElvesSystemModel.maxHistoryTimes
    local canRewardTimes    = ModelManager.ElvesSystemModel.summonCanRewardTimes
    local historyTimes      = ModelManager.ElvesSystemModel.summonHistoryTimes
    local recvMark          = ModelManager.ElvesSystemModel.summonRewardMark
    local rewardData        = ModelManager.ElvesSystemModel:getCumulateReward(false)
    print(8848,">>.maxHistoryTimes>>",maxHistoryTimes,">>>canRewardTimes>>",canRewardTimes,">>historyTimes>>",historyTimes,">>recvMark>>",recvMark)
    for i=1,3 do
        local data1  = rewardData[i]
        local reward = data1.reward[1]
        local item      = self.item[i]
        local txt_itmeNum = self.txt_itmeNum[i]
        local takeCtrl  = item:getController("takeCtrl")
        local txt_num   = item:getChildAutoType("txt_num")
        txt_num:setText("X" .. reward.amount)
        txt_itmeNum:setText(data1.times)
        local itemCell  = BindManager.bindItemCell(item:getChildAutoType("itemCell"))
        itemCell:setData(reward.code, reward.amount, reward.type)
        itemCell.txtNum:setVisible(false)
        local flag = bit.band(recvMark, bit.lshift(1, i-1)) > 0

        item:getChildAutoType("itemCell"):setTouchable(false)
        if flag then    -- 已领取
            takeCtrl:setSelectedIndex(2)
        else
            if canRewardTimes > 0 then
                takeCtrl:setSelectedIndex(1)
            else
                takeCtrl:setSelectedIndex((historyTimes >= data1.times) and 1 or 0)
            end
        end

        item:removeClickListener(11)
        item:addClickListener(function(context)
            context:stopPropagation()
            if takeCtrl:getSelectedIndex() == 0 then
                RollTips.show(Desc.ElvesSystem_summonNoRewardTips1)
                return
            elseif takeCtrl:getSelectedIndex() == 2 then
                RollTips.show(Desc.ElvesSystem_summonNoRewardTips2)
                return
            end
            local reqInfo = {
                type = 1,
                index = i,
            }
            RPCReq.Elf_ReceiveSummonReward(reqInfo,function(params)
                printTable(8848,">>.params>>",params)
                ModelManager.ElvesSystemModel.summonRewardMark = params.data.rewardMark or 0
                ModelManager.ElvesSystemModel:setSummonData(params.data,true)
                -- self:refreshCumulate()
            end)
        end,11)
    end
end

return ElvesSummonView