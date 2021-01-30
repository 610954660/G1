--added by xhd
--任务成就系统model层
local BaseModel = require "Game.FMVC.Core.BaseModel"
local TaskConfiger = require "Game.ConfigReaders.TaskConfiger"
local TaskModel = class("TaskModel", BaseModel)
local gamePlayType = GameDef.GamePlayType.TaskMain
local band = bit.band
local lshift = bit.lshift
local RecordType = GameDef.RecordType
function TaskModel:ctor()
end

function TaskModel:init( ... )
	self.__taskOdm = {} 
	self.dailyTaskOdm= {}
	self.weekTaskOdm = {}
	self.dailyActvScore = {}
	self.AahieveTaksOdm={}
	self.weekActvScore = {}
	self.worldTeamArean = {} -- 组队竞技任务
	self.aniFlagArr = {false,false,false,false,false}
end

function TaskModel:getAniFlagIndex( index )
	return self.aniFlagArr[index]
end

function TaskModel:setAniFlagIndex( index,flag)
	self.aniFlagArr[index] = flag
end

--初始化数据
function TaskModel:initData(data,activeScore)
	if data then
		--任务模块
		if data[GameDef.TaskCategory.Main] and data[GameDef.TaskCategory.Main].category == GameDef.TaskCategory.Main then
			--printTable(5656,data[GameDef.TaskCategory.Achieve],"主线任务信息")
			self.__taskOdm = data[GameDef.TaskCategory.Main].records or {}
		end
		--日常
	    if data[GameDef.TaskCategory.Daily] and data[GameDef.TaskCategory.Daily].category == GameDef.TaskCategory.Daily then
			self.dailyTaskOdm = data[GameDef.TaskCategory.Daily].records or {}
		end
		--周常
		if data[GameDef.TaskCategory.Weekly] and data[GameDef.TaskCategory.Weekly].category == GameDef.TaskCategory.Weekly then
			self.weekTaskOdm = data[GameDef.TaskCategory.Weekly].records or {}
		end
		if data[GameDef.TaskCategory.Achieve]  then
			--printTable(5656,data[GameDef.TaskCategory.Achieve],"成就信息")
			self.AahieveTaksOdm = data[GameDef.TaskCategory.Achieve].records or {}
		end

		-- 组队竞技任务
		if data[GameDef.TaskCategory.WorldTeamArena] then
			self.worldTeamArean = data[GameDef.TaskCategory.WorldTeamArena].records or {}
		end
	end
    -- printTable(1,"服务器数据",activeScore)
    --活跃度数据
    if activeScore then
		for k,v in pairs(activeScore) do
            if v.type == GameDef.GamePlayType.TaskDaily then
    			self.dailyActvScore = v
    		end
    		if v.type == GameDef.GamePlayType.TaskWeekly then
    			self.weekActvScore = v
    		end
		end
    end
    self:check_redDot()
end

