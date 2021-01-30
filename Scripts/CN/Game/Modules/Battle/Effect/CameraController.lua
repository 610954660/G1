---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-05-27 15:53:21
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class CameraControlle
local CameraController = {}

local screenView=nil
local shakeView=nil
local shakeLists={}
local fguiShakeAc=false
local MapWidth=false
local MapHeight=false
local centerPos=false
local actionList={}
local lastViewPos=Vector2.zero

local skakeType={
	[0]={0,0},
	[1]={1,0.25},
	[2]={2,0.25},
	[3]={3,0.25}
}

local initPos=false

--local 
--x=	tonumber(self.canshu.posx:getText()),
--y=	tonumber(self.canshu.posy:getText()),
--scale=	tonumber(self.canshu.scale:getText()),
--ease=	tonumber(self.canshu.ease:getText()),
--duration=	tonumber(self.canshu.duration:getText()),
--resetTime=	tonumber(self.canshu.resetTime:getText()),

function CameraController.zoomInto(focus,moData,finished)
	
	local iPivotX = focus.x / MapWidth;
	local iPivotY = focus.y / MapHeight;
	local fromScale={x=screenView:getScaleX(),y=screenView:getScaleY()}
	if   moData.scale~=1 then
		screenView:setPivot(iPivotX,iPivotY,false)
	end

	local from =screenView:getPosition()

	local to=Vector2(moData.x,moData.y)
	local function runAction()
	    TweenUtil.scaleTo(screenView, {from = {x = fromScale.x, y = fromScale.y}, to = {x = moData.scale, y =moData.scale}, time = moData.duration, ease = moData.ease})
		local function complete()
	
		end
		local sId =BattleManager:schedule(function()
				if finished then
					finished()
				end
				if moData.scale==1 then
					screenView:setPivot(0,0,false)
				end
		end,moData.resume+moData.duration, 1)
		TweenUtil.moveTo(screenView, {onComplete = complete,from = from, to = to, time = moData.duration, ease = moData.ease,tweenType="Battle"})

	end
	if moData.delay=="" then
		moData.delay=0
	end
	BattleManager:schedule(function()
			runAction()
	end,moData.delay, 1)

end

--function CameraController.zoomInto2(focus,moData,finished)

	--local iPivotX = focus.x / MapWidth;
	--local iPivotY = focus.y / MapHeight;
	--screenView:setPivot(iPivotX,iPivotY,false)
	--local from =screenView:getPosition()
	--local to=Vector2(moData.x,moData.y)
	--if moData.delay=="" then
		--moData.delay=0
	--end
	--local a0=cc.DelayTime:create(moData.delay)
	--local a1=cc.MoveBy:create(moData.duration,to)
	--local a4=cc.ScaleTo:create(moData.duration,moData.scale)
	--local a2=cc.DelayTime:create(moData.resume)
	--local a3=cc.CallFunc:create(function()
			--finished()
		--end)
	--screenView:displayObject():runAction( cc.Sequence:create(a0,cc.Spawn:create(a1,a4),a2,a3))

--end

function CameraController.creatorActions(focus,moData)
	local iPivotX = focus.x / MapWidth;
	local iPivotY = focus.y / MapHeight;
	local to=Vector2(moData.x,moData.y)
	--to.y=to.y*10
	--printTable(086,to,".......")
	if moData.delay=="" then
		moData.delay=0
	end
	local viewNode=screenView:displayObject()
	local a=cc.CallFunc:create(function()
		 screenView:setPivot(0.5,0.5,false)
	end)
	local a0=cc.DelayTime:create(moData.delay)
	local a2=cc.MoveBy:create(moData.duration,to)
	local a3=cc.ScaleTo:create(moData.duration,moData.scale)
	local a4=cc.Spawn:create(a2,a3)
	
	local a1=cc.DelayTime:create(moData.resume)
	printTable(0232,to,"creatorActions")
	table.insert(actionList,a)
	table.insert(actionList,a0)
	table.insert(actionList,a4)
	table.insert(actionList,a1)
	if moData.autoBack then
		local backFunc=cc.CallFunc:create(function()
			  CameraController.resetScreenView()	
		end)
		table.insert(actionList,backFunc)
	end
	
	
end


function CameraController.runActions(finished)
	if next(actionList)== nil then
		return
	end
	local a=cc.CallFunc:create(function()
			actionList={}
			if finished then
				finished()
			end
	end)
	table.insert(actionList,a)
	screenView:displayObject():runAction(cc.Sequence:create(actionList))
end





