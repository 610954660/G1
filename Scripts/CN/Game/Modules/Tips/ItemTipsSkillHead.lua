--道具tips
--added by wyang
local ItemTipsSkillHead = class("ItemTipsSkillHead",View)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsSkillHead:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsSkillHead"
   self._isFullScreen = false

	self.itemData = args.data
	self.codeType = args.data.codeType
end

function ItemTipsSkillHead:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsSkillHead:_initUI( ... )
	local viewRoot = self.view;
	local txt_name = viewRoot:getChild("txt_name")
	local txt_level = viewRoot:getChild("txt_level")
	local txt_release = viewRoot:getChild("txt_release")
    local skillTipIcon =viewRoot:getChild("_Loader$icon") 
	local config
	if self.codeType == CodeType.PASSIVE_SKILL then
		config = DynamicConfigData.t_passiveSkill[self.itemData.id]
		txt_name:setText(config.name)
		txt_level:setText("")
		txt_release:setText("")
	elseif self.codeType == CodeType.EQUIPMENT_SKILL then
		printTable(33,"ssssssssssssssssss---=== ",self.itemData)
		config = DynamicConfigData.t_equipskill[self.itemData.id]
		txt_name:setText(config.skillName)
		local text = Desc.equipment_pos
		if #config.positionLimit >=4 then
			text = text..Desc.equipment_posAll
		else
			for k,v in pairs(config.positionLimit) do
				text = text.."["..Desc["common_equipPosT"..v].."]"
			end
		end
		txt_release:setText(text)
	elseif self.codeType == CodeType.SKILL then
		config = DynamicConfigData.t_skill[self.itemData.id]
		local nameStr = config.skillName
		if self.itemData.activeLv then
			if self.itemData.activeLv then
				nameStr = string.format(Desc.itemtips_skillNameLv, config.skillName, self.itemData.activeLv)
				txt_level:setText(self.itemData.activeLv)
			else
				nameStr = config.skillName
				txt_level:setText("")
			end
		end
		if config.selfBuff == 0 then
			txt_release:setText(Desc.itemtips_skillRelease3)
		else
			if config.beginShow == 0 then
				txt_release:setText(Desc.itemtips_skillRelease2)
			else
				txt_release:setText(string.format(Desc.itemtips_skillRelease1,config.beginShow,config.coolRound))
			end
		end
		txt_name:setText(nameStr)
	elseif self.codeType == CodeType.GUIILD_SKILL or self.codeType == CodeType.HALLOW_SKILL then
		config = DynamicConfigData.t_skill[self.itemData.id]
		local nameStr = config.skillName
		if self.itemData.activeLv then
			if self.itemData.activeLv then
				nameStr = string.format(Desc.itemtips_skillNameLv, config.skillName, self.itemData.activeLv)
				txt_level:setText(self.itemData.activeLv)
			else
				nameStr = config.skillName
				txt_level:setText("")
			end
		end
		if config.selfBuff == 0 then
			txt_release:setText(Desc.itemtips_skillRelease3)
		else
			if config.beginShow == 0 then
				txt_release:setText(Desc.itemtips_skillRelease2)
			else
				txt_release:setText(string.format(Desc.itemtips_skillRelease1,config.beginShow,config.coolRound))
			end
		end
		txt_name:setText(nameStr)
	end
	
    local touchurl
	if self.codeType == CodeType.EQUIPMENT_SKILL then
		touchurl = PathConfiger.getEquipmentSkillIcon(self.itemData.id)
	else
		touchurl = ModelManager.CardLibModel:getItemIconByskillId(config.icon)
	end
   
    skillTipIcon:setURL(touchurl)
end

-- [子类重写] 准备事件
function ItemTipsSkillHead:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsSkillHead:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsSkillHead:_exit()
end


return ItemTipsSkillHead