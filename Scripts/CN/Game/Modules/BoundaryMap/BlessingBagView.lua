local BlessingBagView = class("BlessingBagView",Window)
function BlessingBagView:ctor(data)
 	self._packName 	= "BoundaryMap"
 	self._compName 	= "BlessingBagView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.skills = BoundaryMapModel:getRouteBuff()
	self.t_BoundaryBless = BoundaryMapModel:getBoundaryBless()
end
function BlessingBagView:_initUI()
	self.view:getChildAutoType("closeButton"):addClickListener(function()
		self:closeView()
	end)

	self.controller = self.view:getController("noDataCtrl")
	self.controller:setSelectedIndex(#self.skills == 0 and 1 or 0)
	self.skillList = self.view:getChildAutoType("$list")
	self.skillList:setItemRenderer(handler(self,self.skillListHandle))

	self.skillList:setData(self.skills)
end

function BlessingBagView:skillListHandle(index,obj)
	local skill = self.t_BoundaryBless[self.skillList._dataTemplate[index + 1]]
	if skill then
		obj:getChildAutoType("icon"):setURL(string.format("%s%s.png", "Icon/skill/", skill.icon))
		obj:getChildAutoType("name"):setText(skill.name)
		obj:getChildAutoType("skilltxt"):setText(skill.desc)
	end
end
function BlessingBagView:_exit()
end
return BlessingBagView