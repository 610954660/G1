-- added by wyz
-- 精灵方案名称修改

local ElvesPlanEditBoxView = class("ElvesPlanEditBoxView",Window)

function ElvesPlanEditBoxView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesPlanEditBoxView"
    self._rootDepth = LayerDepth.PopWindow

    self.txt_edittext   = false -- 方案文本
    self.btn_cancel     = false
    self.btn_ok         = false
end

function ElvesPlanEditBoxView:_initUI()
    local txt_edittext   = self.view:getChildAutoType("txt_edittext")
	self.txt_edittext = BindManager.bindTextInput(txt_edittext)
    self.btn_cancel     = self.view:getChildAutoType("btn_cancel")
    self.btn_ok         = self.view:getChildAutoType("btn_ok")
end

function ElvesPlanEditBoxView:_initEvent()   
    self.btn_cancel:removeClickListener(888)
    self.btn_cancel:addClickListener(function()
        ViewManager.close("ElvesPlanEditBoxView")
    end,888)

    self.btn_ok:removeClickListener(888)
    self.btn_ok:addClickListener(function()
        self:refreshPanal()
        ViewManager.close("ElvesPlanEditBoxView")
    end,888)
    local planId = self._args.id 
    local data = ModelManager.ElvesSystemModel.planInfo[planId]
    self.txt_edittext:setText(data.name)
    self.txt_edittext:setMaxLength(6)
end

function ElvesPlanEditBoxView:refreshPanal()
    local planId = self._args.id 
    local allPlanData = ModelManager.ElvesSystemModel.planInfo
    local data = ModelManager.ElvesSystemModel.planInfo[planId]
    local nametext = self.txt_edittext:getText();
    --print(8848,"nametext = ",nametext)
    if nametext == data.name then
        -- RollTips.show(string.format(Desc.ElvesSystem_editNamesuccess,nametext))
    elseif nametext ~= "" then
        for k,v in pairs(allPlanData) do
            if nametext == v.name then
                RollTips.show(Desc.ElvesSystem_editHaveName)
                return
            end
        end
        local reqInfo = {
            id      = planId,
            name    = nametext,
        }
        RPCReq.Elf_SetPlanName(reqInfo,function(data)
            print(8848,">>>>>>>>方案名修改成功>>>>>>")
            ModelManager.ElvesSystemModel:setPlanName(nametext,planId)
            print(8848,">>>>>>>>>>planId>>>>>>",planId)
            Dispatcher.dispatchEvent(EventType.ElvesPlanView_refreshListPage,{id = planId})
        end)
    end
    

end

return ElvesPlanEditBoxView