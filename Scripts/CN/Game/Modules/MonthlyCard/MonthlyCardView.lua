-- add by zn
-- 福利月卡

local MonthlyCardView = class("MonthlyCardView", Window);

function MonthlyCardView:ctor()
    self._packName = "LoginAward";
    self._compName = "MonthlyCardView";
    self.timer = {};
    
end

function MonthlyCardView: _initUI()
    local root = self;
    for i = 1, 2 do
        local card = self.view:getChildAutoType("card"..i);
        root["card"..i] = card;
        card.desc1 = card:getChildAutoType("desc1");
        card.desc2 = card:getChildAutoType("Desc2");
        card.btn_getAward = card:getChildAutoType("btn_getAward");
        card.txt_leaveTime = card:getChildAutoType("txt_leaveTime");
        card.txt_totalGet = card:getChildAutoType("totalGet");
        card.txt_dailyGet = card:getChildAutoType("dailyGet");
        card.btn_active = card:getChildAutoType("btn_active"..i);
        card.progress = card:getChildAutoType("progress");
        card.ctrl = card:getController("c1");
        card.txt_got = card:getChildAutoType("txt_Got");
    end
    self:MonthlyCard_refreshView();
end

function MonthlyCardView: _initEvent()
    for i = 1, 2 do
        local card = self["card"..i]
        card.btn_getAward:addClickListener(function ()
            MonthlyCardModel:getDailyAward(i);
        end)

        RedManager.register("V_MONTHLYCARD_"..i, card.btn_getAward:getChildAutoType("img_red"));

        card.btn_active:addClickListener(function ()
            --ModuleUtil.openModule(ModuleId.DailyGiftBag);
			if ServerTimeModel:getOpenDay() >= 7 then
				ModuleUtil.openModule(ModuleId.MonthlyGiftBag.id)
			else
				ModuleUtil.openModule(ModuleId.NewServerGift.id)
			end
        end)
    end
end

function MonthlyCardView: MonthlyCard_refreshView()
    if (tolua.isnull(self.view)) then return end;
    self:clearTimer();
    for i = 1, 2 do
        self:upCardPanel(i);
    end
end

function MonthlyCardView: upCardPanel(type)
    local panel = self["card"..type];
    local conf = DynamicConfigData.t_MoonCard[type];
    local data = MonthlyCardModel:getCardData(type);
    panel:setTitle(conf.name);
    local txt = data.dayState and Desc.MonthlyCard_got or Desc.MonthlyCard_get;
    panel.btn_getAward:setGrayed(data.dayState);
    panel.btn_getAward:setTouchable(not data.dayState);
    panel.btn_getAward:setTitle(txt);
    panel.desc1:setText(string.format(Desc.MonthlyCard_needRecharge, conf.charge));
    panel.desc2:setText(conf.desc1 or "");
    local dayGet = conf.dayGet[1] and conf.dayGet[1].amount or 0;
    panel.txt_dailyGet:setText(dayGet);
    panel.txt_totalGet:setText(conf.allGet);

    local days = data.days or 0;
    local got = days * dayGet;
    panel.txt_got:setText(string.format(Desc.MonthlyCard_gotCount, got, conf.allGet));
    
    if (data.time == 0) then
        panel.ctrl:setSelectedIndex(0);
        panel.progress:setMax(conf.charge);
        panel.progress:setValue(data.recharge);
    else
        panel.ctrl:setSelectedIndex(1);
        local leaveTime = data.time - ServerTimeModel:getServerTime();
        local function changeTime()
            if (data.leaveTime < 3600) then
                panel.txt_leaveTime:setText(StringUtil.formatTime(math.floor(data.leaveTime), "h", Desc.MonthlyCard_str1))
            elseif (data.leaveTime < 86400) then
                panel.txt_leaveTime:setText(string.format(Desc.MonthlyCard_timeHour, math.floor(data.leaveTime / 3600)));
            else
                panel.txt_leaveTime:setText(string.format(Desc.MonthlyCard_timeDay, math.floor(data.leaveTime / 86400)));
            end
        end
        changeTime();
        self.timer[type] = Scheduler.schedule(function (time)
            leaveTime = leaveTime - time;
            changeTime();
        end, 1, 0);
    end

end

function MonthlyCardView: clearTimer()
    for _, id in pairs(self.timer) do
        if (id) then
            Scheduler.unschedule(id)
        end
    end
    self.timer = {};
end

function MonthlyCardView: _exit()
    self:clearTimer();
end

return MonthlyCardView;