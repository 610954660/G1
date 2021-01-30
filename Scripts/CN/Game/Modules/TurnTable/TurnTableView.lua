-- added by zn
-- 聚能寻宝界面

-- local TimeUtil= require "Game.Utils.TimeUtil";
local ItemCellCircle = require "Game.Modules.TurnTable.ItemCellCircle";
local TimeLib = require "Game.Utils.TimeLib";
local TurnTableConfiger = require "Game.ConfigReaders.TurnTableConfiger";
local LotteryPanel = require "Game.Modules.TurnTable.LotteryPanel";

local TurnTableView, Super = class("TurnTableView", Window);

function TurnTableView:ctor()
	self._packName = "TurnTable";
	self._compName = "TurnTableView";
	-- 单抽按钮
	self.lotteryBtn_1 = false;
	self.lotteryCost_1 = false;
	-- 十抽按钮
	self.lotteryBtn_10 = false;
	self.lotteryCost_10 = false;
	-- 抽中奖励标识
	self.propFlag = false;
	-- 跳过动画复选按钮
	self.checkBtn = false;
	
	-- 普通聚能按钮
	self.normalBtn = false;
	-- 高级聚能按钮
	self.specialBtn = false;
	-- 刷新按钮
	self.refreshBtn = false;
	self.refreshCost = false;
	-- 兑换商店按钮
	self.storeBtn = false;
	-- 帮助按钮
	self.helpBtn = false;
	-- 时空商店按钮
	self.btn_shop = false;
	
	-- 公示按钮
	self.noticeBtn = false;
	-- 进度条
	self.progress = false;
	-- 积分宝箱
	self.scoreBoxs = {}
	for i = 1, 5 do
		self.scoreBoxs[i] = false;
	end
	-- 转盘道具
	self.tablePool = {}
	for i = 1, 8 do
		self.tablePool[i] = false;
	end
	-- 按钮倒计时
	self.refreshTimer = false;

	self.lotteryPanel = false;

	self.closeBtn = false;
	self.refreshing = false;
	self.btn_lucky = false;
	self.list_lucky = false;
end

function TurnTableView:_initUI()
	self.view:getChildAutoType("frame/fullScreen"):setIcon('UI/TurnTable/bg.jpg');
	-- 抽奖按钮
	self.lotteryBtn_1 = self.view:getChildAutoType("btn_lottery_x1");
	self.lotteryCost_1 = BindManager.bindCostItem(self.view:getChild('cost_1'));
	self.lotteryCost_1:setAllInfoChangeColor(true)
	self.lotteryCost_1:setGreenColor("#3BFE44")
	self.lotteryCost_1:setRedColor("#D12121")
	self.lotteryBtn_10 = self.view:getChildAutoType("btn_lottery_x10");
	self.lotteryCost_10 = BindManager.bindCostItem(self.view:getChild('cost_10'));
	self.lotteryCost_10:setAllInfoChangeColor(true)
	self.lotteryCost_10:setGreenColor("#3BFE44")
	self.lotteryCost_10:setRedColor("#D12121")
	-- 刷新奖池按钮
	self.refreshBtn = self.view:getChildAutoType("table/btn_refresh");
	self.refreshCost = BindManager.bindCostItem(self.refreshBtn);
	-- 跳过动画
	self.checkBtn = self.view:getChildAutoType("checkBox");
	-- 积分箱
	for idx in ipairs(self.scoreBoxs) do
		self.scoreBoxs[idx] = self.view:getChildAutoType("box_"..idx);
	end
	-- 转盘奖品
	for idx in ipairs(self.tablePool) do
		local item = self.view:getChildAutoType("table/itemCell_"..idx);
		self.tablePool[idx] = ItemCellCircle.new(item);
	end
	-- 聚能类型
	self.normalBtn = self.view:getChildAutoType("btn_normal");
	self.specialBtn = self.view:getChildAutoType("btn_special");
	self.storeBtn = self.view:getChildAutoType("btn_store");
	-- 帮助
	self.helpBtn = self.view:getChildAutoType("btn_help");
	-- 公示
	self.noticeBtn = self.view:getChildAutoType('btn_noticeRate');
	-- 进度条
	self.progress = self.view:getChildAutoType("progress");
	self.btn_shop = self.view:getChildAutoType("btn_shop");

	self.closeBtn = self.view:getChildAutoType("frame"):getChildAutoType("closeButton");
	self.list_lucky = self.view:getChildAutoType("list_lucky");

	self.lotteryPanel = LotteryPanel.new(self.view);
	self.lotteryPanel:setFinishCallBack(self.showResultAwardsWin);
	self.btn_lucky = self.view:getChildAutoType("btn_lucky");

	local key1 = "V_ACTIVITY_"..GameDef.ActivityType.PowerTurnTable.."_btn1"
	RedManager.register(key1, self.normalBtn:getChildAutoType("img_red"));
	local key2 = "V_ACTIVITY_"..GameDef.ActivityType.PowerTurnTable.."_btn2"
	RedManager.register(key2, self.specialBtn:getChildAutoType("img_red"));
	self.checkBtn:setSelected(TurnTableModel:getPassAnimFlag());
	self:changeTableType(1);
	self:upAllViewStatus();
	
	

	TurnTableModel:getLuckyList()
	
	self.btn_shop:setVisible(ModuleUtil.moduleOpen(ModuleId.TurnTableShop.id))
	self.btn_shop:addClickListener(function ( ... )
		ModuleUtil.openModule(ModuleId.TurnTableShop.id)
	end)

