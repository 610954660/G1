local ClearanceView = class("ClearanceView",Window)
function ClearanceView:ctor(data)
 	self._packName 	= "BoundaryMap"
 	self._compName 	= "ClearanceView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.t_BoundaryNode = BoundaryMapModel:getBoundaryNode()
end
function ClearanceView:_initUI()
	self.view:getChildAutoType("blackbg"):addClickListener(function()
		self:closeView()
	end)

	self.bossList = self.view:getChildAutoType("bossList")
	self.bossList:setItemRenderer(handler(self,self.bossListHandle))


	local spineParentDown = self.view:getChildAutoType("spineParentDown")
	local spineParentUp = self.view:getChildAutoType("spineParentUp")
	local spineDown =  SpineUtil.createSpineObj(spineParentDown, vertex2(spineParentDown:getWidth()/2,spineParentDown:getHeight()/2), "gongnengjiesuo_down", "Spine/ui/jiesuan", "efx_gongnengjiesuo", "efx_gongnengjiesuo",true)
	local spineUp =  SpineUtil.createSpineObj(spineParentUp, vertex2(spineParentUp:getWidth()/2,spineParentUp:getHeight()/2), "gongnengjiesuo_up", "Spine/ui/jiesuan", "efx_gongnengjiesuo", "efx_gongnengjiesuo",true)
	
	local t_fight = DynamicConfigData.t_fight
	self.showData = {}
	for key,value in pairs(self.t_BoundaryNode) do
		local config = DynamicConfigData.t_monster[value.bossid]
		local showData = {}
		showData.code = config.monsterId
		showData.level = t_fight[value.nodeBoss]["level1"]
		showData.star = t_fight[value.nodeBoss]["star1"]
		showData.category = config.category
		showData.layer = value.layer
		table.insert(self.showData,showData)
	end
	table.sort(self.showData,function(a,b)
		return a.layer < b.layer
	end)
	self.bossList:setData(self.showData)
end

function ClearanceView:bossListHandle(index,obj)
	local heroCell = BindManager.bindHeroCell(obj:getChildAutoType("playerCell"))
	heroCell:setData(self.showData[index + 1])

	local starList = obj:getChildAutoType("starList")
	starList:setItemRenderer(function(index, obj1)
		obj1:getController("state"):setSelectedIndex(starList._dataTemplate[index + 1])
	end)

	local curDif = BoundaryMapModel:getBossDifficultById(index + 1)
	if curDif and curDif.mark >= 1 then
		local list = {0,0,0,0,0,0}
		for i = 1,curDif.mark do
			list[i] = 1
		end
		starList:setData(list)
	end
end
function ClearanceView:_exit()
end
return ClearanceView