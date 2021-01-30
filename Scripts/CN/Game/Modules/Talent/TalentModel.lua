-- add by zn
-- 特性

local TalentModel = class("TalentModel", BaseModel)

function TalentModel:ctor()
    -- self:initListeners()
end

-- 获取英雄的特性
function TalentModel:getHeroTalentInfo(hero)
    local equipInfo = hero.newPassiveSkill or {}
    local conf = DynamicConfigData.t_PassiveSkillOpen
    local heroStar = hero.star
    local gird = {}
    for i = 1, #conf do
        local c = conf[i]
		local skillId = equipInfo[i] and equipInfo[i].skillId or false
		skillId = (skillId and skillId ~= 0) and skillId or false -- 没有技能服务端会给0
		if skillId then
			gird[i] = {
				index = equipInfo[i] and equipInfo[i].index or false,
				skillId = skillId or false,
				state = skillId and 2 or 1 -- 2是已装备  1没装备
			}
		else
			if (heroStar < c.heroStar) then
				gird[i] = {
					star = c.heroStar,
					state = 0 -- 没解锁
				}
			else
				gird[i] = {
					skillId =  false,
					state = 1 -- 2是已装备  1没装备
				}
			end
		end
    end
    return gird
end

function TalentModel:checkModelOpen(hero, showTips)
    local tanlentInfo = self:getHeroTalentInfo(hero)
    local star = 0
    -- for i= 1,4 do
        if (tanlentInfo[1].state == 0) then
            star = tanlentInfo[1].star
        end
    -- end
    if (star ~= 0) then
        if (showTips) then
            RollTips.show(string.format(Desc.Talent_locked, star));
        end
        return false
    end
    return true
end

-- 学习特性
function TalentModel:learnTalent(hero, pos, skillId)
    local conf = DynamicConfigData.t_passiveSkill[skillId]
    if (conf) then
        if (ModelManager.PlayerModel:isCostEnough(conf.learnCost, true)) then
            local info = {
                uuid = hero.uuid,
                skillId = skillId,
                index = pos
            }
            local oldCombat = hero.combat
            RPCReq.Hero_NewLearnPassiveSkill(info, function(params)
                if (params.isAdd) then
                    local h = params.hero
                    local newOldCombat = h.combat
                    if (newOldCombat > oldCombat) then
                        RollTips.showAddFightPoint(newOldCombat - oldCombat)
                    end
                    CardLibModel:UpCardHeroAttr(params,2);
                    self:checkRed();
                    Dispatcher.dispatchEvent("cardView_activeSkillSuc", params, skillId)
                else
                    local count = hero.newPassiveSkillCount or 0
                    hero.newPassiveSkillCount = count + 1
                    Dispatcher.dispatchEvent("cardView_activeSkillFail")
                    RollTips.show(Desc.Talent_learnFail)
                end
            end)
        end
    end
end

-- 遗忘特性
function TalentModel:forgetTalent(heroUuid, pos)
    local conf = DynamicConfigData.t_PassiveConst[1]
    local cost = conf.passiveResetCost[1]
    if (not PlayerModel:checkCostEnough(cost, true)) then
        return;
    end
    local info = {
        uuid = heroUuid,
        index = pos
    }
    RPCReq.Hero_RemovePassiveSkill(info, function(params)
        CardLibModel:UpCardHeroAttr(params,2);
        self:checkRed();
        RollTips.show(Desc.Talent_forgetTalent)
    end)
end

function TalentModel:isLearnedTalent(hero, skillId)
    local equipInfo = hero.newPassiveSkill or {}
    for _, info in pairs(equipInfo) do
        if (info.skillId == skillId) then
            return true
        end
    end
    return false
end

function TalentModel:checkRed()
    local allCards = CardLibModel:getAllCards()
	local battleHero = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
	for _,info in pairs(allCards) do
		local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
        if hero and self:checkModelOpen(hero) then
            local isInBattleArray = battleHero.array[hero.uuid]
            for i = 1, 5 do
                local flag = false;
                if (isInBattleArray and self:haveBook(hero, i)) then
                    flag = true;
                end
                RedManager.updateValue("V_passiveSkill"..hero.uuid.."_"..i, flag)
			end
		end
	end
end

function TalentModel:haveBook(hero, pos)
    local equipInfo = self:getHeroTalentInfo(hero)
    if (not equipInfo[pos] or equipInfo[pos].state ~= 1) then
        return false
    end
    local openConf = DynamicConfigData.t_PassiveSkillOpen[pos]
    local typeList = {}
    for _, color in pairs(openConf.typeList) do
        typeList[color] = true
    end
    local talentList = {}
    local talentConf = DynamicConfigData.t_passiveSkill
    for _, conf in pairs(talentConf) do
        if (conf.learn == 1 and typeList[conf.quality] and not self:isLearnedTalent(hero, conf.id)) then
            table.insert(talentList, conf.learnCost)
        end
    end
    for _, cost in pairs(talentList) do
        if ModelManager.PlayerModel:isCostEnough(cost, false) then
            return true
        end
    end
    return false
end

return TalentModel