end

-- 注册UI事件
function TurnTableView:_initEvent()
	-- 单抽
	self.lotteryBtn_1:addClickListener(function()
		self:lottery(1)
	end)
	-- 连抽
	self.lotteryBtn_10:addClickListener(function()
		self:lottery(10)
	end)
	-- 复选按钮
	self.checkBtn:addClickListener(function()
		TurnTableModel:setPassAnimFlag(not TurnTableModel:getPassAnimFlag());
	end)
	-- 聚能类型切换
	self.normalBtn:addClickListener(function()
		self:changeTableType(1);
		TurnTableModel:getLuckyList()
	end);
	self.specialBtn:addClickListener(function()
		if (TurnTableModel:existSpecialTable()) then
			self:changeTableType(2);
			TurnTableModel:getLuckyList()
		else
			self.normalBtn:setSelected(true);
		end
	end)
	-- 积分宝箱
	for idx in ipairs(self.scoreBoxs) do
		self.scoreBoxs[idx]:addClickListener(function()
			local status = TurnTableModel:getScoreBoxStatus(idx)
			-- if (status == 0) then
				-- self:showBoxAward(idx);
			-- else
			if (status == 1) then
				self:getBoxAward(idx);
			end
		end)
	end
	-- 帮助
	self.helpBtn:addClickListener(function()
		RollTips.showHelp(Desc.help_StrTitle5, Desc.help_StrDesc5);
	end)
	self.storeBtn:addClickListener(function ()
		
	end)
	-- 概率公示
	self.noticeBtn:addClickListener(function()
		RollTips.showHelp(Desc.help_StrTitle6, Desc.help_StrDesc6);
	end)
	-- 刷新
	self.refreshBtn:addClickListener(function()
		self:refresh();
		TurnTableModel:getLuckyList()
	end)
	-- 关闭
	self.closeBtn:removeClickListener();
	self.closeBtn:addClickListener(function()
		if (self.refreshing) then
			return;
		end
		if self.lotteryPanel.isLotterying then
			RollTips.show(Desc.turnTable_isLotterying);
			return;
		end
		self:closeView();
	end)

	self.btn_lucky:addClickListener(function ()
		ViewManager.open("TurnTableLuckyView")
	end)
end

function TurnTableView:changeTableBg()
	local type = TurnTableModel.tableType - 1;
	local tableBg = "UI/TurnTable/tableBg"..type..".png";
	local table = "UI/TurnTable/table"..type..".png";
	local propFlag = "UI/TurnTable/flag"..type..".png";
	self.view:getChild("tableBg"):setIcon(tableBg);
	self.view:getChild("table/table"):setIcon(table);
	self.view:getChild("table/prop_flag"):setIcon(propFlag);
