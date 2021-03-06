--Name : DevilResView.lua
--Author : generated by FairyGUI
--Date : 2020-4-13
--Desc : 神之遗物 xhd

local DevilResView,Super = class("DevilResView", Window)
local MazeConfiger  = require "Game.ConfigReaders.MazeConfiger"
function DevilResView:ctor()
	--LuaLog("DevilResView ctor")
	self._packName = "SealDevil"
	self._compName = "DevilResView"
	self._rootDepth = LayerDepth.PopWindow
	self.data = {}
end

function DevilResView:_initEvent( )
	
end

function DevilResView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Maze.DevilResView
	vmRoot.list = viewNode:getChildAutoType("list")--list
	vmRoot.list:setOpaque(false)
	--{vmFieldsEnd}:Maze.DevilResView
	--Do not modify above code-------------
end

function DevilResView:_initUI( )
	self:_initVM()
	--local config = DynamicConfigData.t_DevilRoadSkill
	
	
	
	self.list:setItemRenderer(function( index,obj )
            local skill=self.data[index+1]
			local skillData=DynamicConfigData.t_DevilRoadSkill[skill]
			-- printTable(1,config)
			local name = obj:getChildAutoType("name")
			local btype = obj:getChildAutoType("btype")
			local icon = obj:getChildAutoType("icon")
			local icon2 = obj:getChildAutoType("icon2")
			local titleTxt = obj:getChildAutoType("skilltxt")
			name:setText(skillData.skillName)
			--local 
			obj:getController("c1"):setSelectedIndex(skillData.color-1)
			icon:setURL(string.format("%s%s.png", "Icon/maze/", skillData.icon))
			btype:setURL(UIPackageManager.getUIURL(self._packName,"t"..skillData.color))
			--icon2:setURL(string.format("%s%s.png", "Icon/maze/", config.apply))
			titleTxt:setText(skillData.showName)
	end)
	
	self.data = SealDevilModel.curBuffs
	if tolua.isnull(self.view) then return end
	if self.data and #self.data>0 then
		--printTable(1,self.data)
		self.view:getController("noDataCtrl"):setSelectedIndex(0)
		self.list:setData(self.data)
	else
		self.view:getController("noDataCtrl"):setSelectedIndex(1)
	end
	
end




return DevilResView