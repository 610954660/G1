--added by wyang
--道具框封裝
--local SkillCell = class("SkillCell")
local SkillCell,Super = class("SkillCell",BindView)
function SkillCell:ctor(view)
	self.txt_lv = false
	self.iconLoader = false
	self.ctrl = false
	
	self._skillId = false
	self._skillInfo = false
	self.heroId = 0 --在哪个英雄身上的（显示tips会用到）

	
	self._bindMap = {}
	
	self._noHasNum = false
end


function SkillCell:_initUI( ... )
	self.ctrl = self.view:getController("button")
	self.iconLoader = self.view:getChildAutoType("iconLoader/iconLoader")
	self.txt_lv = self.view:getChildAutoType("txt_lv")
end

function SkillCell:setSelected(select)
	self.ctrl:setSelectedIndex(select and 1 or 0)
end

function SkillCell:getSelected()
	return self.ctrl:getSelectedIndex() == 1
end

--直接设设置code的数据
--点击是否显示tips
--heroId 在哪个英雄身上的，
function SkillCell:setData(skillId, showTips,heroId)
	self.heroId = heroId or 0
	--if tips == nil then tips = true end
	local skillInfo = DynamicConfigData.t_skill[skillId]
	if skillInfo then
		self._skillInfo = skillInfo
		local ultSkillurl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
		self.iconLoader:setURL(ultSkillurl) --放了一张技能图片
		--self.txt_lv:setText("等级："..skillInfo.level)
		if (showTips) then
			self.view:removeClickListener()
			self.view:addClickListener(function ()
				ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillId, heroId = self.heroId})
			end)
		end
	end
end

--设置装备技能的数据
function SkillCell:setEquipmentData(skillId,tips)
	
	if skillId then
		local ultSkillurl = PathConfiger.getEquipmentSkillIcon(skillId)
		print(33,"ultSkillurl = ",ultSkillurl)
		self.iconLoader:setURL(ultSkillurl) --放了一张技能图片
		self.iconLoader:setScale(1,1)
		self.view:removeClickListener(100)
		if tips then
			self.view:addClickListener(
				function(context)
					--点击查看技能详情
					ViewManager.open("ItemTips", {codeType = CodeType.EQUIPMENT_SKILL, id = skillId})
				end,
				100
			)
		end
	else
		self.iconLoader:setURL("ui://it0palm6vc08xcwwqx") --放了一张技能图片
		self.iconLoader:setScale(0.7,0.7)
		self.view:removeClickListener(100)
		if tips then
			self.view:addClickListener(
				function(context)
					RollTips.show(Desc.equipment_noskill)
				end,
				100
			)
		end
	end
end

function SkillCell:setJewelryData(skillId, tips)
	if skillId then
		local ultSkillurl = PathConfiger.getEquipmentSkillIcon(skillId)
		print(2233, "SkillCell:setJewelryData", ultSkillurl);
		self.iconLoader:setURL(ultSkillurl) --放了一张技能图片
		self.iconLoader:setScale(1,1)
		self.view:removeClickListener(100)
		if tips then
			self.view:addClickListener(
				function(context)
					--点击查看技能详情
					ViewManager.open("ItemTips", {codeType = CodeType.PASSIVE_SKILL, id = skillId, data={id = skillId}})
				end,
				100
			)
		end
	else
		self.iconLoader:setURL("ui://it0palm6vc08xcwwqx") --放了一张技能图片
		self.iconLoader:setScale(0.7,0.7)
		self.view:removeClickListener(100)
		if tips then
			self.view:addClickListener(
				function(context)
					RollTips.show(Desc.equipment_noskill)
				end,
				100
			)
		end
	end
end

function SkillCell:showSkillName(type,name)
	self.view:getController("c1"):setSelectedIndex(1)
	self.view:getController("c2"):setSelectedIndex(type or 0)
	local itemName = self.view:getChildAutoType("itemName");
	itemName:setText(name or self._skillInfo.skillName)
	if type == 0 or type == nil then
		local pos = itemName:getPosition()
		itemName:setPosition(self.view:getWidth()/2 - itemName:getWidth()/2, pos.y)
	end
end

--退出操作 在close执行之前 
function SkillCell:_onExit()
    print(1,"SkillCell __onExit")
end

return SkillCell