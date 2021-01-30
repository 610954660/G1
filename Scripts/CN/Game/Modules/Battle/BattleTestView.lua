
---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-13 19:30:46
---------------------------------------------------------------------
-- 战斗开始之后
--
---@class BattleTestView
local BattleTestView,Super = class("BattleTestView", Window)
local HeroPos=ModelManager.BattleModel.HeroPos
local SeatType=ModelManager.BattleModel.SeatType
local HeroItem=require "Game.Modules.Battle.Cell.HeroItem"
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
local battleData= require "Game.Modules.Battle.Cell.battleData"--暂时通过一个表的形式下发战报数据
local CameraController=require "Game.Modules.Battle.Effect.CameraController"

function BattleTestView:ctor()
	self._packName = "Battle"
	self._compName = "BattleTestView"
	self.battlePackge="Battle"
    --self._showParticle = true
	self.playFx=false
	self.addHero=false
	
	self.skillId=false
	self.heroId=false
	self.buffId=false
	self.targetId=false
	
	
	self.heroList=false
	self.skillList=false
	self.buffList=false
	
	
	self.L_item=false
	
	self.haveData=false
	self.fightTest=false
	
	self.fullScreen=false
	
	self.isBezier=false
	
    self.testSkillType=0
end

function BattleTestView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Battle.BattleTestView
		vmRoot.AttackList = viewNode:getChildAutoType("$AttackList")--Label
		vmRoot.targetlList = viewNode:getChildAutoType("$targetlList")--Label
		vmRoot.testEffect = viewNode:getChildAutoType("$testEffect")--Button
		local canshu1 = viewNode:getChildAutoType("$canshu1")--Label
		vmRoot.canshu1 = canshu1
			canshu1.duration = viewNode:getChildAutoType("$canshu1/$duration")--text
			canshu1.delayTime = viewNode:getChildAutoType("$canshu1/$delayTime")--text
			canshu1.scale = viewNode:getChildAutoType("$canshu1/$scale")--text
			canshu1.ease = viewNode:getChildAutoType("$canshu1/$ease")--text
			canshu1.resetTime = viewNode:getChildAutoType("$canshu1/$resetTime")--text
			canshu1.posx = viewNode:getChildAutoType("$canshu1/$posx")--text
			canshu1.posy = viewNode:getChildAutoType("$canshu1/$posy")--text
			canshu1.Btn = viewNode:getChildAutoType("$canshu1/$Btn")--Button
			canshu1.cameraType = viewNode:getChildAutoType("$canshu1/$cameraType")--text
	--{vmFieldsEnd}:Battle.BattleTestView
	--Do not modify above code----------
	local canshu1 = viewNode:getChildAutoType("$canshu1")--Label
	vmRoot.canshu1 = canshu1
	canshu1.delayTime = viewNode:getChildAutoType("$canshu1/$delayTime")--text
	canshu1.posy = viewNode:getChildAutoType("$canshu1/$posy")--text
	canshu1.ease = viewNode:getChildAutoType("$canshu1/$ease")--text
	canshu1.scale = viewNode:getChildAutoType("$canshu1/$scale")--text
	canshu1.duration = viewNode:getChildAutoType("$canshu1/$duration")--text
	canshu1.cameraType = viewNode:getChildAutoType("$canshu1/$cameraType")--text
	canshu1.Btn = viewNode:getChildAutoType("$canshu1/$Btn")--Button
	canshu1.posx = viewNode:getChildAutoType("$canshu1/$posx")--text
	canshu1.resetTime = viewNode:getChildAutoType("$canshu1/$resetTime")--text
end


