-- add by zn
-- 特性学习

local TalentLearnView = class("TalentLearnView", Window)

function TalentLearnView:ctor()
    self._packName = "Talent"
    self._compName = "TalentLearnView"
    self._rootDepth = LayerDepth.PopWindow
    self._allSkillData = false
    self.pos = self._args.index -- 学习的位置
    self.typeList = self._args.listType;
end

function TalentLearnView:_initUI()
    local root = self
    local rootView = self.view
        root.list_page = rootView:getChildAutoType("list_page")
        root.list_skill = rootView:getChildAutoType("list_skill")
        root.talentCell = rootView:getChildAutoType("talentCell")
        root.txt_name = rootView:getChildAutoType("txt_name")
        root.txt_desc = rootView:getChildAutoType("txt_desc/txt_desc")
        root.itemCell = BindManager.bindItemCell(rootView:getChildAutoType("itemCell"))
        root.txt_bookName = rootView:getChildAutoType("txt_bookName")
        root.btn_learn = rootView:getChildAutoType("btn_learn")
        root.txt_rate = rootView:getChildAutoType("txt_rate")
        root.costItem = rootView:getChildAutoType("costItem")

    self.costItmeObj = BindManager.bindCostItem(self.costItem) 
    self.list_page:setSelectedIndex(0)
    self.list_page:setItemRenderer(function(idx, obj)
        obj:setTitle(Desc["Talent_LearnPageType"..self.typeList[idx + 1]])
    end)
    self.list_page:setNumItems(#self.typeList)
    self._allSkillData = {}
    local heroSkill = DynamicConfigData.t_passiveSkill
    for key, value in pairs(heroSkill) do
        if value.learn == 1 then
            --self._allSkillData[#self._allSkillData + 1] = value
			-- if value.quality <= 3 then 
			-- 	table.insert(self._allSkillData[value.quality], value)
            -- elseif value.quality == 5 then
            --     table.insert(self._allSkillData[2], value)
            -- elseif value.quality == 6 then
            --     table.insert(self._allSkillData[3], value)
            -- end
            local quality = value.quality
            if (not self._allSkillData[quality]) then
                self._allSkillData[quality] = {}
            end
            table.insert(self._allSkillData[quality], value)
        end
    end
	TableUtil.sortByMap(self._allSkillData, {{key="learn",asc = true}})
    self:upListSkill()
end

function TalentLearnView:_initEvent()
    self.list_page:addClickListener(function()
        self:upListSkill()
    end)
    self.btn_learn:addClickListener(function()
        local hero = ModelManager.CardLibModel.curCardStepInfo
        local page = self.list_page:getSelectedIndex() + 1
        local index = self.list_skill:getSelectedIndex() + 1
        local data = self._allSkillData[self.typeList[page]][index]
        TalentModel:learnTalent(hero, self.pos, data.id)
    end)
end

function TalentLearnView:upListSkill()
    local selectPage = self.list_page:getSelectedIndex() + 1;
    self:sortSkillList()
    local data = self._allSkillData[self.typeList[selectPage]]
    self.list_skill:setItemRenderer(function(idx, obj)
        self:upItem(idx, obj, data[idx + 1])
    end)
    self.list_skill:setNumItems(#data)
    self.list_skill:setSelectedIndex(0)
    self:upRightPanel()
end

function TalentLearnView:upItem(idx, obj, data)
    local frame = obj:getChildAutoType("frame")
    local iconLoader = obj:getChildAutoType("iconLoader")
    local txt_name = obj:getChildAutoType("txt_name")
    -- local frameUrl = PathConfiger.getPassiveSkillFrame(data.quality)
    local iconUrl = ModelManager.CardLibModel:getItemIconByskillId(data.icon)
    txt_name:setText(data.name)
    -- frame:setIcon(frameUrl)
    iconLoader:setIcon(iconUrl)
    obj:getController("corner"):setSelectedIndex(data.sortFlag)
    obj:getController("c1"):setSelectedIndex(data.recommand)
    obj:getController("showName"):setSelectedIndex(1)
    obj:removeClickListener()
    obj:addClickListener(function()
        self.list_skill:setSelectedIndex(idx)
        self:upRightPanel()
    end)
end

function TalentLearnView:sortSkillList()
    local hero = ModelManager.CardLibModel.curCardStepInfo
    local learnedInfo = TalentModel:getHeroTalentInfo(hero)
    local hasLearn={};
    for key, value in pairs(learnedInfo) do
        local skillId = value.skillId
        if (skillId) then
            hasLearn[skillId] = skillId
        end
    end
    local herItem = DynamicConfigData.t_hero[hero.code]

    local suggestPassive = DynamicConfigData.t_SuggestPassive[herItem.suggestpassive] or {} -- 推荐特性
    suggestPassive = suggestPassive and suggestPassive.passivecombin or {};

    local selectPage = self.list_page:getSelectedIndex() + 1;
    local table = self._allSkillData[self.typeList[selectPage]];
    
    for idx, conf in ipairs(table) do
        local suggestFlag = false;
        for _, id in ipairs(suggestPassive) do
            if (id == conf.id) then
                suggestFlag = true;
                break;
            end
        end
        conf.sortFlag = 0;
		conf.recommand = 0
        -- 已学习
        if (hasLearn[conf.id] ~= nil) then
            conf.sortFlag = 3;
        -- 可学习
        elseif (ModelManager.PlayerModel:isCostEnough(conf.learnCost, false)) then
            conf.sortFlag = 2;
        -- 推荐
        end

		if (suggestFlag) then
            conf.recommand = 1;
        end
    end
    TableUtil.sortByMap(table, {{key= "sortFlag", asc = true},{key= "recommand", asc = true}, {key = "id", asc = false}});
end

function TalentLearnView:upRightPanel()
    local page = self.list_page:getSelectedIndex() + 1
    local index = self.list_skill:getSelectedIndex() + 1
    local data = self._allSkillData[self.typeList[page]][index]
    self.talentCell:getController("c1"):setSelectedIndex(2)
    local iconUrl = ModelManager.CardLibModel:getItemIconByskillId(data.icon)
    self.talentCell:setIcon(iconUrl)
    self.txt_name:setText(data.name)
    self.txt_desc:setText(data.desc)
	
    if (data.sortFlag == 3) then
        self.view:getController("c1"):setSelectedIndex(1)
    else
        self.view:getController("c1"):setSelectedIndex(0)
        local cost = data.learnCost[1]
		self.costItmeObj:setData(cost.type, cost.code, cost.amount)
        self.itemCell:setData(cost.code, 0, cost.type)
        --[[local has = ModelManager.PackModel:getItemsFromAllPackByCode(cost.code)
        local str = has < cost.amount and string.format("[color=%s]%s[/color]", ColorUtil.textColorStr.red, has) or has
        str = str.."/"..cost.amount
        self.txt_count:setText(str)--]]
        local name = self.itemCell._itemData:getName()
        self.txt_bookName:setText(name)
        self:upSucRate()
    end
end

-- 更新成功率
function TalentLearnView:upSucRate()
    local hero = ModelManager.CardLibModel.curCardStepInfo
    local girdInfo = TalentModel:getHeroTalentInfo(hero)
    local equipCount = 0
    for i = 1, #girdInfo do
        if (girdInfo[i].state == 2) then
            equipCount = equipCount + 1
        end
    end
    if (equipCount == 0) then
        self.txt_rate:setText(string.format(Desc.Talent_successRate3, 100))
    else
        local sucConf = DynamicConfigData.t_PassiveSkillLearn[equipCount]
        local failCount = hero.newPassiveSkillCount
        if (sucConf and failCount) then
            local count = sucConf.pCount - failCount
            if (count == 0) then
                self.txt_rate:setText(string.format(Desc.Talent_successRate3, 100))
                return;
            end
        end
        local conf = DynamicConfigData.t_PassiveSkillOpen[self.pos]
        if (conf) then
            self.txt_rate:setText(string.format(Desc.Talent_successRate3, conf.learnRate/100))
        else
            self.txt_rate:setText("")
        end
    end
end

function TalentLearnView:cardView_activeSkillSuc()
    -- self:upListSkill()
    self:closeView();
end

function TalentLearnView:cardView_activeSkillFail()
    self:upListSkill()
end

return TalentLearnView