--检测红点
function TaskModel:check_redDot( ... )
	-- print(1,"TaskModel  check_redDot")
	GlobalUtil.delayCallOnce("TaskModel:check_redDot",function()
		RedManager.updateValue("M_BTN_TASK",false)
		RedManager.updateValue("V_TASK_DAILY",false)
		RedManager.updateValue("V_TASK_WEEK",false)
		RedManager.updateValue("V_TASK_MAIN",false)
	    RedManager.updateValue("V_TASK_Achievement",false)
		local config = self:getAllShowTask( GameDef.TaskCategory.Daily )
		local taskFlag = false
		for k,v in pairs(config) do
			local status = self:getRewardStatus(GameDef.TaskCategory.Daily,v.recordId,v.seq)
			if status == 1 and PlayerModel.level>=v.lv then
				taskFlag = true
				break
			end
		end
		RedManager.updateValue("V_TASK_DAILY",taskFlag)

		config = self:getAllShowTask( GameDef.TaskCategory.Weekly )
		taskFlag = false
		for k,v in pairs(config) do
			local status = self:getRewardStatus(GameDef.TaskCategory.Weekly,v.recordId,v.seq)
			if status == 1 and PlayerModel.level>=v.lv then
				taskFlag = true
				break
			end
		end
		RedManager.updateValue("V_TASK_WEEK",taskFlag)

		config = self:getAllShowTask( GameDef.TaskCategory.Main )
		taskFlag = false
		for k,v in pairs(config) do
			local status = self:getRewardStatus(GameDef.TaskCategory.Main,v.recordId,v.seq)
			if status == 1 then
				taskFlag = true
				break
			end
		end
		RedManager.updateValue("V_TASK_MAIN",taskFlag)
		config = self:getAllShowTask(GameDef.TaskCategory.Achieve,0)
		taskFlag = false
		local taskconfig = TaskConfiger.getAllAchieveConfig()	
		for group,groupData in pairs(taskconfig) do
			RedManager.updateValue("V_TASK_Achievement_"..group,taskFlag)
		end	
		for k,v in pairs(config) do
			local status = self:getRewardStatus(GameDef.TaskCategory.Achieve,v.recordId,v.seq)
			if status == 1 and PlayerModel.level>=v.lv then	
				taskFlag = true
			    RedManager.updateValue("V_TASK_Achievement_"..v.taskGroup,taskFlag)
			end
		end
		RedManager.updateValue("V_TASK_Achievement",taskFlag)
	    RedManager.updateValue("V_TASK_Achievement_0",taskFlag)
			
			

		--如果周常/日常有可领取奖励 任务入口图标增加红点
        -- if not RedManager.getTips("M_BTN_TASK") then
        	local gamePlayArr = {GameDef.GamePlayType.TaskDaily,GameDef.GamePlayType.TaskWeekly}
			for k=1,2 do
				-- if RedManager.getTips("M_BTN_TASK") then
		    	-- 	break
		    	-- end
		    	-- print(1,"k",k.."循环")
				local score,records = ModelManager.TaskModel:getActiValByType(gamePlayArr[k])
			    for i=1,5 do
			    	local flag = false
			    	local config = TaskConfiger.getActiConfig( gamePlayArr[k],i )
			        for k,v in pairs(records) do
			        	if config.id == v.id then --存在
			        		flag = true
			        		break	        		
			        	end
			        end
			        if not  flag and score>= config.score then
			        	-- print(1,"111111111111111111111111111111111111")
						if k == 1 then 
							RedManager.updateValue("V_TASK_DAILY",true)
						elseif k == 2 then
							RedManager.updateValue("V_TASK_WEEK",true)
						end
			        	-- RedManager.updateValue("M_BTN_TASK",true)
			        	break
			        else
                        -- print(1,"22222222222222222222222222222222")
			        	-- RedManager.updateValue("M_BTN_TASK",false)
			        end
			    end
			end
		-- end
		
		-- 组队竞技任务奖励红点
		CrossTeamPVPModel:updateRewardRed()
	end, self, 0.2)
	

end

function TaskModel:updateActivScore( data )
	-- printTable(1,"updateActivScore",data)
	-- RedManager.updateValue("M_BTN_TASK",false)
	if data then
		for k,v in pairs(data) do
            if v.type == GameDef.GamePlayType.TaskDaily then
    			self.dailyActvScore = v
    		end
    		if v.type == GameDef.GamePlayType.TaskWeekly then
    			self.weekActvScore = v
    		end
		end
	end
	Dispatcher.dispatchEvent(EventType.dailyScore_update)
	self:check_redDot()
end

function TaskModel:getActiValByType(gamePlay)
	if gamePlay ==GameDef.GamePlayType.TaskDaily then
		return self.dailyActvScore.score or 0,self.dailyActvScore.rewardRecord or {}
	end
	if gamePlay ==GameDef.GamePlayType.TaskWeekly then
		return self.weekActvScore.score or 0,self.weekActvScore.rewardRecord or {}
	end
end

function TaskModel:getTaskDataByType()
	 return self.__taskOdm
end

