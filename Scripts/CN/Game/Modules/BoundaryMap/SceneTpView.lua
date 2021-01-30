local SceneTpView = class("SceneTpView",Window)
function SceneTpView:ctor(args)
 	self._packName 	= "BoundaryMap"
 	self._compName 	= "SceneTpView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.effet_str = false
	
	self.difficulty = args.difficulty
end
function SceneTpView:_initUI()
	self.view:getChildAutoType("closeButton"):addClickListener(function()
		self:closeView()
	end)
	self.view:getChildAutoType("blackbg"):addClickListener(function()
		self:closeView()
	end)
	self.effet_str = self.view:getChildAutoType("effet_str")
	self.list = self.view:getChildAutoType("$list")
	self.list:setItemRenderer(handler(self,self.listHandle))

	self.boundaryNode = BoundaryMapModel:getBoundaryNode()
	self.list:setData(self.boundaryNode)
	
	
	if self.difficulty ~= table.nums(DynamicConfigData.t_BoundaryNode) then
		local config = DynamicConfigData.t_BoundaryDifficulty[self.difficulty + 1].unlock
		self.effet_str:setText(string.format(Desc.Boundary_desc14,config[1],config[2]))
	else
		self.effet_str:setText(Desc.Boundary_desc15)
	end
end
function SceneTpView:listHandle(index,obj)
	obj:getChildAutoType("title"):setText(string.format(Desc.Boundary_desc1,index + 1))
	local btn_go = obj:getChildAutoType("btn_go")
	btn_go:addClickListener(function()
		if obj:getController("state"):getSelectedIndex() == 1 then
			RollTips.show(Desc.Boundary_desc7)
			return
		end
		BoundaryMapModel:setCurLayer(index + 1)
		self:closeView()
	end)
	local progressBar = obj:getChildAutoType("progressBar")
	progressBar:setMax(16)
    progressBar:setValue(0)
	--local val = progressBar:getChildAutoType("val")
	--val:setText(0)
	--local count = progressBar:getChildAutoType("count")
	--count:setText(16)
	local route = BoundaryMapModel:getRouteNodeByLayer(index + 1)
	if route and route.node then
		local max = 0
		for key,value in pairs(route.node) do
			max = max + value.pos
		end
		progressBar:setValue(max)
	end

	if index + 1 > BoundaryMapModel:getCurBestToScene() then
		obj:getController("state"):setSelectedIndex(2)
		local severDay = tonumber(os.date("%d",ServerTimeModel:getServerTime()))
		obj:getChildAutoType("time"):setText(BoundaryMapModel:getBoundaryNode()[index + 1].openDay - severDay..Desc.Boundary_desc5)
	else
		local best = BoundaryMapModel:getBestMarkScene()
		obj:getController("state"):setSelectedIndex((best >= index) and 0 or 1)
	end
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
function SceneTpView:_exit()
end
return SceneTpView