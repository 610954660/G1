--道具tips
--added by wyang
local ItemTipsEquipSkill = class("ItemTipsEquipSkill",View)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsEquipSkill:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsEquipSkill"
   self._isFullScreen = false

	self._data = args.data
end

function ItemTipsEquipSkill:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsEquipSkill:_initUI( ... )
	
	local list_skill = self.view:getChildAutoType("list_skill")
	local uuid = self._data:getUuid()
	local skilldata = EquipmentModel:getSkillData(uuid)
	if skilldata  then
		if skilldata.skill and #skilldata.skill>0 then
			self.view:getController("c1"):setSelectedIndex(0)
			printTable(33,"skilldata = ",skilldata.skill)
			list_skill:setItemRenderer(function(index,obj)
					local skillInfo = EquipmentModel:getSkillConfigByCode(skilldata.skill[index+1])
					local configSkill = DynamicConfigData.t_skill
					local skillId = tonumber(skilldata.skill[index+1])
					local sdata = configSkill[skillId]
					if sdata then
						obj:setIcon(CardLibModel:getItemIconByskillId(sdata.icon))
					end 
					
					obj:getChildAutoType("title"):setVisible(true)
					obj:setTitle(skillInfo.skillName)
					obj:getChildAutoType("desc"):setText(skillInfo.skillDesc)
				end)
			list_skill:setNumItems(#skilldata.skill)
			return
		else
			list_skill:setNumItems(0)
		end
	end
	
	local itemInfo = self._data:getItemInfo()
	local info = DynamicConfigData.t_equipEquipment[itemInfo.code]
	if itemInfo.color > 5 then
		self.view:getController("c1"):setSelectedIndex(1)
	else
		self.view:getController("c1"):setSelectedIndex(2)
	end
	
	local btn_recast = self.view:getChildAutoType("btn_recast")
	btn_recast:addClickListener(function(context)
			ModuleUtil.openModule(ModuleId.Forge.id)
		end,33)
		
	local btn_upStar = self.view:getChildAutoType("btn_upStar")
	btn_upStar:addClickListener(function(context)
			ModuleUtil.openModule(ModuleId.EquipmentforgeView.id)
		end,33)
	
	
end

-- [子类重写] 准备事件
function ItemTipsEquipSkill:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsEquipSkill:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsEquipSkill:_exit()
end


return ItemTipsEquipSkill