--检测是否完成
function TaskModel:checkIsFinish(category,recordId, seq)
	local data
	if category ==GameDef.TaskCategory.Main then
		data = self.__taskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Daily then
		data = self.dailyTaskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Weekly then
		data = self.weekTaskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Achieve then
		data = self.AahieveTaksOdm[recordId]
	elseif category == GameDef.TaskCategory.WorldTeamArena then
		data = self.worldTeamArean[recordId]
	end
	if not data then
		return false
	end

	local finish = data.finish
	if not finish then
		return false
	end


	local shift = (seq - 1) % 32
	local arrayIndex = math.ceil(seq / 32)
	local num = finish[arrayIndex]
	if category ==GameDef.TaskCategory.Main or category ==GameDef.TaskCategory.Achieve then
		--printTable(5656,seq,data,category)
	end

	if not num then
		return false
	end

	return band(num, lshift(1, shift)) > 0
end

function TaskModel:getACCValue(category,recordId,seq )
	local data
	if category ==GameDef.TaskCategory.Main then
		data = self.__taskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Daily then
		data = self.dailyTaskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Weekly then
		data = self.weekTaskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Achieve then
		data = self.AahieveTaksOdm[recordId]
	elseif category == GameDef.TaskCategory.WorldTeamArena then
		data = self.worldTeamArean[recordId]
	end
	if not data then
		return 0
	end
	return data.acc or 0
end

function TaskModel:getTaksOdm(category,recordId,seq )
	local data
	if category ==GameDef.TaskCategory.Main then
		data = self.__taskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Daily then
		data = self.dailyTaskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Weekly then
		data = self.weekTaskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Achieve then
		data = self.AahieveTaksOdm[recordId]
	elseif category == GameDef.TaskCategory.WorldTeamArena then
		data = self.worldTeamArean[recordId]
	end
	if not data then
		return 0
	end
	return data 
end



--@return: 0：无奖励且未领取过；1：有奖励；2：无奖励且领取过
-- 未领取   可领取   已领取
--catogery 任务类型
function TaskModel:getRewardStatus(category,recordId, seq)
	if not self:checkIsFinish(category,recordId, seq) then
		if category == 5 then
			local ll = 1
		end
		return 0
	end

	local data
	if category ==GameDef.TaskCategory.Main then
		data = self.__taskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Daily then
		data = self.dailyTaskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Weekly then
		data = self.weekTaskOdm[recordId]
	elseif category ==GameDef.TaskCategory.Achieve then
		data = self.AahieveTaksOdm[recordId]
	elseif category == GameDef.TaskCategory.WorldTeamArena then
		data = self.worldTeamArean[recordId]
	end

	local got = data.got
	if not got then
		return 1
	end

	local shift = (seq - 1) % 32
	local arrayIndex = math.ceil(seq / 32)
	local num = got[arrayIndex]
	if not num then
		return 1
	end

	if band(num, lshift(1, shift)) > 0 then
		return 2
	end
	return 1
end