end

-- 更新整个界面
function TurnTableView:upAllViewStatus()
	self.lotteryPanel:ressetFlagAngle();
	self:changeTableBg();
	self:upPoolInfo();
	self:upScoreTabInfo();
	self:upBtnsInfo();
	self:upScoreProgress();
	self:upRefreshTime();
end

-- 刷新奖池
function TurnTableView:refresh()
	if self.lotteryPanel.isLotterying then
		RollTips.show(Desc.turnTable_isLotterying);
		return;
	end

	local conf = TurnTableConfiger.getTableInfoByType(TurnTableModel.tableType);
	local refresh = conf.refresh[1];
	local freeTime = TurnTableModel:getRefreshLeftTime();
	if ((freeTime == 0) or PlayerModel:checkCostEnough(refresh, true)) then
		local info = {
			-- activityId = TurnTableModel.activityId,
			poolType = TurnTableModel.tableType
		}
		RPCReq.Activity_PowerTurnTable_Refresh(info, function()
			if (tolua.isnull(self.view)) then return end;
			self:playRefreshAnim();
			RollTips.show(Desc.turnTable_refreshSuccess);
		end);

	end
end

function TurnTableView:playRefreshAnim()
	local function changVisible(show)
		for i = 1, #self.tablePool do
			self.tablePool[i].view:setVisible(show);
		end
		self.refreshBtn:setVisible(show);
		self.lotteryBtn_1:setVisible(show);
		self.lotteryBtn_10:setVisible(show);
		self.lotteryCost_1:setVisible(show);
		self.lotteryCost_10:setVisible(show);
		self.specialBtn:setVisible(show);
		self.normalBtn:setVisible(show);
		self.refreshing = not show;
	end
	
	changVisible(false);
	for i = 1, #self.tablePool do
		self.tablePool[i].view:setVisible(true);
	end
	self.view:getChildAutoType("table"):getTransition("enter"):play(function ()
		changVisible(true);
	end)
end

--[[ 抽奖开始
	@param type 1 单抽 2 连抽
--]]
function TurnTableView:lottery(lottype)

	if self.lotteryPanel.isLotterying then
		RollTips.show(Desc.turnTable_isLotterying);
		return;
	end

	-- 条件判断
	local enough, itemBuy = TurnTableModel:haveEnoughCoin(lottype);
	if (not enough) then
		if (itemBuy) then
			self:showFastBuy(lottype);
		end
		return;
	end

	-- 抽奖成功
	local function success(param)
		-- LuaLog("抽奖结果");
		TurnTableModel:setRewardList(param.rewardList,param.scoreReward[1]);
		printTable(8848, param);
		if (tolua.isnull(self.view)) then return end;
		self.lotteryPanel:lottery(param.rewardList);
		self:upBtnsInfo();
	end

	-- 请求抽奖
	local info = {
		poolType = TurnTableModel.tableType,
		drawType = lottype,
	}
	RPCReq.Activity_PowerTurnTable_Draw(info, success);
end

-- 展示道具奖励 包括抽奖奖励跟开箱奖励
-- @delay boolean
function TurnTableView:showResultAwardsWin(delay)
	delay = (type(delay) == 'number') and delay or 0;
	Scheduler.scheduleOnce(delay, function ()
		local data = {
			show = 1,
			reward = TurnTableModel.rewardList
		}
		ViewManager.open("AwardShowView",data);
		TurnTableModel:getLuckyList()
	end)
end

-- 改变界面普通聚能 或者 高级聚能
function TurnTableView:changeTableType(tableType)
	if self.lotteryPanel.isLotterying then
		self.view:getController("typeCtrl"):setSelectedIndex(TurnTableModel.tableType - 1);
		RollTips.show(Desc.turnTable_isLotterying);
		return;
	end
	if (TurnTableModel.tableType == tableType) then return end;
	TurnTableModel:setTableType(tableType);
	self.refreshBtn:getController("c2"):setSelectedIndex(tableType - 1)
	self.progress:getController("c1"):setSelectedIndex(tableType - 1)
	self:upAllViewStatus();
