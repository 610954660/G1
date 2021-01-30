-- add by zn
-- 纹章系统

local EmblemModel = class("EmblemModel", BaseModel)

function EmblemModel:ctor()
    self.__uuidMap = {}; -- uuid为索引
    self.__itemList = {}; -- 所有纹章
    -- self.__equipedUuidMap = {}; -- 已经穿戴的
    self.__heroEmblemMap = {};  -- 英雄id与已装备索引
    self:initListeners()
    -- self.refreshInterval = false; -- 背包刷新间隔
    -- self.redInterval = false; -- 红点检测间隔
    self.rewardEmblemCache = {};
end

function EmblemModel:clearItemsInfo()
    self.__uuidMap = {}; -- uuid为索引
    self.__itemList = {}; -- 所有纹章
    -- self.__equipedUuidMap = {}; -- 已经穿戴的
    self.__heroEmblemMap = {};  -- 英雄id与已装备索引
end

-- 背包内的 （仅内部调用）
function EmblemModel:__getAllBagItem()
    local bag = PackModel:getEmblemBag();
    for idx, eq in pairs(bag.__packItems) do
        local data = self:__rebuildStruct(eq)
        if (data) then
            self.__uuidMap[data.uuid] = data;
            table.insert(self.__itemList, data);
        end
    end
end

-- 英雄身上穿的 （仅内部调用）
function EmblemModel:__getHeroEquiped(excludeEquiped)
    local bag = PackModel:getDressEmblemBag();
    for idx, eq in pairs(bag.__packItems) do
        local data = self:__rebuildStruct(eq)
        if (data) then
            self.__uuidMap[data.uuid] = data;
            if (not self.__heroEmblemMap[data.heroUuid]) then
                self.__heroEmblemMap[data.heroUuid] = {}
            end
            local map = self.__heroEmblemMap[data.heroUuid];
            map[data.pos] = data.uuid;
            if (excludeEquiped) then
                table.insert(self.__itemList, data);
            end
        end
    end
    -- print(2233, "===== 英雄已穿戴 ======", TableUtil.GetTableLen(bag.__packItems));
end

-- 整理数据结构
function EmblemModel:__rebuildStruct(emblem)
    -- 背包内数据
    local conf = DynamicConfigData.t_Emblem
    local info = false;
    if (emblem.__bagType) then
        local data = emblem.__data;
        local uuid = data.uuid;
        local spData = data.specialData.heraldry or {};
        if (not spData) then return false end
        local c = conf[spData.heraldryId];
        if (c) then
            info = {
                uuid = uuid,
                code = spData.heraldryId,  -- id 对应 t_Emblem表
                category = spData.category, -- 种族
                exp = spData.exp, -- 当前星级的经验
                star = spData.star, -- 星级
                pos = c.pos, -- 纹章所属装配位置 1，2，3，4
                color = c.rank,  -- 品质颜色
                suitId = c.suitId, -- 套装id
                heroUuid = spData.heroUuid or false, -- 被穿戴时会有对应的英雄uuid
				bagType = emblem.__bagType,
				itemId = data.id,
				itemCode = emblem.__data.code,
				categoryShow = spData.categoryShow or false,
            }
        end
    else -- 服务端数据
        local uuid = emblem.heraldryUuid;
        local c = conf[emblem.code];
        if (c) then
            info = {
                uuid = uuid,
                code = emblem.code,  -- id 对应 t_Emblem表
                category = emblem.category, -- 种族
                star = emblem.star, -- 星级
                pos = c.pos, -- 纹章所属装配位置 1，2，3，4
                color = c.rank,  -- 品质颜色
                suitId = c.suitId, -- 套装id
                -- heroUuid = spData.heroUuid or false, -- 被穿戴时会有对应的英雄uuid
				-- bagType = emblem.__bagType,
				-- itemId = data.id,
				-- itemCode = emblem.__data.code,
				-- categoryShow = spData.categoryShow or false,
            }
        end
    end
    return info;
end

