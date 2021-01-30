---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-08 20:19:34
---------------------------------------------------------------------

-- 战前准备的操作界面
--
---@class ArrayBaseView
local TrainingPrepareView,Super = class("TrainingPrepareView", MutiWindow)
local UpdateDescription = require "Configs.Handwork.UpdateDescription"
local SeatType=ModelManager.BattleModel.SeatType
local HeroPos=ModelManager.BattleModel.HeroPos
local SeatItem=require "Game.Modules.Battle.Cell.SeatItem"
local SubItem=require "Game.Modules.Battle.Cell.SubItem"

local BattleConfiger=require "Game.ConfigReaders.BattleConfiger"
function TrainingPrepareView:ctor()
	self._packName = "Training"
	self._compName = "TrainingPrepareView"

	self.selectList=false--战前准备英雄选择列表
	self.categoryList=false--英雄筛选列表

	self.beginBtn=false  --开始战斗按钮
	self.saveBt=false    --
	self._isFullScreen = true
	self.bgIcon=false
	self.myFightCamp=false --我放战力
	self.enemyFightCamp=false--地方战力

	--self._waitBattle = true --如果有战斗未结束跳转到这里需要等待战斗结束

	self.playerSeatLatout=false
	self.playerList=false
	self.playerSubList=false
	self.enemyList=false
	self.enemySubList=false


	self.cardControllers=false
	self.handCardInfos=false
	self.HeroCells=false


	self.atackController=false

	self.troopBtn=false
	self.txt_tactical=false
	self.battleArrayType=false  --玩法id 对应的阵容
	self._rootDepth = LayerDepth.Window

	self.curCategory=0
	self.prepareTitle=false
	
	--self.haveTroop=false
	
	self.path = "Map/100026.jpg"

	
end

function TrainingPrepareView:_initVM( )

end



function TrainingPrepareView:_initUI()
	PHPUtil.reportStep(ReportStepType.FIRST_FIGHT_PREPARE)
	local viewRoot = self.view
	self.bgIcon=self.view:getChildAutoType("frame")
	self.selectList=self.view:getChildAutoType("selectList")
	self.playerSeatLatout=self.view:getChildAutoType("playerSeatLatout")
	self.enemyFightCamp=self.view:getChildAutoType("enemyFightCamp")
	self.myFightCamp=self.view:getChildAutoType("myFightCamp")
	self.prepareTitle=self.view:getChildAutoType("prepareTitle")
	self.playerList=self.playerSeatLatout:getChildAutoType("playerList")
	self.playerSubList=self.playerSeatLatout:getChildAutoType("playerSubList")
	self.enemyList=self.playerSeatLatout:getChildAutoType("enemyList")
	self.enemySubList=self.playerSeatLatout:getChildAutoType("enemySubList")
	self._closeBtn=self.view:getChildAutoType("closeButton")
	self.troopBtn=self.view:getChildAutoType("troopBtn")
	self.txt_tactical=self.view:getChildAutoType("txt_tactical")
	self.categoryList=self.view:getChildAutoType("categoryList")
	self.atackController=self.view:getController("configType")
	self.beginBtn=self.view:getChildAutoType("beginBtn")
	self.saveBt=self.view:getChildAutoType("confirm")
	self.uiTypeCtr=self.view:getController("configType")
	self.campDetail=self.view:getChildAutoType("campDetail")
	self.taskTip=self.view:getChildAutoType("taskTip")
	self.btn_help=self.view:getChildAutoType("btn_help")
	

	--RedManager.register("M_TACTICAL", self.troopBtn:getChild("img_red"))
	
	self:initData()
	self.beginBtn:addClickListener(function ()
		 self:beginBattle()
	end)
	self._closeBtn:removeClickListener()
	self._closeBtn:addClickListener(function ()
			self:_returnView()
			self:closeView()
	end)
	self.campDetail:addClickListener(function ()
			ViewManager.open("BattleRaceView")
	end)
	self.btn_help:addClickListener(function ()
			ViewManager.open("TrainingTipView",{windowType=0})
	end)

    if not TrainingModel:isOpen() then
		ViewManager.open("TrainingTipView",{windowType=0,isAutoOpen=true})
		TrainingModel:setHadOpen(true)
	end
end



function TrainingPrepareView:onViewControllerChanged()
	
end



