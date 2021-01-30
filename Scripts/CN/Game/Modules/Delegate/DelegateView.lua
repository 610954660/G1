
-- added by zn
-- 委托任务

local DelegateConfiger = require "Game.ConfigReaders.DelegateConfiger";
local TimeLib = require "Game.Utils.TimeLib";
local DelegateView, Super = class("DelegateView", Window);

local pointCostData = {
    code = 9,
    type = CodeType.MONEY,
    amount = 1000,
}
function DelegateView:ctor()
	self._packName = "Delegate";
    self._compName = "DelegateView";
    
    -- 任务描述
    self.txt_taskDesc = false;
    -- 任务列表
    self.list_task = false;
    -- 刷新按钮
    self.btn_refresh = false;
    -- 一键领奖按钮
    self.btn_getAll = false;
    -- 领取任务奖励按钮
    -- self.btn_getOne = false;
    -- 帮助说明
    self.btn_help = false;
    -- 派遣按钮
    self.btn_ok = false;
    self.costItem_ok = false;
    -- 一键上阵
    self.btn_recom = false;
    -- 委托积分进度条
    self.prog_point = false;
    -- 委托积分添加按钮
    self.btn_addPoint = false;
    -- 委托券数量
    self.item_propCount = false;
    -- 委托条件列表
    self.list_condition = false;
    self.com_tips = false;
    -- 添加英雄按钮
    self.btn_addHero = {};
    self.btn_addHeroItem = {};
    for i = 1, 3 do
        self.btn_addHero[i] = false;
        self.btn_addHeroItem[i] = false;
    end
    self.conditions = {};
    -- 任务加速按钮
    self.btn_quick = false;
    -- 任务列表对象
    self.taskObjs = {};
    self.btn_go1 = false;
    self.btn_go2 = false;

    -- 委托活动开启时减少的消耗
    self.txt_subNum = false
	
	self._selectedItemIndex = -2 --选中的index
end

function DelegateView:_initUI()
    -- self:setBg("bg_generalA.jpg");
    self.view:getChildAutoType("rolePic"):setIcon("Bg/DelegetRole.png");
    -- 帮助说明
    self.btn_help = self.view:getChildAutoType("btn_help");
    -- 委托积分进度条
    self.prog_point = self.view:getChildAutoType("prog_point");
    self.prog_point:setValue(ModelManager.PlayerModel:getMoneyByType(9));
    self.prog_point:setMax(DelegateConfiger.getMaxPointByLevel(tonumber(PlayerModel.level)))
    -- 委托积分添加按钮
    self.btn_addPoint = self.view:getChildAutoType("btn_add");
    -- 委托券数量
    self.item_propCount = BindManager.bindCostItem(self.view:getChildAutoType("costItem_prop"));

    self.com_tips = self.view:getChildAutoType("com_tips");
    -- 任务列表
    self.list_task = self.view:getChildAutoType("taskList");
    -- 任务描述(人物语言框文本)
    self.txt_taskDesc = self.view:getChildAutoType("txt_role");
    -- 添加英雄按钮
    for idx in ipairs(self.btn_addHero) do
        self.btn_addHero[idx] = self.view:getChildAutoType("btn_addHero"..idx);
        self.btn_addHeroItem[idx] = BindManager.bindCardCell(self.btn_addHero[idx]:getChildAutoType("cardItem"));
    end
    -- 委托条件列表
    self.list_condition = self.view:getChildAutoType("conditionList");

    -- 刷新按钮
    self.btn_refresh = self.view:getChildAutoType("btn_refresh");
    self.costItem_refresh = BindManager.bindCostItem(self.view:getChildAutoType("costItem_refresh"));

    -- 一键领奖按钮
    self.btn_getAll = self.view:getChildAutoType("btn_getAll");
    -- 领取任务奖励按钮
    -- self.btn_getOne = self.view:getChildAutoType("btn_getOne");
    -- 派遣按钮
    self.btn_ok = self.view:getChildAutoType("btn_ok");
    -- self.btn_okItem = BindManager.bindCostButton(self.btn_ok:getChildAutoType("costItem"));
    self.costItem_ok = BindManager.bindCostItem(self.view:getChildAutoType("costItem_ok"));
    self.costItem_ok:setData(pointCostData.type, pointCostData.code, pointCostData.amount, true, false, true);

    self.txt_subNum = self.view:getChildAutoType("txt_subNum")
    -- 委托活动开启时减少的消耗 added by wyz
    local moduleId = ModelManager.DelegateActivityModel:getModuleId() or 1
    local DelegateActivityData = DynamicConfigData.t_DelegateActivity
    local activityBaseInfo = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.DelegateContend)   -- 判断委托活动开没开启
    if not activityBaseInfo then
        self.txt_subNum:setVisible(false)
    else
        local subNum = DelegateActivityData[moduleId].cost/100 * pointCostData.amount
        self.txt_subNum:setVisible(true)
        self.txt_subNum:setText("(-"..subNum .. ")")
    end

    -- 一键上阵
    self.btn_recom = self.view:getChildAutoType("btn_recom");
    -- 任务加速按钮
    self.btn_quick = self.view:getChildAutoType("btn_quick");
    self.costItem_quick = BindManager.bindCostItem(self.view:getChildAutoType("costItem_quick"));

    
    -- 拉取任务
    self:getTaskData();
    self:getHeroData();
