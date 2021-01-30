
local  FsmMachine = class("FsmMachine")

local instance=false

function FsmMachine:ctor()
	self.states = {}
	self.curState = nil
	self.battleState="end"
end

function FsmMachine:getInstance()
	return instance
end


-- 添加状态
function FsmMachine:AddState(baseState)
	self.states[baseState.stateName] = baseState
end

-- 初始化默认状态
function FsmMachine:AddInitState(baseState)
	self.curState = baseState
end

-- 更新当前状态
function FsmMachine:Update()
	self.curState:OnUpdate()
end


--添加一个特效播放等待队列
function FsmMachine:addWaitQues(index,id,fxName)
	local quesName="特效:("..index..")".."人物ID:["..id.."]"..fxName	
	return BattleManager:getInstance():addWaitQues(quesName)
end



function FsmMachine:changeBattleState(stateName)
    self.battleState=stateName
end

function FsmMachine:getBattleState()
	return self.battleState
end


-- 切换状态
function FsmMachine:Switch(stateName)
	if self.curState.stateName ~= stateName then
		self.curState:OnLeave()
		self.curState = self.states[stateName]
		self.curState:OnEnter()
	end
end

instance = FsmMachine.new()

return instance