--获取当前应该显示的任务
--任务 日常 周常 组队竞技
function TaskModel:getAllShowTask( category,groupId)
	local pLevel = ModelManager.PlayerModel.level
	local configs = {}
	if category ==GameDef.TaskCategory.Main  then
		TaskConfiger.initShowConfig()
		local taskconfig = TaskConfiger.getAllConfig()
		local groupConifg = TaskConfiger.getAllTaskGroupConfig()
		for k,v in pairs(groupConifg) do
			local ChildGroup = v
			local recordId = ChildGroup[1].recordId
			local id =ChildGroup[1].id
			local curConfig = TaskConfiger.getConfigById(recordId,id)
			-- printTable(1,curConfig)
            if pLevel>=curConfig.lv then
            	for i,v in ipairs(ChildGroup) do
            		local tempConfig = TaskConfiger.getConfigById(v.recordId,v.id)
            		if pLevel >=tempConfig.lv then--等级达到 
            			if self:getRewardStatus(category,tempConfig.recordId,tempConfig.seq)~=2  then
                               TaskConfiger.insertShowTable(tempConfig,category)
            				break
            			end
            		end
            	end
            end
		end
	else
		if category ==GameDef.TaskCategory.Daily then
			configs = TaskConfiger.getAllDailyConfig()
			TaskConfiger.initDailyShowConfig()
		elseif category ==GameDef.TaskCategory.Weekly then
			configs = TaskConfiger.getAllWeekConfig()
			TaskConfiger.initWeekShowConfig()
		elseif  category ==GameDef.TaskCategory.WorldTeamArena then
			configs = TaskConfiger.getAllWorldTeamConfig()
			TaskConfiger.initWorldTeamAreanConfig()
		end

		for k,v in pairs(configs) do
		    local configChild = v
			for i,val in ipairs(configChild) do
				-- if pLevel >=val.lv then--等级达到     
				   --  if category ==GameDef.TaskCategory.Main then --主线
				   --  	if self:getRewardStatus(category,k,val.seq)~=2  then
							-- TaskConfiger.insertShowTable(val)
	      --           	break
				    if  category ==GameDef.TaskCategory.Daily or category ==GameDef.TaskCategory.Weekly or category ==GameDef.TaskCategory.WorldTeamArena then --日常 周常 组队竞技
						if category ==GameDef.TaskCategory.Daily then
							TaskConfiger.insertDailyShowTable(val)
						elseif category ==GameDef.TaskCategory.Weekly then
							TaskConfiger.insertWeekShowTable(val)
						elseif category ==GameDef.TaskCategory.WorldTeamArena then
							TaskConfiger.insertWorldTeamShowTable(val)
						end
				    end         
				-- end
			end
		end

	end
	
    if category ==GameDef.TaskCategory.Achieve then
		TaskConfiger.initAchievementConfig()
		local taskconfig = TaskConfiger.getAllAchieveConfig()
		for group,groupData in pairs(taskconfig) do
			if groupId==0 or  groupId==group then
				for k, curConfig in pairs(groupData) do
					if pLevel>=curConfig.lv then
						TaskConfiger.insertShowTable(curConfig,category)
					end
				end
			end
		end
	end
	

	local allshowTable = {}
	if category ==GameDef.TaskCategory.Main or category ==GameDef.TaskCategory.Achieve  then
		allshowTable = TaskConfiger.getShowTable(category)
	elseif category ==GameDef.TaskCategory.Daily then
		allshowTable = TaskConfiger.getDailyShowTable()
	elseif category ==GameDef.TaskCategory.Weekly then
		allshowTable = TaskConfiger.getWeekShowTable()
	elseif category ==GameDef.TaskCategory.WorldTeamArena then
		allshowTable = TaskConfiger.getWorldTeamAreanTable()
	end
	table.sort(allshowTable,function(a,b)
		if (not a) or (not b) then
			return false
		end
		local acc1 = self:getACCValue(category,a.recordId,a.seq)
		local status1 = self:getRewardStatus(category,a.recordId,a.seq)

		local acc2 = self:getACCValue(category,b.recordId,b.seq)
		local status2 = self:getRewardStatus(category,b.recordId,b.seq)

			
		if category~=GameDef.TaskCategory.Main then --周常 日常
			local temp_table = {1,0,3,2}
			status1 = temp_table[status1+1]
			status2 = temp_table[status2+1]

			if pLevel<a.lv then
				status1 = 2
			end

            if pLevel<b.lv then
				status2 = 2
			end

			if status1 == status2 then
				if acc1 and acc2 then
					local num1 = 1.0*acc1/a.count
					local num2 = 1.0*acc2/b.count
					if num1 == num2 then
						return a.lv < b.lv
					else
						return num1 > num2	
					end
				else
					return a.lv < b.lv
				end	
				
			else
				return status1 < status2	
			end  	
        else
        	if status1 == status2 then
				if acc1 and acc2 then
					local num1 = 1.0*acc1/a.count
					local num2 = 1.0*acc2/b.count
					if num1 == num2 then
						return a.recordId<b.recordId
					else
						return num1 > num2	
					end
				else
					return a.lv < b.lv
				end	
				
			else
				return status1 > status2	
			end 
        end
		return false
	end)
	return allshowTable
end





