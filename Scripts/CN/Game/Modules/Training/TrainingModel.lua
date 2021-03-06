--Date :2020-12-07
--Author : generated by FairyGUI
--Desc : 

local TrainingModel = class("Training", BaseModel)

function TrainingModel:ctor()
	self.cardList=false
	self.__seatInfos=false
	self.__enemyInfos=false
	self.TaskId=1
	self.taskData=false
	self.__pushIndex=1
	self.haveReward=false
	
	self.answer={}
	self.luaFile = false
	self.taskState={
		[1]={
			taskId=1,
		    state=1	
		},
	}  --0:待解锁 1:已解锁不可领奖 2:已通关可领奖 3:已通关已领奖
	
	self.allFinishTime=0
end

function TrainingModel:init(data)

end

function TrainingModel:initData(data)
	self.haveReward=false
	if data.trainingCamp then
		self.taskState=data.trainingCamp.task
		self.allFinishTime=data.trainingCamp.allFinishTime or 0
		RedManager.updateValue("V_TRANNING_FIRST",self.taskState[1].state==1)
		for k, v in pairs(self.taskState) do
			if v.state==2 then
				self.haveReward=true
				break;
			end
		end
		RedManager.updateValue("V_TRANNING_REWARD",self.haveReward)
	end
	--printTable(0,"训练营任务数据==>",data)
	Dispatcher.dispatchEvent(EventType.training_UpdateData)
end



function TrainingModel:setTrainData(TaskId)
	self.TaskId=TaskId
	self.taskData=self:getTaskById(self.TaskId)
end


function TrainingModel:setSeatInfos(seatInfos)
	self.__seatInfos=seatInfos
end

function TrainingModel: getSeatInfos()
	return self.__seatInfos
end

function TrainingModel:setEnemyInfos(enemyInfos)
	self.__enemyInfos=enemyInfos
end

function TrainingModel:getEnemyInfos()
	return self.__enemyInfos
end

function TrainingModel:getSeatById(seatID)
	local seat=false
	for k, v in pairs(self.__seatInfos) do
		if v.seatId== seatID then
			seat=v
		end
	end
	return seat
end

function TrainingModel:getSeatByUUId(uuid)
	local seat=false
	for k, v in pairs(self.__seatInfos) do
		if v.uuid== uuid then
			seat=v
		end
	end
	return seat
end

--将卡牌置入首选的一个空位
function TrainingModel:getLateSeat()
	print(0866,"最近位置",self.__pushIndex)
	
	local optionPos= self.taskData.position
	local seat=self.__seatInfos[optionPos[self.__pushIndex]]
	return seat
end

function TrainingModel:getAnswerById(heroId,pos)
	local answerData=false
	for k, v in pairs(self.taskData.answer) do
		if v.heroId==heroId and v.pos==pos then
			answerData=v
		end
	end
	return answerData
end


function TrainingModel:goToAnswerFight(data,isRight)
	local mapConfig={
		arrayType=38888
	}
	local answerData= self:getAnswerById(data.heroId,data.pos)
	local function battleFunc(eventType)
		if eventType=="begin" then
			if isRight then
               self:setTaskFinish(self.taskData.id)
			end
			ViewManager.close("TrainingPrepareView")
		end
		if eventType=="end" then
			self:showAlert(isRight)
			--print(5656,"训练营战斗结算",isRight)
		end
	end
	if answerData then

		local battle_Config =  require ("Configs.Generate."..answerData.fightData)   --loadstring(io.readfile(self.luaFile..answerData.fightData..".lua"))()
		Dispatcher.dispatchEvent(EventType.Battle_playEditBattle,mapConfig,battle_Config,battleFunc)
	else
		print(5656,"找不到战斗配置")
	end
end


function TrainingModel:showAlert(isRight)


	--cost[1].amount
	local info = {}
	info.title = ""
	if isRight then
		info.text = DescAuto[326] -- [326]="训练成功，已解锁下一关"
	else
		info.text = DescAuto[327] -- [327]="训练失败，请合理搭配阵容"
	end
	info.type = "ok"
	--info.yesText = Desc.fairyLand_continueFight
	--info.noText = Desc.fairyLand_closeView
	info.mask = true
	info.onOk = function()
		if self.allFinishTime>0 then
			ViewManager.open("TrainingTipView",{windowType=1})
		end
	end
	Alert.show(info)
end




