---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:技能学习
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local FGUIUtil = require "Game.Utils.FGUIUtil"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
local CardTalentLearnSkillView, Super = class("CardTalentLearnSkillView", Window)
function CardTalentLearnSkillView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardTalentLearnSkillView"
	self._rootDepth = LayerDepth.PopWindow
	
	-- self._curCard = false
	self.heroInfo = false;
	
    self.listChoose = false
    self.skillId = false
    self.listSkillName = false
    self.skillActiveBtn = false
    self.heroItem = false
	self.txt_skillName = false
	self.txt_skillDesc = false
	self.itemCell = false
	self.cardCtrl = false
	self.listMaterials = false
	self._allSkillData = {}
    self._selectedSkillItem = false
    self.btn_help = false;
	
	self._selectedType = 1
	
end

function CardTalentLearnSkillView:_initUI()
	
	
	
    self.list_tabBtns = self.view:getChild("list_tabBtns")
    self.listchoose = self.view:getChild("list_choose")
    self.listSkillName = self.view:getChild("list_skillName")
    self.skillActiveBtn = self.view:getChild("btn_learn")
    self.itemCell = self.view:getChild("itemCell")
    self.itemCell:setTouchable(false);
--    self.heroItem = self.view:getChild("heroItem")
	self.txt_skillName = self.view:getChild("txt_skillName")
    self.txt_skillDesc = self.view:getChild("txt_skillDesc")
	self.listMaterials = self.view:getChildAutoType("list_materials")
	self.btn_help = self.view:getChildAutoType("btn_help");
	self.cardCtrl = self.view:getController("cardCtrl")
	
	self.list_tabBtns:regUnscrollItemClick(function (index,obj)
		self._selectedType  = index + 1;
		self:updateSkillList()
	end)
    
    self.btn_help:addClickListener(function ()
        
        RollTips.showHelp(Desc.help_StrTitle17, Desc.help_StrDesc17);
    end)
	--[[self.heroItem:addClickListener(
		function(context)
			ModelManager.CardLibModel:clearSkillActiveChoose()
			self.cardCtrl:setSelectedIndex(1)
		end)--]]
	--local cardCloseBtn = self.view:getChild("cardFrame"):getChild("closeButton")
	--cardCloseBtn:addClickListener(
	--	function(context)
	--		self.cardCtrl:setSelectedIndex(0)
	--	end)
	
    

    self.heroInfo = self._args.heroInfo;
    local hasLearn={};
    for key, value in pairs(self.heroInfo.passiveSkill) do
        hasLearn[key]=value
    end
    for key, value in pairs(self.heroInfo.reservedSkill) do
        hasLearn[key]=value
    end
    printTable(8,'当前打印的卡牌数据',self.heroInfo)
    local herItem = DynamicConfigData.t_hero[self.heroInfo.code]
    self._allSkillData = {{},{}}
    local heroSkill = DynamicConfigData.t_passiveSkill
    for key, value in pairs(heroSkill) do
        if value.learn == 1 then
            --self._allSkillData[#self._allSkillData + 1] = value
			if value.quality <= 3 then 
				table.insert(self._allSkillData[1], value)
			else
				table.insert(self._allSkillData[2], value)
			end
        end
    end
	self._skillData = #self._allSkillData[1] > 0 and self._allSkillData[1][1] or self._allSkillData[2][1]
	self.skillId = self._skillData.id

	self.listSkillName:setVirtual()
    self.listSkillName:setItemRenderer(
        function(index, obj)
            -- local itemcell = obj:getChild("itemCell")
            -- itemcell:setTouchable(false);
            -- local btnCtrl = obj:getController("button")
            obj:getController("showName"):setSelectedIndex(1);
            local skillItem = BindManager.bindItemCell(obj)
            skillItem:setClickable(false);
            local skillData = self._allSkillData[self._selectedType][index + 1]
            skillItem:setData(skillData.id, 1, CodeType.PASSIVE_SKILL)
            skillItem.view:getChildAutoType("frame"):setIcon(PathConfiger.getPassiveSkillFrame(skillData.quality))
			obj:getController("isLock"):setSelectedIndex(1);
			skillItem:setIsSelected(skillData.id == self.skillId and true or false)
			if skillData.id == self.skillId then
                self._selectedSkillItem = skillItem
            end

            obj:getController('corner'):setSelectedIndex(skillData.sortFlag);

            obj:getChildAutoType("txt_name"):setText(skillData.name)
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
			obj:addClickListener(
                function(context)
                    if hasLearn[skillData.id] ~= nil then
                        RollTips.show(DescAuto[58]) -- [58]="已学习的技能"
                    end
					
					self._skillData = skillData
					self.skillId = skillData.id
					if self._selectedSkillItem then
						self._selectedSkillItem:setIsSelected(false)
					end
					self._selectedSkillItem = skillItem
					skillItem:setIsSelected(true)
					ModelManager.CardLibModel:clearupStarInfo()
					self:updateSelctedSkillInfo()
				end,
				100
			)
        end
    )
    
    self:bindEvent()
	
	ModelManager.CardLibModel:clearupStarInfo()
	self.list_tabBtns:setSelectedIndex(self._selectedType - 1)
	self:updateSkillList()
	-- self._curCard = ModelManager.CardLibModel:getCurShowCard()
	self:updateSelctedSkillInfo()
end

function CardTalentLearnSkillView:updateSkillList()
    self:sortSkillList();
	self.listSkillName:setNumItems(#self._allSkillData[self._selectedType])
end

--设置卡牌属性名展示
function CardTalentLearnSkillView:setUpStarMaterials(temp, heroId)
    -- local info = DynamicConfigData.t_hero
    -- local heroItem = info[heroId]
    self.listMaterials:setItemRenderer(
        function(index, obj)
            local materials = temp[index + 1]
            local item = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
            item:setData(materials.code, materials.amount, materials.type);
            local have = PackModel:getItemsFromAllPackByCode(materials.code);
            local str = have < materials.amount and string.format(Desc.common_red, have) or have.."";
            str = str.."/"..materials.amount;
            item.txtNum:setText(str);
            obj:getChild('title'):setText(ItemConfiger.getItemNameByCode(materials.code));
        end
    )
    self.listMaterials:setNumItems(#temp)
end

function CardTalentLearnSkillView:cardView_starUpChoose(_, data)
    -- local heroInfo = ModelManager.CardLibModel.curCardStepInfo
    --local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, heroInfo.star)
    --self:setUpStarMaterials(temp, heroInfo.code)
	self:updateSelctedSkillInfo()
end

function CardTalentLearnSkillView:updateSelctedSkillInfo()
	--ModelManager.CardLibModel:clearupStarInfo()
    local skillItem = BindManager.bindItemCell(self.itemCell)
    skillItem:setClickable(false)
    skillItem.view:getChildAutoType("frame"):setIcon(PathConfiger.getPassiveSkillFrame(self._skillData.quality))
	skillItem:setData(self._skillData.id, 1, CodeType.PASSIVE_SKILL)
	self.txt_skillName:setText(self._skillData.name)
    self.txt_skillDesc:setTitle(self._skillData.desc)
    
    local heroInfo = ModelManager.CardLibModel.curCardStepInfo
    local hasLearn={};
    for key, value in pairs(heroInfo.passiveSkill) do
        hasLearn[key]=value
    end
    for key, value in pairs(heroInfo.reservedSkill) do
        hasLearn[key]=value
    end
    if hasLearn[self._skillData.id] ~= nil then
        self.skillActiveBtn:setVisible(false)
    else
        self.skillActiveBtn:setVisible(true)
        --self.skillId = skillItemInfo.id
        --self:showChoose(skillItemInfo)
    end

	
	local passiveInfo = DynamicConfigData.t_passiveSkill[self.skillId]
	local temp = passiveInfo.learnCost
    self:setUpStarMaterials(temp, self.heroInfo.heroId)
	
    --self:bindEvent()
	--self:showChoose(self._skillData)
end


--绑定事件
function CardTalentLearnSkillView:bindEvent()
    --local heroInfo = ModelManager.CardLibModel.curCardStepInfo
    self.skillActiveBtn:addClickListener(
        function(context)
            local passiveInfo = DynamicConfigData.t_passiveSkill[self.skillId]
            local temp = passiveInfo.learnCost;
            if (PlayerModel:isCostEnough(temp, true)) then
                ModelManager.CardLibModel:learnPassiveSkill(self.heroInfo.uuid, self.skillId)
            end
        end
    )

    --[[local closeBtn = self.view:getChild("closeButton1")
    closeBtn:addClickListener(
        function(context)
            ModelManager.CardLibModel:clearSkillActiveChoose()
            ViewManager.close("CardTalentLearnSkillView")
        end
    )--]]
end

function CardTalentLearnSkillView:isShowTips(heroLeveInfo, uidList)
    -- local heroInfo = ModelManager.CardLibModel.curCardStepInfo
    local cardName=heroLeveInfo.heroDataConfiger.heroName;
    local level=heroLeveInfo.level;
    local stage=heroLeveInfo.stage;
    local levelCost= DynamicConfigData.HeroLevelAccumulationConfig[level];
    local stageCost= DynamicConfigData.HeroStageAccumulationConfig[stage];
    local iic={}
    local iic2={}
    if levelCost then
        iic= levelCost.costList;
    end
    if stageCost then
        iic2= stageCost.costList;
    end
   local info=ModelManager.CardLibModel:setReward(iic,iic2);
   printTable(8,'>>>>>>>>>>>>>>????????????',iic,iic2,info)
   local costStr='';
    for key, value in pairs(info) do
         local itemInfo = ItemConfiger.getInfoByCode(value.code)  
        costStr= costStr..itemInfo.name.."  ".. value.amount..'\n'
    end
    local info = {}
    info.text =cardName.."已经进行过培养操作，一旦合并将消失，同时退还以下培养材料，请问是否确认？\n"..costStr
    info.title = "技能学习"
    info.yesText = "确定"
    info.noText = "取消"
    info.okText = "okText"
    info.noClose = "yes"
    info.type = "yes_no"
    info.mask = true
    info.onClose = function()
        print(5, "noClose")
    end
    info.onYes = function()
        print(5, "onYes")
        ModelManager.CardLibModel:learnPassiveSkill(self.heroInfo.uuid, self.skillId, uidList)
    end
    info.onNo = function()
        print(5, "onNo")
    end
    Alert.show(info)
end

function CardTalentLearnSkillView: sortSkillList()
    self.heroInfo = ModelManager.CardLibModel.curCardStepInfo
    local hasLearn={};
    for key, value in pairs(self.heroInfo.passiveSkill) do
        hasLearn[key]=value
    end
    for key, value in pairs(self.heroInfo.reservedSkill) do
        hasLearn[key]=value
    end
    local herItem = DynamicConfigData.t_hero[self.heroInfo.code]

    local suggestPassive = DynamicConfigData.t_SuggestPassive[herItem.suggestpassive] or {} -- 推荐特性
    suggestPassive = suggestPassive and suggestPassive.passivecombin or {};

    local table = self._allSkillData[self._selectedType];
    
    for idx, conf in ipairs(table) do
        local suggestFlag = false;
        for _, id in ipairs(suggestPassive) do
            if (id == conf.id) then
                suggestFlag = true;
                break;
            end
        end
        conf.sortFlag = 0;
        -- 已学习
        if (hasLearn[conf.id] ~= nil) then
            conf.sortFlag = 3;
        -- 可学习
        elseif (ModelManager.PlayerModel:isCostEnough(conf.learnCost, false)) then
            conf.sortFlag = 2;
        -- 推荐
        elseif (suggestFlag) then
            conf.sortFlag = 1;
        end
    end
    TableUtil.sortByMap(table, {{key= "sortFlag", asc = true}, {key = "id", asc = false}});
end

return CardTalentLearnSkillView