function BattleTestView:_initUI()

	self:_initVM()
	self.view:setSortingOrder(100)
	CameraController.setScreenView(self.view,self.view)
	BattleManager:beginGame()
	local fullScreen = self.view:getChildAutoType("frame/fullScreen")
	fullScreen:setIcon(PathConfiger.getMapBg(100002))
	
	self.playFx=self.view:getChildAutoType("playFx")
	self.fightTest=self.view:getChildAutoType("fightTest")
	self.fullScreen=self.view:getChildAutoType("fullScreen")
	self.closeButton=self.view:getChildAutoType("closeButton")
	self.heroList=self.view:getChildAutoType("heroList/combox")
	self.isBezier=self.view:getChildAutoType("$isBezier")
	self.heroId=self.view:getChildAutoType("heroList/ID")
	self.skillId=self.view:getChildAutoType("skillList/ID")
	self.buffId=self.view:getChildAutoType("bufflList/ID")
	self.targetId=self.view:getChildAutoType("$targetlList/ID")
	self.attackId=self.view:getChildAutoType("$AttackList/ID")
	--self.inputRect=self.view:getChildAutoType("inputRect")
	self.canshu1:setSortingOrder(20)
	self.view:getChildAutoType("skillList"):setSortingOrder(20)
	self.view:getChildAutoType("heroList"):setSortingOrder(20)
	self.view:getChildAutoType("bufflList"):setSortingOrder(20)
	self.isBezier:addClickListener(function ()
			if self.isBezier:isSelected() then
				self.testSkillType=4
			else
				self.testSkillType=0
			end
	end)
	
	

	local allHurtTip=FGUIUtil.createObjectFromURL(self._packName,'allHurHp')--总伤害特效
	local zshSkeleton=SpineUtil.createSpineObj(allHurtTip,Vector2(130,15),nil,PathConfiger.getSettlementRoot(),"Ef_zongshanghai")
	self.view:addChild(allHurtTip)
	allHurtTip:setPosition(self.fightTest:getX(),self.fightTest:getY()-50)
	allHurtTip:setVisible(false)
	allHurtTip.Skeleton=zshSkeleton


	BattleModel:setMapPoint({
			center=self.view:getChildAutoType("centerPoint"),
			enemyCenter=self.view:getChildAutoType("enemyCenter"),
			playerCenter=self.view:getChildAutoType("playerCenter"),
			arrayCenter=self.view:getChildAutoType("arrayCenter"),
			allHurtTip=allHurtTip
	})


	
	self.testEffect:addClickListener(function()

			ViewManager.close("BattleTestView")
			Dispatcher.dispatchEvent(EventType.Battle_playEditBattle)
			
	end)
	
	self.addHero=self.view:getChildAutoType("addHero")
	
	
	self.centerPoint=self.view:getChildAutoType("centerPoint")
	
	local testData={
		cure=0,
		code=54002,
		id=211,
		hp=800,
		hpMax=800,
		hurt=200,
		id=122,
		addShield=300,
	}
	local heroList={}
	--self.view:getChildAutoType("L_22"):setSortingOrder(8)
	--self.L_item=HeroItem.new(self.view:getChildAutoType("L_22"))
	--self.L_item.index=122
	
	
	self.L_item=BattleModel:creatFightItem(122,54002,nil,self.view:getChildAutoType("L_22"))

	
	
	for seatKey, ranges in ipairs(SeatType.front) do
		local layer=0
		for seatId = ranges[1], ranges[2] do
			layer=layer+1
			local itemCell=self:creatItem(self.view,seatId,HeroPos.enemy,layer*4)
			heroList[itemCell.index]=itemCell
		    local baseData=clone(testData)
			baseData.id=itemCell.index
			itemCell:setData(baseData)
		end
	end
	heroList[122]=self.L_item
	ModelManager.BattleModel:setHeroItemLists(heroList)
	self.L_item.heroPos=HeroPos.player
	local cIndex=0
	for k, v in pairs(DynamicConfigData.t_hero) do
		cIndex=cIndex+1
		if cIndex==1 then
			testData.code=k
		end
	end
	self.addHero:addClickListener(function ()
			self:creatHero()
	end)
	self.playFx:addClickListener(function ()
			testData.code=tonumber(self.heroId:getText())
			if self:checkHeroCode(testData.code) then
				self:beginFight()
			end
	end)
	self.fightTest:addClickListener(function ()
			BattleManager:getInstance():cleansup()--清理战斗数据

		    --local testData=self:calculateData(battleData,50)
			--printTable(086,testData)
			--ModelManager.BattleModel:updateBettleData(testData)
			ViewManager.close("BattleTestView")
			
			FightManager.openFight(battleData.gamePlayInfo.arrayType,{isTest=true,isRecord=true,battleData=battleData})
			cc.Director:getInstance():getScheduler():setTimeScale(1.5)
			
	end)
	

	self.canshu1.Btn:addClickListener(function ()
		local target=ModelManager.BattleModel:getHeroItemById(tonumber(self.targetId:getText()))
		local baseData={
			x=	tonumber(self.canshu1.posx:getText()),
			y=	tonumber(self.canshu1.posy:getText()),
			scale=	tonumber(self.canshu1.scale:getText()),
			ease=	tonumber(self.canshu1.ease:getText()),
			duration=	tonumber(self.canshu1.duration:getText()),
			resume=	tonumber(self.canshu1.resetTime:getText()),	
			delay=	tonumber(self.canshu1.delayTime:getText()),
			cameraType= tonumber(self.canshu1.cameraType:getText()),
			autoBack=true,
		}
		CameraController.setScreenView(self.view)
		CameraController.zoomIntoTest(self.L_item,baseData,function ()
					CameraController.runActions()
						
		end)
	
	end)
	
	self:setListToComBox()
	self:initFakeData()
	
	
	--ccDrawInit()
	--ccPointSize(10)
	--ccDrawColor4f(0,255,0,255)
	--ccDrawLine(Vector2(500,500),Vector2(600,600))
	--local drawNode=cc.DrawNode:create()
	--drawNode:init()
	--print(086,drawNode:init(),"drawNode:init()")
	--drawNode:setLineWidth(10)
	--drawNode:drawLine(Vector2(50,50),Vector2(50,-200),{r=255,g=0,b=0})
	--self.view:displayObject():addChild(drawNode)
	--drawNode:setPosition(500,500)
	--self.view:getParent():setAlpha(100)
	--ParticleUtil.createParticleObj(self.zoomBt,Vector2.zero,"Effect","particle_texture")
	--ParticleUtil.createInFullScreen("particle_texture",self.view)
	--cc.Director:getInstance():getScheduler():setTimeScale(5)