function CameraController.runCameraId(cameraId,attacker,beAttackers,finished)
	local cameraData=DynamicConfigData.t_CameraPara[cameraId]

	if cameraData==nil then
		finished()
		return 
	end
	CameraController.setScreenView()
	local baseData=clone(cameraData)
	print(0232,"runCameraId",cameraData.cameraType,cameraId)
	if cameraData.cameraType==1 then --镜头跟随玩家自己	
		local focus=screenView:localToGlobal(attacker.view:getPosition())
		focus.x=math.ceil(focus.x)
		focus.y=math.ceil(focus.y)
		baseData.x=centerPos.x-focus.x-baseData.x
		baseData.y=centerPos.y-focus.y+baseData.y
		local moveByX=baseData.x-lastViewPos.x
		local moveByY=baseData.y-lastViewPos.y
		lastViewPos.x=clone(baseData.x)
		lastViewPos.y=clone(baseData.y)
		baseData.x=moveByX
		baseData.y=-moveByY
		CameraController.creatorActions(focus,baseData)
		finished()
		return
	end
	if cameraData.cameraType==2 then --镜头跟随攻击目标平均值
		local focus=Vector2.zero
		for k, beAttacker in pairs(beAttackers) do
		     local  temp=screenView:localToGlobal(beAttacker.view:getPosition())
			 focus.x=focus.x+temp.x
			 focus.y=focus.y+temp.y
		end
		focus={x=focus.x/table.nums(beAttackers),y=focus.y/table.nums(beAttackers)}
		baseData.x=centerPos.x-focus.x
		baseData.y=centerPos.y-focus.y
		CameraController.zoomInto(focus,baseData,function ()
				finished()
			end)
		return
	end
	if cameraData.cameraType==3 then 
		local focus=centerPos
		baseData.x=0
		baseData.y=0
		CameraController.zoomInto(focus,baseData,function ()
				finished()
			end)
		return
	end
	if cameraData.cameraType==4 then --镜头自定义移动
		local focus=false
		--print(086,baseData.x,baseData.y,"??")
		if attacker.heroPos==BattleModel.HeroPos.player then
		    focus=Vector2(baseData.x,baseData.y)
		else
			focus=Vector2(-baseData.x,baseData.y)
		end
		baseData.x=-focus.x
		local moveByX=baseData.x-lastViewPos.x
		local moveByY=baseData.y-lastViewPos.y
		lastViewPos.x=clone(baseData.x)
		lastViewPos.y=clone(baseData.y)
		baseData.x=moveByX
		baseData.y=moveByY
		print(0232,moveByX,moveByY,"\\\\")
		CameraController.creatorActions(focus,baseData)
		finished()
		return
	end
end



function CameraController.zoomIntoTest(attacker,cameraData,finished)

	local baseData=clone(cameraData)
	if cameraData.cameraType==1 then --镜头跟随玩家自己
		local focus=screenView:localToGlobal(attacker.view:getPosition())
		focus.x=math.ceil(focus.x)
		focus.y=math.ceil(focus.y)
		baseData.x=centerPos.x-focus.x-baseData.x
		baseData.y=centerPos.y-focus.y+baseData.y
		
		local moveByX=baseData.x-lastViewPos.x
		local moveByY=baseData.y-lastViewPos.y
		
		lastViewPos.x=clone(baseData.x)
		lastViewPos.y=clone(baseData.y)
		baseData.x=moveByX
		baseData.y=-moveByY
		CameraController.creatorActions(focus,baseData)
		finished()	
	    --focus=screenView:localToGlobal(attacker.view:getPosition())--老的实现方式
		--focus.x=math.ceil(focus.x)
		--focus.y=math.ceil(focus.y)
		--baseData.x=centerPos.x-focus.x
		--baseData.y=centerPos.y-focus.y
		--CameraController.zoomInto(focus,baseData,function ()
				--finished()
		--end)
		return
		
	end
	if cameraData.cameraType==2 then --镜头跟随攻击目标平均值
		RollTips.show("cameraType==2 镜头跟随攻击目标平均值测试面板没添加")
		finished()
	end
	if cameraData.cameraType==3 then --镜头跟随攻击目标平均值
		RollTips.show("cameraType==3 镜头回到初始点 测试面板没添加")
		finished()
	end
	if cameraData.cameraType==4 then --镜头自定义移动
		local focus=false
		focus=Vector2(baseData.x,baseData.y)
		baseData.x=-focus.x
		local moveByX=baseData.x-lastViewPos.x
		local moveByY=baseData.y-lastViewPos.y
		lastViewPos.x=clone(baseData.x)
		lastViewPos.y=clone(baseData.y)
		baseData.x=moveByX
		baseData.y=moveByY
		print(086,moveByX,moveByY)
		CameraController.creatorActions(focus,baseData)
		finished()
		return
	end
	

end


local unitIndex =1
function CameraController.getUnitIndex()
	unitIndex = unitIndex + 1
	return unitIndex
end
--施法屏幕震动（镜头表调）
function CameraController.shakingView(shockId,finished)
	
    local shockData=DynamicConfigData.t_Shock[shockId]
	CameraController.setScreenView()
	local t=false
	if shakeView then
		t=shakeView:getTransition(tostring(shockData.shockType))
	else
		t=screenView:getTransition(tostring(shockData.shockType))
	end
	if t then
		local tIndex=CameraController.getUnitIndex()
		shakeLists[tIndex]=t
		local a0=cc.DelayTime:create(shockData.delay)
		local a1=cc.CallFunc:create(function()
				t:play(function ()
					
				end)
		end)
		local a2=cc.DelayTime:create(shockData.duration)
		local a3=cc.CallFunc:create(function()
				t:stop(true,false)
				shakeLists[tIndex]=nil	
				--print(086,screenView:getGroup())
				--screenView:getGroup():setPosition(0,0)
				finished()
		end)
		screenView:displayObject():runAction(cc.Sequence:create(a0,a1,a2,a3))
	end