--更新奖励领取情况
function TaskModel:updateRewardStatus(playType,updateInfo)
	local data 
	if playType ==GameDef.GamePlayType.TaskMain  then
		data = self.__taskOdm[updateInfo.recordId]
	elseif playType ==GameDef.GamePlayType.TaskDaily  then
		data = self.dailyTaskOdm[updateInfo.recordId]
	elseif playType ==GameDef.GamePlayType.TaskWeekly  then
		data = self.weekTaskOdm[updateInfo.recordId]
	elseif playType ==GameDef.GamePlayType.TaskAchieve  then-- 成就奖励
		data = self.AahieveTaksOdm[updateInfo.recordId]
	elseif playType ==GameDef.GamePlayType.TaskWorldTeamArena then --组队竞技
		data = self.worldTeamArean[updateInfo.recordId]
	elseif playType == GameDef.GamePlayType.ActivitySevenDayRecord
			or playType == GameDef.GamePlayType.ActivityRiskDiary then
        return
    elseif playType == GameDef.GamePlayType.DutyTask  then --职级任务
		ModelManager.DutyModel:updateRewardStatus(updateInfo)
        return
    elseif playType == GameDef.GamePlayType.ActivityCollectThingsDaily  
    	or playType == GameDef.GamePlayType.ActivityCollectThingsHas then -- 集物活動
    	ModelManager.CollectThingModel:updateRewardStatus(updateInfo)
		return 
	elseif playType ==GameDef.GamePlayType.ActivityHeroCome  then-- 英雄降临
		ModelManager.OperatingActivitiesModel:setTaskNieYinComingMap(updateInfo)
	elseif playType ==GameDef.GamePlayType.ActivityPrimaryTask  then-- 开服福利
		ModelManager.OperatingActivitiesModel:setOpenTakeWelfareTaskMap(updateInfo)		
	elseif playType ==GameDef.GamePlayType.ActivityElfCollection  then-- 精灵收集
		ModelManager.OperatingActivitiesModel:setElvestoCollectActiveTaskMap(GameDef.ActivityType.ElfCollection,updateInfo)		
	elseif playType ==GameDef.GamePlayType.ActivityElfSummon  then-- 精灵召唤
		ModelManager.OperatingActivitiesModel:setElvestoCollectActiveTaskMap(GameDef.ActivityType.ElfSummon,updateInfo)		
	elseif playType ==GameDef.GamePlayType.GodArms then -- 秘武玩法
		ModelManager.SecretWeaponsModel:updateSecretWeaponsTaskInfo(updateInfo)	
	end
	if data then
		data.got = updateInfo.got
		data.seq = updateInfo.seq
	end
	self:check_redDot()
	Dispatcher.dispatchEvent(EventType.task_update, gamePlayType, updateInfo.recordId, updateInfo.seq)
end


