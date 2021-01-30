--Date :2021-01-21
--Author : generated by FairyGUI
--Desc : 

local TwistSpFestivalModel = class("TwistSpFestival", BaseModel)

function TwistSpFestivalModel:ctor()
	self.activeData=false
	self.activeConfig=false
	self.moduleId=1
	self.hasOpen=false
end

function TwistSpFestivalModel:init()
   self:setSendWordActiveDataCfg()
end


function TwistSpFestivalModel:initData(data)
	if data and data.festivalWish then
		self.activeData = data.festivalWish or  {}
	end
	self:setSendWordActiveDataCfg()
	local acConfig=ActivityModel:getActityByType(GameDef.ActivityType.FestivalWish)
	if acConfig then
		self.moduleId=acConfig.showContent.moduleId or 1
	end
	self:redCheck()
end


function TwistSpFestivalModel:getAciveConfig()
	return self.activeConfig
end


function TwistSpFestivalModel:getAciveData()
    return self.activeData
end


function TwistSpFestivalModel:setSendWordActiveDataCfg()
	if TableUtil.GetTableLen(self.activeConfig) == 0 then
		self.activeConfig = DynamicConfigData.t_FestivalWishConfig[self.moduleId]
	end
end





function TwistSpFestivalModel:redCheck()
	GlobalUtil.delayCallOnce("TwistSpFestivalModel:redCheck",function()
			self:updateRed()
		end, self, 0.1)
end



--填写祝福
function TwistSpFestivalModel:postWish(content,finished)
	local param={	
		content=content
	}
	local function success(data)
		printTable(5656,"填写寄语返回",data)
		if finished then
			finished()
		end
		self.activeData.isWish=true
		self.activeData.myWish.content=content
		Dispatcher.dispatchEvent(EventType.activity_FestivalWishUpdate,{showAction=true})
		
	end
	RPCReq.Activity_FestivalWish_Post(param,success)
end


--提交寄语确认
function TwistSpFestivalModel:showConfirmView(yesFunc)
	local info = {}
	info.title = "提示"
	info.text = "亲爱的探长，您的寄语将以弹幕的形式展示给其它玩家，且不可更改，确定提交吗？"
	info.yesText ="提交"
	info.noText = "取消"
	info.mask = true
	info.type = "yes_no"
	info.onYes = function()
		if yesFunc then
			yesFunc()
		end
	end
	info.onNo = function()

	end
	Alert.show(info)
end




--获取寄语信息
function TwistSpFestivalModel:getBarrage(finished)
	
	local param={}
	local function success(data)
		printTable(5656,"拉取寄语信息返回",data)
		if finished then
			finished(data)
		end
	end
	RPCReq.Activity_FestivalWish_GetBarrage(param,success)
end




function TwistSpFestivalModel:updateRed()
	RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.FestivalWish,not self.activeData.isWish and not self.hasOpen)
end



return TwistSpFestivalModel