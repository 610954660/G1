--added by wyang
--封魔之路地图移动组件
local SealDevilMapRect = class("SealDevilMapRect")
local SealDevilGrid = require "Game.Modules.SealDevil.SealDevilGrid"
function SealDevilMapRect:ctor(view)
	self.view = view
	self._mapItems = {}
	self.raw=6 --排
	self.row=9 --列
end

function SealDevilMapRect:init( ... )
	--self.mapItem = self.view:getChildAutoType("mapItem")
end


--打开地图时的初始化
function SealDevilMapRect:initMap()
	local mapData=SealDevilModel:getMapData()
	
	local index=0
	for y = 1, self.raw do
		for x = 1, self.row do
			index=index+1
			local mapItem = self._mapItems[index]
			if not mapItem then
				local xV=(125+y*2.5)*(x-1)+(80-y*10)
				local yV=100*y+25
				local LineWidth=2.5*y+8
				local downRotate=10-x*2
				mapItem  = SealDevilGrid.new(self.view,Vector2(xV,yV),LineWidth,downRotate)		
				self._mapItems[x]=self._mapItems[x] or {}
				self._mapItems[x][y]= mapItem
				mapItem.view:setVisible(false)
			end
		end
	end
	self:resetMap()
end

function SealDevilMapRect:resetMap(isRest)
	
	local mapConfig=SealDevilModel:getMapConfig()
	SealDevilModel:setMapGridInfo(self._mapItems)
	for k, v in pairs(mapConfig) do
		local pIndex=v.point[1]
		if self._mapItems and self._mapItems[pIndex.x] and self._mapItems[pIndex.x][pIndex.y] then
			self._mapItems[pIndex.x][pIndex.y]:setData(v,isRest)
		end
	end
end

function SealDevilMapRect:updateGrid(data)
	local mapData=SealDevilModel:getMapData()
	local gridIndex=mapData[data.gridInfo.id].point[1]
	local grid=self._mapItems[gridIndex.x][gridIndex.y]
	
	if data.gridInfo.id==3 then
		printTable(5656,data,"data")
	end
	if data.gridInfo.isTrigger and grid.gridEvent then
		grid.gridEvent()
	else
		grid:event_updateGrid(data)
	end

end








function SealDevilMapRect:getMapItem()
    return self._mapItems
end


--添加需要移动的点
function SealDevilMapRect:addMovePoint(points)
	if #points == 0 then return end
	for _,v in ipairs(points) do
		self._movePosList:enqueue(points)
	end
	self:moveNext()
end


function SealDevilMapRect:setRoleArrow()
	if tolua.isnull(self.view) then
		return
	end
	local curPos = self._roleMc:getPosition()
	local nexIndex=0
	if TwistRegimentModel.grid==26 then
		nexIndex=1
	else
		nexIndex=TwistRegimentModel.grid+1
	end
	local posItem = self.mapItem:getChildAutoType("rollItem_"..nexIndex)
	local pos = posItem:getPosition()
	print(5656,self:getAngleByPos(curPos,pos),nexIndex)
	local index = self:getAngleByPos(curPos,pos)
	if index then
		self._roleMc:getController("c1"):setSelectedIndex(index)
	end
end


function SealDevilMapRect:getAngleByPos(p1,p2)
	if p2.x > p1.x then
		return 0
	elseif p2.x < p1.x then
		return 2
	else
		if p2.y > p1.y then
			return 3
		elseif p2.y < p1.y then
			return 1
		end
	end
end

function SealDevilMapRect:isSpeedUp(isUp)
	self._moveTime = isUp and 0.15 or 0.5
end





return SealDevilMapRect