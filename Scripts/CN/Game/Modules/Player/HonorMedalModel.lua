-- add by zn
-- 荣誉勋章

local HonorMedalModel = class("HonorMedalModel", BaseModel)

function HonorMedalModel:ctor()
    self:initListeners()
    self.honorLevel = 0;
    self.equipedMedal = {};
end

function HonorMedalModel:GamePlay_UpdateData(_, params)
    if params.gamePlayType == GameDef.GamePlayType.HonorMedalWall then
        local data = params.gp.honorMedalWall
        self.honorLevel = data.honorCurLevel or 0;
        self.equipedMedal = data.loadAchievementMedal or {};
        self:checkRed()
        Dispatcher.dispatchEvent("HonorMedal_update", data);
	end
end

function HonorMedalModel:HonorMedalWall_InitData(_, params)
    local data = params.honorMedalWall
    if (data) then
        self.honorLevel = data.honorCurLevel or 0;
        self.equipedMedal = data.loadAchievementMedal or {};
        self:checkRed()
        Dispatcher.dispatchEvent("HonorMedal_update", data);
    end
end

function HonorMedalModel:upHonorLv()
    RPCReq.GamePlay_Modules_HonorMedalWall_Update({}, function(params)
        if (params.curLevel) then
            self.honorLevel = params.curLevel;
            self:checkRed()
            Dispatcher.dispatchEvent("HonorMedal_update");
        end
    end)
end

function HonorMedalModel:equipMedal(pos, code)
    local info = {
        posId = pos,
        itemCode = code
    }
    RPCReq.GamePlay_Modules_HonorMedalWall_Load(info, function(params)
        if (params.loadItemCode) then
            if code == 0 then
                self.equipedMedal[pos] = nil
            else
                self.equipedMedal[pos] = {
                    posId = pos,
                    itemCode = code
                }
            end
            self:checkRed()
            Dispatcher.dispatchEvent("HonorMedal_update");
        end
    end)
end

function HonorMedalModel:isEquiped(code)
    for _, d in pairs(self.equipedMedal) do
        if (d and d.itemCode == code) then
            return d.posId;
        end
    end
    return false;
end

function HonorMedalModel:isInBag(code)
    local bag = PackModel:getHonorMedalBag().__packItems;
    for _, d in pairs(bag) do
        if (d.__data.code == code) then
            return true;
        end
    end
    return false;
end

-- 1.获得的新勋章上有红点
-- 2.可晋升有红点
-- 3.有可装配勋章且有空位时
function HonorMedalModel:checkRed()
    
    local bag = PackModel:getHonorMedalBag().__packItems or {};
    local str = FileCacheManager.getStringForKey("HonorMedal_NewMedal", "");
    local arr = string.split(str, ",");
    local conf = DynamicConfigData.t_MedalOfAchievement;
    
    
    
    -- 2.
    local exp = 0
    local lv = 0
    for _, d in pairs(bag) do
        local code = d.__data.code;
        local c = conf[code];
        if (c) then
            exp = exp + c.point;
        end
    end
    for _, c in ipairs(DynamicConfigData.t_MedalOfHonor) do
        if (exp >= c.needPoint) then
            lv = c.id
        end
    end
    RedManager.updateValue("HonorMedal_Equip_0", self.honorLevel < lv);
    -- 3.
    local bagCount = TableUtil.GetTableLen(bag)
    local arr1 = {}
    for i = 1, 5 do
        if (not self.equipedMedal[i]) then
            -- RedManager.updateValue("HonorMedal_Equip_"..i, true);
            table.insert(arr1, i);
        else
            bagCount = bagCount - 1
            RedManager.updateValue("HonorMedal_Equip_"..i, false);
        end
    end
    local flag = bagCount > 0
    for _, idx in pairs(arr1) do
        RedManager.updateValue("HonorMedal_Equip_"..idx, flag);
    end

    -- 1. 
    for code in pairs(conf) do
        if (not TableUtil.Exist(arr, tostring(code)) and self:isInBag(code)) then
            RedManager.updateValue("HonorMedal_New_"..code, true);
            if (TableUtil.GetTableLen(self.equipedMedal) == 5) then -- 策划要装备满时，如果有新勋章，最后一个孔位要有红点 所以放最后判断 要强制修改标志
                RedManager.updateValue("HonorMedal_Equip_5", true);
            end
        else
            RedManager.updateValue("HonorMedal_New_"..code, false);
        end
    end
end

function HonorMedalModel:pack_HonorMedalWall_change()
    self:checkRed();
end

return HonorMedalModel