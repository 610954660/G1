-- 帮助系统 特性帮助
-- added by xhd

local HelpTalentView, Super = class("HelpTalentView", Window)

function HelpTalentView:ctor()
    self._packName = "HelpSystem"
    self._compName = "HelpTalentView"
    self.curSelectId = 1
    self.quality =  3
    self.selectData = false
end

function HelpTalentView:_initUI() -- 推荐阵容
    self.c1 = self.view:getController("c1")
    self.channel1 = self.view:getChild("channel1")
    self.channel2 = self.view:getChild("channel2")
    self.wfdetail = self.view:getChildAutoType("wfdetail")
    self.list = self.view:getChildAutoType("list")
    self.name = self.view:getChildAutoType("name")
    self.txt_name = self.view:getChildAutoType("txt_name")
    self.txt_desc = self.view:getChildAutoType("txt_desc"):getChildAutoType("txt_desc")
    self.itemCell =  BindManager.bindItemCell(self.view:getChildAutoType("itemCell"))
    self.txt_bookName = self.view:getChildAutoType("txt_bookName")
    self.curTexing = self.view:getChildAutoType("curTexing")
    self._allSkillData = {}
    local heroSkill = DynamicConfigData.t_passiveSkill
    for key, value in pairs(heroSkill) do
        if value.learn == 1 then
            local quality = value.quality
            if (not self._allSkillData[quality]) then
                self._allSkillData[quality] = {}
            end
            table.insert(self._allSkillData[quality], value)
        end
    end
    TableUtil.sortByMap(self._allSkillData, {{key="learn",asc = true}})
    self:updateLeftDown()
end

--UI初始化
function HelpTalentView:_initEvent(...)
    self.channel1:addClickListener(
        function(...)
            self.c1:setSelectedIndex(0)
            self.curSelectId = 1
            self:updateLeftDown()
        end
    )

    self.channel2:addClickListener(
        function(...)
            self.curSelectId = 2
            self.c1:setSelectedIndex(1)
            self:updateLeftDown()
        end
    )

    self.wfdetail:setText(Desc.help_StrDesc17)
end

--更新列表
function HelpTalentView:updateLeftDown()
    if self.curSelectId == 1 then
        self.quality = 3
    end
    if self.curSelectId == 2 then
        self.quality = 5
    end
    local data = self._allSkillData[self.quality]
    self.list:setItemRenderer(function(idx, obj)
        self:upItem(idx, obj, data[idx + 1])
    end)
    self.list:setNumItems(#data)
    self.list:setSelectedIndex(0)
    self.selectData = data[1]
    self:updateRightPanel()
end

function HelpTalentView:upItem(idx, obj, data)
    local frame = obj:getChildAutoType("frame")
    local iconLoader = obj:getChildAutoType("iconLoader")
    local txt_name = obj:getChildAutoType("txt_name")
    local iconUrl = ModelManager.CardLibModel:getItemIconByskillId(data.icon)
    txt_name:setText(data.name)
    iconLoader:setIcon(iconUrl)
    -- obj:getController("corner"):setSelectedIndex(data.sortFlag)
    -- obj:getController("c1"):setSelectedIndex(data.recommand)
    obj:getController("showName"):setSelectedIndex(0)
    obj:removeClickListener(100)
    obj:addClickListener(function()
        self.selectData = data
        self.list:setSelectedIndex(idx)
        self:updateRightPanel()
    end,100)
end


function HelpTalentView:updateRightPanel()
    local index = self.list:getSelectedIndex() + 1
    local data = self._allSkillData[self.quality][index]
    self.txt_name:setText(data.name)
    self.txt_desc:setText(data.desc)
    self:updateCurTexing()
    local cost = data.learnCost[1]
    self.itemCell:setData(cost.code, 0, cost.type)
    local name = self.itemCell._itemData:getName()
    self.txt_bookName:setText(string.format( "%s *%s",name, cost.amount))

end

function HelpTalentView:updateCurTexing( ... )
    local frame = self.curTexing:getChildAutoType("frame")
    local iconLoader = self.curTexing:getChildAutoType("iconLoader")
    local txt_name = self.curTexing:getChildAutoType("txt_name")
    local iconUrl = ModelManager.CardLibModel:getItemIconByskillId(self.selectData.icon)
    txt_name:setText(self.selectData.name)
    iconLoader:setIcon(iconUrl)
    -- obj:getController("corner"):setSelectedIndex(data.sortFlag)
    -- obj:getController("c1"):setSelectedIndex(data.recommand)
    self.curTexing:getController("showName"):setSelectedIndex(0)
end


return HelpTalentView
