local FunCheckManager = {}
local CheckedFunc = require "Configs.Handwork.FunCheck"
local director = cc.Director:getInstance()
-- local funcCheck = FunctionCheck:getInstance()

local checkedFuncNum = 0
local schedulerId = 0
local haveCheckFunc = false

local function doCheckFunc(isChangeFunc)
	if isChangeFunc then
		print("~~~~~~~~~~FunctionCheck~~~~change~~~~~~~~~~")
	else
		print("~~~~~~~~~~FunctionCheck~~~~no change~~~~~~~~~~")
	end
end

function FunCheckManager.initCheckedFunc()
	for _, v in ipairs(CheckedFunc) do
		if v.platform==CC_TARGET_PLATFORM then
			funcCheck:addFunction(v.funName, v.dllName)
			checkedFuncNum = checkedFuncNum + 1
		end
	end
end

function FunCheckManager.startCheckFunc()
	if haveCheckFunc then
		return
	end

	if checkedFuncNum == 0 then
		return
	end

	function onSchedule(time)
		if director:getDeltaTime()>0.020 then
			return
		end

		funcCheck:startCheckFunction(doCheckFunc)
	end

	schedulerId = director:getScheduler():scheduleScriptFunc(onSchedule, 5, false);
	haveCheckFunc = true
end

function FunCheckManager.endCheckFunc()
	director:getScheduler():unscheduleScriptEntry(schedulerId)
	haveCheckFunc = false
end

return FunCheckManager