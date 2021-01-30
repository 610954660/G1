local BlessingSelectView = class("BlessingSelectView",Window)
function BlessingSelectView:ctor(data)
 	self._packName 	= "BoundaryMap"
 	self._compName 	= "BlessingSelectView"
	self._rootDepth = LayerDepth.PopWindow
	self.skills = BoundaryMapModel:getBlessing()
	self.t_BoundaryBless = BoundaryMapModel:getBoundaryBless()

	self.itemList = {}
	self.selectIndex = 1
end
function BlessingSelectView:_initUI()
	self.view:getChildAutoType("blackbg"):addClickListener(function()
		self:closeView()
	end)
	self.getBtn = self.view:getChildAutoType("getBtn")
	self.getBtn:addClickListener(function()
		RPCReq.Boundary_SetBlessingBuff({pos = self.selectIndex},function(info)
			BoundaryMapModel:addRouteNodeBuff(info.skillid)
			local pos = self.itemList[self.selectIndex]:localToGlobal(cc.p(0,0))	
			Dispatcher.dispatchEvent("getBuff_action",self.itemList[self.selectIndex],pos)
			self:closeView()
		end)
	end)
	
	self.skillList = self.view:getChildAutoType("$list")
	self.skillList:setItemRenderer(handler(self,self.skillListHandle))
	self.skillList:setData(self.skills)
end

function BlessingSelectView:skillListHandle(index,obj)
	local skill = self.t_BoundaryBless[self.skillList._dataTemplate[index + 1]]
	obj:getChildAutoType("icon"):setURL(string.format("%s%s.png", "Icon/skill/", skill.icon))
	obj:getChildAutoType("name"):setText(skill.name)
	obj:getChildAutoType("skilltxt"):setText(skill.desc)
	obj:addClickListener(function()
		for key,value in pairs(self.itemList) do
			value:setScale(1,1)
		end
		obj:setScale(1.2,1.2)
		self.selectIndex = index + 1
		self.getBtn:setVisible(true)
	end)
	table.insert(self.itemList,obj)
end
function BlessingSelectView:_exit()
	BoundaryMapModel:setBlessing({})
end
return BlessingSelectView