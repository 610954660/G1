--added by xhd
--道具框封裝
local ItemSkillCell = class("ItemSkillCell")
--local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function ItemSkillCell:ctor(view)
    self.view = view
    self.view:addEventListener(
        FUIEventType.Exit,
        function(context)
            self:__onExit()
        end
    )
    self.iconLoader = false
    --是否选中
    self.selectFrameImg = false
    --等级label
    self.__levelLabel = false
    -- --其余数据
    self._itemData = false
    --背景
    self.itembg = false
end

function ItemSkillCell:init(...)
    self.iconLoader = self.view:getChildAutoType("iconLoader")
    self.selectFrameImg = self.view:getChildAutoType("selectFrameImg")
    if self.selectFrameImg then
        self.selectFrameImg:setVisible(false)
    end
    self.__levelLabel = self.view:getChildAutoType("lv")
    self.itembg = self.view:getChildAutoType("cellbg")
    self.itembg:setVisible(false)
end

--道具框清空
function ItemSkillCell:setEmpty()
    -- body
end
--设置数据
function ItemSkillCell:setItemData(skillId, ...)
    if not skillId then
        return
    end
    self._itemData = ...;
    local skillInfo = DynamicConfigData.t_skill[skillId]
    if skillInfo then
        local skillurl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
        self:showIcon(skillurl)
        self:setSkillLevel(1)
    end
end

--设置数量
function ItemSkillCell:setSkillLevel(level)
    if level > 0 then
        self.__levelLabel:setText(level)
    else
        self.__levelLabel:setText("")
    end
end

--提供接口强行更改icon的方法
function ItemSkillCell:showIcon(url)
    self.iconLoader:setURL(url)
    self.iconLoader:setVisible(true)
end

function ItemSkillCell:setseleFrameVisible(bool)
    if bool then
        self.selectFrameImg:setVisible(true)
    else
        self.selectFrameImg:setVisible(false)
    end
end

function ItemSkillCell:onClickCell(data)
    --tips弹出
    if self._itemData then
        ViewManager.open("ItemTipsView",self._itemData)
    end
end

--退出操作 在close执行之前
function ItemSkillCell:__onExit()
end

return ItemSkillCell
