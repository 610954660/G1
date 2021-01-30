---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: 李接健
-- Date: 2020-12-29 19:43:57
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SealDevilGrid
local SealDevilGrid = {}

local SealDevilGrid = class("SealDevilGrid")
function SealDevilGrid:ctor(parent,pos,lineWith,downRotate)
	self.data = false
	self.iconLoder = false
	self._packName = "SealDevil"
	--ui://
	self.gridEvent=false  --每个item 触发的Event
	self.randomEvent=false--随机事件触发器
	self.openEvent=false
	
	
	self._packName = "SealDevil"
	self._gridName = "mapGrid"
	self.view=FGUIUtil.createObjectFromURL(self._packName, self._gridName)
	parent:addChild(self.view)
	self.view:setPosition(pos.x,pos.y)
	self.roadState=self.view:getController("roadState")
	self.hungCom=self.view:getChild("hungCom")
	self.right=self.view:getChild("right")
	self.left=self.view:getChild("left")
	self.up=self.view:getChild("up")
	self.down=self.view:getChild("down")
	
	self.right:setWidth(lineWith)
	self.left:setWidth(lineWith)
	
	self.down:setRotation(downRotate)
	
	
	self.gridObj=false --格子上的怪物对象
	
	self.state= self.view:getChild("state")
	
	
	
end


function SealDevilGrid:initEvent( )
	self.view:addClickListener(function ()	
	     -- RollTips.show("点击了格子"..self.data.point[1].x.." "..self.data.point[1].y.."事件类型"..self.data.type)
		  local showStr="格子"..self.data.point[1].x.." "..self.data.point[1].y.."事件类型 "..self.data.type
		  if SealDevilModel:checkCanMeve(self.data.id) then
				 --RollTips.show(showStr.." 可以移动")
				 if self.gridEvent then
					self.gridEvent()
				 end
		  else
				 RollTips.show(Desc.DevilRoad_str2)
		  end	
	end,21)

end



function SealDevilGrid:setData(data,isRest)
	if isRest then
		self.left:setVisible(false)
		self.right:setVisible(false)
		self.up:setVisible(false)
		self.down:setVisible(false)
	end
	self.data=data
	self:updateGrid()
	self:initEvent()
	self.view:setVisible(true)
end

--1 小怪
--2 宝藏
--3 传送
--4 随机事件
--5 隐藏路线
--6 泉水
--7 Boss


--封魔之路刷新地图每个格子的信息
function SealDevilGrid:updateGrid()

	local data = self.data
	self:setDefault()
	
	if self.data.status==2 then
		self:openBoxRoad()
		return
	end
	if self.data.status==1 then
	   self:setOpenRoad()
	   return 
    end
	self.hungCom:setVisible(true)
	if(data.type == GameDef.DevilRoadGridType.Base ) then
	     --出生点
	elseif(data.type == GameDef.DevilRoadGridType.Monster) then
		 self:creatOrchin()
	elseif(data.type == GameDef.DevilRoadGridType.Treasure) then
		 self:creatBox()
	elseif(data.type == GameDef.DevilRoadGridType.Pass) then
		
         --传送
		 self:creatTransmission()
	elseif(data.type == GameDef.DevilRoadGridType.Random) then
		
		self:creatRandom()
	elseif(data.type == GameDef.DevilRoadGridType.HideRoad) then
         self:creatHideLoad()
	elseif(data.type == GameDef.DevilRoadGridType.Spring) then
		self:creatSpring()
	elseif(data.type == GameDef.DevilRoadGridType.Boss) then
		self:creatBoss()
	end
	
end


--消息刷新格子状态
function SealDevilGrid:event_updateGrid(data)
	self.data.status=data.gridInfo.status
	if data.gridInfo.status==1 then
		self:setOpenRoad()
		if self.randomEvent then
			self.randomEvent(data)
		end
	end
	if self.data.status and self.data.status~=2 and self.data.status~=-1 then --已联通的路线
		SealDevilModel:setNextOpen(self.data)
	end
	self:setGridLine()
end



function SealDevilGrid:setDefault()
	self.roadState:setSelectedPage("pass")
	self:setGridLine()
	if self.gridObj then
		self.gridObj:removeFromParent()
		self.gridObj=false
		self.hungCom:setVisible(false)
	end
