
-- added by zn
-- 直购礼包

local ActivityType = require "Configs.GameDef.ActivityType";
local Configer = require "Game.ConfigReaders.MoneyBuyGiftConfiger";
local MoneyBuyGiftModel = class("MoneyBuyGiftModel", BaseModel)

function MoneyBuyGiftModel:ctor()
    self.dataList = false; -- 所有数据  id为key  {[101]={}, [102] = {}, [202] = {} ....}
    self.idList = false; -- 记录id索引  {[1] = {101, 102, 103}, [2] = {201, 202} ....}
    self:initData();
    self.selectData = false;
    self.typeId = false;
    self.giftRecords = {}
end

-- 剩余购买次数
function MoneyBuyGiftModel:getRemainingBuyCountByGiftId(giftId)
    local record = self.giftRecords[giftId] or DT
    local hasBoughtTimes = record.buyTimes or 0
    local config = self.dataList[giftId]
    return config.buyTimes - hasBoughtTimes
end

-- 是否可购买，0表示可购买 1表示不可购买
function MoneyBuyGiftModel:getStatusByGiftId(giftId)
    return self:getRemainingBuyCountByGiftId(giftId) > 0 and 0 or 1
end

-- 是否存在新服专享礼包
function MoneyBuyGiftModel:haveOnlyNewServerGift()
    local info = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.SaleGiftPack)
    if not info then return end
    local endTime = TimeLib.GetDateStamp(info.realStartMs) + 7*24*60*60*1000
    local now = ServerTimeModel:getServerTimeMS()
    if now >= endTime then
        return false
    end

    -- 如果服务端回传的礼包列表里有“新服专享”礼包则显示新服专享礼包界面
    for giftId, _ in pairs(self.giftRecords) do
        if self.dataList[giftId] and self.dataList[giftId].giftType == 4 then
            return true
        end
    end

    return false
end

-- 更新数据
function MoneyBuyGiftModel:upBoughtData(data)
    self.giftRecords = data

    --for id, val in pairs(data) do
    --    local confData = self.dataList[id];
    --    if (confData) then
    --        confData.buyCount = val.buyTimes and confData.buyTimes - val.buyTimes or confData.buyTimes;
    --        confData.status = confData.buyCount > 0 and 0 or 1 --  0 可购买
    --    end
    --end
    self:sortIdList();
    self:checkRedDot();
    Dispatcher.dispatchEvent("MoneyBuy_upGoodsList");
end

function MoneyBuyGiftModel:initData()
    self.dataList = Configer.getAllConf();
    self.idList = {};
    for id, val in pairs(self.dataList) do
        if (not self.idList[val.giftType]) then self.idList[val.giftType] = {} end;
        table.insert(self.idList[val.giftType], id);
    end
    -- self:sortIdList();
end

-- 给id索引列表排序 
function MoneyBuyGiftModel:sortIdList()
    for _, tab in ipairs(self.idList) do
        table.sort(tab, function(left, right)
            if(#tab < 5) then
                return left < right;
            else
                -- 可购买的在前
                local leftStatus = self:getStatusByGiftId(left)
                local rightStatus = self:getStatusByGiftId(right)
                if leftStatus ~= rightStatus then
                    return leftStatus == 0
                end

                -- id小的在前
                return left < right
            end
        end);
    end
end

function MoneyBuyGiftModel:checkRedDot()
    -- "V_ACTIVITY_"..self.typeId.."_DAY", "V_ACTIVITY_"..self.typeId.."_WEEK", "V_ACTIVITY_"..self.typeId.."_MONTH"
    if (not self.typeId) then
        self.typeId = ActivityType.SaleGiftPack;
        local map = {
            "V_ACTIVITY_"..self.typeId.."_DAY",
            "V_ACTIVITY_"..self.typeId.."_WEEK",
            "V_ACTIVITY_"..self.typeId.."_MONTH",
            "V_ACTIVITY_"..self.typeId.."_ONLYNEWSERVER",
        }
        RedManager.addMap("V_ACTIVITY_"..self.typeId, map);
    end

    for type, idList in ipairs(self.idList) do
        local flag = false;
        for _, id in ipairs(idList) do
            local data = self.dataList[id]
            if (data and self:getStatusByGiftId(id) == 0 and data.price == 0) then
                flag = true;
                break;
            end
        end

        local haveOnlyNewServerGift = self:haveOnlyNewServerGift()
        if type == 1 then
            RedManager.updateValue("V_ACTIVITY_"..self.typeId.."_DAY", flag);
        elseif type == 2 then
            RedManager.updateValue("V_ACTIVITY_"..self.typeId.."_WEEK", flag and not haveOnlyNewServerGift);
        elseif type == 3 then
            RedManager.updateValue("V_ACTIVITY_"..self.typeId.."_MONTH", flag);
        elseif type == 4 then -- 新服专享
            RedManager.updateValue("V_ACTIVITY_"..self.typeId.."_ONLYNEWSERVER", flag and haveOnlyNewServerGift);
        end
    end
end

return MoneyBuyGiftModel;