-- 获取所有纹章  excludeEquiped 为ture包含已穿戴
function EmblemModel:getBag(excludeEquiped, checkRed)
    checkRed = checkRed == nil and true or checkRed;
    if (checkRed) then
        self:checkRedDot();
    end
    self:clearItemsInfo();
    self:__getAllBagItem();
    self:__getHeroEquiped(excludeEquiped)
    return self.__itemList;
end

-- 根据穿戴位置获取  pos为0是整个背包
function EmblemModel:getEmblemsByPos(pos, checkRed)
    local sortMap = {{key = "pos", asc = false}, {key = "color", asc = true}, {key = "star", asc = true}, {key = "category", asc = true}}
    if (pos == 0) then
        local list = self:getBag(false, checkRed);
        TableUtil.sortByMap(list, sortMap);
        return list;
    else
        local items = self:getBag(false, checkRed);
        local list = {};
        for _, emblem in ipairs(items) do
            if (emblem.pos == pos) then
                table.insert(list, emblem);
            end
        end
        TableUtil.sortByMap(list, sortMap);
        return list;
    end
end

function EmblemModel:equip(emblem, hero)
    local info = {
        heroUuid = hero.uuid,
        heraldryUuid = emblem.uuid
    }
    local uuid = hero.uuid
    local oldCombat = hero.combat
    RPCReq.Heraldry_Wearing(info, function (params)
        -- printTable(2233, params);
        local newhero = CardLibModel:getHeroByUid(uuid)
        local newCombat = newhero.combat
        if newCombat > oldCombat then
            RollTips.showAddFightPoint(newCombat - oldCombat, true)
        end
		Dispatcher.dispatchEvent("Emblem_refreshBagInfo")
        Dispatcher.dispatchEvent(EventType.Emblem_emblemEquipChange, params)
    end)
end

function EmblemModel:unequip(emblem, hero)
    local info = {
        heroUuid = hero.uuid,
        heraldryUuid = emblem.uuid
    }
    RPCReq.Heraldry_Unload(info, function (params)
        -- printTable(2233, params);
		Dispatcher.dispatchEvent("Emblem_refreshBagInfo")
        Dispatcher.dispatchEvent(EventType.Emblem_emblemEquipChange)
    end)
end

