local BaseModel = require "Game.FMVC.Core.BaseModel"
local RetrieveModel = class("RetrieveModel", BaseModel)

function RetrieveModel:ctor()
end
function RetrieveModel:init()
    self.retrieveInfo = {}
    self.lastRewardMap = {}
    self.firstLogingState = false
end

function RetrieveModel:setLoginState() --首次登陆红点状态
    self.firstLogingState = true
end

function RetrieveModel:getLoginState() --首次登陆红点状态
    return self.firstLogingState
end

function RetrieveModel:setRetrieveInfo(info)
    self.retrieveInfo = {}
    for key, value in pairs(info) do
        if value and value.ids and #value.ids == 0 and self.lastRewardMap[key]==nil  then
        else
            self.retrieveInfo[key] = value
        end
    end
end

function RetrieveModel:getRetrieveInfo()
    return self.retrieveInfo or {}
end

function RetrieveModel:getRetrueveState() --是否有可领取条目
    local has = false
    if next(self.retrieveInfo) ~= nil then
        has = true
    end
    return has
end

function RetrieveModel:isHasRetrueveReward() --是否有可领取奖励
    local has = false
    if next(self.retrieveInfo) ~= nil then
        for key, value in pairs(self.retrieveInfo) do
            if value and value.ids and #value.ids > 0 then
                has = true
                break
            end
        end
    end
    return has
end

function RetrieveModel:getRetruveCost(ids, costType) --当前的消耗
    local tableAll = {}
    local allrewardInfo = {}
    local configInfo = DynamicConfigData.t_RetrieveReward
    if ids then
        for key, value in pairs(ids) do
            local fonfigItem = configInfo[value]
            if costType == 0 then --当前是金币
                table.insert(tableAll, fonfigItem.goldCost)
            else
                table.insert(tableAll, fonfigItem.diamondCost)
            end
        end
    end
    allrewardInfo = TableUtil:getReward(tableAll, 1)
    return allrewardInfo
end

function RetrieveModel:getRetrueveReward(ids, costType) --当前的奖励
    local tableAll = {}
    local allrewardInfo = {}
    local configInfo = DynamicConfigData.t_RetrieveReward
    if ids then
        for key, value in pairs(ids) do
            local fonfigItem = configInfo[value]
            if costType == 0 then --当前是金币
                table.insert(tableAll, fonfigItem.goldItems)
            else
                table.insert(tableAll, fonfigItem.diamondItems)
            end
        end
    end
    allrewardInfo = TableUtil:getReward(tableAll, 1)
    return allrewardInfo
end

function RetrieveModel:LastsetOnekeyRetrueveReward(costType) --设置一键扫荡最后一次的奖励
    local serverInfo = self:getRetrieveInfo()
    for key, value in pairs(serverInfo) do
        local serverItem = serverInfo[key]
        if serverItem.ids then
            if self.lastRewardMap[key]==nil then
                self.lastRewardMap[key]={}
            end
            self.lastRewardMap[key]=self:getRetrueveReward(serverItem.ids, costType)
        end
    end
end

function RetrieveModel:LastsetRetrueveReward(ids, costType) --设置当前最后一次的奖励
    local tableAll = {}
    tableAll=  self:getRetrueveReward(ids, costType)
    return tableAll or {}
end

function RetrieveModel:LastgetRetrueveReward(code, costType) --当前最后一次的奖励
   return self.lastRewardMap[code] or {}
end

function RetrieveModel:getRetruveAllCost(costType) --当前一键找回的消耗
    local tableAll = {}
    local allrewardInfo = {}
    local serverInfo = self:getRetrieveInfo()
    local configInfo = DynamicConfigData.t_RetrieveReward
    for key, value in pairs(serverInfo) do
        local serverItem = serverInfo[key]
        if serverItem.ids then
            for k, v in pairs(serverItem.ids) do
                local fonfigItem = configInfo[v]
                if costType == 0 then --当前是金币
                    table.insert(tableAll, fonfigItem.goldCost)
                else
                    table.insert(tableAll, fonfigItem.diamondCost)
                end
            end
        end
    end
    allrewardInfo = TableUtil:getReward(tableAll, 1)
    return allrewardInfo
end

function RetrieveModel:getRetruveChooseCost(ids, costType, count) --当前选择的消耗
    local tableAll = {}
    local allrewardInfo = {}
    local configInfo = DynamicConfigData.t_RetrieveReward
    if ids then
        for i = 1, #ids, 1 do
            if i <= count then
                local id = ids[i]
                local fonfigItem = configInfo[id]
                if costType == 0 then --当前是金币
                    table.insert(tableAll, fonfigItem.goldCost)
                else
                    table.insert(tableAll, fonfigItem.diamondCost)
                end
            end
        end
    end
    allrewardInfo = TableUtil:getReward(tableAll, 1)
    return allrewardInfo
end

function RetrieveModel:upRetrieveRed()
    local hasReward = self:isHasRetrueveReward()
    local isShow = self:getLoginState()
    local red = false
    if hasReward and isShow == false then
        red = true
    end
    RedManager.updateValue("V_RETRIEVERED", red)
end

--request回收物品
function RetrieveModel:RetrieveItem(type, useGold, times)
    local function success(data)
        -- Dispatcher.dispatchEvent(EventType.HallowCopy_getInfoUpdate)
    end
    local info = {
        type = type, --1:integer #回收系统类型
        useGold = useGold, --2:boolean #是否使用金币，true使用金币，false使用钻石
        times = times --3:integer #回收多少次
    }
    printTable(5, "回收物品发送的参数", info)
    RPCReq.Retrieve_RetrieveItem(info, success)
end

--一键找回
function RetrieveModel:OneKeyRetrieveItem(useGold)
    local function success(data)
        --Dispatcher.dispatchEvent(EventType.HallowCopy_getInfoUpdate)
    end
    local info = {
        useGold = useGold --1:boolean #是否使用金币，true使用金币，false使用钻石
    }
    printTable(5, "一键找回发送的参数", info)
    RPCReq.Retrieve_OneKeyRetrieveItem(info, success)
end

return RetrieveModel
