--Name : FairyLandQuestionView.lua
--Author : wyang
--Date : 2020-4-15
--Desc : 

local FairyLandQuestionView,Super = class("FairyLandQuestionView", Window)

function FairyLandQuestionView:ctor()
	--LuaLog("FairyLandQuestionView ctor")
	self._packName = "FairyLand"
	self._compName = "FairyLandQuestionView"
	self._rootDepth = LayerDepth.PopWindow
	self.txt_qn = false
	self.txt_time = false
	self.list_answer = false
	
	self._answerData = {}
	self._qnInfo = false
	self._updateTimeId = false
	self._hasSendQn = false
	
	self._qnConfig = false
end

function FairyLandQuestionView:_initEvent( )
	
end


function FairyLandQuestionView:_initUI( )
	self._qnInfo = self._args
	self.txt_qn = self.view:getChildAutoType("txt_qn")
	self.txt_time = self.view:getChildAutoType("txt_time")
	self.list_answer = self.view:getChildAutoType("list_answer")
	
	self._closeBtn:setVisible(false)
	self._qnConfig = DynamicConfigData.t_question[self._qnInfo.value]
	if(not self._qnConfig) then return end
	
	self.txt_qn:setText(self._qnConfig.issue)
	self._answerData = {}
	for i = 1,4,1 do
		local akey = self._qnConfig["opt"..i]
		if  akey and akey ~="" then
			table.insert(self._answerData, self._qnConfig["opt"..i])
		end
	end
	
	self.list_answer:setItemRenderer(
			function(index, obj) 
				local info = self._answerData[index + 1]
				obj:setTitle(info);
				obj:removeClickListener(100)
				obj:addClickListener(
					function(...)
						self:sendAn(index + 1)
					end,100
				)
			end
		)
		self.list_answer:setData(self._answerData)
	
	local startTime = ServerTimeModel:getServerTime()
	local updateTime = function ()
		local time = ServerTimeModel:getServerTime()
		local timeLeft = self._qnInfo.sec - time
		if FairyLandModel.autoNext and (ServerTimeModel:getServerTime() - startTime) >= 2 then
			self:autoAn()
		end
		if(timeLeft <= 0) then
			--RollTips.show(Desc.fairyLand_answerTimeout)
			--self:closeView()
			--Dispatcher.dispatchEvent(EventType.fairyLand_moveNextGrid)
			--return
			Scheduler.unschedule(self._updateTimeId)
		end
		
		self.txt_time:setText(string.format(Desc.fairyLand_answerTime, timeLeft))
	end
	
	self._updateTimeId  = Scheduler.schedule(function()
		updateTime()
	end,1)
	updateTime()
	
	
end

--自动答题
function FairyLandQuestionView:autoAn()
	local anNum = #self._answerData
	local random = math.floor(math.random() * anNum) + 1
	print(69, "FairyLandQuestionView:autoAn", random)
	self:sendAn(random)
end

--·¢Ëʹð°¸
function FairyLandQuestionView:sendAn(anIndex)
	if self._hasSendQn then return end
	local params = {}
	params.value = anIndex
	params.onSuccess = function (res )
		--printTable(1, res)
		ModelManager.FairyLandModel:addGetRewardGrid()
		ModelManager.FairyLandModel:updateInfo(res.data)

		if(res.result) then
			RollTips.show(Desc.fairyLand_answerRight)
		else
			local an = self._qnConfig["opt"..res.value]
			RollTips.show(string.format(Desc.fairyLand_answerWrong, an))
		end
		Dispatcher.dispatchEvent(EventType.fairyLand_moveNextGrid)
		
		if tolua.isnull(self.view) then return end
		if(res.data.reward) then
			local curItem = self.list_answer:getChildAt(anIndex - 1)
			ModelManager.FairyLandModel.reward = false
			--RollTips.flyReward(res.data.reward, curItem)
			RollTips.showReward(res.data.reward, nil, FairyLandModel.autoNext and 2 or -1)
		end
		self:closeView()
		
	end
	
	--params.onFail = function()
	--	self:closeView()
	--	Dispatcher.dispatchEvent(EventType.fairyLand_moveNextGrid)
	--end
	RPCReq.FairyLand_Action(params, params.onSuccess, params.onFail)
	--self:closeView()
	--ModelManager.FairyLandModel:addGetRewardGrid()
	--Dispatcher.dispatchEvent(EventType.fairyLand_moveNextGrid)
	self._hasSendQn = true
end


--´ðÌⳬʱ£¬·þÎñ¶ËÍƽ±Àø¹ýÀ´£¨³¬ʱҲÓн±Àø£©
function FairyLandQuestionView:FairyLand_UpdateFairyLandData(_,params)
	RollTips.show(Desc.fairyLand_answerTimeout)
	self:closeView()
	ModelManager.FairyLandModel:addGetRewardGrid()
	Dispatcher.dispatchEvent(EventType.fairyLand_moveNextGrid)
end


--initEventºóִÐÐ
function FairyLandQuestionView:_enter( ... )
	print(1,"FairyLandQuestionView _enter")
end


--ҳÃæÍ˳öʱִÐÐ
function FairyLandQuestionView:_exit( ... )
	print(1,"FairyLandQuestionView _exit")
	Scheduler.unschedule(self._updateTimeId)
end

return FairyLandQuestionView