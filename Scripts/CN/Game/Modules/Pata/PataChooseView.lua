local PataChooseView,Super = class("PataChooseView", Window)
local OpenParam=require "Game.Consts.OpenParam"
function PataChooseView:ctor()
	LuaLogE("PataChooseView ctor")
	self._packName = "Pata"
	self._compName = "PataChooseView"
		
	--self.viewData = {
		--{battleArrayType=6,name="第五之塔",activeType=2000,towerType=1,rankType=2,space = -15,showCount = 6,moveCount = 4},
		--{battleArrayType=7,name="幻想之柱",activeType=2001,towerType=5,rankType=4,space = 0,showCount = 6,moveCount = 4},
		--{battleArrayType=8,name="世界树之心",activeType=2002,towerType=4,rankType=3,space = 0,showCount = 6,moveCount = 4},
		--{battleArrayType=9,name="虚拟之殿",activeType=2003,towerType=6,rankType=5,space = 13,showCount = 5,moveCount = 4},
		--{battleArrayType=16,name="双重之圣",activeType=2005,towerType=2,rankType=19,space = -4,showCount = 6,moveCount = 4}
	--}
	self.viewData={}
	for k, v in pairs(OpenParam.PataParam) do
		table.insert(self.viewData,v)
	end
	--self.viewData=OpenParam.PataParam
	table.sort(self.viewData,function (a,b)
			return a.type<b.type
	end)
	

	self.items = false
	self._rootDepth = LayerDepth.Window
end

function PataChooseView:_initUI()
	LuaLogE("PataChooseView _initUI")
	self.items = {}
	--self.closeBtn = self.view:getChildAutoType("frame/closeBtn")
	self:setBg("worldchallengeArena.jpg")
	local k=0
	for activeType,v in pairs(self.viewData) do
		k=k+1
		local item = self.view:getChildAutoType("btn_type"..k)
		if k==1 then
			local imgRed = item:getChildAutoType("img_red")
			RedManager.register( "V_TOWER" , imgRed , self.view , ModuleId.Tower.id )
		end
		
		RedManager.register( v.battleArrayType , item:getChildAutoType("image_battle") , self.view , ModuleId.Tower.id )
		SpineUtil.createBattleFlag(item:getChildAutoType("image_battle"))
		
		
		
		--print(521000 , "Item : " , "btn_type"..k , item)
		item.relationLoader = item:getChildAutoType("relationLoader")
		--item.txt_name:setText( v.name )
		item.txt_layer = item:getChildAutoType("floorIndex")
		--item.txt_layer:setText( "第"..k.."层" )		
		item.txt_time = item:getChildAutoType("openTime")
		--item.txt_time:setText( "" )
		item:addClickListener(function ( ... )
			local towerOpen = true
			if v.activeType~= 2000 then
				towerOpen = ModuleUtil.moduleOpen( ModuleId.TowerRace.id, true )					
				if towerOpen ~= true then return end
			end			
			if towerOpen == true then
				ViewManager.open("PataView" , {
					type = v.battleArrayType,
					activeType = v.activeType,
					towerType = v.towerType,
					rankType = v.rankType,
					name = v.name,
					space = v.space,
					showCount = v.showCount,
					moveCount = v.moveCount,
					category= v.category,
				})
			end
		end)
		self.items[activeType] = item
	end
	PataModel:updateRed()
	--[[self.closeBtn:addClickListener(function()
		self:closeView()
	end)--]]

	self:updateView()
end
function PataChooseView:pata_showNext()
	self:updateView()
end

----添加红点
--function PataChooseView:_addRed( ... )
	--local imgRed = self.btnRank:getChildAutoType("img_red")
	--RedManager.register( "V_TOWER_RANK" , imgRed , self.view , ModuleId.Tower.id )
--end


function PataChooseView:updateView()	
	for k,item in pairs(self.items) do
		local activeType = self.viewData[k].activeType
		local floor = ModelManager.PataModel:getPataFloor(activeType);				
		item.txt_layer:setText(floor.."层" )
			
		local hasOpen = ModelManager.PataModel:isOpen( activeType )
		local cfg_towerType = DynamicConfigData.t_towerType[ activeType ]
		item.relationLoader:setURL(PathConfiger.getCardSmallCategory(cfg_towerType.iconRes))
		
		
		if hasOpen ~= true then
			item.txt_time:setText( cfg_towerType.openTips )
			item:getController("open"):setSelectedPage("false")
			--item:setGrayed(true)
			item:setTouchable(false)
		else 
			item:getController("open"):setSelectedPage("true")
			item:setGrayed(false)
			item:setTouchable(true)	
			item.txt_time:setText( "" )
		end

		printTable(1 , "爬塔副本信息： ", hasOpen , floor )

	end
end

--initEvent后执行
function PataChooseView:_enter( ... )
	print(1,"PataChooseView _enter")
end


function PataChooseView:_initEvent( ... )
	self:addEventListener(EventType.pata_showNext,self)
end

function PataChooseView:_exit()
	--doExit Excute
end

return PataChooseView
