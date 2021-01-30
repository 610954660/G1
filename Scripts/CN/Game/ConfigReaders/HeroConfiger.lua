--背包配置读取器
local HeroConfiger = {}

local t_bag_config = nil
local skillActiveStep = false

function HeroConfiger.getHeroInfoByID(heroId)
	local heroInfo=DynamicConfigData.t_hero[heroId]
	if not  heroInfo then
		RollTips.show(heroId..DescAuto[1]) -- [1]="配表中不存在！"
		return false
	else
		return heroInfo
	end
end


function HeroConfiger.initHeroInfo(value)
	local heroCode = value.code
	local hero=DynamicConfigData.t_hero[heroCode]--读表的数据
	value["heroId"]=hero.heroId
	value['heroDataConfiger']=hero;
	if not value.attrs or TableUtil.isEmpty(value.attrs) then
		value.attrs = HeroConfiger.getHeroAttr(heroCode)
	end
	
	--如果服务端没传，就默认为空
	if not value.attrPointPlanNew or TableUtil.isEmpty(value.attrPointPlanNew) then
		value.attrPointPlanNew = {}
		for i=1,3 do
			local plan = {
				id = i,
				attrPointNum = 0,
				points = {},
			}
			value.attrPointPlanNew[i] = plan
		end
	end
end

function HeroConfiger.GetLevelRatio( level )
  local info = DynamicConfigData.t_Numerical[level]
  if not info then
    return 1
  end
  return info.numerical
end

function HeroConfiger.getHeroAttr(code)
	local heroConf = DynamicConfigData.t_hero[code]
	if not heroConf then
		return {}
	end

	local level = 1
	local stage = 0
	local star = heroConf.heroStar

	local stageRateField = "stageRate"..stage
	local stageRate = heroConf[stageRateField] or 1
	local levelRatio = HeroConfiger.GetLevelRatio(level)
	local starRatio = 0
	local attrRatio = level * (levelRatio + stageRate) + starRatio

	local newAttrs = {}
	local FightAttrType = GameDef.FightAttrType
	--气血
	local attrId = FightAttrType.hp
	local attrVal = heroConf.baseHp + heroConf.kHp * attrRatio
	newAttrs[attrId] = {id = attrId, value = attrVal}

	--物理攻击
	attrId = FightAttrType.attack
	attrVal = heroConf.baseDam + heroConf.kDam * attrRatio
	newAttrs[attrId] = {id = attrId, value = attrVal}

	--物理防御
	attrId = FightAttrType.defense
	attrVal = heroConf.baseDef + heroConf.kDef * attrRatio
	newAttrs[attrId] = {id = attrId, value = attrVal}

	--法术攻击
	attrId = FightAttrType.magic
	attrVal = heroConf.baseMagdam + heroConf.kMagdam * attrRatio
	newAttrs[attrId] = {id = attrId, value = attrVal}

	--法术防御
	attrId = FightAttrType.magicDefense
	attrVal = heroConf.baseMagdef + heroConf.kMagdef * attrRatio
	newAttrs[attrId] = {id = attrId, value = attrVal}

	--速度
	attrId = FightAttrType.speed
	attrVal = heroConf.baseSpeed + heroConf.kSpeed * attrRatio
	newAttrs[attrId] = {id = attrId, value = attrVal}

	for _, attrData in pairs(newAttrs) do
	attrData.value = math.floor(attrData.value)
	end

	return newAttrs
end

function HeroConfiger.getMaxCapacityByType(CardType)
	return DynamicConfigData.t_hero[CardType]
end

