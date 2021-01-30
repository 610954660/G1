-- add by zn
-- 饰品

local JewelryModel = class("JewelryModel", BaseModel)
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger";
local ItemBase = require("Game.Modules.Pack.ItemBase");
-- local  
-- local GirdRightLimit = 10; 

function JewelryModel:ctor()
    self.bag = false;
    self.GirdLeftLimit = 100; -- 左槽等级限制
    self.GirdRightLimit = 12; -- 右槽星级限制
    self.heroInfo = false;
    self.selectedNum = 0; -- 已选择的数量
    self.__itemArr = {}; -- 根据背包顺序存储
    self.__uuidArr = {}; -- 根据uuid存储
    self.selectedArr = {}; -- 选择的物品
    self.colorArr = {} -- 按颜色品质分
    -- self.heroEquiped = {} -- 英雄已经穿戴的
    self.proficiency = 0; -- 合成熟练度
    self:initListeners();
end

function JewelryModel:Jewelry_Update(_, param)
    self.proficiency = param.proficiency
    -- printTable(2233, "熟练度更新====", param);
end


function JewelryModel:Hero_HeroList()
    local heroList = CardLibModel:getAllCards();
    self.__uuidArr= self.__uuidArr or {};
    self.__itemArr= self.__itemArr or {};
    self.colorArr= self.colorArr or {};
    for _,v in pairs(heroList) do
        for pos, jewelry in pairs(v.jewelryMap) do
            if (jewelry.uuid) then
                local je = jewelry
                local dd = self:__rebuildStruct(je);
                dd.pos = pos;
                dd.heroUuid = v.uuid;
                local color = dd.color;
                self.__uuidArr[je.uuid] = dd;
                self.colorArr[color] = self.colorArr[color] or {};
                table.insert(self.colorArr[color], dd.uuid);
                table.insert(self.__itemArr, dd);
            end
        end
    end
end

function JewelryModel:loginPlayerDataFinish()
    self.bag = PackModel:getJewelryBag();
    self.colorArr = {};
    self.__itemArr = {};
    self.__uuidArr = {};
    for idx, je in pairs(self.bag.__packItems) do
        local data = je.__data;
        local color = je:getColorId();
        local dd = self:__rebuildStruct(je)
        self.__uuidArr[data.uuid] = dd;
        table.insert(self.colorArr[color], dd.uuid);
        table.insert(self.__itemArr, dd);
    end
end

function JewelryModel: __rebuildStruct(oldData)
    if (oldData.__data) then -- 背包内的数据
        local data = oldData.__data;
        local spData = data.specialData.jewelry;
        local color = oldData:getColorId();
        if (not self.colorArr[color]) then
            self.colorArr[color] = {};
        end
        local dd = {
            uuid = data.uuid,
            code = data.code,
            skill = spData and spData.skill or {},
            showSkill = spData and spData.showSkill or {},
            attr = spData and spData.attr or {},
            showAttr = spData and spData.showAttr or {},
            luckyProb = spData and spData.luckyProb or 0,
            percentageValue = spData and spData.percentageValue or false,
            percentageValueShow = spData and spData.percentageValueShow or false,
            color = color,
            name = oldData:getName();
        }
        if (dd.percentageValueShow == 0) then
            dd.percentageValueShow = false;
        end
        return dd;
    else -- 英雄装备身上的
        local conf = DynamicConfigData.t_item[oldData.code];
        oldData.luckyProb = oldData.luckyProb or 0;
        oldData.color = conf.color;
        oldData.name = conf.name;
        return oldData;
    end
end

function JewelryModel:getBag(excludeEquiped)
    
    self:loginPlayerDataFinish();
    if (excludeEquiped) then
        self:Hero_HeroList();
    end
    return self.__itemArr;
end

function JewelryModel:getJewelryByUuid(uuid)
    return self.__uuidArr[uuid];
end

