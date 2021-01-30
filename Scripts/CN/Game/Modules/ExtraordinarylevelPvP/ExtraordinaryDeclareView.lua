--Date :2020-12-30
--Author : generated by FairyGUI
--Desc :

local ExtraordinaryDeclareView, Super = class("ExtraordinaryDeclareView", Window)

function ExtraordinaryDeclareView:ctor()
    --LuaLog("ExtraordinaryDeclareView ctor")
    self._packName = "ExtraordinarylevelPvP"
    self._compName = "ExtraordinaryDeclareView"
    self._rootDepth = LayerDepth.PopWindow
end

function ExtraordinaryDeclareView:_initEvent()
end

function ExtraordinaryDeclareView:_initVM()
    local viewNode = self.view
    ---Do not modify following code--------
    --{autoFields}:ExtraordinarylevelPvP.ExtraordinaryDeclareView
	self.blackBg = viewNode:getChildAutoType('blackBg')--GButton
	self.c1 = viewNode:getController('c1')--Controller
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list_duanwei1 = viewNode:getChildAutoType('list_duanwei1')--GList
	self.list_duanwei2 = viewNode:getChildAutoType('list_duanwei2')--GList
	self.list_type = viewNode:getChildAutoType('list_type')--GList
 --{autoFieldsEnd}:ExtraordinarylevelPvP.ExtraordinaryDeclareView
    --Do not modify above code-------------
end

function ExtraordinaryDeclareView:_initListener()
    self.list_type:setItemRenderer(
        function(index, obj)
            local title = obj:getChildAutoType("title")
            if index == 0 then
                obj:setSelected(true)
                self:showList(0, self.list_duanwei1)
                title:setText("段位预览")
            else
                title:setText("段位继承")
            end
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    if index == 0 then
                        self:showList(0, self.list_duanwei1)
                        self.c1:setSelectedIndex(0)
                    else
                        self:showList(1, self.list_duanwei2)
                        self.c1:setSelectedIndex(1)
                    end
                end,
                100
            )
        end
    )
    self.list_type:setNumItems(2)
end

function ExtraordinaryDeclareView:showList(type, listObj)
    local listData = {}
    local config = DynamicConfigData.t_Levelrule
    if type == 0 then
        for i = 1, #config, 1 do
            local item = config[i]
            local levelName = item.levelName
            if levelName ~= "" then
                table.insert(listData, item)
            end
        end
    else
        for i = 1, #config, 1 do
            local item = config[i]
            local levelName = item.ResetLevel
            if levelName then
                table.insert(listData, item)
            end
        end
    end

    listObj:setItemRenderer(
        function(index, obj)
            local itemInfo = listData[index + 1]
            if type == 0 then
                local img_duanwei = obj:getChildAutoType("img_duanwei")
                img_duanwei:setURL(string.format("%s%s.png", "Icon/ExtraordinaryLevel/dan", itemInfo.showInherit))
                local txt_desc = obj:getChildAutoType("txt_desc")
                txt_desc:setText(itemInfo.levelName)
            else
                local yuantext = ExtraordinarylevelPvPModel:getDanChinese(itemInfo.level)
                local resetTxt = ExtraordinarylevelPvPModel:getDanChinese(itemInfo.ResetLevel)
                local txt_desc1 = obj:getChildAutoType("txt_desc1")
                local txt_desc2 = obj:getChildAutoType("txt_desc2")
                txt_desc1:setText(yuantext)
                txt_desc2:setText(resetTxt)
            end
        end
    )
    listObj:setNumItems(#listData)
end

function ExtraordinaryDeclareView:_initUI()
    self:_initVM()
    self:_initListener()
end

return ExtraordinaryDeclareView