end


function SealDevilGrid:openBoxRoad()
	self.gridEvent=function()
		SealDevilModel:devilRoad_Jump(self.data,function (res)
				Dispatcher.dispatchEvent(EventType.DevilRoad_updateGrid,res.data)
		end)
	end
end


function SealDevilGrid:setOpenRoad()
	if self.data.type == GameDef.DevilRoadGridType.HideRoad then
		self:creatHideLoad()
	end
	self.roadState:setSelectedPage("onHero")
	self.gridEvent=function()
		SealDevilModel:devilRoad_Jump(self.data)
	end
	if self.gridObj then
		self.gridObj:removeFromParent()
		self.gridObj=false
		self.hungCom:setVisible(false)
	end
end

--创建小怪
function SealDevilGrid:creatOrchin()
	self.gridObj=FGUIUtil.createObjectFromURL(self._packName, "orchin")
	self.hungCom:addChild(self.gridObj)
	self.roadState:setSelectedPage("pass")
	self.gridEvent=function()
		SealDevilModel:devilRoad_challege(self.data,function(data)
			 ViewManager.open("DevilBuffView",{skillList=data.chooseBuffs})
		end)
	end
end


--创建boss
function SealDevilGrid:creatBoss()
	self.gridObj=FGUIUtil.createObjectFromURL(self._packName, "boss")
	self.hungCom:addChild(self.gridObj)
	self.roadState:setSelectedPage("boss")
    printTable(5656,self.data)
	self.gridEvent=function()
		SealDevilModel:devilRoad_challege(self.data,function(data)
				SealDevilModel:setCurGatePass()
				--ViewManager.open("DevilBuffView",{skillList=data.chooseBuffs})
		end)
	end
	
end


--创建宝箱
function SealDevilGrid:creatBox()
	self.gridObj=FGUIUtil.createObjectFromURL(self._packName, "box")
	self.hungCom:addChild(self.gridObj)
	self.roadState:setSelectedPage("pass")
	self.gridEvent=function()
		SealDevilModel:devilRoad_Jump(self.data,function (res)
			self:event_updateGrid(res.data)
		end)
	end
end


--创建隐藏通道
function SealDevilGrid:creatHideLoad()
	--self.gridObj=FGUIUtil.createObjectFromURL(self._packName, "box")
	--self.hungCom:addChild(self.gridObj)
	local mapData=SealDevilModel:getMapData()
	local selfIndex=self.data.point[1]

	local nextIndex=mapData[self.data.nextId2[1]].point[1]
	if nextIndex.x-selfIndex.x==1 and nextIndex.y==selfIndex.y then
		self.right:setURL(UIPackageManager.getUIURL(self._packName,"hideLine_X"))
	end
	if nextIndex.x-selfIndex.x==-1 and nextIndex.y==selfIndex.y then
		self.left:setURL(UIPackageManager.getUIURL(self._packName,"hideLine_X"))
	end
	if nextIndex.y-selfIndex.y==1 and nextIndex.x==selfIndex.x then
		self.down:setURL(UIPackageManager.getUIURL(self._packName,"hideLine_Y"))
	end
	if nextIndex.y-selfIndex.y==-1 and nextIndex.x==selfIndex.x then
		local gridItem=SealDevilModel.mapGrids[nextIndex.x][nextIndex.y]
		gridItem.down:setURL(UIPackageManager.getUIURL(self._packName,"hideLine_Y"))
	end

	
	self.roadState:setSelectedPage("pass")
	self.gridEvent=function()
		SealDevilModel:devilRoad_challege(self.data,function(data)
				ViewManager.open("DevilBuffView",{skillList=data.chooseBuffs,exitFunc=function()	
							self:showAlert(function () end,"ok")
				end})	
		end)
	end
end



