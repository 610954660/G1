---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:技能学习
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local FGUIUtil = require "Game.Utils.FGUIUtil"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
local ItemCell = require "Game.UI.Global.ItemCell"
local CardTalentActiveSkillView, Super = class("CardTalentActiveSkillView", Window)
function CardTalentActiveSkillView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardTalentActiveSkillView"
	self._rootDepth = LayerDepth.PopWindow
	
	self._curCard = false
	
	self._skillData = self._args[1]
	self.skillId = self._skillData.id
    self.listChoose = false
    self.listSkillName = false
    self.skillActiveBtn = false
    self.btn_money = false
    self.costItem = false;
    self.heroItem = false
	-- self.txt_skillName = false
	self.txt_skillDesc = false
	self.itemCell = false
	self.cardCtrl = false
	self.listMaterials = false
	self._allSkillData = {}
	self._selectedSkillItem = false
	
	self.costItem = false
	self.cost = false
end

function CardTalentActiveSkillView:_initUI()
	
    self.listchoose = self.view:getChild("list_choose")
    self.skillActiveBtn = self.view:getChild("btn_active")
    self.btn_money = self.view:getChild("btn_money")
    self.itemCell = self.view:getChild("itemCell")
    -- self.itemCell:getController("showName"):setSelectedIndex(1);
    self.heroItem = self.view:getChild("heroItem")
	-- self.txt_skillName = self.view:getChild("txt_skillName")
    self.txt_skillDesc = self.view:getChild("txt_skillDesc")
	self.listMaterials = self.view:getChildAutoType("list_materials")
    self.costItem = BindManager.bindCostItem(self.view:getChildAutoType("costItem"));
    -- self.costItem:setUseMoneyItem(true);
	--local costBar = self.view:getChildAutoType("costBar")
	--self.costBar = BindManager.bindCostBar(costBar)
	-- self.btn_money = BindManager.bindCostButton(self.btn_money)

    self:bindEvent()
	
	self._curCard = ModelManager.CardLibModel.curCardStepInfo
	self:updateSelctedSkillInfo()
end

--设置卡牌属性名展示
function CardTalentActiveSkillView:setUpStarMaterials(temp, heroId)
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

function CardTalentActiveSkillView:cardView_starUpChoose(_, data)
    --local heroInfo = ModelManager.CardLibModel.curCardStepInfo
    --local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, heroInfo.star)
    --self:setUpStarMaterials(temp, self._curCard.heroId)
	self:updateSelctedSkillInfo()
end

function CardTalentActiveSkillView:updateSelctedSkillInfo()
	local skillItem = BindManager.bindItemCell(self.itemCell)
    skillItem:setData(self._skillData.id, 1, CodeType.PASSIVE_SKILL)
    self.itemCell:getChildAutoType("txt_name"):setText(self._skillData.name);
    self.itemCell:getChildAutoType("frame"):setIcon(PathConfiger.getPassiveSkillFrame(self._skillData.quality));
	-- self.txt_skillName:setText(self._skillData.name)
	self.txt_skillDesc:setText(self._skillData.desc)

	
	local passiveInfo = DynamicConfigData.t_passiveSkill[self.skillId]
	local temp = passiveInfo.activeCost
    self:setUpStarMaterials(temp, self._curCard.heroId)
	
	
	self.cost  = passiveInfo.activeMoneyCost
	--self.costBar:setData(passiveInfo.activeMoneyCost,true)
    -- self.btn_money:setData(passiveInfo.activeMoneyCost[1])
    local cost = passiveInfo.activeMoneyCost[1];
    self.costItem:setData(cost.type, cost.code, cost.amount, true)
    --self:bindEvent()
	--self:showChoose(self._skillData)
end


--绑定事件
function CardTalentActiveSkillView:bindEvent()
    local heroInfo = ModelManager.CardLibModel.curCardStepInfo
    self.skillActiveBtn:addClickListener(
        function(context)
            local passiveInfo = DynamicConfigData.t_passiveSkill[self.skillId]
	        local temp = passiveInfo.activeCost;
            if PlayerModel:isCostEnough(temp, true) then
                local info = {}
                info.text = string.format(Desc.card_activeComfirm, ItemConfiger.getItemNameByCode(temp[1].code));
                info.title = DescAuto[53] -- [53]="提示"
                info.yesText = DescAuto[54] -- [54]="确定"
                info.noText = DescAuto[55] -- [55]="取消"
                info.noClose = "yes"
                info.type = "yes_no"
                info.mask = true
                info.align = "center"
                info.onClose = function()
                    print(5, "noClose")
                end
                info.onYes = function()
                    print(5, "onYes")
                    ModelManager.CardLibModel:activePassiveSkill(self._curCard.uuid, self.skillId)
                    self:closeView()
                end
                info.onNo = function()
                    print(5, "onNo")
                end
                Alert.show(info)
                    
                --
            end
        end
    )
	
	self.btn_money:addClickListener(
        function(context)
			
			local info = {}
			info.text = string.format(Desc.card_activeMoney, self.cost[1].amount)
			info.title = DescAuto[53] -- [53]="提示"
			info.yesText = DescAuto[54] -- [54]="确定"
			info.noText = DescAuto[55] -- [55]="取消"
			info.noClose = "yes"
			info.type = "yes_no"
			info.mask = true
			info.align = "center"
			info.onClose = function()
				print(5, "noClose")
			end
			info.onYes = function()
				print(5, "onYes")
				if ModelManager.PlayerModel:isCostEnough(self.cost, true) then
					ModelManager.CardLibModel:activePassiveSkillByMoney(heroInfo.uuid, self.skillId);
					self:closeView()
				end
			end
			info.onNo = function()
				print(5, "onNo")
			end
			Alert.show(info)
	
			
        end
    )

end

function CardTalentActiveSkillView:isShowTips(heroLeveInfo, uidList)
    local heroInfo = ModelManager.CardLibModel.curCardStepInfo
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
        costStr= costStr..itemInfo.name.."  ".. value.amount..DescAuto[56] -- [56]='，'
    end
    local info = {}
    info.text =cardName..DescAuto[57]..costStr -- [57]="已经进行过培养操作，一旦合并将消失，同时退还以下培养材料，请问是否确认？\n\n"
    info.title = DescAuto[53] -- [53]="提示"
    info.yesText = DescAuto[54] -- [54]="确定"
    info.noText = DescAuto[55] -- [55]="取消"
    info.okText = "okText"
    info.noClose = "yes"
    info.type = "yes_no"
    info.mask = true
    info.align = "center"
    info.onClose = function()
        print(5, "noClose")
    end
    info.onYes = function()
        print(5, "onYes")
        ModelManager.CardLibModel:activePassiveSkill(self._curCard.uuid, self.skillId, uidList)
    end
    info.onNo = function()
        print(5, "onNo")
    end
    Alert.show(info)
end

function CardTalentActiveSkillView:_enter()
    ModelManager.CardLibModel:clearupStarInfo()
end

function CardTalentActiveSkillView:_exit()
	if ModelManager.CardLibModel then
		ModelManager.CardLibModel:clearupStarInfo()
	end
end

return CardTalentActiveSkillView
