-- 帮助系统  阵法帮助
-- added by xhd
local HelpTacticalView, Super = class("HelpTacticalView", Window)

function HelpTacticalView:ctor()
    self._packName = "HelpSystem"
    self._compName = "HelpTacticalView"
    self.config = false
    self.curSelectTid = false
end

function HelpTacticalView:_initUI() -- 推荐阵容
    self.c1 = self.view:getController("c1")
    self.channel1 = self.view:getChild("channel1")
    self.channel2 = self.view:getChild("channel2")
    self.channel3 = self.view:getChild("channel3")
    self.zfList = self.view:getChildAutoType("zfList")
    self.name = self.view:getChildAutoType("name")
    self.zType = self.view:getChildAutoType("zType")
    self.zfDetail = self.view:getChildAutoType("zfDetail")
    self.list_attr = self.view:getChildAutoType("list_attr")
    for i = 1, 6 do
       self["posAttr"..i] = self.view:getChildAutoType("posAttr"..i)
    end
end

--UI初始化
function HelpTacticalView:_initEvent(...)
    self.channel1:addClickListener(
        function(...)
            self.c1:setSelectedIndex(0)
            self:changePage(1)
        end
    )

    self.channel2:addClickListener(
        function(...)
            self.c1:setSelectedIndex(1)
            self:changePage(2)
        end
    )

    self.channel3:addClickListener(
        function(...)
            self.c1:setSelectedIndex(2)
            self:changePage(3)
        end
    )
    

    self.zfList:setItemRenderer(function(index, obj2)
        local obj = obj2:getChildAutoType("taticalCell")
        local indexArr = self.zfList._dataTemplate
        local config = DynamicConfigData.t_TacticalUnlock[indexArr[index+1]]
        local iconLoader = obj:getChildAutoType("iconLoader")
        local path = PathConfiger.getTacticalIcon(config.tactical)
        iconLoader:setURL(path)
        if config.tactical == self.curSelectTid then
            obj2:setSelected(true)
            self:updatePanel()
        else
            obj2:setSelected(false)
        end
        obj:removeClickListener(100)
        obj:addClickListener(
            function(...)
                self.curSelectTid = config.tactical
                self:updatePanel()
        end,100)
    end)

    self.list_attr:setItemRenderer(
        function(index, obj)
            local config = DynamicConfigData.t_Tactical[self.curSelectTid][index]
			local name = obj:getChildAutoType("name")
			name:setText(string.format(Desc.tactical_pos, (index)))
			local desc_txt =  obj:getChildAutoType("txt_desc")
			desc_txt:setText(config.UpgradeDescribe)
    end)
        
    self:changePage(1)

end

--更新页面
function HelpTacticalView:changePage( index )
    self.config  = DynamicConfigData.t_TacticalUnlock
    local indexArr = {}
    if index == 1 then
        indexArr = {1,2,3,4}
    elseif index == 2 then
        indexArr = {5,6,7}
    elseif index == 3 then
        indexArr = {8,9,10}
    end
    -- if not self.curSelectTid then
        self.curSelectTid = indexArr[1]
    -- end
    self.zfList:setData(indexArr)
end

function HelpTacticalView:updatePanel()
    self:updateLeftDown()
    self:updateRight()
end

function  HelpTacticalView:updateLeftDown( ... )
    local config  = self.config[self.curSelectTid]
    self.name:setText(config.name)
    self.zType:setText(config.describe)
    self.zfDetail:setText(config.describe1)
    local allInfo = DynamicConfigData.t_Tactical[self.curSelectTid]
    local num = 0 
    for k,v in pairs(allInfo) do
        num = num + 1
    end
    self.list_attr:setNumItems(num)
end

function  HelpTacticalView:updateRight( ... )
    local allInfo = DynamicConfigData.t_Tactical[self.curSelectTid]
    for i = 1, 6 do
        local config = allInfo[i-1]
        local pos = self["posAttr"..i]:getChildAutoType("pos")
        local num = self["posAttr"..i]:getChildAutoType("num")
        local str = config["standDescribe"..i]
        local arr =  StringUtil.lua_string_split(str, "color")
        str = arr[1]
        str = string.sub(str,1,-2)
        pos:setText(str)
        num:setText(i)
    end
end
return HelpTacticalView
