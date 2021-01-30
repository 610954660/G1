-- added by wyz
-- 精灵召唤 概率说明

local ElvesSummonHelpView = class("ElvesSummonHelpView",Window)

function ElvesSummonHelpView:ctor()
    self._packName = "ElvesSystem"
    self._compName = "ElvesSummonHelpView"
    self._rootDepth = LayerDepth.PopWindow

    self.list_help = false
end

function ElvesSummonHelpView:_initUI()
    self.list_help = self.view:getChildAutoType("list_help")
end

function ElvesSummonHelpView:_initEvent()
    local helpData = DynamicConfigData.t_ElfShowRate
    self.list_help:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data = helpData[index]
        local txt_name = obj:getChildAutoType("txt_name")
        local txt_val = obj:getChildAutoType("txt_val")
        txt_name:setText(data.name)
        txt_val:setText(data.rate .. "%")
    end)
    self.list_help:setData(helpData)
end

return ElvesSummonHelpView