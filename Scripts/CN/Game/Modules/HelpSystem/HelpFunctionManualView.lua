-- added by wyz
-- 功能手册

local HelpFunctionManualView = class("HelpFunctionManualView",Window)

function HelpFunctionManualView:ctor()  
    self._packName = "HelpSystem"
    self._compName = "HelpFunctionManualView"
    self.list_func = false
end

function HelpFunctionManualView:_initUI()
    self.list_func = self.view:getChildAutoType("list_func")
end

function HelpFunctionManualView:_initEvent()
    self:refreshPanel() 
end

function HelpFunctionManualView:refreshPanel()
    local moduleCfg = DynamicConfigData.t_module
    local funcData = {}
    for k,v in pairs(moduleCfg) do
        if v.noteIsShow >0 then
            funcData[v.noteIsShow] = v
        end
    end
    local scollIndex = 1
    for i=1,#funcData do
        local data = funcData[i]
        local tips = ModuleUtil.getModuleOpenTips(data.id)
        if not tips then
            scollIndex = i
        end
    end

    self.list_func:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data  = funcData[index]
        local reward    = data.outPut or {}
        local bg    = obj:getChildAutoType("bg")
        local icon  = obj:getChildAutoType("icon")
        local txt_funcName  = obj:getChildAutoType("txt_funcName")
        local txt_conditionTitle  = obj:getChildAutoType("txt_conditionTitle")
        local txt_condition  = obj:getChildAutoType("txt_condition")
        local txt_funcDescTitle  = obj:getChildAutoType("txt_funcDescTitle")
        local txt_funcDesc  = obj:getChildAutoType("txt_funcDesc")
        local list_reward  = obj:getChildAutoType("list_reward")
        local txt_outputTitle  = obj:getChildAutoType("txt_outputTitle")
        local openState  = obj:getController("openState") -- 0 已解锁 1 未解锁
        local mInfo = DynamicConfigData.t_module[data.id]
        local desc  = ModuleUtil.getConditionTip2(mInfo)
        local tips = ModuleUtil.getModuleOpenTips(data.id)

        openState:setSelectedIndex((not tips) and 0 or 1)
        bg:setURL(PathConfiger.getFuncManualResource(data.picture))
        icon:setURL(PathConfiger.getFuncManualResource(data.icon))
        txt_funcName:setText(data.name)
        txt_funcDesc:setText(data.dec)
        txt_condition:setText(desc)
        if TableUtil.GetTableLen(reward) > 0 then
            list_reward:setItemRenderer(function(idx2,obj2)
                local index2 = idx2 + 1
                local rewardData = reward[index2]
                local itemCell = BindManager.bindItemCell(obj2)
                itemCell:setAmountVisible( rewardData.amount > 1  )
                itemCell:setData(rewardData.code,rewardData.amount,rewardData.type)
            end)
            list_reward:setData(reward)
        end

    end)
    self.list_func:setData(funcData)
    self.list_func:scrollToView(scollIndex-1,false,true)
end


return HelpFunctionManualView