end

function DelegateView:_initEvent()
    -- 帮助说明
    self.btn_help:addClickListener(function()
        RollTips.showHelp(Desc.help_StrTitle7, Desc.help_StrDesc7);
    end)
    -- 委托积分添加按钮
    self.btn_addPoint:addClickListener(function ()
        ViewManager.open("ItemNotEnoughView", {type = CodeType.MONEY, code = 9, amount=1, callFunc = function (arg1, arg2, arg3)
            self:closeView();
        end})
    end)
    -- 委托券数量
    self.item_propCount:setData(CodeType.ITEM, 10000051, 0, false, true, true);

    -- 任务列表
    self.list_task:setItemRenderer(function (idx, obj)
        self.taskObjs[idx] = obj;
        self:upTaskListItem(idx, obj);
    end);
    -- self.list_task:setVirtual();

    -- 任务条件列表
    -- self.list_condition:setVirtual();
    self.list_condition:setItemRenderer(function (idx, obj)
        self.conditions[idx + 1] = obj;
    end)

    for idx in ipairs(self.btn_addHero) do
        self.btn_addHero[idx]:addClickListener(function ()
            local task = DelegateModel.taskList[DelegateModel:getCurIdx()];
            if (task.status == 2) then
                ViewManager.open("DelegateHeroChoseView");
            end
        end)
    end

    -- 一键领取按钮
    self.btn_getAll:addClickListener(function ()
        self:clickBtnGetAll();
    end)

    -- 领取
    -- self.btn_getOne:addClickListener(function()
    --     self:clickBtnGetOne();
    -- end)

    -- 刷新
    self.btn_refresh:addClickListener(function()
        if (DelegateModel:existHighLvTask()) then
            local function onYes()
                self:clickBtnRefresh();
            end
            local arg = {
                text = Desc.delegate_refreshTips,
                type = "yes_no",
                onYes = onYes,
            }
            Alert.show(arg)
        else
            self:clickBtnRefresh();
        end
    end)

    -- 派遣
    self.btn_ok:addClickListener(function()
        DelegateModel:starTask(function ()
            -- self:upTaskInfoPanel(1);
            -- self:upRefreshBtnStatus();
        end);
    end)

    -- 一键上阵
    self.btn_recom:addClickListener(function()
        local flag = DelegateModel:getRecomList();
        if (flag ~= true) then
            RollTips.show(Desc.delegate_cannotRecom);
            DelegateModel:clearWait();
        end
    end)

    -- 加速
    self.btn_quick:addClickListener(function()
        local task = DelegateModel.taskList[DelegateModel:getCurIdx()];
        local conf = DelegateConfiger.getConfByID(task.id);
        local cost = conf.cost[1];
        if (not PlayerModel:checkCostEnough(cost, true)) then
            return;
        end
        local info = {
            index = DelegateModel.curIdx,
        }
        local function success(param)
            DelegateModel:setTaskData(param.data, false);
			if (tolua.isnull(self.view)) then return end;
            self:getHeroData();
            self:upTaskInfoPanel(1);
        end
        RPCReq.Delegate_AddSpeed(info, success);
    end)

    self.btn_go1 = self.com_tips:getChildAutoType("btn_go1")
    self.btn_go1:addClickListener(function ()
        ModuleUtil.openModule(ModuleId.PriviligeGiftView.id);
    end)
    self.btn_go2 = self.com_tips:getChildAutoType("btn_go2");
    self.btn_go2:addClickListener(function ()
        ModuleUtil.openModule(ModuleId.PriviligeGiftView.id);
    end)
    self:PriviligeGift_upGiftData();
end

