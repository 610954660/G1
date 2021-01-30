local ItemTipsTacticalView = class("ItemTipsTacticalView", Window)
--local ItemCell = require "Game.UI.Global.ItemCell"

function ItemTipsTacticalView:ctor(args)
    self._packName = "ToolTip"
    self._compName = "ItemTipsTacticalView"
    self._rootDepth = LayerDepth.AlertWindow
    self.data = self._args.id
    printTable(1,self.data)
end

function ItemTipsTacticalView:_initUI( ... )
   self:updateInfo(self.data)
end

--更新信息面板
function ItemTipsTacticalView:updateInfo(tactical)
    local level = ModelManager.TacticalModel:getTacticalLevel(tactical)
    local unlockInfo = DynamicConfigData.t_TacticalUnlock[tactical]
    local allInfo = DynamicConfigData.t_Tactical[tactical]
    local info = allInfo[level + 1]
    local upgradeInfo = DynamicConfigData.t_TacticalUpgrade[tactical][level + 1]

    local txt_name = self.view:getChildAutoType("txt_name")
    local txt_desc = self.view:getChildAutoType("txt_desc")
    local list_attr = self.view:getChildAutoType("list_attr")
    local loader_icon = self.view:getChildAutoType("icon_loader")
    local txt_zfPanel = self.view:getChildAutoType("txt_zfPanel")

    loader_icon:setURL(PathConfiger.getTacticalBigIcon(tactical))	
    txt_name:setText(unlockInfo.name)
    txt_desc:setText(unlockInfo.describe1)
    txt_zfPanel:getChildAutoType("name"):setText(unlockInfo.describe)
    txt_zfPanel:getController("c1"):setSelectedIndex(tactical)
    local isActived = ModelManager.TacticalModel:isActived(tactical)

    list_attr:setItemRenderer(
        function(index, obj)
            local name = obj:getChildAutoType("name")
            name:setText(string.format(Desc.tactical_pos, (index)))
            local desc_txt =  obj:getChildAutoType("txt_desc")
            desc_txt:setText(allInfo[index].UpgradeDescribe)
            if index <= level then
                name:setColor(cc.c3b(16,151,23))
                desc_txt:setColor(cc.c3b(16,151,23))
            else
                name:setColor(cc.c3b(116,130,142))
                desc_txt:setColor(cc.c3b(116,130,142))
            end
        end)
    list_attr:setNumItems(6)
end

-- [子类重写] 准备事件
function ItemTipsTacticalView:_initEvent( ... )

end

-- [子类重写] 添加后执行
function ItemTipsTacticalView:_enter()
    -- TODO
end

-- [子类重写] 移除后执行
function ItemTipsTacticalView:_exit()
    -- TODO
end

return ItemTipsTacticalView