-- 根据道具品级获取 0 全部 1 白 2 绿.....
function JewelryModel: getItemsByType(type, excludeEquiped)
    if (type == 0) then
        return self:getBag(excludeEquiped) or {};
    else
        local uuidArr = self.colorArr[type] or {};
        local arr = {};
        for _, uuid in pairs(uuidArr) do
            local je = self.__uuidArr[uuid]
            if (je) then
                table.insert(arr, je)
            end
        end
        return arr;
    end
    -- local arr = {}
    -- for _, data in ipairs(self.__itemArr) do
    --     if (data.baseData:getColorId() == type) then
    --         table.insert(arr, data)
    --     end
    -- end
    -- return arr;
end

--计算装备战力
function JewelryModel:calcCombat(jInfo)
    local totalPower = 0
    local attr = {};
    local addPercent = jInfo.percentageValue or 0;
    for k, v in pairs(jInfo.attr) do
        attr[v.id] = v.value * (1 + addPercent / 10000);
    end
    totalPower = HeroConfiger.CaleAttrPower(attr);
	for k, v in pairs(jInfo.attr) do
		totalPower = totalPower + JewelryConfiger.getAddPower(v.id, v.value)
    end
	
    if (not jInfo.percentageValue and jInfo.skill) then
        local skilldata = jInfo.skill
        if skilldata  then
            totalPower = totalPower + HeroConfiger.CaleSkillPower(skilldata)
        end
    end
	return totalPower
end

function JewelryModel:select(uuid)
    
    local d = self:getJewelryByUuid(uuid);
    local c = d.color;
    for _, id in pairs (self.selectedArr) do
        if (id) then
            local dd = self:getJewelryByUuid(id);
            if (dd) then
                local color = dd.color;
                if (c ~= color) then
                    RollTips.show(Desc.Jewelry_colorDiff);
                    return false;
                end
            end
        end
    end

    for idx in pairs (self.selectedArr) do
        if (not self.selectedArr[idx]) then
            self.selectedNum = self.selectedNum + 1;
            self.selectedArr[idx] = uuid;
            return true;
        end
    end
    if (self.selectedNum < 5) then
        self.selectedNum = self.selectedNum + 1;
        table.insert(self.selectedArr, uuid);
        return true;
    else
        RollTips.show(Desc.Jewelry_selectMax);
    end
    return false;
end

function JewelryModel:unselect(uuid)
    for idx, id in ipairs (self.selectedArr) do
        if (uuid == id) then
            self.selectedNum = self.selectedNum - 1;
            self.selectedArr[idx] = false;
            return;
        end
    end
end

function JewelryModel: isSelected(uuid)
    return table.hasValue(self.selectedArr, uuid);
end

function JewelryModel: clearSelected()
    self.selectedArr = {};
    self.selectedNum = 0;
end