function TrainingPrepareView:beginBattle()
     if next(TrainingModel.answer)==nil then
		RollTips.show(Desc.battle_DetailsStr3)
		return 
	 else
		local isRight= (TrainingModel.answer.heroId==TrainingModel.taskData.correct[1].id and  TrainingModel.answer.pos==TrainingModel.taskData.correct[1].pos)
		if TrainingModel.taskData.taskType==1 then  --阵容教学	
			TrainingModel:goToAnswerFight(TrainingModel.answer,isRight)
		end
		if TrainingModel.taskData.taskType==2 then --阵法教学
		     if isRight then
				print(5656,"选对了阵法")
				TrainingModel:goToAnswerFight({heroId=1,pos=-1},isRight)
			 else
				print(5656,"选错了阵法")
				TrainingModel:goToAnswerFight({heroId=0,pos=-1},isRight)
			 end	
		end
	 end
end



--初始化座位信息
function TrainingPrepareView:initData()
	
    TrainingModel:setTrainData(self._args.taskId)
	self.bgIcon:setIcon(self.path)
	self:setCardList(TrainingModel:getCardList())
	local seatInfos={}
	local enemyInfos={}
	for seatId = 1, 6 do
		seatInfos[seatId]=self:creatItem(self.playerList,seatId)
		seatInfos[seatId]:setForbid()
		enemyInfos[seatId]=self:creatItem(self.enemyList,seatId)
	end
	for k, seat in pairs(TrainingModel.taskData.position) do
		seatInfos[seat]:setDefault()
	end
	if table.getn(TrainingModel.taskData.position)>1 then
		for k, seat in pairs(TrainingModel.taskData.position) do
			seatInfos[seat].canDrag=true
		end
	end
	TrainingModel:setSeatInfos(seatInfos)
	TrainingModel:setEnemyInfos(enemyInfos)
	local taskData=TrainingModel.taskData
	self.prepareTitle:setText(taskData.title)
	self.taskTip:setText(taskData.tips)
	self:setPlayerInfos()
	self:setEnemyInfos()
	
	taskData.taskType=1 --1 是阵型 2 是阵法
	for k, v in pairs(taskData.correct) do
		if v.pos==-1 then --代表阵法
			taskData.taskType=2
		end
	end	
	if taskData.taskType==2 then
		self.troopBtn:getChild("effectLoader"):displayObject():removeAllChildren()
		SpineUtil.createSpineObj(self.troopBtn:getChild("effectLoader"), vertex2(0,0), "animation", "Spine/ui/button", "zhenfatishi_texiao", "zhenfatishi_texiao",true)
		RedManager.register("", self.troopBtn:getChild("effectLoader"))
		self.troopBtn:getChild("effectLoader"):setVisible(true)
		self.taticalCell = BindManager.bindTacticalCell(self.troopBtn)
		self:tatical_change("",{id=1})
		self.troopBtn:addClickListener(function ()
				ModuleUtil.openModule(ModuleId.Tactical.id,true,{isTrain=true})
		end)
	end

	
	BattleModel.rollOverFx= fgui.GObject:create()
	SpineUtil.createSpineObj(BattleModel.rollOverFx,Vector2(0,0),"animation",PathConfiger.getSettlementRoot(),"Ef_tongyongxuanzhongguang")
	self.view:addChild(BattleModel.rollOverFx)
	BattleModel.rollOverFx:setVisible(false)
	

end

function TrainingPrepareView:creatItem(list,seatId)
	local child=list:getChildAutoType(seatId)
	local itemCell=false
	itemCell=BindManager.bindTraningCell(child)
	itemCell.seatId=seatId
	itemCell.zIndex=seatId

	itemCell.Onclick=function(uuid,seatId)
		self:outToTable(uuid,seatId)
	end
	return itemCell
end



--更新敌方阵容信息
function TrainingPrepareView:setEnemyInfos()

	for i, v in pairs(TrainingModel:getEnemyArray()) do
		if v.hp == 0 then
			print(4,v.id,"已阵亡")
		else
			local seat=TrainingModel:getEnemyInfos()[v.id]
			if seat then
				seat.view:setVisible(true)
				seat:initItemCell(v.code,v.star,v.level,v.type,nil,v.fashionId,v.uniqueWeaponLevel)
				seat.goWrap:setScaleX(-1)
			else
				print(4,v.id,"没有座位信息")
			end
		end
	end
	--BattleModel:changeCampeItem(self.eneymyCamp,BattleModel.HeroPos.enemy)
end


--更新自己阵容信息
function TrainingPrepareView:setPlayerInfos()
	for i, v in pairs(TrainingModel:getSelfArray()) do --默认第一种战斗配置
		local hero=v
		local seat=TrainingModel:getSeatById(v.id)
		if seat then
			seat:initItemCell(v.code,v.star,v.level,v.type,nil,v.fashionId, v.uniqueWeaponLevel)
		else
			print(4,v.id,"没有座位信息")
		end
	end
	--BattleModel:changeCampeItem(self.selfCamp,BattleModel.HeroPos.player)
