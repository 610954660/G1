--added by wyang
--秘境地图移动组件
local TwistRegimentMapRect = class("TwistRegimentMapRect")
local TwistRegimentMapItem = require "Game.Modules.TwistRegiment.TwistRegimentMapItem"
function TwistRegimentMapRect:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	self.mapItem =false
	self._roleMc = false
	self.spineMc = false
	self.spineMc_down = false
	self.spineMc_up = false
	self.pic_bg = false
	self.txt_layer = false
	self.mapSwichCtrl = false
	self.spineNode = false
	self.modelNode = false



	self._isMoving = false
	self._movePosList = Queue.new()
	self._mapItems = {}
	self._moveTime 	= 0.5 	-- 移动时间
	self._floor = 1
	self._isInit  = false
	
	self.isBossOpen=false
	self.bossGridInfo=false
	

	
	self.griddleCom=false
	self.gridRollBt=false
	self.gridRandomBt=false
	self.griddleList=false
	self.chorBossBtn=false
	self.bigRewardPre=false
	self.buySepecial=false
	self.txt_countTimer=false
	self.txt_countTitle=false
	self.hearCom=false
	
	self.fxpoint=false
	
	
	
	self.calltimer=false
	self.normalCount=false
	self.specialCount=false
	

end

function TwistRegimentMapRect:init( ... )
	
	self.mapItem = self.view:getChildAutoType("mapItem")
	self.txt_layer = self.view:getChildAutoType("txt_layer")
	local viewWidth = self.view:getWidth()
	local viewHeight = self.view:getHeight()
	local pt = self.view:localToGlobal(Vector2.zero)
	self.mapItem:setDragBounds(CCRectMake( - (3200 - viewWidth) + pt.x, - (1440 -viewHeight) + pt.y, 3200*2 - viewWidth, 1440*2 - viewHeight))

	
	
	self._roleMc = self.mapItem:getChildAutoType("roleMc")
	self.hearCom=self._roleMc:getChildAutoType("hearCom")
	self.hearCom:setIcon(PathConfiger.getHeroOfMonsterIcon(PlayerModel.head))
	self.chorBossBtn=self.view:getChildAutoType("chorBossBtn")
	self.griddleCom   = self.view:getChildAutoType("griddleCom")
	self.gridRandomBt=self.view:getChildAutoType("gridRandomBt")
	self.gridRollBt=self.griddleCom:getChildAutoType("gridRollBt")
	self.griddleList=self.griddleCom:getChildAutoType("griddleList")
	self.normalCount=self.view:getChildAutoType("normalCount")
	self.specialCount=self.view:getChildAutoType("specialCount")
	self.bigRewardPre=self.view:getChildAutoType("bigRewardPre")
	self.txt_countTimer=self.view:getChildAutoType("txt_countTimer")
	self.txt_countTitle=self.view:getChildAutoType("txt_countTitle")
	self.fxpoint=self.view:getChildAutoType("fxpoint")
	self.buySepecial  = self.view:getChildAutoType("buySepecial")
	local cost=DynamicConfigData.t_monopolyCost[1].cost
	local costObject=BindManager.bindCostButton(self.buySepecial)
	self.buySepecial:setTitle(DescAuto[331]) -- [331]="购买"
	costObject:setData(cost[1])
	self.buySepecial:addClickListener(function ()
		TwistRegimentModel:Activity_Monopoly_Buy()
	end)
	

	self.bigRewardPre:addClickListener(function(context)
		--self:showRewardView()
		TwistRegimentModel:showRewardView(self.bossGridInfo)
	end)
	
	self.gridRandomBt:addClickListener(function( ... )
			self:rollCom(1,0)
	end)
	for i=0,self.griddleList:getNumItems()-1 do
		self.griddleList:getChildAt(i):addClickListener(function()
				self:rollCom(2,i+1)
				self.gridRollBt:dispatchEvent(FUIEventType.Click)
		end)
	end
	
	self.chorBossBtn:addClickListener(function ()
			if self.isBossOpen then
				TwistRegimentModel:joinBattleEvent(self.bossGridInfo.id,self.bossGridInfo.p5)	
			else
				RollTips.show(Desc.TwistRegiment_limitBoss)
			end
	end)
	self.gridRollBt:addClickListener(function(context )
			context:stopPropagation()
	end)
	self.view:addClickListener(function ()
			if self.gridRollBt:isSelected() then
				self.gridRollBt:setSelected(false)
			end
	end)
	
	RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.Monopoly.."commonTimes",self.gridRandomBt:getChildAutoType("img_red"))
	RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.Monopoly.."specialTimes",self.gridRollBt:getChildAutoType("img_red"))
	
