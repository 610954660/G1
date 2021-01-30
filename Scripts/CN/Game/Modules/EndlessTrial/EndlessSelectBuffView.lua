-- addedby wyz
-- 无尽试炼选择buff增益

local MazeConfiger  = require "Game.ConfigReaders.MazeConfiger"
local EndlessSelectBuffView = class("EndlessSelectBuffView",View)


function EndlessSelectBuffView:ctor()
	self._packName 	= "EndlessTrial"
	self._compName 	= "EndlessSelectBuffView"
	self._rootDepth = LayerDepth.PopWindow

	self.list_hero 	= false 	-- 阵容列表
	self.list_buff 	= false 	-- 增益buff列表

	self.btn_select = false 	-- 选择并挑战按钮
	self.timer 		= false 	-- 计时器 五分钟没有选择buff自动选择一个
	self.isSelectBuff = false 	-- 是否已选择buff
	self.selectSkillId = false
end

function EndlessSelectBuffView:_initUI()
	self.list_hero 	= self.view:getChildAutoType("list_hero")
	self.list_buff 	= self.view:getChildAutoType("list_buff")

	self.btn_select = self.view:getChildAutoType("btn_select")
end


function EndlessSelectBuffView:_initEvent()
	-- printTable(8848,"self._args",self._args)
	LuaLogE("无尽试炼 >>>>> 进入buff选择界面")
	local buffSelectData = self._args.buffSelect
	local heroInfoList 	 = self._args.heroInfoList
	local buffColorCfg 	 = DynamicConfigData.t_TopChallengeBuff

	-- buff列表
	self.list_buff:setSelectedIndex(0)
	self.list_buff:setItemRenderer(function(idx,obj)
		local skillId = buffSelectData[idx+1]
		local txt_skill = obj:getChildAutoType("txt_skill")
		local icon 		= obj:getChildAutoType("icon")
		local boxColorCtrl 		= obj:getController("boxColorCtrl")
		local config 	= MazeConfiger.getRelicConfig(skillId)

		if (0 == idx) then
			self.selectSkillId = buffSelectData[idx+1]
			-- printTable(8848,"self.selectSkillId",self.selectSkillId)
			ModelManager.EndlessTrialModel:setBuffName(config.showName)
		end
		-- 技能名字 config.skillName
		-- 技能描述 config.showName
		txt_skill:setText(config.showName)
		boxColorCtrl:setSelectedIndex(buffColorCfg[skillId].color)
		icon:setURL("Icon/topchallenge/"..skillId ..".png")

	end)
	self.list_buff:setNumItems(#buffSelectData)

	self.list_buff:removeClickListener(22)
	self.list_buff:addClickListener(function ()
		local idx = self.list_buff:getSelectedIndex()
		self.selectSkillId = buffSelectData[idx+1]
		local config 	= MazeConfiger.getRelicConfig(self.selectSkillId)
		ModelManager.EndlessTrialModel:setBuffName(config.showName)
		-- printTable(8848,"self.selectSkillId",self.selectSkillId)
	end, 22)

	-- 选择并挑战按钮
	self.btn_select:removeClickListener(22)
	self.btn_select:addClickListener(function()
		-- print(8848,">>>>>>>>>self.selectSkillId>>>>>>",self.selectSkillId)
		self:RPCReqBuff(self.selectSkillId)
	end,22)

	-- 英雄列表
	heroInfoList = ModelManager.EndlessTrialModel:setAllInBattle(heroInfoList)
	self.list_hero:setItemRenderer(function(idx,obj)
		local data 		= heroInfoList[idx+1]
		local heroCell 	= BindManager.bindHeroCell(obj)
		heroCell:setData(data)

	end)
	self.list_hero:setData(heroInfoList)

	local startTime = 0
	local function docallback()
 		startTime = startTime + 1
 		if startTime >= 300 then
 			Scheduler.unschedule(self.timer)
			self.timer = false
			self:RPCReqBuff(self.selectSkillId)
 		end
	end
	self.timer = Scheduler.schedule(docallback,1)
end

function EndlessSelectBuffView:RPCReqBuff(selectSkillId)
	LuaLogE("无尽试炼 >>>>>>> 开始请求buff")
	local reqBuff = {
		buffId = selectSkillId,
	}
	local reqInfo = {
		type 	= self._args.type,
		level 	= self._args.level,
	}
	printTable(8848,">>>>>>>>>self.selectSkillId>>>>>>",reqBuff)
	RPCReq.TopChallenge_ChooseBuff(reqBuff,function()
		printTable(8848,">>>>>>>>>self.selectSkillId>>>>>>111111",reqInfo) 
		RPCReq.TopChallenge_Challenge(reqInfo,function(params)
			ModelManager.EndlessTrialModel:setDailyDataReward(self._args.level)
			if params.result then
				local dayStr = DateUtil.getOppostieDays()
				FileCacheManager.setIntForKey("EndlessTrialFirstFight" .. dayStr, ModelManager.EndlessTrialModel:getMaxLevel(self._args.type))
			end
			Dispatcher.dispatchEvent(EventType.EndlessTrial_refreshAddTopChallengeView)
			ModelManager.EndlessTrialModel:setCurrentLevel()
			LuaLogE("无尽试炼 >>>>>>> 选择完buff并关闭buff界面")
			if not self.isSelectBuff then
				self.isSelectBuff = true
				ViewManager.close("EndlessSelectBuffView")
			end
			if params.isDailyLimit then
				Dispatcher.dispatchEvent(EventType.battle_end)
			end
		end)
	end)

end

function EndlessSelectBuffView:EndlessTrial_endBuffView()
	ViewManager.close("EndlessSelectBuffView")
end

function EndlessSelectBuffView:_exit()
	LuaLogE("无尽试炼 >>>>>>> 关闭buff界面")
	if self.timer then
		Scheduler.unschedule(self.timer)
		self.timer = false
	end
	if not self.isSelectBuff and ModelManager.EndlessTrialModel.result then
		self.isSelectBuff = true
		self:RPCReqBuff(self.selectSkillId)
	end
end

return EndlessSelectBuffView