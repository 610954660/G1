
-- 装备升星活动
-- add by zn

local EquipUpStarModel = class("EquipUpStarModel", BaseModel)

function EquipUpStarModel:ctor()
    self.selected1 = false; -- 橙装选择
    self.selected2 = false; -- 红装选择
    self:initListeners();
end

-- 活动结束处理
function EquipUpStarModel:Activity_UpdateData( _, params)
	if params.type ~= GameDef.ActivityType.EquipUpStar then
		return
	end
	if params.endState then --如果是true 直接结束
		ModelManager.ActivityModel:speDeleteSeverData(params.type)
	end
end

function EquipUpStarModel:selectEquip(type, equipInfo)
    self["selected"..type] = equipInfo;
    Dispatcher.dispatchEvent("EquipUpStarView_upPanel", type);
end

-- 脱装
function EquipUpStarModel:unEquip(equipInfo, cb)
    if (equipInfo and equipInfo.heroUuid) then
        local info = {
            type = 0,
            pos = equipInfo.id,
            heroUuid = equipInfo.heroUuid
        }
        RPCReq.Equipment_TakeOff(info, function(args)
            if args.isSuccess then
                local downEquip = args.list[1]
                EquipmentModel:upBagEquip(downEquip)
                EquipmentModel:setSkillData(downEquip.uuid, downEquip)
                EquipmentModel:updateWearEqList(args.pos, nil, equipInfo.heroUuid)
                equipInfo.uuid = downEquip.uuid;
                equipInfo.heroUuid = nil;
            end
            if (cb) then
                cb(equipInfo);
            end
        end, function (err)
            if (cb) then
                cb(equipInfo);
            end
        end)
    end
end

-- 升星
function EquipUpStarModel:upStar(type, equipInfo)
    if (equipInfo and equipInfo.uuid) then
        local conf = DynamicConfigData.t_EquipExchangeActivity[equipInfo.code];
        if (not PlayerModel:isCostEnough(conf.costItem, true)) then
            return;
        end
        local info = {
            uuid = equipInfo.uuid,
            heroUuid = equipInfo.heroUuid or ""
        }
        RPCReq.Activity_EquipUpStar_Exchange(info, function (param)
            printTable(2233, "=========== 装备升星", param)
            local uuid = param.uuid;
            local skill = equipInfo.skill;
            EquipmentModel:setSkillData(uuid, {skill = skill})
            self["selected"..type] = false;
            Dispatcher.dispatchEvent("EquipUpStarView_upPanel", type)
        end)
    end
end

-- 获取对应装备列表
function EquipUpStarModel:getEquipList(type)
    local color = 4--type == 1 and 5 or 6;
    local allEq = {};
    local eqConf = DynamicConfigData.t_equipEquipment;
    local activeConf = DynamicConfigData.t_EquipExchangeActivity;
    -- 所有英雄身上的穿戴
    local wearList = EquipmentModel:getWearEqList();
    for herouuid, eqList in pairs(wearList) do
        for i, eqData in pairs(eqList) do
            local c = eqData and eqConf[eqData.code] or nil
            if (c and c.color >= color and activeConf[eqData.code]) then
                local d = {
                    code = eqData.code,
                    id = eqData.id,
                    skill = eqData.skill,
                    uuid = eqData.uuid,
                    heroUuid = herouuid
                }
                table.insert(allEq, d);
            end
        end
    end
    -- 背包内的
    local bagList = EquipmentModel:getEquipBag().__packItems;
    for _, itemdata in pairs(bagList) do
        local data = itemdata:getData();
        if (itemdata:getColorId() >= color and activeConf[data.code]) then
            local uuid = itemdata:getUuid();
            local skillInfo = EquipmentModel:getSkillData(uuid)
            local skill = skillInfo and skillInfo.skill or nil;
            local d = {
                code = data.code,
                id = itemdata:getItemId(),
                skill = skill,
                uuid = uuid,
                heroUuid = false,
            }
            table.insert(allEq, d);
        end
    end
    return allEq;
end

return EquipUpStarModel;