end



function TwistRegimentMapRect:rollCom(rollType,num)
	
	if TwistRegimentModel.activeEnd then
		RollTips.show(DescAuto[332]) -- [332]="活动已结束"
		self._isMoving=false
		return 
	end
	if self._isMoving then
		RollTips.show(DescAuto[333]) -- [333]="请等待移动完成"
	    return
	end
	local activeData=TwistRegimentModel:getAcitveData()
	if rollType==2 and  activeData.specialTimes<1 then
		RollTips.show(Desc.TwistRegiment_limitTimes)
		return
	end
	if rollType==1 and  activeData.commonTimes<1 then
		RollTips.show(Desc.TwistRegiment_limitTimes)
		return
	end
	TwistRegimentModel:setGirdCanFight(true)
	self._isMoving=true
	local beginNum=TwistRegimentModel.grid
	TwistRegimentModel:monopoly_Shake(rollType,num,function (success,res)		
			if success then
				TwistRegimentModel.monopolyData=res
				TwistRegimentModel.hadShowReward=false
				local view = ViewManager.getLayerTopWindow(LayerDepth.Window)
				local fXparent=view.window.view
				local MapWidth=fgui.GRoot:getInstance():getViewWidth()
				local MapHeight=fgui.GRoot:getInstance():getViewHeight()
				local centerPos=Vector2(MapWidth/2+200,MapHeight/2)
				local skeletonNode=SpineUtil.createSpineObj(self.fxpoint, {x=0,y=200}, nil, SpinePathConfiger.CrapsEffect.path, SpinePathConfiger.CrapsEffect.upEffect, SpinePathConfiger.CrapsEffect.upEffect)
				local animationName=rollType==1 and  SpinePathConfiger.CrapsEffect.animatin_b or   SpinePathConfiger.CrapsEffect.animatin_o
				skeletonNode:setAnimation(0,animationName..res.addStep,false)
				GlobalUtil.delayCall(function()end,function ()
						if  not tolua.isnull(skeletonNode) then
							skeletonNode:removeFromParent()
							self:setMovePoint(beginNum,res.addStep)
						end
				end,2,1)	
			else
				self._isMoving=false
			end

	end)
end




--打开地图时的初始化
function TwistRegimentMapRect:initMap(isChangeMap)
	local activeData=TwistRegimentModel:getAcitveData()
	if activeData.rewardTimes>1 and activeData.fromLogin then
		self._roleMc:setTitle("x"..activeData.rewardTimes)
	else
		self._roleMc:setTitle("")
	end

	
	local limitTimes=DynamicConfigData.t_monopolyCost[1].limitTimes
	
	if activeData.commonTimes<1 then
		self.normalCount:setText(string.format(Desc.TwistRegiment_gridCount," "..ColorUtil.formatColorString1(activeData.commonTimes,"#FF3B3B")..ColorUtil.formatColorString1("/"..limitTimes,"#FF3B3B")))
	else
		self.normalCount:setText(string.format(Desc.TwistRegiment_gridCount," "..ColorUtil.formatColorString1(activeData.commonTimes,"#119717")..ColorUtil.formatColorString1("/"..limitTimes,"#119717")))
	end

	if activeData.specialTimes<1 then
		self.specialCount:setText(string.format(Desc.TwistRegiment_gridCount," "..ColorUtil.formatColorString1(activeData.specialTimes,"#FF3B3B")))
	else
		self.specialCount:setText(string.format(Desc.TwistRegiment_gridCount," "..ColorUtil.formatColorString1(activeData.specialTimes,"#119717")))
	end
	self.buySepecial:setVisible(activeData.specialTimes<1)
	self.txt_countTimer:setVisible(activeData.commonTimes<10)
    self.txt_countTitle:setVisible(activeData.commonTimes<10)
	if activeData.isOpenBoss then
		self.chorBossBtn:getController("buttonType"):setSelectedPage("normal")
		self.chorBossBtn:getChildAutoType("img_red"):setVisible(true)
	else
		self.chorBossBtn:getController("buttonType"):setSelectedPage("gray")
		self.chorBossBtn:getChildAutoType("img_red"):setVisible(false)
	end
	self.isBossOpen=activeData.isOpenBoss
	for k, gridInfo in pairs(TwistRegimentModel:getAcitveConfig()) do
		if gridInfo.type==6 then
			self.bossGridInfo=gridInfo
	    else
			local mapItem = self._mapItems[k]
			if not mapItem then
				local posItem = self.mapItem:getChildAutoType("rollItem_"..k)
				mapItem = TwistRegimentMapItem.new(posItem)
				self._mapItems[k] = mapItem
			end
			mapItem:setData(gridInfo)
			mapItem:updateIcon()
		end

	end
	self:updateCountTimer()
	RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.Monopoly.."commonTimes",  activeData.commonTimes>0 )
	RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.Monopoly.."specialTimes",  activeData.specialTimes>0)
