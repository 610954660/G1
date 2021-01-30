-- 帮助系统 圣器帮助
-- added by xhd

local HelpHallowView, Super = class("HelpHallowView", Window)

function HelpHallowView:ctor()
    self._packName = "HelpSystem"
    self._compName = "HelpHallowView"
    self.curSelectTid = 0
    self.curSkillId = false
end

function HelpHallowView:_initUI() -- 推荐阵容
   self.hallowList = self.view:getChildAutoType("hallowList")
   local comp = self.view:getChildAutoType("comp")
   self.loader_icon = comp:getChildAutoType("loader_icon")
   self.loader_effect = comp:getChildAutoType("loader_effect")
   self.name = self.view:getChildAutoType("name")
   self.detail = self.view:getChildAutoType("detail/detail")
   self.list_skill = self.view:getChildAutoType("list_skill")
--    self.skillDetail = self.view:getChildAutoType("skillDetail")
   self.btn_help = self.view:getChildAutoType("btn_help")
   self.imgLoader = self.view:getChildAutoType("imgLoader")
end

--UI初始化
function HelpHallowView:_initEvent(...)
    self.btn_help:removeClickListener()
    self.btn_help:addClickListener(function()
        local info={}
		info['title']=Desc["help_StrTitle141"]
		info['desc']=Desc["help_StrDesc141"]
		ViewManager.open("GetPublicHelpView",info) 
    end)
    self.list_skill:setItemRenderer(function (idx, obj)
        local allSkill = self.list_skill._dataTemplate
        local skillObj = obj:getChildAutoType("skillCell")
        local title = obj:getChildAutoType("title")
        local skillDetail = obj:getChildAutoType("skillDetail")
        if (not obj.skillCell) then
            obj.skillCell = BindManager.bindSkillCell(skillObj);
        end
        local skillId = allSkill[idx + 1];
        obj.skillCell:setData(skillId);
        local lockCtrl = skillObj:getController("lockCtrl");
        lockCtrl:setSelectedIndex(0);
        local nameCtrl = skillObj:getController("c1");
        nameCtrl:setSelectedIndex(0);
        local selectFrameImg = skillObj:getChildAutoType("selectFrameImg");
        selectFrameImg:setVisible(true)
        local config  = DynamicConfigData.t_buff[skillId]
        local skillConfig =  DynamicConfigData.t_skill[skillId]
        skillDetail:setText(config.buffDescribe)
        title:setText(skillConfig.skillName)

        local id = 0;
        -- local lv = false

        -- id = math.floor(skillId / 10) * 10 + 1;
        -- obj.skillCell:showSkillName()
         -- local txt_name = skillObj:getChildAutoType("itemName");
        -- txt_name:setColor(ColorUtil.textColor.white)

        obj.skillCell.view:removeClickListener();
        obj.skillCell.view:addClickListener(function ()
            self.curSkillId = skillId
            local info = {codeType = CodeType.SKILL, id = self.curSkillId,activeLv =3}
            ViewManager.open("ItemTips", info)
        end)
        if not self.curSkillId then
            self.curSkillId = skillId
            skillObj:setSelected(true)
        else
            skillObj:setSelected(false)
        end
    end)

    self.hallowList:setItemRenderer(
       function(index, obj) 
          local loader_icon = obj:getChildAutoType("loader_icon")
          loader_icon:setURL(string.format("UI/Hallow/hallow%s.png", index+1))
          if index+1 == self.curSelectTid then
            obj:setSelected(true)
            self:updatePanel()
        else
            obj:setSelected(false)
        end
        obj:removeClickListener(100)
        obj:addClickListener(
            function(...)
                self.curSelectTid = index + 1
                self:updatePanel()
        end,100)
    end
    )
    self.curSelectTid = 1
    self.hallowList:setNumItems(5)
end

--更新面板
function HelpHallowView:updatePanel()
    local textArr = {DescAuto[162],DescAuto[163],DescAuto[164],DescAuto[165],DescAuto[166]} -- [162]="神族圣器" -- [163]="魔族圣器" -- [164]="兽族圣器" -- [165]="人族圣器" -- [166]="械族圣器"
    self.name:setText(textArr[self.curSelectTid])
    local txt = DynamicConfigData.t_HallowHelpDesc[self.curSelectTid].desc
    local iconURL = PathConfiger.getCardCategoryColor(self.curSelectTid)
    -- txt = "<img src='"..iconURL.."' width = '50' height = '50' align = 'bottom' />"..txt
    self.detail:setText("     "..txt)
    self.imgLoader:setURL(iconURL)
    self.loader_icon:setURL(string.format("UI/Hallow/hallow%s.png",self.curSelectTid))

    local conf = DynamicConfigData.t_HallowLevel[self.curSelectTid];
    local allSkill = conf[#conf].skill;
    self.list_skill:setData(allSkill);
    self.curSkillId = false
end

-- function HelpHallowView:updateSkillShow( ... )
--     --技能描述
--     local config  = DynamicConfigData.t_buff[self.curSkillId]
--     self.skillDetail:setText(config.buffDescribe)
-- end

return HelpHallowView