--更新某个任务的是否完成情况
function TaskModel:updateProgress(playType,updateInfo)
	--printTable(5656,"更新某个任务的是否完成情况",playType,updateInfo)
    local data ={}
	if playType ==GameDef.GamePlayType.TaskMain  then
		data = self.__taskOdm[updateInfo.recordId]
		if not data then
			data = updateInfo
			self.__taskOdm[updateInfo.recordId] = data
		end
	elseif playType ==GameDef.GamePlayType.TaskDaily  then
		data = self.dailyTaskOdm[updateInfo.recordId]
	    if not data then
			data = updateInfo
			self.dailyTaskOdm[updateInfo.recordId] = data
		end
	elseif playType ==GameDef.GamePlayType.TaskWeekly  then
		data = self.weekTaskOdm[updateInfo.recordId]
	    if not data then
			data = updateInfo
			self.weekTaskOdm[updateInfo.recordId] = data
		end
	elseif playType ==GameDef.GamePlayType.TaskAchieve  then-- 成就奖励
		data = self.AahieveTaksOdm[updateInfo.recordId]
		if not data then
			data = updateInfo
			self.AahieveTaksOdm[updateInfo.recordId] = data
		end
	elseif playType ==GameDef.GamePlayType.ActivitySevenDayRecord  then
        return
    elseif playType ==GameDef.GamePlayType.DutyTask  then --职级系统
		ModelManager.DutyModel:updateProgress(updateInfo)
        return
    elseif playType == GameDef.GamePlayType.ActivityCollectThingsDaily 
    	or playType == GameDef.GamePlayType.ActivityCollectThingsHas then -- 集物活动
    	ModelManager.CollectThingModel:updateProgress(updateInfo)
		return
	elseif playType ==GameDef.GamePlayType.ActivityHeroCome  then-- 英雄降临
		ModelManager.OperatingActivitiesModel:setTaskNieYinComingMap(updateInfo)	
	elseif playType ==GameDef.GamePlayType.ActivityPrimaryTask  then-- 开服福利
		ModelManager.OperatingActivitiesModel:setOpenTakeWelfareTaskMap(updateInfo)	
	elseif playType ==GameDef.GamePlayType.ActivityElfCollection  then-- 精灵收集
		ModelManager.OperatingActivitiesModel:setElvestoCollectActiveTaskMap(GameDef.ActivityType.ElfCollection,updateInfo)		
	elseif playType ==GameDef.GamePlayType.ActivityElfSummon  then-- 精灵召唤
		ModelManager.OperatingActivitiesModel:setElvestoCollectActiveTaskMap(GameDef.ActivityType.ElfSummon,updateInfo)	
	elseif playType ==GameDef.GamePlayType.TaskWorldTeamArena then -- 组队竞技
		data = self.worldTeamArean[updateInfo.recordId]
	    if not data then
			data = updateInfo
			self.worldTeamArean[updateInfo.recordId] = data
		end
	elseif playType ==GameDef.GamePlayType.GodArms then -- 秘武玩法
		ModelManager.SecretWeaponsModel:updateSecretWeaponsTaskInfo(updateInfo)	
	end

	local _finish = data and data.finish or {}

	local doneFlag = false
	local finish = updateInfo.finish
	if finish then
		for k, num in ipairs(finish) do
			local _num = _finish[k] or 0
			if num ~= _num then
				for i = 1, 32 do
					local n = lshift(1, (i - 1))
					if band(num, n) > 0 and band(_num, n) <= 0 then
						doneFlag = true
						local seq = (k - 1) * 32 + i
						
						Dispatcher.dispatchEvent(EventType.task_finish, gamePlayType, updateInfo.recordId, seq)
						-- Dispatcher.dispatchEvent(EventType.task_update, gamePlayType, updateInfo.recordId, seq)
					end
				end
			end
		end
		data.finish = finish
		data.finDt = updateInfo.finDt
	end
	
	if data then
		data.acc = updateInfo.acc
	end
	self:check_redDot()
	Dispatcher.dispatchEvent(EventType.task_update)

	return doneFlag
end



function TaskModel:updateActivTaskCategoryData( data )
	if data then
			--日常
	    if data[GameDef.TaskCategory.Daily] and data[GameDef.TaskCategory.Daily].category == GameDef.TaskCategory.Daily then
			self.dailyTaskOdm = data[GameDef.TaskCategory.Daily].records or {}
		end
		--周常
		if data[GameDef.TaskCategory.Weekly] and data[GameDef.TaskCategory.Weekly].category == GameDef.TaskCategory.Weekly then
			self.weekTaskOdm = data[GameDef.TaskCategory.Weekly].records or {}
		end
		if data[GameDef.TaskCategory.Achieve] then
			self.AahieveTaksOdm = data[GameDef.TaskCategory.Achieve].records or {}
		end
		if data[GameDef.TaskCategory.WorldTeamArena] then
			self.worldTeamArean = data[GameDef.TaskCategory.WorldTeamArena].records or {}
		end
	end
	Dispatcher.dispatchEvent(EventType.dailyTask_update)
end




--model清除
function TaskModel:clear()
    self.__taskOdm = {}
    self.dailyTaskOdm = {}
	self.weekTaskOdm = {}
	self.worldTeamArean = {}
end

return TaskModel