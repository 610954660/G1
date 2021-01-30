-- added by zn
-- 转盘model
local ActivityType = require "Configs.GameDef.ActivityType";
local TurnTableConfiger = require "Game.ConfigReaders.TurnTableConfiger";
local BaseModel = require "Game.FMVC.Core.BaseModel";
local TurnTableModel = class("TurnTableModel", BaseModel);

--[[
	.PPowerTurnTable {
		poolType 		0:integer			# 转盘类型
		poolId			1:integer			# 当前抽取奖池id
		drawCount		2:integer			# 抽取次数
		refreshTimeMs 	3:integer			# 更新时间戳
		point 			4:integer			# 积分点
		recvMark  		5:integer 			# 二进制计数 位为 数对应的 为0 或者空 是没有领取 对应的为 1 是已经领取
	}
--]]

function TurnTableModel:ctor()
	-- 跳过动画标识
	self.passAnimFlag = 0;
	-- 1 普通转盘 2 高级转盘 可能没有2
	self.tableList = {};
	-- 展示转盘类型
	self.tableType = 1;
	-- 活动Id
	self.activityId = GameDef.ActivityType.PowerTurnTable
	-- 奖励列表
	self.rewardList = false;
	self._redMap = false;
end

function TurnTableModel:setTableType(tabType)
	self.tableType = tabType;
end

function TurnTableModel:setData(param)
	-- if (param.data) then
	-- 	self.tableList = param.data;
	-- end
	if (param.activityId) then
		self.activityId = param.activityId
	end
	self.tableList = param;
	self:checkRedPoint();
end

-- @rewardList 服务端返回List 为中奖位置
function TurnTableModel:setRewardList(rewardList,reward)
	self.rewardList = {};
	local conf = TurnTableConfiger.getTableAwards(self.tableList[self.tableType].poolId);
	for _, idx in ipairs(rewardList) do
		table.insert(self.rewardList, conf[idx]);
	end
	table.insert(self.rewardList,reward);
end

-- 是否存在高级转盘
function TurnTableModel:existSpecialTable(showTips)
	showTips = showTips == nil and true or false
	local conf = TurnTableConfiger.getTableInfoByType(2);
	local limitType = conf.condition; -- 1=默认开启，2=开服时间，3=等级开启
	local value = conf.startValue;
	if (limitType == 2) then
		-- LuaLog("开服天数", ServerTimeModel.getOpenDay(), "解锁条件", value);
		return (ServerTimeModel:getOpenDay() >= value)
	elseif (limitType == 3) then
		-- LuaLog("玩家等级", PlayerModel.level, "解锁条件", value);
		if (PlayerModel.level < value and showTips) then
			RollTips.show(string.format(Desc.turnTable_levelLimit, value));
		end
		return (PlayerModel.level >= value)
	end
	return false;
end

-- 获取某一类型转盘数据 1 普通转盘 2高级转盘
function TurnTableModel:getTableDataByType(tableType)
	return self.tableList[tableType];
end

-- 获取刷新剩余时间
function TurnTableModel:getRefreshLeftTime()
	local data = self.tableList[self.tableType];
	-- LuaLogE("===== 刷新时间")
	-- printTable(1, data);
	-- LuaLog("刷新时间戳", data.refreshTimeMs, "服务器时间", ServerTimeModel:getServerTime());
	local leftTime = data.refreshTimeMs / 1000 - ServerTimeModel:getServerTime();
	if (leftTime <= 0) then
		return 0;
	end
	return leftTime;
end

-- 宝箱领取情况  @return 0 未领取 1 可领取 2 已领取
function TurnTableModel:getScoreBoxStatus(idx, tableType)
	if not self.tableList then return 0 end;
	tableType = tableType == nil and self.tableType or tableType;
	local data = self.tableList[tableType];
	local conf = TurnTableConfiger.getScoreBoxListByType(self.tableType);
	local num = data.recvMark;
	local curScore = data.point;
	local status = 0;
	local flag = bit.band(num, bit.lshift(1, idx - 1)) > 0;
	if flag == true then
		status = 2;
	elseif curScore >= conf[idx].needPoint then
		status = 1;
	end
	return status;