end

-- 改变奖池内道具显示
function TurnTableView:upPoolInfo()
	local info = TurnTableModel:getTableDataByType(TurnTableModel.tableType);
	if not info then return end
	local conf = DynamicConfigData.t_TurnTableRewardPool[info.poolId];
	local list = TurnTableConfiger.getTableAwards(info.poolId);
	local drawRecord = info.drawRecord or {};
	for i = 1, #self.tablePool do
		local c = false;
		if (conf) then
			c = conf[i].limitTime;
		end
		local itemData = list[i];
		self.tablePool[i]:setData(itemData.code, itemData.amount, itemData.type);
		-- print(2233, c)
		if (drawRecord[i] and c and c ~= 0 and drawRecord[i].count >= c) then
			self.tablePool[i]:setGrayed(true);
		else
			self.tablePool[i]:setGrayed(false);
			
		end
	end
end

-- 改变积分进度
function TurnTableView:upScoreProgress()
	local info = TurnTableModel:getTableDataByType(TurnTableModel.tableType);
	self.progress:setValue(math.min(info.point, 1000));
end

-- 领取积分盒子奖励
function TurnTableView:getBoxAward(idx)
	local info = {
		-- activityId = TurnTableModel.activityId,
		id = idx,
		poolType = TurnTableModel.tableType
	}
	RPCReq.Activity_PowerTurnTable_RecvReward(info, function (param)
		-- LuaLog("=== 积分宝箱领取成功 ===");
		if (tolua.isnull(self.view)) then return end;
		self:upBtnsInfo();
	end)
end

-- 改变积分栏信息
function TurnTableView:upScoreTabInfo()
	TurnTableModel:checkRedPoint();
	for idx in ipairs(self.scoreBoxs) do
		local box = self.scoreBoxs[idx]
		if (box.SpineAnim) then
			box.SpineAnim:removeFromParent();
			box.SpineAnim = nil;
		end
		
		local ctrl = box:getController("c1");
		local status = TurnTableModel:getScoreBoxStatus(idx);
		ctrl:setSelectedIndex(status);
		if status == 1 then
			box.SpineAnim = SpineUtil.createSpineObj(box:getChild("icon"),{x=41,y=38}, "fangkuang", "Effect/UI", "xunbaojiemian_texiao", "xunbaojiemian_texiao",true)
		end
		local conf = TurnTableConfiger.getScoreBoxListByType(TurnTableModel.tableType);
		local reward = conf[idx].reward[1];
		local itemCell = BindManager.bindItemCell(box:getChildAutoType("itemCell"));
		itemCell:setNoFrame(true);
		itemCell:setData(reward.code, reward.amount, reward.type);

		itemCell:setIsHook(status == 2);
		itemCell.view:setTouchable(status ~= 1);
		box:setTouchable(status ~= 2);
		local key = "V_ACTIVITY_"..GameDef.ActivityType.PowerTurnTable.."_BOX"..idx;
		RedManager.register(key, box:getChildAutoType("img_tips"))
	end
end

