
-- added by zn
-- 限时升级活动

local TimeUtil = require "Game.Utils.TimeUtil";

local UpgradeActivityView, Super = class("UpgradeActivityView", Window)

function UpgradeActivityView: ctor()
    self._packName = "UpgradeActivity";
    self._compName = "UpgradeActivityView";
    self.txt_countDown = false;
    self.list_item = false;
    self.timer = false;
end

function UpgradeActivityView: _initUI()
    self.txt_countDown = self.view:getChild('txt_countDown');
    self.list_item = self.view:getChild('list_item');
    -- self.list_item:setVirtual();
    self:initCountDown();
    self:UpgradeActivity_upView();
end

function UpgradeActivityView: initCountDown()
    if (self.timer) then
        TimeLib.clearCountDown(self.timer);
    end
    local function formatTime(_time)
        if (_time > 3600 * 24) then
            self.txt_countDown:setText(StringUtil.formatTime(_time, "d", Desc.common_TimeDesc))
        else
            self.txt_countDown:setText(StringUtil.formatTime(_time, "h", Desc.common_TimeDesc2))
        end
    end

    local times = math.floor((UpgradeActivityModel.endMs - ServerTimeModel:getServerTimeMS()) / 1000);
    formatTime(times);
    -- 开倒计时
    self.timer = TimeLib.newCountDown(times, function (time)
        formatTime(time);
    end, function ()
        self.txt_countDown:setText(Desc.activity_txt4)
    end, false, false, false);
end

function UpgradeActivityView: UpgradeActivity_upView()
    -- local conf = DynamicConfigData.t_ActiveLevelUp;
    local data = UpgradeActivityModel.data or {};
    self.list_item:setItemRenderer(function (idx, obj)
        local d = data[idx + 1];
        -- local c = conf[idx + 1];
        local ctrl = obj:getController("c1");
        ctrl:setSelectedIndex(d.state);
        obj:getChild("txt_level"):setText(string.format(Desc.upgradeAct_level, d.count));
        local progress = obj:getChild("progress");
        progress:setMax(d.count);
        progress:setValue(tonumber(PlayerModel.level));

        -- 奖励列表
        local list_prop = obj:getChild("list_prop");
        list_prop:setItemRenderer(function (idx2, obj2)
            if (not obj2.lua_script) then
                obj2.lua_script = BindManager.bindItemCell(obj2);
            end
            local award = d.reward[idx2 + 1];
            obj2.lua_script:setData(award.code, award.amount, award.type);
            obj2.lua_script:setIsHook(d.state == 3);
        end)
        list_prop:setNumItems(#d.reward);

        -- 领取按钮
        local btn = obj:getChild("btn_get");
        btn:removeClickListener(22);
        btn:addClickListener(function ()
            UpgradeActivityModel:getAward(d.id);
        end, 22)

        -- 前往按钮
        local btn_goto = obj:getChildAutoType("btn_goto");
        btn_goto:removeClickListener(22);
        btn_goto:addClickListener(function ()
            ModuleUtil.openModule(ModuleId.PushMap.id)
        end, 22)

        -- 剩余购买次数
        obj:getChildAutoType("count"):setText(d.leaveCount);

        -- 红点
        RedManager.register("V_UPGRADE_ACTIVITY_"..d.id, btn:getChild('img_red'));
    end)
    self.list_item:setNumItems(#data);
end

function UpgradeActivityView: __onExit()
    if (self.timer) then
        TimeLib.clearCountDown(self.timer);
    end
    Super.__onExit(self);
end

return UpgradeActivityView;