end

--设置卡牌展示
function TrainingPrepareView:setCardList(CardList)
	self.cardControllers={}
	self.HeroCells={}
	self.handCardInfos=CardList
	if tolua.isnull(self.view) then
		return
	end
	self.selectList:setVirtual()
	self.selectList:setItemRenderer(function(index,card)
			local carInfo=CardList[index+1]
			self:tempCommonCell(carInfo,card)
		end)
	self.selectList:setNumItems(#CardList);
end

--放入阵前
function TrainingPrepareView:checkTable(heroInfo,seatId)
	--上阵英雄个数限制
	local seat=TrainingModel:getLateSeat()
	seat:resetItem()
	self:putoTable(seat,heroInfo,true)

end


--英雄下阵
function TrainingPrepareView:outToTable(uuid,seatId)
	print(5656,seatId,"seatId")
	local seatItem=TrainingModel:getSeatById(seatId)
	seatItem:resetItem()
	self:setMaskOnLock()
end

--刷新桌子
function TrainingPrepareView:putoTable(seat,heroInfo,playBorn)
	--print(086,"putoTable")
	seat:setHeroInfo(heroInfo,playBorn)
	self:setMaskOnLock()
end


--已选卡牌放入遮罩
function TrainingPrepareView:setMaskOnCard()
	self:setMaskOnLock()
end


function TrainingPrepareView:setMaskOnLock()
	for k, heroCell in pairs(self.HeroCells) do
		local  stateCtrl=heroCell.view:getController("state")
		heroCell.view:setGrayed(false)
		stateCtrl:setSelectedPage("out")
		if  TrainingModel:checkCard(heroCell.uuid) then
			stateCtrl:setSelectedPage("on")
		end
	end
end



function TrainingPrepareView:tempCommonCell(carInfo,card)--暂时替代卡牌通用框
	local carStateCtrl=card:getController("state")
	card:removeEventListener(FUIEventType.Click,101)
	card:addEventListener(FUIEventType.Click,function (context)
			if carInfo.hp and carInfo.hp<=0 then
				RollTips.show(Desc.battle_cardUseTxt)
				return
			end
			context:stopPropagation()--阻止事件冒泡
			SoundManager.playSound(1,false)
			if carStateCtrl:getSelectedPage()=="on" then
				local seat=TrainingModel:getSeatByUUId(carInfo.uuid)
				local seatId = seat and seat.seatId or false;
				self:outToTable(carInfo.uuid, seatId)
				return
			end
			self:checkTable(carInfo)
		end,101)
	local heroCell = BindManager.bindHeroCell(card)
	table.insert(self.HeroCells,heroCell)
	heroCell:setBaseData(carInfo)
end


--function TrainingPrepareView:doHandMove( data )

	--local info = string.split(data.doNode,",")

	--self.guang:setVisible(false)
	--self.hand:setVisible(true)

	--self.guang:displayObject():stopAllActions()
	--self.hand:displayObject():stopAllActions()

	--local pos1
	--local pos2

	--if info[1] == "1" then
		--local node1 = self.curFindView.view:getChildAutoType(info[3])
		--local node2 = self.curFindView.view:getChildAutoType(info[4])
		--pos1 = node1:localToGlobal(Vector2.zero)
		--pos2 = node2:localToGlobal(Vector2.zero)
	--end
	--local timeMove = info[2]
	----self.window:setVisible(false)
	----self._parentWin.view:setOpaque(false)
	--local moveBy1 = cc.MoveBy:create(timeMove,cc.p(pos2.x-pos1.x,-(pos2.y-pos1.y)))
	--local moveBy2 = cc.MoveBy:create(timeMove,cc.p(pos1.x-pos2.x,-(pos1.y-pos2.y)))
	--self.hand:displayObject():runAction(cc.RepeatForever:create(cc.Sequence:create(moveBy1,moveBy2)))
	--if data.noTounch then
		--GuideModel.waitEvent = true
	--end
--end


function TrainingPrepareView:tatical_change(_,args)
	if args.id then
		self.taticalCell:setData(args.id)
		local info = DynamicConfigData.t_TacticalUnlock[args.id]
		self.txt_tactical:setText(info.name)
		TrainingModel.answer=args.id 
		TrainingModel.answer={
			heroId=args.id,
			pos=-1,
		}
	end
end


--返回上一
function TrainingPrepareView:_returnView()

end



return TrainingPrepareView