end

-- 判断货币是否足够 1 单抽 2 连抽
-- @param gotoTip 是否弹出前往购买提示 默认true
-- @return { 是否有足够货币, 是否配置快捷购买 }
function TurnTableModel:haveEnoughCoin(lotteryType--[[ , gotoTip ]])
	-- gotoTip = (gotoTip == nil) and true or gotoTip;
	local conf = TurnTableConfiger.getTableInfoByType(self.tableType);
	local costConf = conf.needItem[1];
	local cost = 1
	local gotoTip = (self.tableType == 1) and true or false;
	if (lotteryType == 1) then
		cost = conf.draw[1].cost;
	elseif (lotteryType == 10) then
		cost= conf.tenDraw[1].cost;
	end
	-- local have = PackModel:getItemsFromAllPackByCode(costConf.code);
	local enough = PlayerModel:checkCostEnough({type = costConf.type, code = costConf.code, amount=cost}, gotoTip)-- (have >= cost) and true or false;
	local itemBuy = type(conf.itemBuy[1]) ~= "nil";
	-- print(1, "快速购买", enough, itemBuy, cost);
	return enough, itemBuy;
end

-- 检测红点
function TurnTableModel:checkRedPoint()
	if not self.activityId then return end;
	local key = "V_ACTIVITY_"..self.activityId;
	if (not self._redMap) then
		local boxMap = {}
		for j = 1, 5 do
			table.insert(boxMap, key.."_BOX"..j);
		end
		RedManager.addMap(key, boxMap);
		self._redMap = true
	end
	

	-- 检测红点
	local flag1 = false;
	local flag2 = false;
	for j = 1, 5 do
		if (flag1 ~= true or flag2 ~= true) then
			for i = 1, 2 do
				local status = self:getScoreBoxStatus(j, i);
				if (i == 1) then
					flag1 = flag1 or status == 1;
				else
					flag2 = flag2 or status == 1;
				end
			end
		end
		
		local k = key.."_BOX"..j;
		RedManager.updateValue(k, self:getScoreBoxStatus(j) == 1);
	end
	local hasNormal = ModelManager.PackModel:getItemsFromAllPackByCode(10000036)
	local hasSpeacil = self:existSpecialTable(false) and ModelManager.PackModel:getItemsFromAllPackByCode(10000037) or 0
	RedManager.updateTips(key.."_btn1", flag1 or hasNormal >= 10);
	--RedManager.updateTips(key.."_btn2", flag2 or hasSpeacil >= 1);

	local flag = flag1 or flag2 or (hasNormal >= 10 or hasSpeacil >= 1)
	RedManager.updateValue(key, flag);
end

function TurnTableModel: getPassAnimFlag()
	if (type(self.passAnimFlag) ~= "boolean") then
		self.passAnimFlag = FileCacheManager.getBoolForKey(FileDataType.TURNTABLE_ANIM, false);
	end
	return self.passAnimFlag;
end

function TurnTableModel: setPassAnimFlag(val)
	if (self.passAnimFlag == val) then
		return;
	end
	FileCacheManager.setBoolForKey(FileDataType.TURNTABLE_ANIM, val);
	self.passAnimFlag = val;
end

function TurnTableModel:getLuckyList()
	RPCReq.Activity_PowerTurnTable_GetRecords({}, function (params)
		Dispatcher.dispatchEvent("turnTable_luckyList", params);
	end)
end

function TurnTableModel:pack_item_change()
	GlobalUtil.delayCallOnce("TurnTableModel:pack_item_change", function ()
		self:checkRedPoint()
    end, self, 0.5)
end

return TurnTableModel