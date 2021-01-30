--Name : HintController.lua
--Author : generated by FairyGUI
--Date : 2020-4-15
--Desc : 

local HintController = class("HintController",Controller)

function HintController:init()
	self.recordValues = {}
	self.needOpen = {}
	self.checkTimer = false
	self.chapterinfo={}
	self.delayTimer= false
end

function HintController:getOpenInfo(type, value, valueEx)
	if value == nil then value = 0 end
	local moduleIdlist = {}
	for _,v in pairs(DynamicConfigData.t_AutoWindow) do
		local info = v.type
		for _,condition in ipairs(info) do
			if condition.type == type and condition.value == value  and condition.valueEx == valueEx then
				table.insert(moduleIdlist, v)
			end
		end
	end
	return moduleIdlist
end

function HintController:openModules()
	if self.checkTimer then 
		Scheduler.unschedule(self.checkTimer) 
		self.checkTimer = false
	end
		
	local isInBattle = false
	if ViewManager.isShow("BattleBeginView") or ViewManager.isShow("BattlePrepareView") then
		isInBattle = true
	end
	
	TableUtil.sortByMap(self.needOpen, {{key = "id", asc = false}})
	if not isInBattle then
		for _,v in ipairs(self.needOpen) do
			if v.needFunction == 43 then
				local showData = LoginModel:getNotice(11)
				if not showData or #showData<0  then
					showData = LoginModel:getNotice(10)
				end
				if showData and #showData>0 then
					ModuleUtil.openModule(v.needFunction,false)
				end
			elseif v.needFunction == 269 then --时装登录弹窗
				ModuleUtil.openModule(v.needFunction,false)
			elseif ModuleUtil.hasModuleOpen(v.needFunction) then
				ModuleUtil.openModule(v.needFunction,false)
			end
		end
		self.needOpen = {}
	else
		--如果在战斗中，延时0.5秒再检查一次
		
		self.checkTimer = Scheduler.scheduleOnce(0.5, function()
			self:openModules()
		end)
	end
end

--每天首次进入游戏
function HintController:delayOpen(moduleIds)
	if moduleIds then
		for _,v in ipairs(moduleIds) do
			table.insert(self.needOpen, v)
		end
	end
	
	if self.delayTimer then 
		Scheduler.unschedule(self.delayTimer)
		self.delayTimer = false
	end
	self.delayTimer = Scheduler.scheduleOnce(0.7, function()
		self:openModules()
	end)
end


--每天首次进入游戏
function HintController:public_firstEnterGameToday(_,data)
	local moduleIds = self:getOpenInfo(1)
	self:delayOpen(moduleIds)
end

--每次进入游戏
function HintController:public_enterGame(_,data)
	local moduleIds = self:getOpenInfo(2)
	self:delayOpen(moduleIds)
end



--人物升级
function HintController:player_levelUp(_,data)
	local moduleIds = self:getOpenInfo(3, ModelManager.PlayerModel.level)
	self:delayOpen(moduleIds)
end


--任务完成
function HintController:task_finish(_,gamePlayType, recordId, seq)
	local moduleIds = self:getOpenInfo(4, recordId, seq)
	self:delayOpen(moduleIds)
end

--推图层次改变
function HintController:pushMap_getCurPassPoint(_,data)
	printTable(152,"!!!!!!!@@@@@@",data)
	if data and data.chapterId and data.cityId and data.pointId then
		self.chapterinfo=data
		-- local chaptersPoint = DynamicConfigData.t_chaptersPoint[data.cityId][data.chapterId][data.pointId]
		-- if chaptersPoint then
		-- 	local moduleIds = self:getOpenInfo(5, chaptersPoint.fightfd)
		-- 	if self.recordValues[5] and (chaptersPoint.fightfd ~= self.recordValues[5]) then
		-- 		--self:openModules(moduleIds)
		-- 	end
			--self.recordValues[5] = chaptersPoint.fightfd
		--end
	end
end

--推图层次改变
function HintController:pushMap_figthendInfo(...)
	printTable(152,"2222222222@@@@@@",self.chapterinfo)
	if not self.chapterinfo then return end
	local city,chapter,chaptersPoint 
	local city = DynamicConfigData.t_chaptersPoint[self.chapterinfo.cityId]
	if city then
		chapter = city[self.chapterinfo.chapterId]
	end
	if chapter then
		chaptersPoint = chapter[self.chapterinfo.pointId]
	end
	if chaptersPoint then
		local moduleIds = self:getOpenInfo(5, chaptersPoint.fightfd)
		if self.recordValues[5] and (chaptersPoint.fightfd ~= self.recordValues[5]) then
			self:openModules(moduleIds)
		end
		self.recordValues[5] = chaptersPoint.fightfd
	end
end



--新功能开放提示
function HintController:module_open_hint(_)

	if ViewManager.getView("BattleBeginView") then return end
	if ViewManager.getView("BattlePrepareView") then return end
	if ViewManager.getView("ReWardView") then return end
	if ViewManager.getView("AwardShowView") then return end
	if ViewManager.getView("AwardView") then return end
	if ViewManager.getView("SealDevilView") then return end
	if PlayerModel:get_awardData() then return end
	
	if ViewManager.isShow("UpgradeView") then
		return
	end
	
	local info  = ModuleUtil.getNewOpenModuleInfo()
	if info then
		PHPUtil.reportStep(ReportStepType.GET_MODULE_OPEN+info.id)
		ViewManager.open("ModuleOpenView",info)
	end
end


return HintController