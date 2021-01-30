-- added by wyz
-- 无尽试炼二级入口  当同时显示俩个入口时 进入该界面

local EndlessTrialSecondView = class("EndlessTrialSecondView",Window)

function EndlessTrialSecondView:ctor()
    self._packName = "EndlessTrial"
    self._compName = "EndlessTrialSecondView"

    self.btn_synEndless 	= false 	-- 综合试炼按钮
	self.btn_otherEndless 	= false 	-- 其它试炼按钮
end

function EndlessTrialSecondView:_initUI()
    self.btn_synEndless 	= self.view:getChildAutoType("btn_synEndless")
	self.btn_otherEndless 	= self.view:getChildAutoType("btn_otherEndless")
end

function EndlessTrialSecondView:_initEvent()
    self:setBg("endlessTrialBg1.jpg")
    self:refreshPanal()
end

function EndlessTrialSecondView:refreshPanal()
    EndlessTrialModel:getAllCards()
    local trialAllData 		= EndlessTrialModel.trialAllData
	local trialSynthData 	= EndlessTrialModel:getTrialDataByType(GameDef.TopChallengeType.Common) -- 获取综合试炼数据 
    local rewardData 		= EndlessTrialModel:getRewardDataByType(GameDef.TopChallengeType.Common)
    
    -- 综合试炼入口
    local txt_synGateNum = self.btn_synEndless:getChildAutoType("txt_gateNum") 	-- 通关数文本显示
    local currentMaxLv = trialSynthData.maxLevel >= 200 and #rewardData or 200  -- 当前最大关卡

    local btn_synEndlessIcon 			= self.btn_synEndless:getChildAutoType("icon") 
    btn_synEndlessIcon:setURL("Icon/endlessTrial/race".. GameDef.TopChallengeType.Common ..".png")
    
    txt_synGateNum:setText(string.format("%s[color=#ffffff]/%s[/color]",trialSynthData.maxLevel,currentMaxLv))
    self.btn_synEndless:setTitle(Desc.EndlessTrial_type_1)
    self.btn_synEndless:removeClickListener(111)
    self.btn_synEndless:addClickListener(function()
        EndlessTrialModel:setTrialType(trialSynthData.type)
        ModuleUtil.openModule(ModuleId.EndlessTrial.id,true,{trialType = trialSynthData.type})
    end,111)

    -- 其它试炼入口
    local otherTypeCtrl 		= self.btn_otherEndless:getController("typeCtrl") 	-- 控制icon显示
	local txt_otherGateNum 		= self.btn_otherEndless:getChildAutoType("txt_gateNum")
	local raceType 				= trialAllData.raceType
	local trialOtherData 		= EndlessTrialModel:getTrialDataByType(raceType)
    local rewardData 			= EndlessTrialModel:getRewardDataByType(raceType)
    -- otherTypeCtrl:setSelectedIndex(raceType)

    local raceIcon 			= self.btn_otherEndless:getChildAutoType("icon") 
    raceIcon:setURL("Icon/endlessTrial/race".. raceType ..".png")
    
    txt_otherGateNum:setText(string.format("%s[color=#ffffff]/%s[/color]",trialOtherData.maxLevel,#rewardData))
    self.btn_otherEndless:removeClickListener(111)
    self.btn_otherEndless:addClickListener(function()
        EndlessTrialModel:setTrialType(trialOtherData.type)
        ModuleUtil.openModule(ModuleId.EndlessTrial.id,true,{trialType = trialOtherData.type})
    end,111)
    self:setOtherTrialTitle(raceType)
end

function EndlessTrialSecondView:EndlessTrial_refreshMainViewPanel()
    self:refreshPanal()
end

-- 设置试炼按钮标题
function EndlessTrialSecondView:setOtherTrialTitle(trialType)
	self.btn_otherEndless:setText(Desc["EndlessTrial_type_" .. trialType])
end

return EndlessTrialSecondView