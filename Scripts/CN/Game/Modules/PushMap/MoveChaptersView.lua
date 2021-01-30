--Name : MoveChaptersView.lua
--Author : generated by FairyGUI
--Date : 2020-4-9
--Desc : 

local MoveChaptersView,Super = class("MoveChaptersView", Window)

function MoveChaptersView:ctor()
	--LuaLog("MoveChaptersView ctor")
	self._packName = "PushMap"
	self._compName = "MoveChaptersView"
	
	self.worlkMapView=false
	
	self.MapWidth=false
	self.MapHeight=false
	self.centerPoint=false
	
	
	self.maxSize=3
	
	self.lastIndex_Y=0
	self.lastIndex_X=0
	
	self.move=true
    
	self.initPos=false
	
	
	--self._rootDepth = LayerDepth.Window
	
end

function MoveChaptersView:_initEvent( )
	
end

function MoveChaptersView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	

end

function MoveChaptersView:_initUI( )
	self:_initVM()
	self.MapWidth=fgui.GRoot:getInstance():getViewWidth()
	self.MapHeight=fgui.GRoot:getInstance():getViewHeight()
	self.centerPoint={x=self.MapWidth/2,y=self.MapHeight/2}
	
	
	self.mapList=self.view:getChildAutoType("mapList")
	self.initPos=self.mapList:getPosition()
	
	
	self.mapList:addEventListener(FUIEventType.Scroll,function (context)
         --printTable(4,context:getDataValue(),"context")
		   --printTable(4,self.mapList:localToGlobal(Vector2.zero))
		   --printTable(4,self.mapList:getChildAutoType("00"):getPosition())
		   local indexPos=self.mapList:getChildAt(0):localToGlobal(Vector2.zero)
		   self:checkIndexPos(indexPos);
	end)
	--self.mapList:setScale(2,2)
	local za1=self.mapList:getChildAt(0):getChildAutoType("zj1")
	local za3=self.mapList:getChildAt(0):getChildAutoType("zj3")
	local za2=self.mapList:getChildAt(0):getChildAutoType("zj2")
	local za4=self.mapList:getChildAt(0):getChildAutoType("zj4")
	local za5=self.mapList:getChildAt(0):getChildAutoType("zj5")
	--local n32=self.view:getChildAutoType("n32")
	
	--n32:addClickListener(function ()
			--self.move=not self.move
		--end)
	
	
	za1:addClickListener(function ()
		if PushMapModel:getCurMaxCityOpen(1) then
			self:zoomInto(za1,1)
		else
			RollTips.show('当前城市未开启')
		end
	end)
	za3:addClickListener(function ()
		if PushMapModel:getCurMaxCityOpen(3) then
			self:zoomInto(za3,3)
		else
			RollTips.show('当前城市未开启')
		end
	end)
	
	za2:addClickListener(function ()
		if PushMapModel:getCurMaxCityOpen(2) then
			self:zoomInto(za2,2)
		else
			RollTips.show('当前城市未开启')
		end
	end)

	za4:addClickListener(function ()
		if PushMapModel:getCurMaxCityOpen(4) then
			self:zoomInto(za4,4)
		else
			RollTips.show('当前城市未开启')
		end	
	end)
	
	za5:addClickListener(function ()
		if PushMapModel:getCurMaxCityOpen(5) then
			self:zoomInto(za5,5)	
		else
			RollTips.show('当前城市未开启')
		end	
	end)
	
	
end


function MoveChaptersView:zoomInto(parent,cityId)
	
	--self.view:getTransition("t0"):play(function ()
		
	--end)
	local obj=parent:getChildAutoType("centerPos")
	self.mapList:setScale(2,2)
	local from= obj:localToGlobal(Vector2.zero)

	if from.x==self.centerPoint.x and from.y==self.centerPoint.y or self.move==false then
		return
	end
	local pos= {x=self.centerPoint.x-from.x,y=self.centerPoint.y-from.y}
	local targetPos={x=self.mapList:getPosition().x+pos.x,y=self.mapList:getPosition().y+pos.y}
	
	

	local a1= fgui.GTween:to(self.mapList:getPosition(),targetPos,1)
	a1:setEase(7)
	a1:onUpdate(function(tweener)
			if tolua.isnull(self.view) then
				return
			end
			self.mapList:setPosition(tweener:getDeltaValue():getVec2().x,tweener:getDeltaValue():getVec2().y)
		end
	)
	a1:onComplete(function ()
			if tolua.isnull(self.view) then
				return
			end
	end)
	
	local a2= fgui.GTween:toDouble(1,2,1)
	a2:setEase(7)
	a2:onUpdate(function(tweener)
	       if tolua.isnull(self.view) then
	     return
	end
	self.mapList:setScale(tweener:getDeltaValue():getD(),tweener:getDeltaValue():getD())
	    end
	)
	a2:onComplete(function ()
	      if tolua.isnull(self.view) then
	        return
		   end
	       Scheduler.schedule(function()
					if tolua.isnull(self.view) then
						return
					end
					self.mapList:setScale(1,1)
					self.mapList:setPosition(self.initPos.x,self.initPos.y)
			end,0.5,1)
			printTable(9,'cityId>>>>>>>>>>>>>>',cityId)
			PushMapModel:getOldBattleData(cityId);
			ViewManager.open("PushMapChaptersView",{cityId});
	end)
	
	
	

	

	
end



function MoveChaptersView:showMap(id)
	print(4,"需要显示的图块",id)
end


function MoveChaptersView:hideMap(id)
	print(4,"需要隐藏的图块",id)
end




--判断当前显示位置最外一圈图块
function MoveChaptersView:checkIndexPos(indexPos)
	local index_X=math.floor((-indexPos.x)/self.MapWidth)
	local index_Y=math.floor((-indexPos.y)/self.MapHeight)

	if self.lastIndex_X==index_X and  self.lastIndex_Y==index_Y  then
		return 
	else
		self.lastIndex_X=index_X
		self.lastIndex_Y=index_Y
	end
    for x = 0, self.maxSize-1 do	
		for y = 0, self.maxSize-1 do
			local cx=x+index_X
			local cy=y+index_Y
			if math.abs(x-index_X)<2 and math.abs(y-index_Y)<2 then
				self:showMap(x..y)
			else
				self:hideMap(x..y)
			end
		end
    end
end






return MoveChaptersView