end

--受击屏幕震动（skill表调）
function CameraController.fguiShakeView(type)
	if not shakeView then
		return 
	end
	local fguiShakeObj=shakeView:getChild("shakeNode") --or shakeView
	fguiShakeAc= fgui.GTween:shake(shakeView:getPosition(),skakeType[type][1],skakeType[type][2])
	fguiShakeAc:setEase(12)
	fguiShakeAc:onUpdate(function(tweener)
			if tolua.isnull(fguiShakeObj) then
				print(4,"shakeView 已经移除")
				return
			end
		fguiShakeObj:setPosition(tweener:getDeltaValue():getVec2().x,tweener:getDeltaValue():getVec2().y)
	end)
	fguiShakeAc:onComplete(function(tweener)
			if tolua.isnull(shakeView) then
				return
			end
			fguiShakeAc=false
	end)
end




function CameraController.resumeView(finished)
	TweenUtil.scaleTo(screenView, {from = screenView:getScale(), to = {x = 1, y =1}, time = 1, ease = EaseType.QuartOut,tweenType="Battle"})
	TweenUtil.moveTo(screenView, {onComplete = finished,from = screenView:getPosition(), to = Vector2.zero, time = 1, ease = EaseType.QuartOut,tweenType="Battle"})
end

local layerColor=nil
local blankMask=nil


function CameraController.setScreenView(view,shakeNode)	

	if screenView==nil then
		shakeView=shakeNode
		if view==nil then 
			local top=ViewManager.getLayerTopWindow(LayerDepth.Window)
			view=top.window.view
		end
		screenView=view
		MapWidth=fgui.GRoot:getInstance():getViewWidth()
		MapHeight=fgui.GRoot:getInstance():getViewHeight()
		centerPos=Vector2(MapWidth/2,MapHeight/2)
		screenView:addEventListener(FUIEventType.Exit,function(context)
	      screenView=nil
		  layerColor=nil	
		end);
		initPos=Vector2(screenView:displayObject():getPositionX(),screenView:displayObject():getPositionY())
	end
	if  layerColor==nil then
		
		layerColor= cc.LayerColor:create({r=0,g=0,b=0,a=0},display.width,display.height)
		blankMask = fgui.GObject:create()
		blankMask:setTouchable(false)
		layerColor:setScale(1.2,1.2)
		blankMask:displayObject():addChild(layerColor)
		screenView:addChild(blankMask)
		local pos = screenView:globalToLocal(Vector2(0, display.height))
		blankMask:setPosition(pos.x,pos.y)
	end
end

function CameraController.getScreenView()
    return screenView
end

function CameraController.getViewCenter()
	return centerPos
end

--黑屏
function CameraController.blankScreen()
	 CameraController.setScreenView()
	 blankMask:setVisible(true)
	 layerColor:runAction(cc.FadeTo:create(0.3,150))
	 return blankMask,layerColor
end

--亮屏
function CameraController.lightScreen(complete)
	if not tolua.isnull(layerColor) and blankMask:isVisible() then
		local finished=cc.CallFunc:create(function ()
				if complete then
					complete()
				end
				blankMask:setVisible(false)
			end)
		layerColor:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),finished))
	else
		if complete then
			complete()
		end
	end
end

function CameraController.resetScreenView()
    if screenView then
		screenView:displayObject():stopAllActions()	
		screenView:setPivot(0,0,false)
		screenView:displayObject():setScale(1,1)
		screenView:displayObject():setPosition(0,0)
		screenView:setScale(1,1)
		lastViewPos=Vector2.zero
		if fguiShakeAc then
			fguiShakeAc:kill()
			fguiShakeAc=false
		end
		if next(shakeLists)~=nil then
		   for k, t in pairs(shakeLists) do
				if not tolua.isnull(t) then
					t:stop(true,false)
				end
		   end
		   shakeLists={}
		   --unitIndex=1
		end
		
	end
	print(086,"resetScreenView")
end

--释放技能时隐藏不相关的角色
function CameraController.hideHeroByScreenType(attacker,beAttackers,screenType)
	if screenType~="" and screenType~=0 then
		for k, v in pairs(BattleModel:getLifeHero()) do
			v.view:setVisible(false)
		end
	end
	if screenType==2 then
		for k, v in pairs(beAttackers) do
			v.view:setVisible(true)
		end
		attacker.view:setVisible(true)
	end
	if screenType==1 then
		attacker.view:setVisible(true)
	end
end

function CameraController.getSelfLocalPos(pos)
	local top=ViewManager.getLayerTopWindow(LayerDepth.Window)
	local view=top.window.view
	return view:globalToLocal(pos)
end


function CameraController.clear()
	--layerColor:stopAllActions()
end

----获取组件本身的屏幕坐标
--function CameraController.getSelfScreenPos(item)
	--return screenView:localToGlobal(item:getPosition())
--end



return CameraController