function DelegateView:PriviligeGift_upGiftData()
    if (not PriviligeGiftModel:getPriviligeGift(2)) then
        self.btn_go1:setTouchable(true);
        self.btn_go1:setTitle(Desc.delegate_str3)
    else
        self.btn_go1:setTouchable(false);
        self.btn_go1:setTitle(Desc.delegate_str4)
    end

    if (not PriviligeGiftModel:getPriviligeGift(3)) then
        self.btn_go2:setTouchable(true);
        self.btn_go2:setTitle(Desc.delegate_str3)
    else
        self.btn_go2:setTouchable(false);
        self.btn_go2:setTitle(Desc.delegate_str4)
    end
end

-------------------------- 任务部分 ----------------------

-- 拉取任务数据
function DelegateView:getTaskData()
    DelegateModel:getTaskData(function ()
		if tolua.isnull(self.view) then return end
        self:upTaskInfoPanel(1);
        -- self:upRefreshBtnStatus();
    end);
end

-- 更新任务列表有无的显示状态
function DelegateView:delegate_upTaskList(_, sorted)
    if (tolua.isnull(self.view)) then return end;
    self:clearTimer();
    local ctrl = self.view:getController("c1");
    if (#DelegateModel.taskList > 0) then
        ctrl:setSelectedIndex(0);
        self.list_task:setNumItems(#DelegateModel.taskList);
		self._selectedItemIndex = 0
    else
        ctrl:setSelectedIndex(1);
    end
    self:upRefreshBtnStatus();
    if (sorted and #DelegateModel.taskList > 0) then
        self.list_task:scrollToView(0);
    end
	
	
end

function DelegateView:scrollToListItem(id)
	
	for k,v in pairs(DelegateModel.taskList) do
		if v.id == tonumber(id) then
			print(33,"DelegateModel.taskList = ",k,v)
			self.list_task:scrollToView(k-1)
			return
		end
	end
end

-- 更新任务列表Item
function DelegateView:upTaskListItem(idx, obj)
	local effectLoader = obj:getChildAutoType("effectLoader")
	effectLoader:displayObject():removeAllChildren()
	if (idx < 5 and self._selectedItemIndex == -1) then
		Scheduler.scheduleOnce(idx*0.1, function( ... )
			if effectLoader and  (not tolua.isnull(effectLoader)) then
				obj:getTransition("t0"):play(function( ... )
						end);
				SpineUtil.createSpineObj(effectLoader, vertex2(0,0), "fx_renwushuaxin_up", "Spine/ui/weituorenwu", "weituorenwu_texiao", "weituorenwu_texiao",false)
			end
		end)
	elseif (self._selectedItemIndex~= -1 and idx == self._selectedItemIndex) then
		obj:getTransition("t0"):play(function( ... )
						end);
		SpineUtil.createSpineObj(effectLoader, vertex2(0,0), "fx_renwushuaxin_up", "Spine/ui/weituorenwu", "weituorenwu_texiao", "weituorenwu_texiao",false)
	end

    local data = DelegateModel.taskList[idx + 1];
    local conf = DelegateConfiger.getConfByID(data.id);
    -- 第一个没有装饰
    -- obj:getChildAutoType("adornment"):setVisible(idx ~= 0);
    if (idx == DelegateModel:getCurIdx() - 1) then
        obj:setSelected(true);
        self:upTaskInfoPanel(idx + 1);
    else
        obj:setSelected(false);
    end
	obj:setName(data.id);
    -- 根据数据初始化
    -- A.常态（未领取，待领奖）
    obj:getController("level"):setSelectedIndex(data.color - 1);
    obj:getController("status"):setSelectedIndex(data.status - 1);
    obj:setTitle(conf.name);
    local txt = obj:getChildAutoType("txt_countDown");
    txt:setText(Desc.delegate_finished);
    if (not obj.lua_script) then
        obj.lua_script = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
    end
    obj.lua_script:setData(conf.reward[1].code, conf.reward[1].amount, conf.reward[1].type);
    -- B.进行中
    if data.status == 1 then
        local prog = obj:getChildAutoType("pro_countDown");
        -- local max = conf.time * 3600
        prog:setMax(conf.time);
        -- 倒计时
        local function onCountDown(time)
			if (tolua.isnull(self.view)) then return end;
            txt:setText(TimeLib.formatTime(time));
            prog:setValue(conf.time - time);
            -- LuaLog(conf.time - time, conf.time);
        end  
        local function onEnd ()
            DelegateModel:sortTaskList();
            DelegateModel:checkTaskRed();
			if (tolua.isnull(self.view)) then return end;
            self:delegate_upTaskList();
        end
        local offsetTime = math.ceil((data.endTimeMs / 1000) - ServerTimeModel:getServerTime());
        txt:setText(TimeLib.formatTime(offsetTime));
        prog:setValue(conf.time - offsetTime);

        if (obj.timer) then
            TimeLib.clearCountDown(obj.timer);
            obj.timer = false;
        end
        obj.timer = TimeLib.newCountDown(offsetTime, onCountDown, onEnd, false, false, false);
    end

    obj:removeClickListener(22);
    obj:addClickListener(function()
		self._selectedItemIndex = idx
        self:upTaskInfoPanel(idx + 1);
    end, 22)
	
	-- local effectLoader = obj:getChild("effectLoader")
	-- effectLoader:displayObject():removeAllChildren()
	-- if data.color == 6 then
	-- 	SpineUtil.createSpineObj(effectLoader, vertex2(0,0), "wt_buxiu", "Spine/ui/button", "anniu_texiao", "anniu_texiao",true)
	-- 	elseif data.color == 5 then
	-- 	SpineUtil.createSpineObj(effectLoader, vertex2(0,0), "wt_chuanshuo", "Spine/ui/button", "anniu_texiao", "anniu_texiao",true)
	-- end
	
	
    local red = obj:getChildAutoType('redTips');
    RedManager.removeTips("V_DELEGATETASK"..(idx + 1), red);
    RedManager.register("V_DELEGATETASK"..(idx + 1), red);
end

-- 更新右侧任务详情
function DelegateView:upTaskInfoPanel(taskShowIdx)
    if (#DelegateModel.taskList == 0 or not DelegateModel.taskList) then
        return;
    end
    DelegateModel:setCurIdx(taskShowIdx)
    -- if (taskIdx == DelegateModel.curTask) then return end;
    local data = DelegateModel.taskList[taskShowIdx];
    local conf = DelegateConfiger.getConfByID(data.id);
    -- 更新人物语言框
    self.txt_taskDesc:setText(conf.desc);
    -- 更新已选择的英雄
    self:delegate_upWaitList();
    -- 更新下方按钮显示
    self.view:getController("task"):setSelectedIndex(data.status - 1);
    local c = conf.cost[1];
    self.costItem_quick:setData(c.type, c.code, c.amount, true, false, true);
    DelegateModel:upBtnRed();
end

-- 更新英雄选择区域
function DelegateView:delegate_upWaitList()
    if (tolua.isnull(self.view)) then return end
    local data = DelegateModel.taskList[DelegateModel:getCurIdx()];
    local list = {};
    local heros = {};
    for _, v in pairs(data.heroRecord) do
        table.insert(heros, v);
    end
    if (#heros > 0) then
        DelegateModel.waitList = heros;
    end
    list = DelegateModel.waitList;
    for i = 1, #self.btn_addHeroItem do
        local d = list[i];
        local ctrl = self.btn_addHero[i]:getController("c1");
        if (d ~= nil) then
            ctrl:setSelectedIndex(1);
            self.btn_addHero[i]:setVisible(true);
            self.btn_addHeroItem[i]:setData(DelegateModel:rebuildStruct(d), true);
        else
            ctrl:setSelectedIndex(0);
            self.btn_addHero[i]:setVisible(#heros == 0);
        end
    end
    self:upTaskLimit();
end

-- 更新任务的队伍现在条件
function DelegateView:upTaskLimit()
    local data = DelegateModel.taskList[DelegateModel:getCurIdx()];
    local conf = DelegateConfiger.getConfByID(data.id);

    local starLimit = conf.starRequire;
    local categoryLimit= conf.categoryRequire;
    local _, starFlag, cateFlag = DelegateModel:checkCondition();
    self.list_condition:setNumItems(#starLimit + #categoryLimit);
    -- 先将灰度全部还原
    for k in pairs(self.conditions) do
        self.conditions[k]:setGrayed(false);
    end
    for i = 1, #starLimit + #categoryLimit do
        local limit = false;
        local gray = false;
        local obj = self.conditions[i];
        local ctrl1 = obj:getController("c1");
        if (i <= #categoryLimit) then
            limit = categoryLimit[i];
            ctrl1:setSelectedIndex(0);
            obj:getController("c2"):setSelectedIndex(limit.param);
            gray = cateFlag[i] ~= true;
        else
            limit = starLimit[i - #categoryLimit];
            ctrl1:setSelectedIndex(1);
            obj:getChildAutoType("star"):setText(limit.param);
            gray = starFlag[i - #categoryLimit] ~= true;
        end
        local amount = limit.amount;
        local countCtrl = obj:getController("count");
        if (amount > 1) then
            countCtrl:setSelectedIndex(1);
            obj:getChildAutoType("count"):setText("x"..amount);
        else
            countCtrl:setSelectedIndex(0);
        end
        obj:setGrayed(gray);
    end
end

-- 刷新按钮显示更新
function DelegateView:upRefreshBtnStatus()
    local propData = {type = CodeType.ITEM, code = 10000051, amount = 1};
    local propEnough = PlayerModel:checkCostEnough(propData, false);
    self.btn_refresh:setTitle(Desc.delegate_str5);
    if (DelegateModel.freeCount > 0) then
        self.costItem_refresh:setVisible(false);
        self.btn_refresh:setTitle(Desc.delegate_freeRefresh);
    elseif propEnough then
        self.costItem_refresh:setVisible(true);
        self.costItem_refresh:setData(propData.type, propData.code, propData.amount, true, false, true);
    else
        self.costItem_refresh:setVisible(true);
        self.costItem_refresh:setData(CodeType.MONEY, 2, 30, true, false, true);
    end
end

function DelegateView:upPointProgressMax()
    
end

-------------------------- 英雄派遣部分 ----------------------

-- 获取可派遣英雄
function DelegateView:getHeroData()
    -- local function success(param)
        DelegateModel:getHeroData();
    -- end
    -- RPCReq.Delegate_GetHero({}, success);
end

-- 委托积分改变
function DelegateView:money_change(_, data)
    if (tolua.isnull(self.view)) then return end;
    self.prog_point:setValue(ModelManager.PlayerModel:getMoneyByType(9));
    self:upRefreshBtnStatus();
end

-----------------------------------------------------------------
-- 一键领取奖励
function DelegateView:clickBtnGetAll()
    local list = {};
    for _, task in ipairs(DelegateModel.taskList) do
        if (task.status == 3) then
            table.insert(list, task.idx);
        end
    end
    if (#list > 0) then
        local function success(param)
            DelegateModel:setTaskData(param.data, false);
			if (tolua.isnull(self.view)) then return end;
            self:getHeroData();
        end
        RPCReq.Delegate_Finish({index=0}, success);
    else
        RollTips.show(Desc.delegate_noAward);
    end
end

-- 领取奖励
function DelegateView:clickBtnGetOne()
    -- local status = DelegateModel.taskList[DelegateModel.getCurIdx()];
    local function success(param)
        DelegateModel:setTaskData(param.data, false);
        if (tolua.isnull(self.view)) then return end;
        self:getHeroData();
    end
    RPCReq.Delegate_Finish({index = DelegateModel.curIdx}, success)
end

-- 刷新
function DelegateView:clickBtnRefresh()
    if (DelegateModel.refreshFlag) then
        RollTips.show(Desc.delegate_waitRefresh);
        return;
    end

    local info = {
        costType = 3,
    }
    local propData = {type = CodeType.ITEM, code = 10000051, amount = 1};
    local propEnough = PlayerModel:checkCostEnough(propData, false);
    if (DelegateModel.freeCount > 0) then -- 免费次数
        info.costType = 1;
    elseif propEnough then -- 刷新券
        info.costType = 2;
    end
    if (info.costType == 3) then
        local flag = PlayerModel:checkCostEnough({type = CodeType.MONEY, code = 2, amount = 30}, true);
        if (not flag) then return end;
    end

    
    DelegateModel.refreshFlag = true;
    local function success(param)
		self._selectedItemIndex = -1
        DelegateModel.refreshFlag = false;
        DelegateModel:setTaskData(param.data);
        RollTips.show(Desc.delegate_refreshSuccess);
        -- self:upRefreshBtnStatus();
    end
    local function fail(data)
        DelegateModel.refreshFlag = false;
        RollTips.showError(data);
    end
    RPCReq.Delegate_Refresh(info, success, fail);
end

function DelegateView:_addRed()
    RedManager.register("V_BTN_GETONE", self.btn_getAll:getChildAutoType('img_red'));
end

function DelegateView:clearTimer()
    for _,v in pairs(self.taskObjs) do
        if (v.timer) then
            TimeLib.clearCountDown(v.timer);
            v.timer = false;
        end
    end
end

-- function DelegateView:closeView()
--     Super:closeView();
--     -- ViewManager.open("PushMapChapterRewardView");
-- end

function DelegateView:__onExit()
    self:clearTimer();
    Super.__onExit(self);
end

return DelegateView