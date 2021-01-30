
local VoidlandSkillBagView = class("VoidlandSkillBagView", Window)

function VoidlandSkillBagView:ctor()
    self._packName = "Voidland";
    self._compName = "VoidlandSkillBagView";
    self._rootDepth = LayerDepth.PopWindow;
end

function VoidlandSkillBagView:_initUI()
    local root = self;
    local rootView = self.view;
        root.list_skill = rootView:getChildAutoType("list_skill");
        root.btn_close = rootView:getChildAutoType("closeButton");
    self.btn_close:addClickListener(function()
        self:closeView();
    end)

    -- local data = VoidlandModel:getCurModeData();
    if (VoidlandModel.listSkillBag) then
        local list = VoidlandModel.listSkillBag;
        self.list_skill:setOpaque(false);
        self.list_skill:setItemRenderer(function(idx, obj)
            local skillId = list[idx + 1];
            local icon = obj:getChildAutoType("icon");
            local skillInfo = DynamicConfigData.t_skill[skillId]
            if skillInfo then
                -- local ultSkillurl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
                -- icon:setURL(ultSkillurl) --放了一张技能图片
                -- obj:getChildAutoType("txt_skillName"):setText(skillInfo.skillName);
                obj:getChildAutoType("txt_desc"):setText(skillInfo.showName);
            end
            local conf = DynamicConfigData.t_VoidlandSkill[skillId];
            if (conf) then
                local ultSkillurl = ModelManager.CardLibModel:getItemIconByskillId(conf.skillIcon)
                icon:setURL(ultSkillurl) --放了一张技能图片
                obj:getChildAutoType("txt_skillName"):setText(conf.name);
            end
            local ctrl = obj:getController("c1");
            ctrl:setSelectedIndex(conf.color);
        end)
        if (#list > 0) then
            self.list_skill:setNumItems(#list)
            self.view:getController("c1"):setSelectedIndex(1)
            return;
        end
    end
    self.view:getController("c1"):setSelectedIndex(0)
    
end

return VoidlandSkillBagView