-- 转盘圆形奖盘动画控制器
-- added by zn
local LotteryPanel = class("LotteryPanel");

function LotteryPanel:ctor(view)
	self.view = view;
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	-- 是否正在抽奖
    self.isLotterying = false;
	-- 中奖标记
	self.propFlag = self.view:getChildAutoType("table/prop_flag");
	-- 奖励标识的当前位置
	self.curFlagIdx = 1;
	self.scheduleId = false;

	self.finishCallBack = false;
end

function LotteryPanel:setFinishCallBack(callback)
	self.finishCallBack = callback;
end

-- 抽奖
function LotteryPanel:lottery(rewardList)
	if (#rewardList == 1) then
		if (TurnTableModel.passAnimFlag == true) then
			-- self:showResultAwardsWin();
			if self.finishCallBack then self:finishCallBack() end;
		else
			self:lotteryOnce(rewardList[1]);
		end
	else
		if (TurnTableModel.passAnimFlag == true) then
			-- self:showResultAwardsWin();
			if self.finishCallBack then self:finishCallBack() end;
		else
			local len = #rewardList;
			self:lotteryOnce(rewardList[len]);
			-- self:lotteryMore(rewardList);
		end
	end
end

-- 单抽
function LotteryPanel:lotteryOnce(idx)
    local nodeObj = self.propFlag:displayObject();
	self:ressetFlagAngle();
	local aimAngle = self:getFlagAngleOfIdx(idx);
	aimAngle = 2 * 360 + aimAngle;

	local function roll(dt)
		local speed = 0;
		local curRotation = nodeObj:getRotation();
		if (curRotation < 90) then
			speed = 300;
		elseif (curRotation < 180) then
			speed = 500;
		elseif (curRotation < 360) then
			speed = 700;
		elseif (curRotation > aimAngle - 360 and curRotation <= aimAngle - 180) then
			speed = 700;
		elseif (curRotation > aimAngle - 180 and curRotation <= aimAngle - 90) then
			speed = 500;
		elseif (curRotation > aimAngle - 90) then
			speed = 300;
		else
			speed = 1500;
		end
		local rotation = curRotation + speed * dt;
		rotation = math.min(rotation, aimAngle);
		-- 转动停止
		if (rotation == aimAngle) then
			nodeObj:runAction(self:lotteryLockedAnim());
			if (type(self.scheduleId) == "number") then
				if self.finishCallBack then
					Scheduler.scheduleOnce(1, function (arg1, arg2, arg3)
						self:finishCallBack();
						Scheduler.scheduleOnce(0.8, function ()
							self.isLotterying = false;
						end)
					end) 
				end;
				if (self.scheduleId) then
					Scheduler.unschedule(self.scheduleId);
					self.scheduleId = false;
				end
			end
		end
		nodeObj:setRotation(rotation);
	end

	if (type(self.scheduleId) == "number") then
		Scheduler.unschedule(self.scheduleId);
		self.scheduleId = false;
		self.isLotterying = false;
	end
	-- 开始转动
	self.scheduleId = Scheduler.schedule(roll, 0);
	self.isLotterying = true;
end

-- 连抽
function LotteryPanel:lotteryMore(idxArr)
    self:ressetFlagAngle();
	self.isLotterying = true;

	local function endFunc()
		if self.finishCallBack then self:finishCallBack() end;
		self.isLotterying = false;
	end

	local function animFunc(i)
		if type(i) == "table" then
			i = i[1];
		end

		local locked = false;
		-- 还有下一个中奖位置，给锁定动画结束继续动画
		if idxArr[i + 1] ~= nil then
			locked = self:lotteryLockedAnim(animFunc, i + 1);
		-- 否则弹奖励界面
		else
			locked = self:lotteryLockedAnim(endFunc)
		end

		-- 本次中奖位置的动画
		if idxArr[i] == self.curFlagIdx then
			self.propFlag:displayObject():runAction(locked);
		else
			local offsetAngle = false;
			-- 判断角度偏差
			if idxArr[i] > self.curFlagIdx then
				offsetAngle = 45 * (idxArr[i] - self.curFlagIdx);
			else
				offsetAngle = 45 * (8 - self.curFlagIdx + idxArr[i]);
			end
			-- LuaLog("当前奖励位置："..self.curFlagIdx.." 目标位置："..idxArr[i].." 偏差角度："..offsetAngle);
			--
			local time = offsetAngle / 45 * 0.05;
			local rotateBy = cc.RotateBy:create(time, offsetAngle);
			local callFunc = cc.CallFunc:create(function()
				self.curFlagIdx = idxArr[i];
			end)
			local seq = cc.Sequence:create(rotateBy, callFunc, locked);
			self.propFlag:displayObject():runAction(seq);
		end
	end

	animFunc(1);
end

-- 锁定闪烁动画
function LotteryPanel:lotteryLockedAnim(cb, ...)
	local arg = {...};
	local fadeOut = cc.FadeOut:create(0.15);
	local fadeIn = cc.FadeIn:create(0.15);
	local seq = cc.Sequence:create(fadeOut, fadeIn);
	local rep = cc.Repeat:create(seq, 3);
	local delay = cc.DelayTime:create(0.3);
	local callFunc = cc.CallFunc:create(function()
		if cb then
			cb(arg);
		end
		-- LuaLog("== 锁定动画完成");
	end)
	local seq_2 = cc.Sequence:create(rep, delay, callFunc);
	return seq_2;
end

-- 获取奖励标识的角度 idx 1-8
function LotteryPanel:getFlagAngleOfIdx(idx)
	return 45 * (idx - 1);
end

-- 重置中奖位置标识的角度
function LotteryPanel:ressetFlagAngle()
	self.propFlag:displayObject():setRotation(0);
	self.curFlagIdx = 1;
end

function LotteryPanel:__onExit()
	if self.scheduleId then
		Scheduler.unschedule(self.scheduleId);
	end
end

return LotteryPanel