-- 一键添加饰品 
function JewelryModel: addAllJewelry(num)
    num = num == nil and 5 or num;
    local arr = {};
    for i = 1, 6 do --白绿蓝紫橙5种品质
        if (self.colorArr[i] and num <= #self.colorArr[i]) then
            local m = 1
            local count = 0
            while count < num and m <= #self.colorArr[i] do
                local uuid = self.colorArr[i][m]
                local data = self.__uuidArr[uuid]
                if (data.code ~= 60000005) then
                    table.insert(arr, uuid);
                    count = count + 1;
                end
                m = m + 1;
            end
            self.selectedNum = count;
            return arr;
        end
    end
    RollTips.show(string.format(Desc.Jewelry_noSameItem, num));
    return nil;
end

------------------------------------------------------- 英雄信息相关
function JewelryModel:setHeroInfo(heroInfo)
    self.heroInfo = heroInfo;
    -- printTable(2233, self.heroInfo);
end

-- 检索饰品格子状态 status1 左格子  值为1锁定 0可穿戴  具体数据是已穿戴
function JewelryModel:checkGirdStatus(pos)
    local status = 1;
    if (pos == 1 and self.heroInfo.level >= self.GirdLeftLimit) then
        status = 0;
    end
    if (pos == 2 and self.heroInfo.star >= self.GirdRightLimit) then
        status = 0;
    end
    local jewelry = self.heroInfo.jewelryMap[pos];
    status = (jewelry and jewelry.uuid) and jewelry or status;
    if (type(status) == "table") then
        status = self:__rebuildStruct(status);
    end
    return status;
end

function JewelryModel:getJewelryInHeroPos(pos)
    if (self.heroInfo and self.heroInfo.jewelryMap[pos] and self.heroInfo.jewelryMap[pos].uuid) then
        return self:__rebuildStruct(self.heroInfo.jewelryMap[pos]);
    else
        return nil;
    end
end

-- 穿戴
function JewelryModel:equipJewelry(Jewelry, pos)
    Jewelry = type(Jewelry) == "table" and Jewelry.uuid or Jewelry;
    local info = {
        type = 0,
        pos = pos,
        heroUuid = self.heroInfo.uuid,
        itemUuid = Jewelry
    }
    printTable(2233, "穿装参数", info);
    local oldHero = CardLibModel:getHeroByUid(self.heroInfo.uuid)
    local oldAttr = oldHero.attrs
    local oldCombat = oldHero.combat
    RPCReq.Jewelry_Wear(info, function (param)
        printTable(2233, "== 穿装备结果 ==", param);
        self.heroInfo.jewelryMap[pos] = param.item[1];
        self:upHeroData(self.heroInfo.uuid, pos, param.item[1])
        Dispatcher.dispatchEvent("Jewelry_updateWear");

        local hero = CardLibModel:getHeroByUid(self.heroInfo.uuid)
        local newAttr = hero.attrs;
        local newCombat = hero.combat;
        RollTips.showAttrTips(oldAttr, newAttr);
        if (newCombat > oldCombat) then
            RollTips.showAddFightPoint(newCombat - oldCombat);
        end
    end)
end

-- 脱下
function JewelryModel:takeOffJewelry(pos, cb)
    local info = {
        type = 0,
        pos = pos,
        heroUuid = self.heroInfo.uuid,
    }
    printTable(2233, "== 脱装参数 ==", info)
    RPCReq.Jewelry_TakeOff(info, function (param)
        printTable(2233, "== 脱装结果 ==", param)
        if (param and param.isSuccess) then
            self.heroInfo.jewelryMap[pos] = nil;
            self:upHeroData(self.heroInfo.uuid, pos, nil)
            if (cb) then
                cb();
            else
                Dispatcher.dispatchEvent("Jewelry_updateWear");
            end
        end
    end)
end

-- 合成
function JewelryModel:merge(list)
    local d = self:getJewelryByUuid(list[1])
    if (not d) then  -- 可能是数据错误 先刷新一遍物品
        self:clearSelected();
        Dispatcher.dispatchEvent("Jewelry_mergeSuccess");
        return
    end
    local conf = DynamicConfigData.t_JewelryComposite[#list][d.code];
    local info = {
        type = 0,
        count = 0,
        itemList = list
    }
    printTable(2233, "=== 合成参数", list);
    RPCReq.Jewelry_Mix(info, function (param)
        printTable(2233, "===== 合成结果", param);
        self:clearSelected();
        Dispatcher.dispatchEvent("Jewelry_mergeSuccess", param);
        if (not param.isSuccess) then
            local back = conf.failProduct;
            local itemConf = DynamicConfigData.t_item;
            local str = "";
            for idx, d in ipairs(back) do
                if (itemConf[d.code]) then
                    local s = "["..itemConf[d.code].name.."]x"..d.amount;
                    if (str ~= "") then
                        str = str..DescAuto[170]..s; -- [170]="，"
                    else
                        str = s;
                    end
                end
            end
            RollTips.show(Desc.Jewelry_mergeFail..str);
        end
    end)
end

-- 检查放入的是否是同一品质
function JewelryModel:checkSelectedColor()
    local color = false;
    local code = false;
    for _, uuid in ipairs (self.selectedArr) do
        if (uuid) then
            local d = self:getJewelryByUuid(uuid);
            local c = d.color;
            if (color == false) then
                color = c;
                code = d.code;
            elseif (color ~= c) then
                RollTips.show(Desc.Jewelry_colorDiff);
                return false, false;
            end
        end
    end
    return color, code;
end

-- 重铸
function JewelryModel:rebuild(itemUuid, heroUuid, pos)
    
    local otherData = self:getJewelryByUuid(itemUuid);
    local code = otherData and otherData.code or 0;
    local conf = DynamicConfigData.t_Jewelry[code];
    if (conf and not PlayerModel:isCostEnough(conf.cost)) then
        -- RollTips.show(Desc.Jewelry_mergeCostNotEngouh);
        return;
    end
    local info = {
        itemUuid = itemUuid
    }
    if (otherData.pos) then info.pos = otherData.pos end
    if (otherData.heroUuid) then info.heroUuid = otherData.heroUuid end
    printTable(2233, "===== 重铸参数", info);
    RPCReq.Jewelry_Recasting(info, function (param)
        printTable(2233, "========== 重铸结果", param);
        if (otherData.heroUuid) then
            self:upHeroData(otherData.heroUuid, otherData.pos, param.item[1])
        else
            self:upBagData(param.item);
        end
        self.__uuidArr[itemUuid] = self:__rebuildStruct(param.item[1]);
        self.__uuidArr[itemUuid].pos = otherData.pos;
        self.__uuidArr[itemUuid].heroUuid = otherData.heroUuid;
        Dispatcher.dispatchEvent("JewelryRebuild_upRightPanel");
    end)
end

-- 保存重铸
function JewelryModel:saveRebuild(itemUuid, heroUuid, pos)
    local info = {
        itemUuid = itemUuid
    }
    local otherData = self:getJewelryByUuid(itemUuid);
    if (otherData.pos) then info.pos = otherData.pos end
    if (otherData.heroUuid) then info.heroUuid = otherData.heroUuid end
    printTable(2233, "===== 保存重铸参数", info);
    RPCReq.Jewelry_SaveRecasting(info, function (param)
        printTable(2233, "========== 保存重铸结果", param);
        if (otherData.heroUuid) then
            self:upHeroData(otherData.heroUuid, otherData.pos, param.item[1])
        else
            self:upBagData(param.item);
        end
        
        self.__uuidArr[itemUuid] = self:__rebuildStruct(param.item[1]);
        self.__uuidArr[itemUuid].pos = otherData.pos;
        self.__uuidArr[itemUuid].heroUuid = otherData.heroUuid;
        Dispatcher.dispatchEvent("JewelryRebuildView_refreshView");
        Dispatcher.dispatchEvent("Jewelry_updateWear");
    end)
end

function JewelryModel:decompose(itemUuid)
    local info = {
        itemUuid = itemUuid
    }
    RPCReq.Jewelry_Decompose(info, function (param)
        printTable(2233, "===== 分解饰品结果 ====", param);
    end)
end

function JewelryModel:exchangeByProficiency()
    print(2233, "===== 熟练度兑换")
    RPCReq.Jewelry_Exchange({}, function (param)
        print(2233, "==== 熟练度兑换结果", param);
        Dispatcher.dispatchEvent("Jewelry_upView");
    end)
end

-- 获取背包内的道具
function JewelryModel:getJewelryInBag(uuidArr)
    local bag= PackModel:getJewelryBag();
    -- printTable(2233, bag);
    local arr = {};
    for _, je in pairs(bag.__packItems) do
        local d = je.__data;
        if (table.hasValue(uuidArr, d.uuid)) then
            arr[d.uuid] = d.specialData;
        end
    end
    return arr;
end

-- 更新背包内的数据
function JewelryModel:upBagData(dataArr)
    local uuidArr = {};
    for _, data in pairs(dataArr) do
        table.insert(uuidArr, data.uuid);
    end
    local arr = self:getJewelryInBag(uuidArr);
    for _, data in pairs(dataArr) do
        if (arr[data.uuid]) then
            arr[data.uuid].jewelry = data;
        end
    end
end

-- 更新英雄身上的饰品数据
function JewelryModel:upHeroData(heroUuid, pos, data)
    local HeroInfo = CardLibModel:getHeroByUid(heroUuid);
    -- printTable(2233, pos, HeroInfo);
    if (HeroInfo) then
        HeroInfo.jewelryMap[pos] = data;
    end
end

return JewelryModel;
