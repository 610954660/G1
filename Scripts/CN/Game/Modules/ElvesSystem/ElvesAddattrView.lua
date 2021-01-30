-- added by wyz
-- 精灵属性总览

local ElvesAddattrView = class("ElvesAddattrView",Window)

function ElvesAddattrView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesAddattrView"
    self._rootDepth = LayerDepth.PopWindow

    self.list_attr  = false -- 属性列表
end

function ElvesAddattrView:_initUI()
    self.list_attr  = self.view:getChildAutoType("list_attr")
end

function ElvesAddattrView:_initEvent()
    self:refreshPanal()
end


function ElvesAddattrView:refreshPanal()
    local attrData = ModelManager.ElvesSystemModel:getElvesAttr(true)
    --printTable(8848,">>>>>attrData>>>>",attrData)
    self.list_attr:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data = attrData[index]
        local txt_attrName = obj:getChild("txt_attrName")
        local txt_cur = obj:getChild("txt_cur")
        local iconLoader = obj:getChildAutoType("loader_attrIcon")
        if not data.type then
            data.type = index
        end
        iconLoader:setURL(PathConfiger.getFightAttrIcon(data.type))
        txt_attrName:setText(ModelManager.CardLibModel.cardAttrName[data.type])
        txt_cur:setText(" " .. data.value)
    end)
    self.list_attr:setData(attrData)
end

return ElvesAddattrView