-- add by zn
-- 福利月卡

local MonthlyCardModel = class("MonthlyCardModel", BaseModel);

function MonthlyCardModel:ctor()
    self.data = {};
    self:initListeners();
    self.addedRed = false;
    self.timer = {};
end

function MonthlyCardModel:MoonCard_AllData(_, param)
    -- printTable(2233, "===== 福利月卡 =====", param);
    self.data = param.data;
    self:checkRed();
    self:startTimer();
    Dispatcher.dispatchEvent("MonthlyCard_refreshView");
end

function MonthlyCardModel:getDailyAward(type)
    local info = {
        type= type,
    }
    RPCReq.MoonCard_ReceiveDaily(info);
end

function MonthlyCardModel: refreshData()
    print(2233, "MonthlyCardModel: refreshData-------------------------");
    RPCReq.MoonCard_SendInfo({});
end

function MonthlyCardModel:getCardData(type)
    if (self.data) then
        return self.data[type];
    end
    return nil;
end

function MonthlyCardModel: checkRed()
    if (not self.addedRed and #self.data > 0) then
        local map = {};
        for _, data in ipairs(self.data) do
            table.insert(map, "V_MONTHLYCARD_"..data.type);
        end
        RedManager.addMap("V_MONTHLYCARD", map);
        self.addedRed = true;
    end
    for _, data in ipairs(self.data) do
        if (data.time > 0 and data.dayState == false) then
            RedManager.updateValue("V_MONTHLYCARD_"..data.type, true);
        else
            RedManager.updateValue("V_MONTHLYCARD_"..data.type, false);
        end
        print(2233, "V_MONTHLYCARD_"..data.type, RedManager.getTips("V_MONTHLYCARD_"..data.type));
    end
end

function MonthlyCardModel: clearTimer()
    for _, id in pairs(self.timer) do
        Scheduler.unschedule(id)
    end
    self.timer = {};
end

function MonthlyCardModel: startTimer()
    self:clearTimer();
    for _, data in pairs(self.data) do
        if (data.time > 0) then
            data.leaveTime = data.time - ServerTimeModel:getServerTime();
            self.timer[data.type] = Scheduler.schedule(function (time)
                data.leaveTime = math.max(0, data.leaveTime - time);
                if (data.leaveTime == 0) then
                    Scheduler.unschedule(self.timer[data.type]);
                    self.timer[data.type] = false;
                    self:refreshData();
                end
            end, 1, 0);
        end
    end
end

return MonthlyCardModel;