end

--让人物显示在地图中间
function TwistRegimentMapRect:centerRole()
	--local mapWidth = self.mapItem:getWidth()
	--local mapHeight = self.mapItem:getHeight()
	--local rectWidth = self.view:getWidth()
	--local rectHeight = self.view:getHeight()
	--local rolePos = self._roleMc:getPosition()
	--local centerX = rectWidth/2
	--local centerY = rectHeight/2

	--local targetX = centerX - rolePos.x
	--local targetY = centerY - rolePos.y
	--if targetX > 0 then targetX = 0 end
	--if targetY > 0 then targetY = 0 end
	--if targetX < -(mapWidth - rectWidth) then targetX = -(mapWidth - rectWidth) end
	--if targetY < -(mapHeight - rectHeight) then targetY = -(mapHeight - rectHeight) end
	--self.mapItem:setPosition(targetX, targetY)
end

--添加需要移动的点
function TwistRegimentMapRect:addMovePoint(points)
	if #points == 0 then return end
	for _,v in ipairs(points) do
		self._movePosList:enqueue(points)
	end
	self:moveNext()
end


function TwistRegimentMapRect:setMovePoint(beginNum,addNum)
	local movePoint={}
   -- print(5656,"移动到"..targetNum)
	local targetNum=beginNum+addNum
	if targetNum> 26 then
		for i = beginNum, 26 do
			if beginNum~=26 then
				self._movePosList:enqueue(i)
			end
		end
		for i = 1, targetNum-26 do
			self._movePosList:enqueue(i)
		end
	else
		beginNum=beginNum==0 and 1 or beginNum
		for i = beginNum+1, targetNum do
			self._movePosList:enqueue(i)
		end
	end
	
	
	
	--printTable(5656,self._movePosList,"_movePosList")
	self:moveNext()
	
end

function TwistRegimentMapRect:moveNext()
	local moveIndex= self._movePosList:dequeue()
	if moveIndex then
		self:moveToPos(moveIndex)
	else
		self:onMoveEnd()
	end
	
end


--移动完成
function TwistRegimentMapRect:onMoveEnd()
	if self._mapItems[TwistRegimentModel.grid] then
		print(5656,"移动到"..TwistRegimentModel.grid)
		self._mapItems[TwistRegimentModel.grid]:girdEvent(function ()
				self._isMoving=false
		end)
	else
		self._isMoving=false
	end
	
    self:setRoleArrow()
	if tolua.isnull(self._roleMc) then return end
	local activeData=TwistRegimentModel:getAcitveData()
	if activeData.rewardTimes>1  then
		self._roleMc:setTitle("x"..activeData.rewardTimes)
	else
		self._roleMc:setTitle("")
	end

end

function TwistRegimentMapRect:setRoleArrow()
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

	
	
--getChildAutoType("arrow"):setRotation(self:getAngleByPos(curPos,pos))
end



--获取第x个格子对象
function TwistRegimentMapRect:getItem(index,finished)
	return self.mapItem:getChildAutoType("rollItem_"..index)
end

