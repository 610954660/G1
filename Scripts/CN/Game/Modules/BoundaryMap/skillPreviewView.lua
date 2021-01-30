local SkillPreviewView = class("SkillPreviewView",Window)
function SkillPreviewView:ctor(data)
 	self._packName 	= "BoundaryMap"
 	self._compName 	= "SkillPreviewView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.t_BoundaryNode = BoundaryMapModel:getBoundaryNode()
	self.layer = BoundaryMapModel:getCurLayer()
	self.boundaryNodeData = BoundaryMapModel:getBoundaryNode()[self.layer]
	local monster = DynamicConfigData.t_monster[self.boundaryNodeData.bossid]--读表的数据
	self.skills = monster.skill
end
function SkillPreviewView:_initUI()
	self.view:getChildAutoType("blackbg"):addClickListener(function()
		self:closeView()
	end)

	self.skillList = self.view:getChildAutoType("list")
	self.skillList:setItemRenderer(handler(self,self.skillListHandle))

	self.skillList:setData(self.skills)
end

function SkillPreviewView:skillListHandle(index,obj)
	local t_skill = DynamicConfigData.t_skill
	local skill = t_skill[self.skillList._dataTemplate[index + 1]]
	if skill then
		obj:getChildAutoType("name"):setText(skill.skillName)
		obj:getChildAutoType("skilltxt"):setText(skill.showName)
		local skillCellObj = obj:getChild("skillCell")
		local skillCell = BindManager.bindSkillCell(skillCellObj)
		skillCell:setData(skill.skillId)
	end
end
function SkillPreviewView:_exit()
end
return SkillPreviewView