--创建传送阵
function SealDevilGrid:creatTransmission()

	self.openEvent=function()  --传送阵需要打赢小怪的时候才开启
		local eff = SpineMnange.createByPath("Spine/ui/pveStarTemple","xingchenshengsuo_texiao","xingchenshengsuo_texiao")
		eff:setAnimation(0,"animation",true)
		self.gridObj=fgui.GObject:create()
		self.gridObj:setScale(0.5,0.5)
		self.gridObj:displayObject():addChild(eff)
		self.hungCom:addChild(self.gridObj)
		self.gridObj:setPosition(0,-28)
	end
	
	--传送到指定位置
	local function transTo()
		local girdInfo={
			id =self.data.nextId2[1],
			status=0,
			isTrigger=true, --传送后触发当前格子事件
		}
		Dispatcher.dispatchEvent(EventType.DevilRoad_updateGrid,{gridInfo=girdInfo})
	end
	
	
	
	
	local function openTrans()--传送阵已经是开放状态
		self.openEvent()
		self.gridEvent=function()
			SealDevilModel:devilRoad_Jump(self.data,function ()
					self:showAlert(transTo)
				end)
		end
	end 
	
	
	if self.data.status==3 then 
		 openTrans()
	else                         
		self.gridEvent=function()--传送阵没有开发需要挑战
			SealDevilModel:devilRoad_challege(self.data,function(data)
					openTrans()
					ViewManager.open("DevilBuffView",{skillList=data.chooseBuffs,exitFunc=function()
								self:showAlert(transTo)--选择buff后弹提示
					end})
			end)
		end
	end
end



--创建泉水
function SealDevilGrid:creatSpring()
	self.gridObj=FGUIUtil.createObjectFromURL(self._packName, "spring")
	self.hungCom:addChild(self.gridObj)
	self.roadState:setSelectedPage("pass")
	self.gridEvent=function()
		SealDevilModel:devilRoad_Jump(self.data,function ()
				self:showAlert()
		end)
	end
	self.randomEvent=function(data)
        RollTips.show("所有探员已恢复气血")
	end
end



--创建随机事件
function SealDevilGrid:creatRandom()
	self.gridObj=FGUIUtil.createObjectFromURL(self._packName, "rdEvent")
	self.hungCom:addChild(self.gridObj)
	self.roadState:setSelectedPage("pass")
	self.gridEvent=function()
		SealDevilModel:devilRoad_Jump(self.data,function ()
			self:showAlert()
		end)
	end
	
	self.randomEvent=function(data)	
		data.type=self.data.type
		ViewManager.open("DevilEventView",{data=data})	
	end
	
end


function SealDevilGrid:showAlert(yesFunc,type)
	local info = {}
	local descData=DynamicConfigData.t_DevilRoadDesc[self.data.type][1]
	
	if descData.DescValue then
		descData.showDesc=string.format(descData.showDesc,self.data.effect/100)
	end
	
	
	info.text = descData.showDesc
	info.title = descData.showName
	info.yesText ="开启"
	info.noText = "不开启"
	info.mask = true
	info.type = type or "yes_no"
	info.onYes = function()
		if yesFunc then
			yesFunc()
		else
			SealDevilModel:devilRoad_Action()
		end
	end
	info.onNo = function()
			
	end
	Alert.show(info)
	
end



function SealDevilGrid:setLineState()
	self.down:setVisible(true)
end



function SealDevilGrid:setGridLine()
	if not self.data then
		return 
	end
	
	if self.data.type == GameDef.DevilRoadGridType.HideRoad and self.data.status~=1 then
		return 
	end
	
	
	local mapData=SealDevilModel:getMapData()
		local selfIndex=self.data.point[1]
		for k, id in pairs(self.data.nextId) do
			local nextIndex=mapData[id].point[1]
			if nextIndex.x-selfIndex.x==1 and nextIndex.y==selfIndex.y then
				self.right:setVisible(true)
			end
			if nextIndex.x-selfIndex.x==-1 and nextIndex.y==selfIndex.y then
				self.left:setVisible(true)
			end
			if nextIndex.y-selfIndex.y==1 and nextIndex.x==selfIndex.x then
				self.down:setVisible(true)
			end
			if nextIndex.y-selfIndex.y==-1 and nextIndex.x==selfIndex.x then
				local nextGridItem=SealDevilModel.mapGrids[nextIndex.x][nextIndex.y]
				nextGridItem.down:setVisible(true)
			end
	end
end



return SealDevilGrid