--移动到某个点
function TwistRegimentMapRect:moveToPos(index)
	if tolua.isnull(self.mapItem) then return end
	
	
	local posItem = self.mapItem:getChildAutoType("rollItem_"..index)
	if(posItem) then
		local pos = posItem:getPosition()
		
		local curPos = self._roleMc:getPosition()

		--if curPos.x < pos.x then
			--self.modelNode:setScaleX(1)
		--else
			--self.modelNode:setScaleX(-1)
		--end
		FairyLandModel.moving = true
		print(5656,self:getAngleByPos(curPos,pos),"self:getAngleByPos(curPos,pos)",index)
		--self._roleMc:getChildAutoType("arrow"):setRotation(self:getAngleByPos(curPos,pos))
		local index = self:getAngleByPos(curPos,pos)
		if index then 
			self._roleMc:getController("c1"):setSelectedIndex(index)
		end
		
		local tween1 = fgui.GTween:to(curPos,{x=pos.x,y=pos.y},self._moveTime)
		tween1:onUpdate(function(tweener)
				if tolua.isnull(self._roleMc) then
					return
				end
				self._roleMc:setPosition(tweener:getDeltaValue():getVec2().x,tweener:getDeltaValue():getVec2().y)
				self:centerRole()
			end)

		tween1:onComplete(function(tweener)
				FairyLandModel.moving = false
				self:moveNext()
				
		end)
	end
	--TwistRegimentModel.grid=index
end


function TwistRegimentMapRect:getAngleByPos(p1,p2)
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

function TwistRegimentMapRect:isSpeedUp(isUp)
	self._moveTime = isUp and 0.15 or 0.5
end

--直接去到某点（用于打开时）
function TwistRegimentMapRect:setToPos(index)
	local posItem = self.mapItem:getChildAutoType("rollItem_"..index)
	if(posItem) then
		local pos = posItem:getPosition()
		self._roleMc:setPosition(pos.x, pos.y)
		self:centerRole()
	end
	self:setRoleArrow()
	if self._mapItems[TwistRegimentModel.grid] then
		self._mapItems[TwistRegimentModel.grid]:girdEvent(function ()
				self._isMoving=false
			end)
	else
		self._isMoving=false
	end
end

function TwistRegimentMapRect:playInEffect(endFunc)
	self._roleMc:setVisible(true)
end

function TwistRegimentMapRect:playOutEffect(endFunc)
	--SpineUtil.createSpineObj(self.spineMc_down, vertex2(0,0), "mijing_xs_down", "Spine/ui/mijing", "efx_mijing", "efx_mijing",false)


	--self.spineMc:getTransition("out"):play(function( ... )

		--end)

	--local spineNode = SpineUtil.createSpineObj(self.spineMc_up, vertex2(0,0), "mijing_xs_up", "Spine/ui/mijing", "efx_mijing", "efx_mijing",false)
	--spineNode:setCompleteListener(function(name)
			--Scheduler.scheduleNextFrame(function()
					--if endFunc then endFunc() end
				--end)
		--end)

end

-- 倒计时
function TwistRegimentMapRect:updateCountTimer()


	if self.calltimer  then
		Scheduler.unschedule(self.calltimer)
		self.calltimer=false
	end
	local activeData=TwistRegimentModel:getAcitveData()
	local  seasonEndDt = activeData.nextEndTimeMs	
	if not seasonEndDt then return end
	seasonEndDt= (seasonEndDt-ServerTimeModel:getServerTimeMS())/1000
	
	print(5656,seasonEndDt,"seasonEndDt")
	if seasonEndDt<0 then
		self.txt_countTimer:setText(TimeLib.formatTime(0))
	else
		--local  day=math.floor(seasonEndDt/86400)
		--local time = ServerTimeModel:getTodayLastSeconds()
		self.txt_countTimer:setText(TimeLib.formatTime(seasonEndDt))
		if self.calltimer==false then
			local function onCountDown( time )
				self.txt_countTimer:setText(time)
			end
			local function onEnd( ... )

			end
			self.calltimer=TimeLib.newCountDown(seasonEndDt, onCountDown, onEnd, false, false)
		end
	end
end



--扫荡检测
function TwistRegimentMapRect:showRewardView()
	--检测扫荡处理
	local info = {}
	info.text = ""
	info.title = DescAuto[334] -- [334]="奖励预览"
	info.rewardPre=self.bossGridInfo.p6
	--info.yesText=self.btnSweep:getText()
	--info.activeType=GameDef.BattleArrayType.Monopoly
	info.key ="AlertRewardView"
	Alert.show(info)
end


--退出操作 在close执行之前
function TwistRegimentMapRect:__onExit()
	print(1,"TwistRegimentMapRect __onExit")
	Scheduler.unschedule(self.calltimer)
	--   self:_exit() --执行子类重写
	--[[self:clearEventListeners()
	for k,v in pairs(self.baseCtlView) do
	v:__onExit()
	end--]]
end

return TwistRegimentMapRect