end



--根据id创建前排信息和替补信息
function BattleTestView:creatItem(parent,seatId,heroPos,layer)

	local child=parent:getChildAutoType(heroPos.name..seatId)
	print(0934,layer,"layer")
	child:setSortingOrder(layer)
	local itemCell=false
	if seatId<31 then
		--local heroItem=FGUIUtil.createObjectFromURL(self._packName,'heroItem')
		--child:addChild(heroItem)
		itemCell=HeroItem.new(child)--前排信息
		itemCell.design:setTouchable(false)
	else
		itemCell=SubItem.new(child)--替补信息
		itemCell.isSub=true
	end

	itemCell.heroPos=heroPos
	itemCell.index=heroPos.pos+seatId
	--itemCell.mapPoint=self.centerPoint
	return  itemCell

end



function BattleTestView:initFakeData()
	if PlayerModel.level=="" then
		PlayerModel.level=100
	end
end

function BattleTestView:setListToComBox()
	local strList={}
	local listValue={}
	for k, hero in pairs(DynamicConfigData.t_hero) do
		local str=hero.heroId.."  "..hero.heroName 
		table.insert(listValue,hero.heroId)
		table.insert(strList,str)

	end

	self.heroList:setItems(strList)
	self.heroList:setValues(listValue);
	self.heroId:setText(listValue[1])
	self.heroList:addEventListener(FUIEventType.Changed,function(data)
			self.heroId:setText(self.heroList:getValue())
			self:creatHero()
	end)
	

	self:setDropDown(DynamicConfigData.t_skill,"skillId","skillName","skillList")
	self:setDropDown(DynamicConfigData.t_buff,"buffId","buffDescribe","bufflList")
	local tempData={211,122,212,213,221,222,223}
	self:setDropDown(tempData,nil,nil,"$targetlList")
	local tempData={122,211,212,213,221,222,223}
	self:setDropDown(tempData,nil,nil,"$AttackList")
    self:creatHero(54002)
end


function BattleTestView:creatHero(code)
	--BattleManager:beginGame()
	local testData={
		cure=0,
		code=54001,
		id=211,
		hp=800,
		hpMax=800,
	}
	self.haveData=true
	testData.code=tonumber(code or self.heroId:getText())
	if self:checkHeroCode(testData.code) then
		self.L_item:setData(testData)
	end
	local cardInfo=DynamicConfigData.t_hero[testData.code];--根据heroId
	local skillList={}
	for i = 1, 4 do
		local key ='skill'..i
		local activeSkills =cardInfo[key]
		if next(activeSkills)~=nil then
			for k, skillId in pairs(activeSkills) do
				local skill= DynamicConfigData.t_skill[skillId]
				if skill then
					table.insert(skillList,skill)
				end
			end

		end
	end
	self:setDropDown(skillList,"skillId","skillName","skillList")
	
end




function BattleTestView:setDropDown(listData,id,strKey,dropDownName)
	local strList={}
	local listValue={}
	local dropDownList=self.view:getChildAutoType(dropDownName.."/combox")
	local fistLabel=self.view:getChildAutoType(dropDownName.."/ID")
	strList={}
	listValue={}
	for k, itemData in pairs(listData) do
		if id then
			table.insert(listValue,itemData[id])
			if strKey then
			
				if itemData[id]~=nil and itemData[strKey]~=nil then
					local str=itemData[id].."  "..itemData[strKey]
					table.insert(strList,str)
			    else
					print(086,id,itemData[strKey],itemData[id])
					printTable(086,itemData)
					--printTable(086,id,itemData)
				end
	
			end
		else
			table.insert(listValue,itemData)
			local str=k..".  "..itemData
			table.insert(strList,str)
		end
	end
	dropDownList:setItems(strList)
	dropDownList:refresh()
	dropDownList:setValues(listValue);
	fistLabel:setText(listValue[1])
	dropDownList:addEventListener(FUIEventType.Changed,function(data)
			fistLabel:setText(dropDownList:getValue())
	end)
	
	