function HeroConfiger.getHeroInfoToDemoList(CardType)
	local temp={}
	for k, v in pairs(DynamicConfigData.t_hero) do
		temp[#temp+1]=v
	end 
	return temp
end

function HeroConfiger.getSkillList(heroId)
	local activeSkill=DynamicConfigData.t_hero[heroId].activeSkill
	return activeSkill
end

function HeroConfiger.getCardsByCategory(Category)
	print(4,DynamicConfigData.t_hero[Category],"test")
	return DynamicConfigData.t_hero[Category]
end

--获取第x个技能激活阶级
function HeroConfiger.getSkillActiveStep(index,level)
	if not level then level = 1 end
	if not skillActiveStep then
		skillActiveStep = {}
		for lv = 1,3,1 do 
			for step=0,10,1 do
				local info = DynamicConfigData.t_heroStage[step]
				for id = 1,4,1 do
					if not skillActiveStep[id] then skillActiveStep[id] = {} end
					if not skillActiveStep[id][lv] and info.skillLevel[id] == lv then
						skillActiveStep[id][lv] = info.HeroStage
					end
				end
			end
		end
	end
	
	return skillActiveStep[index] and skillActiveStep[index][level] or 0
end

--根据阶级获取当前的技能列表
function HeroConfiger:getSkillListByStep(step, hero)
	local skillArr={}
	local skillLevel= DynamicConfigData.t_heroStage[step]
	if skillLevel==nil then
		return skillArr
	end
	local skillLevelArr=skillLevel.skillLevel
	for i = 1, 4 do
		local level=skillLevelArr[i];
		local activeLevel = HeroConfiger.getSkillActiveStep(i)
		if level == 0 then
			level = 1 --如果还没激活的，拿第一个
		end
		local key ='skill'..i
		--如果没有更高级的技能，显示最后一个
		if level > #hero.heroDataConfiger[key] then
			level = #hero.heroDataConfiger[key]
		end
		local skillId =hero.heroDataConfiger[key][level]
		if skillId then
			table.insert( skillArr, {skillId = skillId, activeLevel = activeLevel, level = level})
		end
	end

	return skillArr;
end

function HeroConfiger.getNextLevelLimit(step, level)
	local conf = DynamicConfigData.t_heroLevel
	local maxLevel = #conf
	local limit = math.floor(maxLevel / 2);
	step = math.min(11, step);
	local c = conf[limit]
	local count = 0;
	while(c.stageLimit ~= step) do
		if (c.stageLimit > step) then
			maxLevel = limit;
			limit = math.floor(maxLevel / 2);
		elseif (c.stageLimit < step) then
			limit = math.floor((maxLevel + limit) / 2);
		end
		c = conf[limit]

		count = count + 1 -- 防止死循环
		if (count > 10) then
			break;
		end
	end
	for lv = limit + 1, maxLevel,1 do 
		local info = conf[lv]
		if info and info.stageLimit > step then break end;
		limit = lv
	end
	return limit
end


--计算属性战力
--@items 英雄id
function HeroConfiger.CaleAttrPowerById(id)
	local config = DynamicConfigData.t_hero[id]
	if not config then
		return 0
	end
	return HeroConfiger.CaleAttrPower(config)
end

--计算属性战力
--@items 在外面定好属性结构
function HeroConfiger.CaleAttrPower(items)
	if not items then
		return 0
	end
	local FightAttrType = GameDef.FightAttrType
	local newAttrs ={}
	local power = 0 
	--气血
	local attrId = FightAttrType.hp
	local attrVal = items.hp or items.baseHp or items[1] or 0
	newAttrs[attrId] = {id = attrId, value = attrVal}

	--物理攻击
	attrId = FightAttrType.attack
	attrVal = items.attack or items.baseDam or items[2] or 0
	newAttrs[attrId] = {id = attrId, value = attrVal}

	--物理防御
	attrId = FightAttrType.defense
	attrVal = items.defense or items.baseDef or items[3] or 0
	newAttrs[attrId] = {id = attrId, value = attrVal}

	--法术攻击
	attrId = FightAttrType.magic
	attrVal = items.magic or items.baseMagdam or items[4] or 0
	newAttrs[attrId] = {id = attrId, value = attrVal}

	--法术防御
	attrId = FightAttrType.magicDefense
	attrVal = items.magicDefense or items.baseMagdef or items[5] or 0
	newAttrs[attrId] = {id = attrId, value = attrVal}

	--速度
	attrId = FightAttrType.speed
	attrVal =items.speed or items.baseSpeed or items[6] or 0
	newAttrs[attrId] = {id = attrId, value = attrVal}

	for k, v in pairs(newAttrs) do 
		local param = HeroConfiger.GetAttrCombatParam(v.id)
		power = power + v.value * param / 100
	end
	power = math.floor(power)
	return power
end
--计算技能战力
--@skills {id,id,id}
function HeroConfiger.CaleSkillPower(skills)
	local power = 0 
	for k, v in pairs(skills) do 
		local skillConf = HeroConfiger.GetPassiveSkillConf(v)
		if skillConf and skillConf.power > 0 then 
			power = power + skillConf.power
		end
	end
	power = math.floor(power)
	return power
end

function HeroConfiger.GetAttrCombatParam( attrId )
	local param = 0
	if not attrId then
		return param
	end
	local config = DynamicConfigData.t_combat[attrId]
	if config then
		param = config.combatParam
	end
	return param
end

--获取被动技能配置
function HeroConfiger.GetPassiveSkillConf(id)
	return DynamicConfigData.t_passiveSkill[id]
end

--获取重置可得到的材料
function HeroConfiger.getHeroResetReward(uuid)
	local getHero = {}
	local getItem = {}
	local getItemMap = {}
	
	local addHero = function(heroId, star)
		table.insert(getHero, {heroId = heroId, heroStar = star, level = 1})
	end
	
	local addItem = function(type, code, amount)
		if not getItemMap[code] then
			getItemMap[code] = {type = type, code = code, amount = amount}
			table.insert(getItem, getItemMap[code])
		else
			getItemMap[code].amount = getItemMap[code].amount + amount
		end
		
	end
	
	local info = ModelManager.CardLibModel:getHeroByUid(uuid)
	if not info then return {},{} end
	addHero(info.heroId, info.star)
	
	--[[for _,v in pairs(info.equipmentMap) do
		addItem(CodeType.ITEM, v.code, 1)
	end
	
	for _,v in pairs(info.jewelryMap) do
		if v.code then
			addItem(CodeType.ITEM, v.code, 1)
		end
	end--]]
	local level = info.level
	local step = info.stage
	local star = info.star
	local uniqueWeaponId = info.uniqueEwapon and  info.uniqueEwapon.id or -1
	local uniqueWeaponLevel = info.uniqueEwapon and  info.uniqueEwapon.level or -1
	--if level > 200 then level = 200 end --最高是200级
	if level > 0 then
		for i = level,2,-1 do
			local levelInfo = DynamicConfigData.t_heroLevel[i]
			addItem(levelInfo.type1, levelInfo.code1,levelInfo.amount1)
			addItem(levelInfo.type2, levelInfo.code2,levelInfo.amount2)
		end
	end
	
	if step > 0 then
		for i = step,1,-1 do
			local costList = DynamicConfigData.t_heroStage[i].costList
			for _,v in ipairs(costList) do
				addItem(v.type, v.code,v.amount)
			end
		end
	end
	
	if uniqueWeaponId > 0 and uniqueWeaponLevel >= 0 then
		local config = DynamicConfigData.t_UniqueWeaponConfig[uniqueWeaponId]
		for i = uniqueWeaponLevel,0,-1 do
			local costList = config[i].cost
			for _,v in ipairs(costList) do
				addItem(v.type, v.code,v.amount)
			end
		end	
	end
	
	--[[local passiveSkill = info.passiveSkill
	for _,v in pairs(passiveSkill) do
		local skillInfo = DynamicConfigData.t_passiveSkill[v.id]
		for _,cost in pairs(skillInfo.activeCost) do 
			addItem(cost.type, cost.code, cost.amount)
		end
		for _,cost in pairs(skillInfo.activeMoneyCost) do 
			addItem(cost.type, cost.code, cost.amount)
		end
	end--]]
	
	
	--[[if star > 5 then
		for i = star - 1,1,-1 do
			local starInfo = DynamicConfigData.t_heroStar[1][i]
			if starInfo then
				addItem(starInfo.material[1].type, starInfo.material[1].code,starInfo.material[1].amount)
				if #starInfo.self > 0 then
					for k=1,starInfo.self[1].num,1 do
						addHero(info.heroId, starInfo.self[1].star)
					end
				end
			end
		end
	end--]]
	
	return getHero,getItem
end


--获取连升5级的消耗
function HeroConfiger.getQuickUpgradeCost(level, upLvNum)
	local costList = {}
	for i=1,upLvNum,1 do
		local heroLeveInfo = DynamicConfigData.t_heroLevel[level + i]
		if(heroLeveInfo) then
			ItemsUtil.addCost(costList, {type = heroLeveInfo.type1, code = heroLeveInfo.code1, amount = heroLeveInfo.amount1})
			ItemsUtil.addCost(costList, {type = heroLeveInfo.type2, code = heroLeveInfo.code2, amount = heroLeveInfo.amount2})
		end
	end
	return costList
end





return HeroConfiger

