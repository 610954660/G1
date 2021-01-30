-- add by zn
-- 饰品技能预览

local JewelrySkillView = class("JewelrySkillView", Window);

function JewelrySkillView: ctor()
    self._packName = "Jewelry";
    self._compName = "JewelrySkillView";
    
    local conf = DynamicConfigData.t_JewelrySkill;
    self.data = {};
    for _, d in pairs(conf) do
        if (not self.data[d.skillLevel]) then
            self.data[d.skillLevel] = {};
        end
        table.insert(self.data[d.skillLevel], d);
    end
end

function JewelrySkillView: _initUI()
    local root = self;
    root.list_tab = self.view:getChildAutoType("list_tab");
    root.list_item = self.view:getChildAutoType("list_item");

    self.list_tab:setSelectedIndex(0);
    self.list_tab:addClickListener(function ()
        self:changeSkill(self.list_tab:getSelectedIndex() + 3);
    end)
    self:changeSkill(3);
    self:setBg("Jewelry.jpg")
end

function JewelrySkillView: changeSkill(type)
    local dataArr = self.data[type];
    self.list_item:setItemRenderer(function (idx, obj)
        local d = dataArr[idx + 1];
        local nameLab = obj:getChildAutoType("name")
        nameLab:setText(d.skillName);
        nameLab:setColor(ColorUtil.getItemColor(type));
        obj:getChildAutoType("desc"):setText(d.skillDesc);
        if (not obj.skillCell) then
            obj.skillCell = BindManager.bindSkillCell(obj:getChildAutoType("skillCell"));
        end
        local ultSkillurl = CardLibModel:getItemIconByskillId(d.skillId);
        obj.skillCell.iconLoader:setURL(ultSkillurl) --放了一张技能图片
    end)
    self.list_item:setNumItems(#dataArr);
end

return JewelrySkillView