function EmblemModel:unequipWithList(list, cb)
    if (not list or #list <= 0) then return end;
    local info = {
        heraldryList = list
    }
    RPCReq.Heraldry_OneKeyUnload(info, function (params)
        if (params.ret) then
            print(2233, "---- 一键脱装 ----");
            Dispatcher.dispatchEvent("Emblem_refreshBagInfo")
            Dispatcher.dispatchEvent(EventType.Emblem_emblemEquipChange)
            if (cb) then cb() end
        end
    end)
end

function EmblemModel:equipWithList(list)
    local info = {
        heraldryList = list
    }
    local posList = {} -- 标记哪些是新穿上的装备，特效展示
    for _, d in pairs(list) do
        local m = self.__uuidMap[d.heraldryUuid];
        if (m) then
            posList[m.pos] = true
        end
    end
    local uuid = list[1].heroUuid
    local hero = CardLibModel:getHeroByUid(uuid)
    local oldCombat = hero.combat
    RPCReq.Heraldry_OneKeyWearing(info, function (params)
        if (params.ret) then
            local newhero = CardLibModel:getHeroByUid(uuid)
            local newCombat = newhero.combat
            if newCombat > oldCombat then
                RollTips.showAddFightPoint(newCombat - oldCombat, true)
            end
            print(2233, "---- 一键穿戴 ---");
            Dispatcher.dispatchEvent("Emblem_refreshBagInfo")
            Dispatcher.dispatchEvent(EventType.Emblem_emblemEquipChange, posList)
        end
    end)
end

--[[ 
    装备属性计算 这里 emblems 为 {1=uuid1, 2=uuid2, 3=uuid3, 4=uuid4}
    @return 
        {
            uuid1 = {attrId1 = {val = value1, add = value2}, attrId2 = {val = value1, add = value2}},  val是基础值 add是加成的值（不含基础值）
            uuid2 = {attrId1 = {val = value1, add = value2}, attrId2 = {val = value1, add = value2}},
        }
]]
function EmblemModel:getEmblemsAttr(emblems, hero)
    if (type(emblems) ~= "table") then return{} end;
    local sx = {};
    local conf = DynamicConfigData.t_Emblem;
    local constConf = DynamicConfigData.t_EmblemConst[1];
    local category = hero and hero.heroDataConfiger.category or 0
    for _, uuid in pairs(emblems) do
        local d = self:getEmblemByUuid(uuid);
        if (d) then
            local c = conf[d.code];
            local attrs = c.attribute
            sx[uuid] = {}
            for _, attr in ipairs(attrs) do
                local id = attr.attrId;
                local star = d.star * constConf.StarAdd;
                local category = category == d.category and constConf.CategoryAdd or 0;
                local add = math.ceil(attr.val * (star + category) / 10000);
                sx[uuid][id] = {
                    val = attr.val,
                    add = add
                }
            end
        end
    end
    return sx;
end

--[[ 
    装备激活的套装属性 -- 2件套 4件套分开计算
    @params emblems {1 = uuid1, 2=uuid2, 3=uuid3, 4=uuid4}最多接受4个uuid
    @return  suit, uuidMap
        suit={ -- suitId 为套装id, level为属性激活的等级
                suitId1 = {2 = level , 4 = level},
                suitId2 = {2 = level , 4 = level},
            }
        uuidMap = {uuid1= {2 = level, 4 = level}, {uuid2 = {2 = level, 4 = level}}}
]]
function EmblemModel:getHeroSuitInfo(emblems)
    if (type(emblems) ~= "table") then return {}, {} end;

    if (TableUtil.GetTableLen(emblems) == 1) then
        local k = next(emblems)
        local uuid = emblems[k]
        local map = {}
        map[uuid] = {}
        return {}, map
    end

    local suit = {};
    local uuidMap = {};
    local temp = {};
    local conf = DynamicConfigData.t_Emblem;
    -- 整理数据
    for _, uuid in pairs(emblems) do
        local d = type(uuid) == "string" and self:getEmblemByUuid(uuid) or uuid;
        if (d) then
            local c = conf[d.code];
            local id = c.suitId;
            local lv = c.rank;
            local pos = c.pos;
            if not temp[id] then
                temp[id] = {};
            end
            -- 这里是防止传入的四个纹章有同一个位置的错误情况
            if temp[id][pos] then
                local old = temp[id][pos]
                if (old.lv < lv) then
                    temp[id][pos] = {pos = pos, lv = lv , uuid = d.uuid};
                end
            else
                temp[id][pos] = {pos = pos, lv = lv , uuid = d.uuid};
            end
        end
    end
    -- 排序筛选套装
    for suitId, a in pairs(temp) do
        suit[suitId] = {}
        local arr = {};
        for _, info in pairs(a) do
            table.insert(arr, info);
        end
        -- 两件套  按品质最高的两个中，低的那个激活属性
        if (#arr >= 2) then
            TableUtil.sortByMap(arr, {{key = "lv", asc = true}});
            local lostLv = arr[2].lv - 1;
            if (lostLv > 0) then
                suit[suitId][2] = lostLv
                for i = 1, #arr do
                    local uid = arr[i].uuid;
                    uuidMap[uid] = {};
                    uuidMap[uid][2] = lostLv;
                end
            end
        end
        -- 四件套  按品质最低的那个激活属性
        if (#arr >= 4) then
            TableUtil.sortByMap(arr, {{key = "lv", asc = false}});
            local lostLv = arr[1].lv - 1;
            if (lostLv > 0) then
                suit[suitId][4] = lostLv
                for i = 1, 4 do
                    local uid = arr[i].uuid;
                    uuidMap[uid] = uuidMap[uid] or {};
                    uuidMap[uid][4] = lostLv;
                end
            end
        end
    end
    return suit, uuidMap;
end

-- 获取整套推荐 2件套 4件套分开计算
function EmblemModel:getSuggestSuit(hero, includeEquiped)
    local allSuit = {};
    local emConf = DynamicConfigData.t_Emblem;
    local emblems = self:getBag(includeEquiped);
    local ordered = {}
    -- 英雄推荐套装
    local heroConf = DynamicConfigData.t_hero[hero.code];
    local heroSuggest = heroConf.suggestEmblem or {};
    local suggestMap = {};
    for _, suitId in pairs(heroSuggest) do
        suggestMap[suitId] = true;
    end
    local category = hero.heroDataConfiger.category;
    -- 每个套装都要展示 没有对应装备的显示空
    local suitConf = DynamicConfigData.t_EmblemSuit;
    for _, conf in ipairs(suitConf) do
        if (includeEquiped and not ordered[conf.suitId]) then
            ordered[conf.suitId] = {};
        end
    end
    -- 将背包纹章按套装、位置分好；
    for _, em in ipairs(emblems) do
        local c = emConf[em.code];
        local suitId = c.suitId;
        if (not ordered[suitId]) then
            ordered[suitId] = {};
        end
        if (not ordered[suitId][em.pos]) then
            ordered[suitId][em.pos] = {};
        end
        local tab = ordered[suitId][em.pos];
        table.insert(tab, em);
    end
    -- 排下序
    for suitId, ems in pairs(ordered) do
        for pos, tab in pairs(ems) do
            if (#tab > 1) then
                table.sort(tab, function (em1, em2)
                    if (em1.color > em2.color) then
                        return true;
                    elseif (em1.color < em2.color) then
                        return false;
                    end
                    if (em1.star > em2.star) then
                        return true
                    elseif (em1.star < em2.star) then
                        return false
                    end
                    if (em1.category ~= em2.category and em1.category == category) then
                        return true;
                    else
                        return false;
                    end
                end)
            end
        end
    end
    
    for suitId, info in pairs(ordered) do
        local activeInfo = {
            suitId = suitId,
            sortFlag = 0
        };
        activeInfo["list"] = {};
        local uuidList = activeInfo["list"];
        local list = {};
        for i = 1, 4 do
            if (info[i]) then
                local d = info[i][1]
                uuidList[i] = d;
                table.insert(list, d)
            end
        end
        local len = #list
        activeInfo.sortFlag = len * 10
        -- 两件套  按品质最高的两个中，低的那个激活属性
        if (len >= 2) then
            TableUtil.sortByMap(list, {{key = "color", asc = true}});
            local lostLv = list[2].color - 1;
            if (lostLv > 0) then
                activeInfo[2] = lostLv;
                activeInfo.sortFlag = 200 + len * 10 + lostLv;
            end
        end
        -- 四件套  按品质最低的那个激活属性
        if (len >= 4) then
            TableUtil.sortByMap(list, {{key = "color", asc = false}});
            local lostLv = list[1].color - 1;
            if (lostLv > 0) then
                activeInfo[4] = lostLv;
                activeInfo.sortFlag = 400 + len * 10 + lostLv;
            end
        end
        if (suggestMap[suitId]) then
            activeInfo.suggest = true;
            activeInfo.sortFlag = activeInfo.sortFlag + 1000;
        end
        table.insert(allSuit, activeInfo)
    end
    table.sort(allSuit, function (a, b)
        if (a.sortFlag ~= b.sortFlag) then
            return a.sortFlag > b.sortFlag;
        else
            return a.suitId < b.suitId;
        end
    end)
    return allSuit
end

-- 检测纹章能否升星
function EmblemModel:checkUpStarExp(emblem)
    if (not emblem) then return false end
    local upgradeCfg = DynamicConfigData.t_EmblemUpgrade
    local constCfg = DynamicConfigData.t_EmblemConst[1]
    local extraExp = emblem.exp or 0 -- 溢出的经验
    local needExp = upgradeCfg[emblem.color][emblem.star + 1] and upgradeCfg[emblem.color][emblem.star + 1]["needExp"] or false -- 升星需要的经验
    -- 没有下一星配置
    if (not needExp) then
        return false
    end
    local realNum = needExp - extraExp
    if (realNum == 0) then return false end
    local addExp = 0
    local material = constCfg.material
    -- 材料
    for _, c in pairs(material) do
        local num = ModelManager.PackModel:getPackByType(GameDef.BagType.Special):getAmountByCode(c.id) or 0
        addExp = addExp + num * c.exp
        if (addExp >= realNum) then
            return true;
        end
    end
    -- 纹章
    local emblems = self:getBag(false)
    for _, c in pairs(emblems) do
        local giveExp = upgradeCfg[c.color][c.star]["giveExp"] or 0
        local exp = giveExp + c.exp
        addExp = addExp + exp
        if (addExp >= realNum) then
            return true;
        end
    end
    return false
end

-- 根据uuid获取纹章数据
function EmblemModel:getEmblemByUuid(uuid)
    if (not uuid) then return false end;
    return self.__uuidMap[uuid];
end

-- 获取英雄的穿戴情况
function EmblemModel:getHeroEquiped(heroUuid)
    if (not heroUuid) then return {} end;
    return self.__heroEmblemMap[heroUuid] or {};
end


function EmblemModel:getHeroList()
    local heroList = CardLibModel:getHeroInfoToIndex();
    local sortMap = {{key="level",asc=true}, {key="star",asc=true},  {key="combat",asc=true},{key="code",asc=false}};
    TableUtil.sortByMap(heroList, sortMap)
    local list = {};
    for _, hero in pairs(heroList) do
        if (self:checkModelOpen(hero, false)) then
            table.insert(list, hero);
        end
    end
    return list;
end

-- 主界面入口是否开放
function EmblemModel:checkMainEnter()
    local allCards = CardLibModel:getAllCards()
    for _,info in pairs(allCards) do
        local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
        if (hero and self:checkModelOpen(hero, false)) then
            return true;
        end
    end
    return false;
end

function EmblemModel:checkModelOpen(hero, showTips)
    showTips = showTips == nil and true or false;
    local tips = ModuleUtil.getModuleOpenTips(ModuleId.EmblemView.id, hero.star)
    local str = tips and tips or ""
    -- 探员星级条件判断
    --local openConf = DynamicConfigData.t_module[ModuleId.EmblemView.id];-- 条件9为英雄星级  特殊处理
--    local limit = openConf and openConf.condition or {};
    --[[for _, info in ipairs(limit) do
        if (info.type == 12) then
            if (hero.star < info.val) then
                local s = string.format(Desc.Emblem_heroStarLimit, info.val)
                str = str == "" and str..s or str..Desc.moduleOpen_and..s;
                break;
            end
        end
    end--]]
    if (showTips and str ~= "") then
        RollTips.show(str..Desc.moduleOpen_tips0)
    end
    return str == ""
end

-- 红点检测
function EmblemModel:checkRedDot()
    GlobalUtil.delayCallOnce("EmblemModel:checkRedDot", function ()
        self:redCheck();
    end, self, 0.2)
end

function EmblemModel:redCheck()
    local allCards = CardLibModel:getAllCards()
    local battleHero = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
    local emblemConst = DynamicConfigData.t_EmblemConst[1].resetCost[1] -- 重铸消耗材料
    local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(emblemConst.id)
    for _,info in pairs(allCards) do
        local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
        if not hero then break end
        if self:checkModelOpen(hero, false) then -- 开启该功能
            if (not RedManager.getRedInfo("V_Emblem"..hero.uuid)) then
                local m = {}
                for i = 1, 4 do
                    table.insert(m, "V_Emblem"..hero.uuid..i);
                end
                RedManager.addMap("V_Emblem"..hero.uuid, m);
            end
            if battleHero.array[info.uuid] then
                local equiped = self:getHeroEquiped(hero.uuid);
                for i = 1, 4 do
                    local redStr = "V_Emblem"..hero.uuid..i
                    local emUuid = equiped[i];
                    local posList = self:getEmblemsByPos(i, false) or {};
                    if (not emUuid) then  -- 未镶嵌有可镶嵌
                        -- print(2233, "111111" ,redStr, #posList > 0)
                        RedManager.updateValue(redStr, #posList > 0);
                    else  -- 已镶嵌有同名更高品质 or 更高星级
                        local curEm = self:getEmblemByUuid(emUuid);
                        local flag = false;
                        for _, d in ipairs(posList) do
                            if (d.suitId == curEm.suitId) then
                                if (d.color > curEm.color) then
                                    flag = true;
                                    break;
                                elseif (d.color >= curEm.color and d.star > curEm.star) then
                                    flag = true;
                                    break;
                                end
                            end
                        end
                        if (curEm.category ~= 0 and curEm.category ~= hero.heroDataConfiger.category and curEm.color >= 6 and hasNum >= emblemConst.cout) then
                            flag = true;
                        end
                        -- if (self:checkUpStarExp(curEm)) then
                        --     flag = true
                        -- end
                        RedManager.updateValue(redStr, flag);
                    end
                end
            else
                local redInfo = RedManager.getRedInfo("V_Emblem"..hero.uuid)
                if (redInfo) then
                    for i = 1, 4 do
                        RedManager.updateValue("V_Emblem"..hero.uuid..i, false)
                    end
                end
            end
        end
        -- print(2233, "---------------------------");
    end
end

-- 探员改变
function EmblemModel:cardView_CardAddAndDeleInfo()
    self:getBag(true, true);
end

function EmblemModel:pack_emblem_change()
    GlobalUtil.delayCallOnce("EmblemModel:packemblemchange", function ()
        self:getBag();
    end, self, 0.2)
end

function EmblemModel:squadtomodify_change()
    self:checkRedDot();
end

-- 用富文本标记处套装激活的具体属性值
function EmblemModel:suitStrToRich(str, level, color) -- 这里传level对应的会高亮，不穿就只是去掉了[]
    -- str = "造成伤害时有[16/20/24/28/32]%概率降低目标[8/9/10/11/12]%速度，持续2回合"
    for word in string.gmatch(str, "%[[%d+./]+%]") do
        local num = {}
        for w in string.gmatch(word, "[%d.]+") do
            table.insert(num, w);
        end
        local s = "" -- 这是要替换的字符串
        local m = "%[" -- 这是用来匹配的字符串，因为word里面有 "[..]"所以自己再组一个用来匹配
        for i, n in ipairs(num) do
            if (i ~= 1) then
                m = m.."/"..n
                if (level and level == i) then
                    color = color and color or ColorUtil.textColorStr_Light.green
                    n = string.format("[color=%s]%s[/color]", color, n);
                end
                s = s.."/"..n
            else
                m = m..n
                if (level and level == i) then
                    color = color and color or ColorUtil.textColorStr_Light.green
                    n = string.format("[color=%s]%s[/color]", color, n);
                end
                s = s..n
            end
        end
        m = m.."%]"
        str = string.gsub(str, m, s, 1)
    end
    return str
end

function EmblemModel:Emblem_refreshBagInfo()
    self:getBag(false, true);
end

function EmblemModel:awardListResetEmblemData(reward)
    local conf = DynamicConfigData.t_item
    local i = 1;
    local len = TableUtil.GetTableLen(reward)
    -- 移除奖励列表是纹章类型28的
    while(i <= len) do
        local item = reward[i]
        if (item and not item.specialData and conf[item.code] and conf[item.code].type == 28) then
            -- 将另一个接口存储的纹章数据放入
            if (#self.rewardEmblemCache > 0) then
                local len = #self.rewardEmblemCache
                for j = len, 1, -1 do
                    local em = self.rewardEmblemCache[j];
                    if (em.code == item.code) then
                        em.type = 3
                        table.insert(reward, em)
                        table.remove(self.rewardEmblemCache, j);
                        item.amount = item.amount - 1;
                        break;
                    end
                end
                if item.amount == 0 then
                    table.remove(reward, i)
                end
            end
        else
            i = i + 1
        end
    end
    self.rewardEmblemCache = {};
    return reward;
end

function EmblemModel:Heraldry_NewItemInfo(_, params)
    table.insert(self.rewardEmblemCache, params.item)
end

return EmblemModel