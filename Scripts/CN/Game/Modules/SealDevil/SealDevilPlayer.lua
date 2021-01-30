---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-12-29 20:06:52
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SealDevilPlayer
--local SealDevilPlayer = {}
local SealDevilPlayer = class("SealDevilPlayer")


function SealDevilPlayer:ctor(view,mapItems)
	
	
	self.view=view
	self._mapGrids = mapItems
	
	
	local heroId = ModelManager.HandbookModel.heroOpertion 
	local skeletonNode=SpineMnange.createSprineById(heroId, true)
	skeletonNode:setAnimation(0, "stand", true);
	
	
	self.spineParent = fgui.GObject:create()
	self.spineParent:displayObject():addChild(skeletonNode)
	self.view:addChild(self.spineParent)
	self.spineParent:setScale(0.8,0.8)
	
	
	local gridInfo= SealDevilModel:getPlayerGrid()
	self:setMove(gridInfo.point[1])

end





function SealDevilPlayer:setMove(point)
	local grid=self._mapGrids[point.x][point.y]
	--grid:setOnHero()
	local goWrap=grid.view:getChild("goWrap")
	local rootPos=self.view:globalToLocal(goWrap:getParent():localToGlobal(goWrap:getPosition()))
	self.spineParent:setPosition(rootPos.x,rootPos.y)
end







return SealDevilPlayer