function TrainingModel:getCardList()
	local taskData=self:getTaskById(self.TaskId)
	local formation=taskData.formation
	local heroList = {}
	for _,heroId in ipairs(formation) do
		local heroInfo = {}
		heroInfo['level'] = 200
		heroInfo['star'] = 5
		heroInfo['code'] = heroId
		heroInfo["uuid"]=heroId
		table.insert(heroList,heroInfo)
	end	
	return heroList
end

function TrainingModel:getSelfArray()
	local taskData=self:getTaskById(self.TaskId)
	local fixedhero=taskData.fixedhero
	local heroList = {}
	for k,data in ipairs(fixedhero) do
		local heroInfo = {}
		heroInfo['level'] = 200
		heroInfo['star'] = 5
		heroInfo['code'] = data.heroId
		heroInfo["uuid"]=data.heroId
		heroInfo['id'] = data.pos
		table.insert(heroList,heroInfo)
	end
	return heroList
end

function TrainingModel:getHeroByUid(uuid)
	local hero=false
	local heroList=self:getCardList()
	for k, v in pairs(heroList) do
		if v.uuid==uuid then
			hero=v
		end
	end
	return hero
end



function TrainingModel:getEnemyArray()
	local taskData=self:getTaskById(self.TaskId)
	local enemy=taskData.enemy
	local enemyposition=taskData.enemyposition
	local heroList = {}
	for k,data in ipairs(enemy) do
		local heroInfo = {}
		heroInfo['level'] = 200
		heroInfo['star'] = data.star
		heroInfo['code'] = data.heroId
		heroInfo['type'] = 2
		heroInfo['id'] = data.pos
		table.insert(heroList,heroInfo)
	end
	return heroList
end


function TrainingModel:getTraningTask()
	 local taskConfigs= DynamicConfigData.t_trainingCamp
	 local taskData={}
	 for k, v in pairs(self.taskState) do
		 taskConfigs[v.taskId].state=v.state
	 end
	 return taskConfigs
end


function TrainingModel:getTaskById(taskId)
	local tasks= DynamicConfigData.t_trainingCamp
	return tasks[taskId]
end


--划分区域管理换阵操作触控区
function TrainingModel:getDropIndex(pos)

	local rawRange ={[1]={100,310},[2]={330,415},[3]={425,640}}
	local rowRange ={[1]=350,[2]=300,[3]=200}
	local rawIndex=0
	local rowIndex=0
	for k, range in pairs(rawRange) do
		if pos.y>range[1] and pos.y<=range[2] then
			rowIndex=k
			rawIndex=k
		end
	end
	if rowIndex==0 or pos.x>680  then
		return false
	end
	if pos.x<rowRange[rowIndex] then
		rowIndex=1
	else
		rowIndex=0
	end
	
	
	return rowIndex*3+rawIndex

end

--判断卡牌是否已放置
function TrainingModel:checkCard(uuid)
	local tag=false
	for k, v in pairs(self.__seatInfos) do
		if v.uuid==uuid then
			tag=true
			return tag
		end
	end
	return tag
end


function TrainingModel:setTaskFinish(taskId)
	local params={
		taskId=taskId
	}
	local function success()
		print(5656,"通关成功..任务ID",taskId)
	end
	printTable(5656,"通关请求 GamePlay_Modules_TrainingCamp_TaskFinish",params)
	RPCReq.GamePlay_Modules_TrainingCamp_TaskFinish(params,success)
end


function TrainingModel:getTaskRewawrd(taskId)
	local params={
		taskId=taskId
	}
	local function success()
		print(5656,"奖励返回",taskId)
	end
	printTable(5656,"请求奖励",params)
	RPCReq.GamePlay_Modules_TrainingCamp_GetTaskReward(params,success)
end



--是否首次弹提示
function TrainingModel:setHadOpen(open)
	FileCacheManager.setBoolForKey(PlayerModel.userid..FileDataType.TRANING_SHOWTIP..self.taskData.id,open,false,false)
end

--是否首次弹提示
function TrainingModel:isOpen()
	return FileCacheManager.getBoolForKey(PlayerModel.userid..FileDataType.TRANING_SHOWTIP..self.taskData.id,false,false,false)
end





--重新登录的时候清理
function TrainingModel:clear()
	self.cardList=false
	self.__seatInfos=false
	self.__enemyInfos=false
end




return TrainingModel