end

--检测effetc表有没有填错特效
function BattleTestView:checkEffectTable()
	local noWrong=true
	for k, effectIDs in pairs(DynamicConfigData.t_effect) do
		 for k, effectData in pairs(effectIDs) do
			local fullName=PathConfiger.getSpineRoot().."/"..effectData.name..".skel"
			if not cc.FileUtils:getInstance():isFileExist(fullName) then
				LuaLogE(fullName.." no find")
				RollTips.show(fullName.." no find")
				noWrong=false
			end
		 end
	end
	if noWrong then
		RollTips.show("没有检测到错误配置")
	end

end



function BattleTestView:checkHeroCode(code)
	if DynamicConfigData.t_hero[code] then
		return self.haveData
	else
		LuaLogE("英雄"..code.." 没有配表")
		RollTips.show("英雄"..code.." 没有配表")
		return  false
	end
end

function BattleTestView:checkSkillCode(skillId)
	if  DynamicConfigData.t_skill[skillId] then
		return  true
	else
		LuaLogE("技能"..skillId.." 没有配表")
		RollTips.show("技能"..skillId.." 没有配表")
		return  false
	end
end



--施法技能测试
function BattleTestView:beginFight()
	print(356,"beginFight",TimeLib.formatTime(ServerTimeModel:getTodayLastSeconds()))
	
	

	
	
	local attackerID=tonumber(self.attackId:getText())
	local targetID=tonumber(self.targetId:getText())
	local skill=tonumber(self.skillId:getText())
	local buffId=tonumber(self.buffId:getText())
	
	CameraController.setScreenView(self.view)
	--创建一个角色参考
	 --BattleModel:creatFightItem(attackerID,54002,parent,HeroPos.player)
	 --BattleModel:creatFightItem(targetID,54002,parent,HeroPos.enemy)
	
	
	local fightObjData=BattleModel:creatSkillData(attackerID,targetID,skill,buffId)
	SkillManager.playSkill(attackerID,targetID,fightObjData,function ()
		print(5656,"施法完成")
	end)
	

end




function BattleTestView:BezierTest()
	local fxList=SpineUtil.createEffectById(240002,PathConfiger.getSpineRoot(),self.view)
	for k, infos in pairs(fxList) do
		local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
		skeletonNode:setAnimation(0, effectConfig.stack, true)
		skillObj:setPosition(600,300)
		skeletonNode:setScaleX(-1)
		self:run_PwAction(skeletonNode,1.5,{x=0,y=0},{x=-400,y=0},500,45)
	end
end


function BattleTestView:buffLianjieTest()
	
	local lineFrom,lineEnd=false,false
	
	local fxList=SpineUtil.createEffectById(490008,PathConfiger.getSpineRoot(),self.view)
	for k, infos in pairs(fxList) do
		local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
		skeletonNode:setAnimation(0, effectConfig.stack, true)
		skillObj:setPosition(500,400)
		if effectConfig.hierarchy>1 then
		  skillObj:setSortingOrder(17)
		end
		if  string.find(effectConfig.stack,"up")~=nil then
			local hangPos=SpineMnange.getBonPosition(skeletonNode,"guanzi_a1",102)
			printTable(08666,hangPos,"hangPos1")
			lineFrom = self.view:globalToLocal(skillObj:localToGlobal(hangPos))
		end
	end
	local fxList2=SpineUtil.createEffectById(490008,PathConfiger.getSpineRoot(),self.view)
	for k, infos in pairs(fxList2) do
		local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
		skeletonNode:setAnimation(0, effectConfig.stack, true)
		skillObj:setPosition(1010,630)
		if effectConfig.hierarchy>1 then
			skillObj:setSortingOrder(20)
		end
		if  string.find(effectConfig.stack,"up")~=nil then
			local hangPos=SpineMnange.getBonPosition(skeletonNode,"guanzi_a1",102)
			lineEnd = self.view:globalToLocal(skillObj:localToGlobal(hangPos))--获取特效挂点坐标
		end
	end
    local particleObj,particle=	ParticleUtil.createParticleObj(self.view,cc.p(lineFrom.x,lineFrom.y),"particle_texture")
	particle:setAngle(-self:getAngleByPos(lineFrom,lineEnd,true))
	particle:setSpeed(Vector2.distance(Vector2(lineFrom.x,lineFrom.y),Vector2(lineEnd.x,lineEnd.y))*2)
	
	--particleObj:setSortingOrder(10)