-- 改变按钮信息 抽奖按钮上道具  刷新按钮信息
function TurnTableView:upBtnsInfo()
	local info = TurnTableConfiger.getTableInfoByType(TurnTableModel.tableType);
	local costConf = info.needItem[1];
	local draw = info.draw[1];
	local tenDraw = info.tenDraw[1];
	local haveCount = ModelManager.PackModel:getItemsFromAllPackByCode(costConf.code);
	self.lotteryCost_1:setData(costConf.type, costConf.code, draw.cost);
	self.lotteryBtn_1:setTitle(string.format(Desc.turnTable_lotteryCount, draw.get));
	self.lotteryBtn_1:getChildAutoType('img_red'):setVisible(haveCount >= draw.cost);

	self.lotteryCost_10:setData(costConf.type, costConf.code, tenDraw.cost);
	self.lotteryBtn_10:setTitle(string.format(Desc.turnTable_lotteryCount, tenDraw.get));
	self.lotteryBtn_10:getChildAutoType('img_red'):setVisible(haveCount >= tenDraw.cost);

	-- 持有道具数量
	local count = PackModel:getItemsFromAllPackByCode(costConf.code);

	-- 更新刷新按钮信息
	local refreshData = info.refresh[1];
	self.refreshCost:setData(refreshData.type, refreshData.code, refreshData.amount, true);
		self.refreshCost.txt_num:setText(string.format(Desc.turnTable_refreshCost, refreshData.amount))
end

-- 更新刷新时间
function TurnTableView:upRefreshTime()
	local refreshTime = TurnTableModel:getRefreshLeftTime();
	local ctrl = self.refreshBtn:getController("c1");
	if (refreshTime == 0) then
		ctrl:setSelectedPage("free");
	else
		ctrl:setSelectedPage("normal");
		if self.refreshTimer then
			-- TimeUtil.clearTime(self.refreshTimer);
			TimeLib.clearCountDown(self.refreshTimer);
		end
		-- LuaLog("剩余时间", refreshTime);
		-- 倒计时
		local view = self.refreshBtn:getChildAutoType("time");
		local str = Desc.turnTable_refreshFreeTime;
		view:setText(string.format(str, TimeLib.formatTime(refreshTime)))
		local function onCountDown(time)
			if (tolua.isnull(view)) then return end;
			view:setText(string.format(str, time))
		end

		local function onEnd()
			if (tolua.isnull(self.view)) then return end;
			self:upRefreshTime();
			TimeLib.clearCountDown(self.refreshTimer);
		end
		self.refreshTimer = TimeLib.newCountDown(refreshTime-1, onCountDown, onEnd, false, false , true)
	end
end

-- 服务端下推奖池变化 更新界面
function TurnTableView:activity_TurnTableActiveUpdate()
	if (tolua.isnull(self.view)) then return end;
	self:upPoolInfo();
	self:upScoreTabInfo();
	self:upBtnsInfo();
	self:upScoreProgress();
	self:upRefreshTime();
end

function TurnTableView:__onExit()
	if self.refreshTimer then
		TimeLib.clearCountDown(self.refreshTimer);
	end
	Super.__onExit(self);
end

-- 显示快捷购买
function TurnTableView:showFastBuy(lottype)
	local function onYes()
		ViewManager.open("ShopView");
	end
	-- local conf = TurnTableConfiger.getTableInfoByType(TurnTableModel.tableType);
	-- local count = conf.itemBuy[1].amount;
	-- local need = lottype == 1 and conf.draw[1].cost or conf.tenDraw[1].cost;
	-- local name = ItemConfiger.getItemNameByCode(conf.itemBuy[1].code, conf.itemBuy[1].type);
	-- local str = lottype == 1 and Desc.turnTable_once or Desc.turnTable_ten
	local tips = Desc.turnTable_gotoStore; --string.format("是否消耗%s%s进行%s抽奖", count * need, name, str);
	local arg = {
		text = tips,
		noText = Desc.turnTable_no,
		type = "yes_no",
		onYes = onYes,
	}
	Alert.show(arg);
end

function TurnTableView:turnTable_luckyList(_, params)
	local list = params.records or {};
    local conf = DynamicConfigData.t_item;
    self.list_lucky:setItemRenderer(function (idx, obj)
        local d = list[idx + 1];
        local code = d.type == 2 and d.code + 2000 or d.code;
        local c = conf[code];
        local color = ColorUtil.itemColorStr[c.color];
        local name = string.format("[color=%s]%s[/color]", color, c.name);
        local str = string.format(Desc.turnTable_luckyStr1, d.playerName, name, d.amount);
        obj:setTitle(str);
    end)
    self.list_lucky:setNumItems(math.min(#list, 2));
end


return TurnTableView