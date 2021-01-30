-- ��ȡ�������
local RewardBoard = class("RewardBoard",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --�������ö�ȡ��
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"
local BagType = GameDef.BagType
function RewardBoard:ctor(view,noClick)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
		
	self.rewardData = DynamicConfigData.t_EventConst[1].finishReward
	
	self.list_reward  = false
	self.btn_getReward = false
end

function RewardBoard:init( ... )
	self.list_reward = self.view:getChildAutoType("list_reward")
	
	self.list_reward:setItemRenderer(function(index,obj)
		local reward = self.rewardData[index + 1]
		local itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
		itemCell:setIsBig(true)
		itemCell:setData(reward.code, reward.amount, reward.type)
	end)
	self.list_reward:setData(self.rewardData)
	
	self.btn_getReward = self.view:getChildAutoType("btn_getReward")
	self.btn_getReward:setGrayed(EventBrocastModel.myRecordInfo and EventBrocastModel.myRecordInfo.dayRecvState)
	self.btn_getReward:setTouchable(not (EventBrocastModel.myRecordInfo and EventBrocastModel.myRecordInfo.dayRecvState))
	RedManager.register("V_NEW_EVENT_REWARD", self.btn_getReward:getChildAutoType("img_red"))
	self.btn_getReward:addClickListener(function ( ... )
		if not (EventBrocastModel.myRecordInfo and EventBrocastModel.myRecordInfo.dayRecvState) then
			EventBrocastModel:getReward()	
		end
	end)
end

--�˳����� ��closeִ��֮ǰ 
function RewardBoard:__onExit()
     print(086,"RewardBoard __onExit")
--   self:_exit() --ִ��������д
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return RewardBoard