end

--抛物线运动

function BattleTestView:run_PwAction(obj,t,startPoint,endPoint,height,angle)
	--local width = math.abs(end_pos.x - star_pos.x)
	--把角度转换为弧度
	local radian = angle*3.14159/180.0;
	-- 第一个控制点为抛物线左半弧的中点
	local q1x = startPoint.x+(endPoint.x - startPoint.x)/4.0;
	local q1 = ccp(q1x, height + startPoint.y+math.cos(radian)*q1x);
	-- 第二个控制点为整个抛物线的中点
	local q2x = startPoint.x + (endPoint.x - startPoint.x)/2.0;
	local q2 = ccp(q2x, height + startPoint.y+math.cos(radian)*q2x);

	--曲线配置
	local cfg={q1,q2,endPoint}
	local a1= cc.BezierBy:create(t,cfg)
	local a2= cc.MoveTo:create(t,endPoint)
	local finihed=cc.CallFunc:create(function()

			obj:removeFromParent()
	end)
	obj:runAction(cc.Sequence:create(a1,finihed))
	
    local LastPos={x=obj:getPositionX(),y=obj:getPositionY()}
	obj:onUpdate(function (dt)
			local nextPos={x=obj:getPositionX(),y=obj:getPositionY()}
			printTable(0866,nextPos,"nextPos")
			obj:setRotation(-self:getAngleByPos(nextPos,LastPos))
			LastPos=nextPos
	end)
end

--特效角度计算
function BattleTestView:getAngleByPos(p1,p2)
	local p = {}
	p.x = (p2.x - p1.x)
	p.y = (p2.y - p1.y)

	local r=0
	if p2.x>p1.x  then
		p.x = (p2.x - p1.x)
		p.y = (p2.y - p1.y)
		r = math.atan2(p.y,p.x)*180/math.pi
	else
		p.x = -(p2.x - p1.x)
		p.y = -(p2.y - p1.y)
		r = -math.atan2(p.y,p.x)*180/math.pi
	end
	return r
end


function BattleTestView:getRunTrace(runTime,playTime)
	return runTime>playTime
end




function BattleTestView:getEffectDatas(skillEffectSeq,heroLists)
	local datas={}
	for k, effectData in pairs(skillEffectSeq) do
		
		local allHurt=self:addValues(effectData.value)
		heroLists[effectData.id].hp=heroLists[effectData.id].hp+allHurt
        if heroLists[effectData.id].hp<0 then
			heroLists[effectData.id].hp=0
		end
		local buffEffect=effectData.buffEffect
		if buffEffect then
			local buffHurt=self:addValues(buffEffect.buffValue)
			heroLists[buffEffect.id].hp=heroLists[buffEffect.id].hp+buffHurt
			if heroLists[buffEffect.id].hp<0 then
				heroLists[buffEffect.id].hp=0
			end
			if buffEffect.id ==111 then
			end
		end
	end
   
end

--#替补上场信息
--.FightObjReplaceData {
--id          1:integer          #替补位置
--replaceId   2:integer          #场上位置
--}
function BattleTestView:exchangeHero(replaceDataSeq,heroLists)
	
	if replaceDataSeq==nil or next(replaceDataSeq)==nil then
		return 
	end
	printTable(086,replaceDataSeq)
	for k, fightObjReplaceData in ipairs(replaceDataSeq) do
		local subtion={}
		for k, v in pairs(heroLists[fightObjReplaceData.replaceId]) do
			subtion[k]=v
		end
		local target={}
		for k, v in pairs(heroLists[fightObjReplaceData.id]) do
			target[k]=v
		end
		heroLists[fightObjReplaceData.replaceId]=target
		heroLists[fightObjReplaceData.id]=subtion
		target.id=fightObjReplaceData.replaceId
		subtion.id=fightObjReplaceData.id

	end
	printTable(086,heroLists)
end

	

function BattleTestView:addValues(list)
	local value=0
	if list==nil or next(list)==nil then
		return value
	end
	for k, v in pairs(list) do
		value=value+v
	end
	return value
end


	
function BattleTestView:_exit()
	BattleManager:getInstance():cleansup(true)--清理战斗数据
end




---(void)thePosition
--{
	--x=x+1;
	--y=G*x*x+SLOPE*x;
	--[ball setPosition:ccp(x,y)];
	--if (y<=0) {
			--x=0;
		--}
	--}
--}
return  BattleTestView