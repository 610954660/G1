
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
local Cache = _G.Cache
local MATH_FLOOR = math.floor
local handle=false
local BaseModel = require "Game.FMVC.Core.BaseModel"
local CardLibModel = class("CardLibModel",BaseModel)

CardLibModel.heroProperty =
{
	HP=0,    --气血
    AD=1,    --物理点数法术
	AP=2,    --法术伤害点
	DEF=3,   --物理防御
	MagDef=4,--法术防御
	Speed=5, --速度属性点
}

function CardLibModel:ctor()
	
end
function CardLibModel:init()
	print(4,"CardLibModel:init")
	self.__learnedSkills = {}   --玩家已经学习的所有技能
	self.__posSkills = {} --同个pos的Table

	handle = true  --cd计时器
	self.__countDownSkills = {} --正在冷却中的技能或者物品
	self.__normalAttackHandle = false
	self.__waitToUseSkill = false  --自动施法时点击的技能
	self.__autoReleaseSkills = {}  --自动释放的技能
	self.__normalSkillIndex = 1
	self.__normalSkillIds = {}

	self.__isTransforming = false
	
	
	self.__cardByPos = {}  --根据位置索引的当前面板技能信息
	self.__CardsCategory=false
	self.__cardsIndex=1
	self.__cardAttrAdd={};
	self.categoryCardNum=0;       
	self.__heroId=-1
	
	self.cardListShow = false -- 当前显示的卡牌列表
	--self.__heroInfos=DynamicConfigData.t_hero--玩家所有的手牌，目前读表取全部
	self.__heroInfos={}----玩家所有的手牌
	self.cardAttrName={[1]=Desc.card_attrName_1,[2]=Desc.card_attrName_2,[3]=Desc.card_attrName_3,[4]=Desc.card_attrName_4,[5]=Desc.card_attrName_5,[6]=Desc.card_attrName_6,[7]=Desc.card_attrName_7}
	self.cardStepAddAttr={[1]=156,[2]=78,[3]=78,[4]=39,[5]=39,[6]=39,[7]=0}
	self.curCardStepInfo=false;
	self.curCardStarUpChoose={};--升星选择数据
	self.baseAttr={[1]='baseHp',[2]='baseDam',[3]='baseDef',[4]='baseMagdam',[5]='baseMagdef',[6]='baseSpeed'}
	self.growthAttr={[1]='kHp',[2]='kDam',[3]='kDef',[4]='kMagdam',[5]='kMagdef',[6]='kSpeed'}
	self.curSkillActiveChoose={};--技能激活选择数据
	self.cardDecomPoseData={};--卡牌分解
	self.cardDecomPoseDataChoose={};--卡牌分解选中数据
	self.cardDecomPoseSetting=0;
	self.maxCombat = 0;
	
	self.cardBagCategory = 0
	
	self.freeResetHeroTimes = 0 --英雄重置免费次数
	self.cardfight =  0
	self.dataInited = false --登陆时是否拿完英雄信息了

	self.quickCardStarUpInfo = false -- 当前快捷升星卡牌
	self.quickCardStarUpChoose = {} -- 快捷升星选择数据
	self.lastCurCardStarUpSelectIndex = 1 -- 打开快捷升星界面时选择的材料index
	self.bOpenCardChooseView = false -- 是否打开了材料选择界面
	self.lastCategory = 0 -- 上次打开的材料选择界面所选分类
	self.quickCardStarUpMap = {} -- 快捷升星后的英雄map
	self.cardTalentLearnMap = {} -- 特性学习显示位置记录

	self.cardResetTheData={};--卡牌转换
	self.cardResetChooseA=false;--A卡牌
	self.cardResetmateriChoose={};--卡牌转换材料选择
end

function CardLibModel:setReward(arg1,arg2)
	local rewardInfo={}
	for key, value in pairs(arg1) do
		table.insert( rewardInfo, value)
	end
	for key, value in pairs(arg2) do
		table.insert( rewardInfo, value)
	end
 return	self:getReward(rewardInfo,1);
end

function CardLibModel:setRewardList(rewardInfo,arg1)
	for key, value in pairs(arg1) do
		table.insert( rewardInfo, value)
	end
	return rewardInfo;
end

--获取当前卡牌信息显示的卡牌
function CardLibModel:getCurShowCard()
	self._cardcgInfo = ModelManager.CardLibModel:getHeroInfoToIndex()
	local indexID = ModelManager.CardLibModel:getCarIndex()
	return self._cardcgInfo[indexID]
end

function CardLibModel:getReward(outputMaterial,multiple)
	local rewardInfo = {}
	for k, v in pairs(outputMaterial) do
		local amount = rewardInfo[v.type .. "_" .. v.code]
		if amount == nil then
			amount = 0
		end
		amount = amount + outputMaterial[k].amount * multiple
		rewardInfo[v.type .. "_" .. v.code] = amount
	end
	local rewardData = {}
	for k, v in pairs(rewardInfo) do
		local reward = {}
		local offset = string.split(k, "_")
		reward["type"] = tonumber(offset[1])
		reward["code"] = tonumber(offset[2])
		reward["amount"] = v
		table.insert(rewardData, reward)
	end
	return rewardData;
end

function CardLibModel:getReward1(outputMaterial,multiple)
	if not outputMaterial then return {} end
	local rewardInfo = {}
	local rewardData = {}
			for k, v in pairs(outputMaterial) do
				if v.type==2 then
					local amount = rewardInfo[v.type .. "_" .. v.code]
					if amount == nil then
						amount = 0
					end
					amount = amount + outputMaterial[k].amount * multiple
					rewardInfo[v.type .. "_" .. v.code] = amount
				else
					table.insert(rewardData, v) 
				end
			end
	for k, v in pairs(rewardInfo) do
		local reward = {}
		local offset = string.split(k, "_")
		reward["type"] = tonumber(offset[1])
		reward["code"] = tonumber(offset[2])
		reward["amount"] = v
		table.insert(rewardData, reward)
	end
	return  rewardData;
end

function CardLibModel:getCardDebrisDecomInfo()
	local temp = ModelManager.PackModel:getHeroCompBag():sort_bagDatas()
	table.sort(temp,function(a,b)
		if a.__data.amount==b.__data.amount then
			return a.__data.code <b.__data.code;
		else
			return a.__data.amount <b.__data.amount
		end
	end)
	return temp;
end

function CardLibModel:setCardAutoDecom(info)
	if info and info ~=0 then
		self.cardDecomPoseSetting=info
	else
		self.cardDecomPoseSetting=0;
	end
end

function CardLibModel:clearCardDecom()
	self.cardDecomPoseDataChoose={};
end

function CardLibModel:getCardDecom()
	local includeBattle = true
	local temp={}
	local battle=ModelManager.BattleModel:getArrayInfo();
	local hasBattle=false;
	if battle then
		 hasBattle=battle.array;
		 printTable(8,'>>>>>>>>>>>>>>>>>',hasBattle)
	end
	for k, v in pairs(self.cardDecomPoseData) do
		if includeBattle or (hasBattle and hasBattle[k]==nil)  then
			v['hasBattle'] = (hasBattle and hasBattle[k]~=nil) and 1 or 0
			if v.star < 6 then
				temp[#temp+1]=v
			end
		end
	end
	--[[table.sort(temp,function(a,b)
		if a.star==b.star then
			return a.level <b.level;
		else
			return a.star<b.star
		end
	end)--]]
	TableUtil.sortByMap(temp, {{key="hasBattle",asc=false} ,{key="level",asc=false} ,{key="star",asc=false},{key="code",asc=false} })
	return temp;
end

--获取某种族的卡牌
function CardLibModel:getCardByCategory(Category, excluedUuids, minStar, minLevel,starTypeFlag)
	if not minStar then minStar = 0 end
	if not minLevel then minLevel = 0 end
	if not excluedUuids then excluedUuids = {} end
	local result={};
	local excluedUuidsMap = {}
	--把excluedUuids改成map形式，避免每次都要遍历(不确定是否传进来的都已经是map)
	for _,uuid in pairs(excluedUuids) do
		excluedUuidsMap[uuid] = uuid
	end
	
	for key, value in pairs(self.__heroInfos) do
		if  Category==0  or Category== key then
			for k, v in pairs(value) do
				local notInclude = true
				if not excluedUuidsMap[v.uuid] then
					local star = starTypeFlag and v.heroDataConfiger.heroStar or v.star
					if star >= minStar and v.level >= minLevel then
						table.insert(result, v)
					end
				end
			end
		end
	end
	return result
end

--检测卡牌中存在超过100级的英雄
function CardLibModel:checkLeveltoLevel(excluedUuids,minLevel )
	for key, value in pairs(self.__heroInfos) do
		for k, v in pairs(value) do
			local notInclude = true
			for _,uuid in pairs(excluedUuids) do
				if uuid == v.uuid then notInclude = false end
			end
			if notInclude then
				if v.level >= minLevel then
					return true
				end
			end
		end
	end
	return false
end
--卡牌转换
function CardLibModel:setCardResetInfo(Category)
	local min=0
	local max=0
	local idex=0
	local configInfo= DynamicConfigData.t_HighStarExchange
	for key, value in pairs(configInfo) do
		idex=idex+1
		if idex==1 then
			min= tonumber(key)
		end
		if tonumber(key)>max then
			max=tonumber(key)
		end
		if tonumber(key)<min then
			min=tonumber(key)
		end
	end
	self.cardResetTheData={};
	if  Category==0 then
		for key, value in pairs(self.__heroInfos) do
			for k, v in pairs(value) do
				if v.star<=max and v.star>=min then
					self.cardResetTheData[k]=v;
				end
			end
		end
	else
		if self.__heroInfos[Category] then
			for key, value in pairs(self.__heroInfos[Category]) do
				if value.star<=max and value.star>=min then
					self.cardResetTheData[key]=value;
				end
			end
		 else
			self.cardResetTheData={}
		 end
	end
end

function CardLibModel:getCardResetChooseA()--A卡牌
	return self.cardResetChooseA
end

function CardLibModel:clearCardResetChooseA()
	self.cardResetChooseA=false
end

function CardLibModel:clearCardResetAllData()
	self.cardResetTheData = {} --卡牌转换
	self:clearCardResetChooseA()
	self:clearCardResetmateriChoose()
end

function CardLibModel:setCardResetmateriChoose(uuid,cardData)
	self.cardResetmateriChoose[uuid]=cardData;--卡牌转换材料选择
end

function CardLibModel:getCardResetmateriChoose()
	return self.cardResetmateriChoose
end

function CardLibModel:getCardResetmateriSucCard(uuidB)
	for key, value in pairs(self.__heroInfos) do
		for k, v in pairs(value) do
			if k==uuidB then
				return v
			end
		end
	end
return false
end

function CardLibModel:getCardResetmateriisSameName(cardData)--是否是同种卡牌
	local synonym=false
	local materInfo= self:getCarResetmateriChooseItemInfo()
	if not materInfo then
		synonym=true
	end
	if materInfo and  materInfo.code==cardData.code then
		synonym=true
	end
	return synonym
end

function CardLibModel:getCarResetmateriChooseItemInfo()
	local info=false
	 local num= self:getCardResetmateriChooseNum()
	 if num then
		local id=0
			for key, value in pairs(self.cardResetmateriChoose) do
				id=id+1
				if id==1 then
					info=value
					break
				end
			end 
	 end
	 return info
end

function CardLibModel:getCardResetmateriChooseNum()
	local info=self.cardResetmateriChoose;
	local num=0;
	if info then
		for k ,value in pairs(info) do
			num=num+1
		end 
	end
	return num;
end

function CardLibModel:clearCardResetmateriChoose()
	self.cardResetmateriChoose={}
end

function CardLibModel:getCardResetmateriChooseList(code)
	local temp = {}
	local configInfo=DynamicConfigData.t_hero
	local category=configInfo[code].category
	if self.__heroInfos[category] then
		for key, value in pairs(self.__heroInfos[category]) do
			local isTure=configInfo[value.code].trueFive
			if value.code~=code and value.star==5 and isTure==1  then
				temp[#temp + 1] = value
			end
		end
	 else
		temp={}
	 end
	 TableUtil.sortByMap(temp, {{key="code",asc=false},{key="level",asc=true},{key="combat",asc=true}})
	 return temp
end

--卡牌转换列表
function CardLibModel:getCardResetInfo()
	local includeBattle = true
	local temp={}
	local battle=ModelManager.BattleModel:getArrayInfo();
	local hasBattle=false;
	if battle then
		 hasBattle=battle.array;
	end
	for k, v in pairs(self.cardResetTheData) do
		if includeBattle or (hasBattle and hasBattle[k]==nil)  then
			v["hasBattle"] = (hasBattle and hasBattle[k]~=nil) and 1 or 0
			temp[#temp+1]=v
		end
	end
	self:starSort(temp)
	--TableUtil.sortByMap(temp, {{key="hasBattle",asc=false} ,{key="level",asc=false} ,{key="star",asc=false},{key="code",asc=false} })
	return temp;
end


function CardLibModel:setCardDecom(Category)
	self.cardDecomPoseData={};
	if  Category==0 then
		for key, value in pairs(self.__heroInfos) do
			for k, v in pairs(value) do
				self.cardDecomPoseData[k]=v;
			end
		end
	else
		if self.__heroInfos[Category] then
			self.cardDecomPoseData=self.__heroInfos[Category]
		 else
			self.cardDecomPoseData={}
		 end
	end
end

function CardLibModel:checkHeroCardNew( code,Category )
	if self.__heroInfos[Category] and #self.__heroInfos[Category]>0  then
        for k,v in pairs(self.__heroInfos[Category]) do
        	if v.code == code then
        		return true
        	end
        end
	end
	return false
end

function CardLibModel:clearSkillActiveChoose()
	self.curSkillActiveChoose={};
end

function CardLibModel:getSkillActiveChooseNum()
	local info=ModelManager.CardLibModel.curSkillActiveChoose;
	local num=0;
	if info then
		for k ,value in pairs(info) do
			num=num+1
		end 
	end
	return num;
end

function  CardLibModel:getActiveSkillCards(needCard)
	local chooseList={};
	printTable(8,"卡牌出战数据",needCard)
	local NeedId=needCard[1].heroCode;
	local heroItem=DynamicConfigData.t_hero[NeedId]
	local category=heroItem.category;
	local uidList=self.__heroInfos[category]
	if uidList==nil then
		return chooseList
	end
	local battle=ModelManager.BattleModel:getArrayInfo();
	local hasBattle={};
	if battle then
		 hasBattle=battle.array;
	end
	local heroInfo= ModelManager.CardLibModel.curCardStepInfo;
	for uid, groupInfos in pairs(uidList) do
		if groupInfos.code==NeedId and hasBattle[uid]==nil and heroInfo.uuid ~=uid then
			chooseList[#chooseList+1]=groupInfos;
		end
	end
	return chooseList;
end

function CardLibModel:getCardHaveHeroId()
	local heroId={}
	for key, value in pairs(self.__heroInfos) do
		if value then
			local uidList=value;
			for uid, info in pairs(uidList) do
				heroId[info.code]=info.code;
			end
		end
	end
	return heroId;
end

--面板属性：基础属性 + 等级*成长*进阶系数 + 加点属性 + 装备属性 + 技能属性
function CardLibModel:getCardAllAttrInfo(cardInfo,level,step, star,isAddShow)
	if  isAddShow==nil then
		isAddShow=true
	end
	local newAttr={};
	local heroId=cardInfo.code;
	local baseInfo=DynamicConfigData.t_hero[heroId];
	local starPointAdd = DynamicConfigData.t_StrarRare;
	for key, value in pairs(self.baseAttr) do
		newAttr[key]=(baseInfo[value])+ (baseInfo[self.growthAttr[key]] ) *(baseInfo['stageRate'..step])*level +  (baseInfo[self.growthAttr[key]] )* starPointAdd[baseInfo.pointId][star].numerical
	end
	if isAddShow then
		local attrPointAdd =DynamicConfigData.t_heroAttrPoint;
		for k, v in pairs(cardInfo.attrPointPlanNew[cardInfo.attrPointId].points) do
			newAttr[v.type]=newAttr[v.type]+(attrPointAdd[baseInfo.pointId][v.type].attrValue*v.num)
		end
	end
	
	--[[for k, v in pairs(newAttr) do
		newAttr[k]=newAttr[k]+ math.round(starPointAdd[baseInfo.pointId][star].numerical*v/100)
	end--]]
	for j, k in pairs(newAttr) do
		newAttr[j]=math.floor(newAttr[j]);
	end
	--printTable(5,'>>>>>>>>>>>基础属性1',newAttr,cardInfo,level,step)
	return newAttr;
end


function CardLibModel:getCurStarIcon(star)
	local starImg='1';
	local numStar=1;
	if star<=5 then
		starImg='1'
		numStar=star;
	elseif star>5 and star<=8 then
		starImg='2'
		numStar=star-5;
	elseif star>8 and star<=11 then
		starImg='3';
		numStar=star-8;
	elseif star>11 and star<=14 then
		starImg='4'
		numStar=star-11;
	elseif star>14 and star<=17 then
		starImg='5'
		numStar=star-14;
	elseif star>17 then
		starImg='6'
		numStar=star-17;
	end
	return starImg,numStar
end
-- 匹配颜色,换行处理
function CardLibModel:parstrStr(str)
	return  string.gsub(str,'<br>','\n');
end

function CardLibModel:clearupStarInfo()
	self.curCardStarUpChoose={};
end

--达到x星的卡牌是否够
function CardLibModel:isStarHeroEnough(star,needNum)
	if not needNum then needNum = 0 end
	local num = 0
	local allCard = self:getAllCards()
	for _,v in ipairs(allCard) do
		if v.star >= star then
			num = num + 1
			if num >= needNum then
				return true
			end
		end
	end
	return false;
end

function CardLibModel:getStarMaterialsNum(mType)
	local info=ModelManager.CardLibModel.curCardStarUpChoose;
	--printTable(5,'>>>>>>>>>>>',info)
	local num=0;
	if info and info[mType]  then
		for k ,value in pairs(info[mType]) do
			num=num+1
		end 
	end
	return num;
end

-- 检测是否是当前已经选择的升星材料
function CardLibModel:isCurCardStarUpChoose(type, data)
	self.curCardStarUpChoose[type] = self.curCardStarUpChoose[type] or {};
	local info = self.curCardStarUpChoose[type];
	for _, value in ipairs(info) do
		if (data.uuid) then
			if (data.uuid == value.uuid) then
				return true;
			end
		elseif (data.code and data.idx == value.idx) then
			return true
		end
	end
	return false;
end

-- 添加选择升星材料
function CardLibModel:addCurCardStarUpChoose(type1, data)
	
	self.curCardStarUpChoose[type1] = self.curCardStarUpChoose[type1] or {};
	local info = self.curCardStarUpChoose[type1];
	for _,v in ipairs(data) do
		if not (self:isCurCardStarUpChoose(type1, v)) then
			table.insert(info, v);
		end
	end
	return true;
end

-- 移除选择升星材料
function CardLibModel:removeCurCardStarUpChoose(type, data)
	self.curCardStarUpChoose[type] = self.curCardStarUpChoose[type] or {};
	local info = self.curCardStarUpChoose[type];
	for idx, value in ipairs(info) do
		if (data.uuid) then
			if (data.uuid == value.uuid) then
				table.remove(info, idx);
				return true;
			end
		elseif (data.code and data.idx == value.idx) then
			table.remove(info, idx);
			return true;
		end
	end
	return false;
end

-- 清除快捷升星材料选择信息
function CardLibModel:clearupQuickStarUpInfo()
	self.quickCardStarUpChoose = {}
end

function CardLibModel:getQuickStarUpMaterialsNum(mType)
	local info = self.quickCardStarUpChoose
	local num = 0
	if info and info[mType] then
		for k ,value in pairs(info[mType]) do
			num = num + 1
		end
	end
	return num
end

-- 检测是否是当前已经选择的快捷升星材料
function CardLibModel:isQuickCardStarUpChoose(type, data)
	self.quickCardStarUpChoose[type] = self.quickCardStarUpChoose[type] or {};
	local info = self.quickCardStarUpChoose[type];
	for _, value in ipairs(info) do
		if (data.uuid) then
			if (data.uuid == value.uuid) then
				return true;
			end
		elseif (data.code and data.idx == value.idx) then
			return true
		end
	end
	return false;
end

-- 添加快捷升星选择材料
function CardLibModel:addQuickCardStarUpChoose(type1, data)
	
	self.quickCardStarUpChoose[type1] = self.quickCardStarUpChoose[type1] or {};
	local info = self.quickCardStarUpChoose[type1];
	for _,v in ipairs(data) do
		if not (self:isCurCardStarUpChoose(type1, v)) then
			table.insert(info, v);
		end
	end
	return true;
end

-- 移除快捷升星选择材料
function CardLibModel:removeQuickCardStarUpChoose(type, data)
	self.quickCardStarUpChoose[type] = self.quickCardStarUpChoose[type] or {};
	local info = self.quickCardStarUpChoose[type];
	for idx, value in ipairs(info) do
		if (data.uuid) then
			if (data.uuid == value.uuid) then
				table.remove(info, idx);
				return true;
			end
		elseif (data.code and data.idx == value.idx) then
			table.remove(info, idx);
			return true;
		end
	end
	return false;
end

-- 清除快捷升星英雄记录
function CardLibModel:clearQuickCardStarUpMap()
	self.quickCardStarUpMap = {}
end

-- 是否快捷升星英雄
function CardLibModel:isQuickCardStarUpHero(uuid)
	if self.quickCardStarUpMap[uuid] then
		return true
	end
	return false
end

function CardLibModel:getLearnSkillCanChooseInfo(temp)
	local chooseList={};
	local heroCode=temp[1].heroCode;
	local info = DynamicConfigData.t_hero
    local heroItem = info[heroCode]
	
	local star=temp[1].star;
	local hasChooseList= self:cardHasChooseInOther(temp[3])
	local cardQuickStarUpHasChooseList = self:cardQuickStarUpHasChooseInOther(temp[3])
	for k, v in pairs(cardQuickStarUpHasChooseList) do
		hasChooseList[k] = v
	end
	local myItem=temp[2];
	local category=heroItem.category;
	local battle=ModelManager.BattleModel:getArrayInfo();
	local hasBattle=false;
	if battle then
		 hasBattle=battle.array;
	end
	--local heroInfo= ModelManager.CardLibModel.curCardStepInfo;
	local categoryInfo= self.__heroInfos[tonumber(category)]
	--if type==1 then
	if categoryInfo then
		for key, value in pairs(categoryInfo) do
			local isInHeroPalace = ModelManager.HeroPalaceModel:isInGroupB(value.uuid)
			if value.star==star and value.code==heroCode and not isInHeroPalace and hasBattle and hasBattle[key]==nil and myItem.uuid ~=key and hasChooseList[key]==nil then
				chooseList[#chooseList+1]=value	;
			end 
		end
	end

	--printTable(5,"..>>>>>>>>",chooseList)
	return chooseList;
end

function CardLibModel:getStarCanChooseInfo(materials, heroItem, index, bIsQuickUp,tempHeroInfo)
	bIsQuickUp = bIsQuickUp or false -- 是否快捷升星
	local chooseList={};
	local type=materials.type;
	local star=materials.star;
	local hasChooseList= self:cardHasChooseInOther(index)
	local cardQuickStarUpHasChooseList = self:cardQuickStarUpHasChooseInOther(index)
	for k, v in pairs(cardQuickStarUpHasChooseList) do
		hasChooseList[k] = v
	end
	local category=heroItem.category;
	local hasBattle=ModelManager.BattleModel:getArrayType(materials.uuid);
	
	local heroInfo= ModelManager.CardLibModel.curCardStepInfo;
	if bIsQuickUp then
		heroInfo= ModelManager.CardLibModel.quickCardStarUpInfo
	end
	
	if tempHeroInfo then
		heroInfo = tempHeroInfo
		--hasChooseList = {}
	end
	local backConf = DynamicConfigData.t_BackstarItem;
	local categoryInfo= self.__heroInfos[tonumber(category)]
	if type==1 then
		for key, value in pairs(categoryInfo) do
			if value.star==star and value.code==heroItem.heroId and heroInfo.uuid ~=key and hasChooseList[key]==nil then
				chooseList[#chooseList+1]=value	;
			end 
		end
	elseif type==2 then
		-- 可以使用相同种族和星级的替身
		local replaceConf = backConf[category][star];
		if (replaceConf) then
			local replaceCount = (replaceConf and replaceConf.id) and ModelManager.PackModel:getItemsFromAllPackByCode(replaceConf.id) or 0;
			local choosedCount = hasChooseList[replaceConf.id] or 0;
			replaceCount = math.max(replaceCount - choosedCount, 0);
			for i = 1, replaceCount do
				chooseList[#chooseList+1]={code=replaceConf.id, type=GameDef.GameResType.Item, amount=1, category = category, star = star, idx = #chooseList+1};
			end
		end
		-- 同种族英雄
		for key1, value in pairs(categoryInfo) do
			if value.star==star and heroInfo.uuid ~=key1 and hasChooseList[key1]==nil then
				chooseList[#chooseList+1]=value	;
			end 
		end
		-- if star == 5 then -- 需要5星卡牌时，增加快捷合成
		-- 	-- 获取4星级同阵营中拥有足够合成材料的探员中战力最低的那个
		-- 	local hero = false
		-- 	for key, value in pairs(categoryInfo) do
		-- 		if value.star == 4 and hasChooseList[key] == nil then
		-- 			local _materials = self:getUpStarMaterials(value.code, value.star)
		-- 			if self:isMaterialEnough(_materials, value) then -- 拥有足够合成材料
		-- 				if not hero or value.combat < hero.combat then
		-- 					hero = value
		-- 				end
		-- 			end
		-- 		end
		-- 	end
		-- 	if hero then
		-- 		hero.quickUp = true
		-- 		table.insert(chooseList, 1, hero)
		-- 	end
		-- end
		if star == 5 then -- 需要5星卡牌时，增加快捷合成
			-- 获取4星级同阵营中拥有足够合成材料的探员
			local heros = {}
			local heroIds = {} -- 同一个探员只显示一个
			for key, value in pairs(categoryInfo) do
				value.quickUp = false 
				if value.star == 4 and hasChooseList[key] == nil then
					local _materials = self:getUpStarMaterials(value.code, value.star)
					if self:isMaterialEnough(_materials, value) and not heroIds[value.heroId] then -- 拥有足够合成材料
						value.quickUp = true
						table.insert(heros, value)
						heroIds[value.heroId] = true
					end
				end
			end
			for k, v in ipairs(heros) do
				table.insert(chooseList, 1, v)
			end
		end
	elseif type==3 then
		-- 替换材料
		for m = 0, 5 do
			local replaceConf = backConf[m][star];
			if (replaceConf) then
				local replaceCount = (replaceConf and replaceConf.id) and ModelManager.PackModel:getItemsFromAllPackByCode(replaceConf.id) or 0;
				local choosedCount = hasChooseList[replaceConf.id] or 0;
				replaceCount = math.max(replaceCount - choosedCount, 0);
				for i = 1, replaceCount do
					chooseList[#chooseList+1]={code=replaceConf.id, type=GameDef.GameResType.Item, amount=1, category = m, star = star, idx = #chooseList+1};
				end
			end
		end
		-- 英雄材料
		categoryInfo = self:getCardByCategory(0)
		for key1, value in pairs(categoryInfo) do
			if value.star==star and heroInfo.uuid ~=value.uuid and hasChooseList[value.uuid]==nil then
				chooseList[#chooseList+1]=value	;
			end 
		end
	end
	--printTable(5,"..>>>>>>>>",chooseList)
	return chooseList;
end

-- 根据分类和星级获取一个快捷合成选项，当前仅当star=5时有返回值
function CardLibModel:getOneQuickStarUpChooseByCategoryAndStar(category, star)
	local hasChooseList= self:cardHasChooseInOther(3)
	local cardQuickStarUpHasChooseList = self:cardQuickStarUpHasChooseInOther(3)
	for k, v in pairs(cardQuickStarUpHasChooseList) do
		hasChooseList[k] = v
	end

	local categoryInfo = self:getCardByCategory(category)
	if star == 5 then -- 需要5星卡牌时，增加快捷合成
		-- 获取4星级中拥有足够合成材料的探员中战力最低的那个
		local hero = false
		for key, value in pairs(categoryInfo) do
			if value.star == star - 1 and hasChooseList[key] == nil then
				local _materials = self:getUpStarMaterials(value.code, value.star)
				if self:isMaterialEnough(_materials, value) then -- 拥有足够合成材料
					if not hero or value.combat < hero.combat then
						hero = value
					end
				end
			end
		end
		if hero then
			hero.quickUp = true
			return hero
		end
	end

	return false
end

-- 根据分类和星级获取一组快捷合成选项，当前仅当star=5时有返回值
function CardLibModel:getQuickStarUpChooseByCategoryAndStar(category, star)
	local hasChooseList= self:cardHasChooseInOther(3)
	local cardQuickStarUpHasChooseList = self:cardQuickStarUpHasChooseInOther(3)
	for k, v in pairs(cardQuickStarUpHasChooseList) do
		hasChooseList[k] = v
	end

	local categoryInfo = self:getCardByCategory(category)
	-- table.sort(categoryInfo, function(a, b)
	-- 	return a.combat < b.combat
	-- end)
	TableUtil.sortByMap(categoryInfo, {{key="heroId",asc=false},{key="combat",asc=false}})
	if star == 5 then -- 需要5星卡牌时，增加快捷合成
		-- 获取4星级中拥有足够合成材料的
		local heros = {}
		local heroIds = {} -- 同一个探员只显示一个
		for key, value in ipairs(categoryInfo) do
			value.quickUp = false 
			if value.star == star - 1 and hasChooseList[key] == nil then
				local _materials = self:getUpStarMaterials(value.code, value.star)
				if not heroIds[value.heroId] and self:isMaterialEnough(_materials, value) then -- 拥有足够合成材料
					value.quickUp = true
					table.insert(heros, value)
					heroIds[value.heroId] = true
				end
			end
		end
		if #heros > 0 then
			return heros
		end
	end

	return false
end

--获取其他材料已选择的卡牌
function  CardLibModel:cardHasChooseInOther(pos)
	local hasChoos={}
	printTable(5,"已选择>>>>>>>>",pos)
	local info=ModelManager.CardLibModel.curCardStarUpChoose;
	if info then
		for key, value in pairs(info) do
			--printTable(5,"已选择key",key, value)
			if pos~=key then
				for k, uid in pairs(value) do
					if (uid.uuid) then
						hasChoos[uid.uuid] = uid.uuid;
					else
						hasChoos[uid.code] = uid.amount;
					end
					
				end
			end
		end
	end
	printTable(5,"已选择>>>>>>>>",hasChoos)
	return hasChoos;
end

--获取快捷升星其他材料已选择的卡牌
function CardLibModel:cardQuickStarUpHasChooseInOther(pos)
	local hasChoos={}
	printTable(5,"已选择>>>>>>>>",pos)
	local info=ModelManager.CardLibModel.quickCardStarUpChoose;
	if info then
		for key, value in pairs(info) do
			--printTable(5,"已选择key",key, value)
			if pos~=key then
				for k, uid in pairs(value) do
					if (uid.uuid) then
						hasChoos[uid.uuid] = uid.uuid;
					else
						hasChoos[uid.code] = uid.amount;
					end
					
				end
			end
		end
	end
	printTable(5,"已选择>>>>>>>>",hasChoos)
	return hasChoos;
end

function CardLibModel:getUpStarMaterials(heroId,star)
	local info= DynamicConfigData.t_hero;
	local starRuleId= info[heroId].starRule;
	local starInfo=DynamicConfigData.t_heroStar;
	local starData=starInfo[starRuleId];
	local starItem=starData[star];
	if not starItem then return end
	printTable(5,"卡牌升星请求返回yfyf",heroId,starRuleId,starItem,star)
	local temp={};
	if #starItem.self>0 then
		for k, selfInfo in pairs(starItem.self) do
			selfInfo['type']=1;
			temp[#temp+1]=selfInfo;
		end
	end
	if #starItem.faction>0 then
		for key, value in pairs(starItem.faction) do
			value['type']=2;
			temp[#temp+1]=value;
		end
	end
	if #starItem.free>0 then
		for k1,free in pairs(starItem.free) do
			free['type']=3;
			temp[#temp+1]=free;
		end
	end
	if #starItem.special>0 then
		for k2,special in pairs(starItem.special) do
			special['type']=4;
			temp[#temp+1]=special;
		end
	else
	end
	printTable(5,'升星材料数据',temp,starItem.material);
	return temp,starItem.material;
end

function CardLibModel:getHeroCardStarDiscretionary(star)
	printTable(5,"DynamicConfigData属性>>>",star);
	local starNum=star;
	if star<=5 then
		starNum=5;
	end
	local info= DynamicConfigData.t_heroStarPoint;
	local starInfo= info[starNum+1]
	if starInfo==nil then
		starInfo=info[starNum]
	end
	return starInfo.attrPoint;
end

function CardLibModel:getHeroCardStarlv(star)
	local LevelMax=0
	local info= DynamicConfigData.t_heroStage;
	for i=1,#info,1 do
		local value=info[i];
		printTable(5,"11111111",value)
		local next=info[i+1];
		if next==nil then
			if star>=value.StarLimit then
				if value.LevelMax > LevelMax then
					LevelMax = value.LevelMax
				end
			end
		else
			if star>=value.StarLimit and star<next.StarLimit then
				return value.LevelMax;
			end
		end
		
    end
	return LevelMax;
end

--根据ID获取卡牌信息
function CardLibModel:getHeroInfoById(heroId,heroUuid,category)
	local infoData= self:getHeroByUid(heroUuid)
	--[[if infoData then
		local category=infoData.heroDataConfiger.category;
		self.categoryCardNum=ModelManager.CardLibModel:getCategoryCardNumber(category)
	end
	if category==nil then
		category=string.sub(heroId,0,1)
	end--]]
	return infoData; --self.__heroInfos[tonumber(category)][heroUuid]
end

--根据uuid获取卡牌信息
function CardLibModel:getHeroByUid(uuid)
	if not self.__heroInfos then return end
	local hero=false
	for category, groupInfos in pairs(self.__heroInfos) do
        if groupInfos[uuid] then
			return groupInfos[uuid]
		end
	end
	return hero
end

function CardLibModel:setHeroRunePageByUid( uuid,runePageId)
	if not self.__heroInfos then return end
	local hero=false
	for category, groupInfos in pairs(self.__heroInfos) do
        if groupInfos[uuid] then
		   groupInfos[uuid].runePageId = runePageId
		end
	end
end


function CardLibModel:getHeroInfoToIndex(needSort, sortType)
	if not self.cardListShow or not next(self.cardListShow)  or needSort then
		self.cardListShow={}
		if not self.__CardsCategory then
			self.__CardsCategory = ModelManager.CardLibModel:getAllCards()
		end
		for k, v in pairs(self.__CardsCategory) do
			v['hasBattle'] = BattleModel:isInBattle(v.uuid, GameDef.BattleArrayType.Chapters) and 1 or 0
			table.insert(self.cardListShow, v)
		end
		local sortMap = {{key="hasBattle",asc=true},{key="star",asc=true} ,{key="level",asc=true} ,{key="combat",asc=true},{key="code",asc=false}};
		if (sortType == 2) then
			sortMap = {{key="star",asc=true}, {key="hasBattle",asc=true}, {key="combat",asc=true}, {key="level",asc=true},{key="code",asc=false}};
		elseif (sortType == 3) then
			sortMap = {{key="combat",asc=true}, {key="hasBattle",asc=true}, {key="star",asc=true},  {key="level",asc=true},{key="code",asc=false}};
		elseif (sortType == 4) then
			sortMap = {{key="level",asc=true}, {key="hasBattle",asc=true}, {key="star",asc=true},  {key="combat",asc=true},{key="code",asc=false}};
		end
		TableUtil.sortByMap(self.cardListShow, sortMap);
	end
	return self.cardListShow
end

function CardLibModel:getCardsByCategory(Category)
	return self.__CardsCategory
end

function CardLibModel:setCardsByCategory(Category)
	if(Category == 0) then
		self.__CardsCategory = ModelManager.CardLibModel:getAllCards()
	else
		if self.__heroInfos[Category] then
			local temp={};
			local listTable= self.__heroInfos[Category]
			for k, v in pairs(listTable) do
					temp[#temp+1]=v
			end
			temp=self:starSort(temp)
			self.__CardsCategory=temp;
		else
		   self.__CardsCategory={}
		end
	end
end

function CardLibModel:getAllCards()
	local temp={}
	--printTable(4,self.__heroInfos,"self.__heroInfos")
	for category, groupInfos in pairs(self.__heroInfos) do
		for k, v in pairs(self.__heroInfos[category]) do
			temp[#temp+1]=v
		end
	end
	temp=self:starSort(temp)
	return temp
end

function CardLibModel:starSort(temp)
	table.sort(temp,function(a,b)
		if a.star==b.star then
			return a.level >b.level;
		else
			return a.star>b.star
		end
	end)
	return temp;
end


function CardLibModel:setChooseUid(uuid)
	ModelManager.CardLibModel:setCardsByCategory(0)
	local CardList=ModelManager.CardLibModel:getHeroInfoToIndex()
	local index
	local heroId
	for i,v in pairs(CardList) do
		if v.uuid == uuid then
			index = i
			heroId = v.heroId
			ModelManager.CardLibModel.curCardStepInfo = v
		end
	end
	if index then
		self.__cardsIndex=index;
		self.__cardByPos=self:getHeroInfoById(heroId,uuid)
	end
end

function CardLibModel:setCarByPosInfo(heroId,uuid,index)
	if index then
		self.__cardsIndex=index;
		self.__cardByPos=self:getHeroInfoById(heroId,uuid)
	end
end

function CardLibModel:getCarByPosInfo()
	return self.__cardByPos
end

function CardLibModel:getCarIndex()
	return self.__cardsIndex
end

--获取战力
function CardLibModel:getFightVal( ... )
	if self.maxCombat==nil then
		self.maxCombat=0
	end
	return self.maxCombat;
	-- local list = self:getAllCards()
	-- table.sort(list,function( a,b )
	-- 	return a.combat > b.combat
	-- end)
	-- local fight = 0
	-- local num=6
	-- if 	PlayerModel.level<60 then
	-- 	num=6
	-- elseif PlayerModel.level>=60 and PlayerModel.level<=69 then
	-- 	num=7
	-- elseif PlayerModel.level>=70 then
	-- 	num=8
	-- end
    -- for i=1,num do
    -- 	if list[i] then
    -- 		fight= fight + list[i].combat
    -- 	end
    -- end
    -- return fight
end

function CardLibModel:getActivationCardNumber()
	local count=0;
	for k, herodata in pairs(self.__heroInfos) do
		for key ,value in pairs(herodata) do 
			count=count+1;
		end
	end
	return count;
end

--得到当前卡牌大类的数量
function CardLibModel:getCategoryCardNumber(type)
	if type == 0 then
		local cards = ModelManager.CardLibModel:getAllCards()
		return #cards
	end
	local count=0;
	for category, groupInfos in pairs(self.__heroInfos) do
		if category==tonumber(type)  then
			for k, v in pairs(self.__heroInfos[category]) do
				count=count+1;
			end
		end
	end
	return count
end

function CardLibModel:getSkillList()
	local skillArr={}
	local skillLevel= DynamicConfigData.t_heroStage[self.__cardByPos.stage]
	if skillLevel==nil then
		return skillArr
	end
	local skillLevelArr=skillLevel.skillLevel
	for i = 1, 4 do
		local level=skillLevelArr[i];
		local key ='skill'..i
		local activeSkill1 =self.__cardByPos.heroDataConfiger[key][level]
		table.insert( skillArr, activeSkill1)
	end
	local passiveSkil=self.__cardByPos.heroDataConfiger.passiveSkill;
	-- local activeSkill1=self.__cardByPos.heroDataConfiger.skill1[1]
	-- local passiveSkil2=self.__cardByPos.heroDataConfiger.skill2[1]
	-- local passiveSkil3=self.__cardByPos.heroDataConfiger.skill3[1]
	-- local passiveSkil4=self.__cardByPos.heroDataConfiger.skill4[1]
	-- table.insert( skillArr, activeSkill1)
	-- table.insert( skillArr, passiveSkil2)
	-- table.insert( skillArr, passiveSkil3)
	-- table.insert( skillArr, passiveSkil4)
	printTable(9,'>>>>>>>>>',skillArr)
	return skillArr ,passiveSkil;
	--skillArr.arrange(passiveSkil)
	--table.insert()
end


--战斗需要显示升级后把这里加上
function CardLibModel:getSkillListbyUUid(type,id) 
	
	local skillArr,passiveSkil={},false
	if type ==1 then
		local cardInfo=self:getHeroByUid(id);--根据uuid
		local skillLevel= DynamicConfigData.t_heroStage[cardInfo.stage]
		if skillLevel==nil then
			return skillArr
		end
		local skillLevelArr=skillLevel.skillLevel
		for i = 1, 4 do
			local level=skillLevelArr[i];
			local key ='skill'..i
			local activeSkill1 =cardInfo.heroDataConfiger[key][level]
			table.insert( skillArr, activeSkill1)
		end
		passiveSkil=cardInfo.passiveSkill;--已激活的被动技能
     else
		--怪物的技能列表
		local cardInfo=DynamicConfigData.t_hero[id];--根据heroId
		for i = 1, 4 do
			local key ='skill'..i
			local activeSkill1 =cardInfo[key][1]
			table.insert( skillArr, activeSkill1)
		end
		passiveSkil=cardInfo.passiveSkill;--已激活的被动技能
	end
	

	return skillArr ,passiveSkil;
end


--request卡牌升级
--upLvNum 连升级数
function CardLibModel:heroLevelUp(uuid, upLvNum)
	if not upLvNum then upLvNum = 1 end
	local oldAttr = self:getHeroByUid(uuid).attrs
	local oldCombat = self:getHeroByUid(uuid).combat
	local function success(data)
		printTable(5,"卡牌升级请求返回",data)
		local newAttr = data.hero.attrs
		RollTips.showAttrTips(oldAttr, newAttr)
		self:UpCardHeroAttr(data,1);
		local newCombat = self:getHeroByUid(uuid).combat
		local addNum = newCombat - oldCombat
		if addNum > 0 then
			RollTips.showAddFightPoint(addNum)
		end
		Dispatcher.dispatchEvent(EventType.cardView_levelUpSuc,data);
		-- Dispatcher.dispatchEvent(EventType.update_cards_fightVal);--战力有刷新
	end
	local function errFun(data)
		self:showErrCodeInfo(data);
	end
	local info = {
		uuid = uuid,
		level = upLvNum
	}
	--print(4,"发送的参数",uuid)
	printTable(5,"卡牌升级发送的参数",info)
	RPCReq.Hero_HeroLevelUp(info,success,nil)
end

--切换配点
function CardLibModel:switchMatchPoint(uuid, planId)
	local oldAttr = self:getHeroByUid(uuid).attrs
	local oldCombat = self:getHeroByUid(uuid).combat
	local function success(data)
		printTable(5,"切换配点返回",data)
		local newAttr = data.hero.attrs
		RollTips.showAttrTips(oldAttr, newAttr)
		self:UpCardHeroAttr(data,1);
		local newCombat = self:getHeroByUid(uuid).combat
		local addNum = newCombat - oldCombat
		if addNum > 0 then
			RollTips.showAddFightPoint(addNum)
		end
		
		RollTips.show(string.format(Desc.card_matchPointSwitch, planId))
		Dispatcher.dispatchEvent(EventType.cardView_matchPointSwitch,{uuid = uuid, type = planId});
	end
	--[[local function errFun(data)
		self:showErrCodeInfo(data);
	end--]]

	printTable(5,"切换配点的参数",uuid, planId)
	local info = {
		id =tonumber(planId);--0:integer		#func
		uuid=uuid
	}
	RPCReq.Hero_changeHeroPointPlan(info,success)
end
function CardLibModel:sendProtocol(textInfo)
	local function success(data)
		printTable(5,"卡牌升级请求返回",data)
		if data.ret==0 then
			RollTips.show(Desc.card_TestCmdSucStr);
		else
			RollTips.show(data.msg);
		end
	end
	local function errFun(data)
		printTable(5,"卡牌升级errFun",data)
	end
	local info = {
		type =tonumber(textInfo.type);--0:integer		#func
		value1=tonumber(textInfo[1]),
		value2=tonumber(textInfo[2]),
		value3=tonumber(textInfo[3]),
		msg=textInfo[4],	--	#备用
	}
	printTable(5,"卡牌升级发送的参数",info)
	RPCReq.Test_Cmd(info,success,errFun,nil,true)
end

function  CardLibModel:showErrCodeInfo(data)
	local errStr='';
		if data.repErrorStr then
			local baseInfo =ItemConfiger.getInfoByCode(tonumber(data.repErrorStr));
			if not baseInfo then		
				return
			end
			local errInfo =GameDef.ErrorCodeDict[tonumber(data.repError)];
			if not errInfo then		
				return
			end
				errStr=baseInfo.name..errInfo.desc;
	else
			local errInfo =GameDef.ErrorCodeDict[tonumber(data.repError)];
			errStr=errInfo.desc;
	end
	RollTips.show(errStr);
end
--request卡牌升阶
function CardLibModel:heroUpgrade(uuid, attrs, curAllAttr, nextAllAttr,soundId)
	local heroInfo= ModelManager.CardLibModel.curCardStepInfo;
	local oldAttr = self:getHeroByUid(uuid).attrs
	local oldCombat = self:getHeroByUid(uuid).combat
	local function success(data)
		self:UpCardHeroAttr(data,2);
		local newAttr = data.hero.attrs
		RollTips.showAttrTips(oldAttr, newAttr)
		RollTips.show(Desc.card_upStepSucStr)
		Dispatcher.dispatchEvent(EventType.cardView_stepUpSuc,data);
		-- Dispatcher.dispatchEvent(EventType.update_cards_fightVal);--战力有刷新
		local newCombat = self:getHeroByUid(uuid).combat
		local addNum = newCombat - oldCombat
		if addNum > 0 then
			RollTips.showAddFightPoint(addNum)
		end
		ViewManager.open("CardStepUpSuccessView", {heroInfo = heroInfo, oldCombat = oldCombat, newCombat = newCombat, attrs = attrs, curAllAttr = curAllAttr, nextAllAttr = nextAllAttr,soundId = soundId})
	end
	local function errFun(data)
		self:showErrCodeInfo(data);
	end
	local info = {
		uuid = uuid
	}
	RPCReq.Hero_HeroStageLevelUp(info,success,nil)
end


--request#升星
function CardLibModel:heroStarLevelUp(cardUuid,costList, starItem, bIsQuickUp,curStage, nextStage)
	local hero = self:getHeroByUid(cardUuid)
	if not hero then return end
	local oldCombat = hero.combat
	local oldStar = hero.star
	local oldAttr = hero.attrs
	local oldLevel = ModelManager.CardLibModel:getHeroCardStarlv(oldStar)
	local heroInfoTemp = ModelManager.CardLibModel.curCardStepInfo
	--[[if bIsQuickUp then
		heroInfoTemp = ModelManager.CardLibModel.quickCardStarUpInfo
	end--]]
	local function success(data)
		printTable(5,"卡牌升星请求返回",data)
		RollTips.show(Desc.card_upStarSucStr);
		self:UpCardHeroAttr(data,2);
		local newCombat = self:getHeroByUid(cardUuid).combat
		local addNum = newCombat - oldCombat
		if addNum > 0 then
--			RollTips.showAddFightPoint(addNum)
		end
		local newAttr = data.hero.attrs
		if bIsQuickUp then
			ViewManager.close("CardQuickStarUpView")
			
			local index = self.lastCurCardStarUpSelectIndex
			local heroInfo = self.curCardStepInfo
			local temp = self:getUpStarMaterials(heroInfo.code, heroInfo.star)
			local heroId = heroInfo.code
			local info = DynamicConfigData.t_hero
		    local heroItem = info[heroId]
		    local materials = temp[index]
			-- local chooseList = self:getStarCanChooseInfo(materials, heroItem, index, true)
			local limitNum = materials.num

		    local allCards = self:getAllCards()

		    -- 自动选择快捷升星的英雄为升星材料
		    local num = self:getStarMaterialsNum(index)
		    if num < limitNum then
		    	local info = {}
		    	for k, v in pairs(allCards) do
		    		if v.uuid == self.quickCardStarUpInfo.uuid then
		    			-- RollTips.show("选择一个材料")
		    			table.insert(info, v)
		    			break
		    		end
		    	end
				self:addCurCardStarUpChoose(index, info)
			end
			-- 记录快捷升星的英雄
			self.quickCardStarUpMap[cardUuid] = self.quickCardStarUpInfo
		end

		if not bIsQuickUp then
			self:clearQuickCardStarUpMap() -- 清除快捷升星英雄记录
			local newhero = self:getHeroByUid(cardUuid)
			local newCombat = newhero.combat
			local newStar = newhero.star
			local newLevel = ModelManager.CardLibModel:getHeroCardStarlv(newStar)
			
			
			ViewManager.open("CardStarUpSuccessView", {heroInfo = heroInfoTemp,curAllAttr = oldAttr, nextAllAttr = newAttr, oldStar = oldStar,oldLevel = oldLevel, newStar = newStar, newLevel = newLevel, hallowPoint = data.addHallowPoint,curStage = curStage, nextStage = nextStage })
			Dispatcher.dispatchEvent(EventType.cardView_starUpSuc,data);
			Dispatcher.dispatchEvent(EventType.event_getHighStarHero,newStar,newhero.code)
		else
			Dispatcher.dispatchEvent(EventType.quickStarUp_suc)
		end
	end
	local function errFun(data)
		self:showErrCodeInfo(data);
	end
	local info = {
		uuid  = cardUuid ,   	-- 1:string        #升星的卡牌uuid
		costList = costList,  	-- 2:*string       #升星材料卡牌uuid列表
		starItem = starItem		-- 3:*HeroStarReplacementItemMap(code)     #升星替换材料map
	}
	printTable(5,"升星发送的参数",info)
	RPCReq.Hero_HeroStarLevelUp(info,success,nil)
end

-- 升级星阶（20星）
function CardLibModel:heroStarSegmentLevelUp(cardUuid, starSegmentId, costList, starItem)
	local hero = self:getHeroByUid(cardUuid)
	local oldCombat = hero.combat
	local oldStar = hero.star
	local oldAttr = hero.attrs
	local oldLevel = HeroConfiger.getNextLevelLimit(hero.stage, hero.level) + self:getSegmentAddLvMax(hero)--ModelManager.CardLibModel:getHeroCardStarlv(oldStar)
	local successFunc = function (param)
		self:UpCardHeroAttr(param,2);
		-- local newCombat = self:getHeroByUid(param.hero.uuid).combat
		-- local addNum = newCombat - oldCombat
		local newhero = self:getHeroByUid(cardUuid)
		local newCombat = newhero.combat
		local newStar = newhero.star
		local newLevel = HeroConfiger.getNextLevelLimit(hero.stage, hero.level) + self:getSegmentAddLvMax(hero)--ModelManager.CardLibModel:getHeroCardStarlv(newStar)
		local newAttr = param.hero.attrs
		-- if addNum > 0 then
		-- 	RollTips.showAddFightPoint(addNum);
		-- end

		ViewManager.open("CardStarUpSuccessView", {heroInfo = hero,curAllAttr = oldAttr, nextAllAttr = newAttr, oldStar = oldStar,oldLevel = oldLevel, newStar = newStar, newLevel = newLevel, hideTop = true});
		Dispatcher.dispatchEvent("cardStarSegmentLevelUp_suc");
		self:segmentRedCheck();
	end
	local info = {
		uuid = cardUuid,
		starSegmentId = starSegmentId,
		costList = costList,
		starItem = starItem
	}
	RPCReq.Hero_HeroStarSegmentLevelUp(info, successFunc);
end

-- 星阶完成后升星（20星）
function CardLibModel:heroStarSegmentLevelUpFinish(cardUuid)
	local hero = self:getHeroByUid(cardUuid)
	local oldCombat = hero.combat
	local oldStar = hero.star
	local oldAttr = hero.attrs
	local oldLevel = ModelManager.CardLibModel:getHeroCardStarlv(oldStar)

	local succesFunc = function (param)
		self:UpCardHeroAttr(param,2);
		local newhero = self:getHeroByUid(cardUuid)
		local newCombat = newhero.combat
		local newStar = newhero.star
		local newLevel = ModelManager.CardLibModel:getHeroCardStarlv(newStar)
		local newAttr = param.hero.attrs
		RollTips.show(Desc.card_upStarSucStr)
		-- ViewManager.open("CardStarUpSuccessView", {heroInfo = hero,curAllAttr = oldAttr, nextAllAttr = newAttr, oldStar = oldStar,oldLevel = oldLevel, newStar = newStar, newLevel = newLevel, hallowPoint = param.addHallowPoint})
		Dispatcher.dispatchEvent(EventType.cardView_starUpSuc,param);
		Dispatcher.dispatchEvent(EventType.event_getHighStarHero,newStar,newhero.code)
	end
	local info = {
		uuid = cardUuid
	}
	RPCReq.Hero_HeroStarSegmentLevelUpFinish(info, succesFunc);
end

--#属性点分配
function CardLibModel:heroAttrPointPlanSet(planId, uuid,addPointPlan)
	local oldAttr = self:getHeroByUid(uuid).attrs
	local oldCombat = self:getHeroByUid(uuid).combat
	
	local function success(data)
		printTable(5,"属性点分配请求返回",data)
		RollTips.show(Desc.card_upPointSucstr)
		self:UpCardHeroAttr(data,2);
		local newAttr = data.hero.attrs
		RollTips.showAttrTips(oldAttr, newAttr)
		local newCombat = self:getHeroByUid(uuid).combat
		local addNum = newCombat - oldCombat
		if addNum > 0 then
			RollTips.showAddFightPoint(addNum)
		end
		Dispatcher.dispatchEvent(EventType.cardView_configurationPoint,data);
	end
	local info = {
		id = planId,
		uuid=  uuid  ,       -- 1:string        #升星的卡牌uuid
        addPointPlan=  addPointPlan    -- 2:HeroAttrPointPlan  #新增加的属性点分配方案
	}
	printTable(5,"属性点分配",info)
	RPCReq.Hero_HeroAttrPointPlanSet(info,success)
end

--#属性点重置
function CardLibModel:heroAttrPointPlanReset(planId, uuid)
	local function success(data)
		printTable(5,"属性点重置请求返回",data)
		RollTips.show(Desc.card_upMatPointSuc)
		self:UpCardHeroAttr(data,2);
		Dispatcher.dispatchEvent(EventType.cardView_configurationPoint,data);
	end
	local info = {
		id = planId,
		uuid=uuid,        --1:string        #升星的卡牌uuid
	}
	printTable(5,"属性点重置",info)
	RPCReq.Hero_HeroAttrPointPlanReset(info,success)
end

--#卡牌分解
function CardLibModel:heroDecompose(uuidList)
	local function success(data)
		printTable(8,"卡牌分解请求返回",data)
		ModelManager.CardLibModel:clearCardDecom()
		Dispatcher.dispatchEvent(EventType.show_gameReward)
		Dispatcher.dispatchEvent(EventType.cardView_DecomposeSuc);
	end
	local info = {
		uuidList=uuidList,     -- 1:*string        #分解的卡牌列表
	}
	printTable(8,"卡牌分解",info)
	RPCReq.Hero_HeroDecompose(info,success)
end

--#卡牌分解
function CardLibModel:decomposeItem(resList)
	local function success(data)
		printTable(8,"碎片分解请求返回",data)
		ModelManager.CardLibModel:clearCardDecom()
		Dispatcher.dispatchEvent(EventType.show_gameReward)
		Dispatcher.dispatchEvent(EventType.cardView_DecomposeDebrisSuc);
	end
	local info = {
		resList=resList			--1:*Common_GameRes  #分解列表
	}
	printTable(8,"碎片分解",info)
	RPCReq.Bag_DecomposeItemCommon(info,success)
end

--#卡牌自动分解设置
function CardLibModel:setAutoDecompose(star)
	local function success(data)
		printTable(8,"卡牌自动分解设置返回",data)
		RollTips.show(DescAuto[46]) -- [46]='设置成功'
		self.cardDecomPoseSetting=data.star;
	end
	local info = {
		star=star;            --1:integer       #自动分解x星及以下星级的卡牌, 位数组, 二进制对应Bit位为1的则分解, 为0则不分解
	}
	printTable(8,"卡牌自动分解设置",info)
	RPCReq.Hero_SetAutoDecompose(info,success)
end


--#卡牌技能激活
function CardLibModel:activePassiveSkill(uuid,skillId)
	-- local oldAttr = self:getHeroByUid(uuid).attrs
	local hero = self:getHeroByUid(uuid)
	local oldCombat = hero.combat;
	if (hero and hero.passiveSkill and hero.passiveSkill[skillId]) then
		RollTips.show(Desc.card_talentActived);
		Dispatcher.dispatchEvent(EventType.cardView_activeSkillSuc,hero, skillId);
		return;
	end
	local function success(data)
		printTable(2233,"卡牌技能激活返回",data)
		RollTips.show(Desc.card_DetailsStr14)
		self:UpCardHeroAttr(data,2);
		-- local newAttr = data.hero.attrs
		-- RollTips.showAttrTips(oldAttr, newAttr)
		local newCombat = self:getHeroByUid(uuid).combat
		local addNum = newCombat - oldCombat
		if addNum > 0 then
			RollTips.showAddFightPoint(addNum)
		end
		
		-- self:clearSkillActiveChoose();
		ViewManager.close('CardTalentActiveSkillView');
		Dispatcher.dispatchEvent(EventType.cardView_activeSkillSuc,data, skillId);
	end
	local info = {
		uuid= uuid ,       --1:string        #卡牌uuid
        skillId = skillId ,      --2:integer       #技能id
        -- costUuidList =costUuidList   --3:*string       #消耗的卡牌列表
	}
	printTable(2233,"卡牌技能激活",info)
	RPCReq.Hero_ActivePassiveSkill(info,success)
end

--##卡牌技能激活(任性一下)
function CardLibModel:activePassiveSkillByMoney(uuid,skillId)
	-- local oldAttr = self:getHeroByUid(uuid).attrs
	local hero = self:getHeroByUid(uuid);
	local oldCombat = hero.combat
	if (hero and hero.passiveSkill and hero.passiveSkill[skillId]) then
		RollTips.show(Desc.card_talentActived);
		Dispatcher.dispatchEvent(EventType.cardView_activeSkillSuc,hero, skillId);
		return;
	end
	local function success(data)
		printTable(8,"卡牌技能激活任性一下返回",data)
		RollTips.show(Desc.card_DetailsStr14)
		self:UpCardHeroAttr(data,2);
		-- local newAttr = data.hero.attrs
		-- RollTips.showAttrTips(oldAttr, newAttr)
		local newCombat = self:getHeroByUid(uuid).combat
		local addNum = newCombat - oldCombat
		if addNum > 0 then
			RollTips.showAddFightPoint(addNum)
		end
		Dispatcher.dispatchEvent(EventType.cardView_activeSkillSuc,data, skillId);
	end
	local info = {
		uuid= uuid ,       --1:string        #卡牌uuid
        skillId = skillId ,      --2:integer       #技能id
	}
	printTable(8,"卡牌技能激活(任性一下)",info)
	RPCReq.Hero_ActivePassiveSkillByMoney(info,success)
end

--#卡牌技能学习
function CardLibModel:learnPassiveSkill(uuid,skillId)
	-- local oldAttr = self:getHeroByUid(uuid).attrs
	local hero = self:getHeroByUid(uuid)
	local oldCombat = hero.combat
	local oldPass = hero.passiveSkill
	local function success(data)
		printTable(2233,"卡牌技能学习返回",data)
		RollTips.show(Desc.card_DetailsStr15)
		self:UpCardHeroAttr(data, "learnTalent");
		self:clearupStarInfo();
		-- local newAttr = data.hero.attrs
		-- RollTips.showAttrTips(oldAttr, newAttr)
		local newCombat = self:getHeroByUid(uuid).combat
		local addNum = newCombat - oldCombat
		if addNum > 0 then
			RollTips.showAddFightPoint(addNum)
		end
		ViewManager.close('CardTalentLearnSkillView');
		Dispatcher.dispatchEvent(EventType.CardView_talentLearnSuc,data, {old = {passiveSkill=oldPass}, skillId = skillId});
	end
	local info = {
		uuid= uuid ,       --1:string        #卡牌uuid
		skillId = skillId ,      --2:integer       #技能id
		-- costUuidList =costUuidList   --3:*string       #消耗的卡牌列表
	}
	printTable(2233,"卡牌技能学习",info)
	RPCReq.Hero_LearnPassiveSkill(info,success)
end

--#卡牌置换
function CardLibModel:HeroChangeStartChange(uuidA,uuidListB)
	local function success(data)
		printTable(158,"卡牌置换返回",data)
		if data and data.uuidB then
		 local cardInfo=self:getCardResetmateriSucCard(data.uuidB)
			if  cardInfo then
				local curAllAttr= ModelManager.CardLibModel:getCardAllAttrInfo({code=cardInfo.code},1,0,5,false);
				local  attr={}
				for key, value in pairs(curAllAttr) do
					local map= attr[key]
					if  not map then
						map={}
					end
					map["id"]=key
					map["value"]=value
					attr[key]=map
				end
				local heroinfo = ModelManager.CardLibModel.cardResetChooseA
				local str=""
				if heroinfo then
					local config=DynamicConfigData.t_hero
					local oldName=config[heroinfo.code].heroName
					local curName=config[cardInfo.code].heroName
					str=string.format(DescAuto[47],ColorUtil.formatColorString1(oldName, "#FFC35B") ,ColorUtil.formatColorString1(curName, "#FFC35B")) -- [47]="探员%s已成功置换成%s,可重新分配自由属性点"
				end
				local oldCardInfo={}
				for key, value in pairs(cardInfo) do
					oldCardInfo[key]=value
					if key=="level"  then
						oldCardInfo[key]=1
					elseif key=="star" then
						oldCardInfo[key]=5
					elseif key=="stage" then
						oldCardInfo[key]=0
					end
				end
				local addHallowPoint =data.addHallowPoint or 0
				local params = {}
				params.reward = data.itemBackList
				params.type = GameDef.GamePlayType.HeroChange
				ModelManager.PlayerModel:set_awardData(params)
				ViewManager.open("CardResetSuccessView", {heroInfo = cardInfo,oldHeroInfo=oldCardInfo ,desc=str, curAllAttr = attr, nextAllAttr = cardInfo.attrs, hallowPoint = addHallowPoint})
			end
		end
		Dispatcher.dispatchEvent(EventType.cardView_ResetTheViewClear);
	end
	local info = {
		uuidA =    uuidA       ,   --1:integer       #待转换卡牌A的uuid
		uuidListB = uuidListB       ,--  2:*integer      #消耗的若干卡牌B的uuid
	}
	printTable(8,"卡牌置换",info)
	RPCReq.HeroChange_StartChange(info,success)
end

--#卡牌技能学习
function CardLibModel:combineCard(itemId,num)
	local function success(data)
		printTable(8,"卡牌合成返回",data)
		--RollTips.show(Desc.card_DetailsStr16)
		ViewManager.close("ItemTipsBagView")
		--Dispatcher.dispatchEvent(EventType.cardView_activeSkillSuc,data);
	end
	local info = {
		itemId =  itemId,     --1:string      #道具id
        num =num,          --2:integer       #合成数量
	}
	printTable(8,"卡牌合成",info)
	RPCReq.Hero_Combine(info,success)
end

--设置锁定
function CardLibModel:setIsLock(idList,isLock)
	local function success(data)
		printTable(8,"卡牌合成返回",data)
		if isLock then
			RollTips.show(Desc.card_setLock1)
		else
			RollTips.show(Desc.card_setLock2)
		end
		for _,uuid in ipairs(idList) do
			local info = self:getHeroByUid(uuid)
			info.locked = isLock
		end
		Dispatcher.dispatchEvent(EventType.cardView_setLockSuc,idList);
	end
	local info = {
		uuidList =  idList,     --1:string      #道具id
        lock =isLock,          --2:integer       #合成数量
	}
	printTable(8,"卡牌合成",info)
	RPCReq.Hero_LockOper(info,success)
end

--添加富文本
function CardLibModel:formatColorString(content, sColor)
		--if sColor then
		--	return "[color=" .. sColor .."]" .. content .."[/color]";
		--else
		--	return content ..'';
		--end
		return string.format("<font color='%s'>%s</font>", sColor,content);
		--[color=#FFFF00]游戏UI编辑器[/color]
end

function  CardLibModel:UpCardHeroAttr(data,upType)
	printTable(8,"卡牌合成>>>>>>>>>>>>>>????",data)
	local herodata=data.hero;
	local heroId=data.hero.code;
	local heroUid=data.hero.uuid;
	
	local category=DynamicConfigData.t_hero[heroId].category;   -- herodata.heroDataConfiger.category--string.sub(heroId,0,1)--
	if herodata then 
		local heroInfo= self.__heroInfos[tonumber(category)][heroUid];
		local oldLevel = heroInfo.level
		
		for p,v in pairs(herodata) do
			heroInfo[p] = v
		end
		
		-- if heroInfo.level == 140 and oldLevel < 140 then
		-- 	RedManager.updateValue("V_CardTaletLevel"..self.uuid, true)  --达到120级时，要红点提醒一下特性
		-- end
		
		ModelManager.EquipmentModel:updateEquipment(herodata)
	end
	
	--[[heroInfo["uuid"]=herodata.uuid--拼接服务端同步的数据
	heroInfo["attrs"]=herodata.attrs--拼接服务端同步的数据
	heroInfo["level"]=herodata.level--(等级)
	heroInfo["star"]=herodata.star--(星级)
	--heroInfo["curExp"]=herodata.exp--（经验值）
	heroInfo["stage"]=herodata.stage--(阶级)
	heroInfo["combat"]=herodata.combat--(战力)
	heroInfo["attrPointNum"]=herodata.attrPointNum--(剩余可分配属性点)
	heroInfo["passiveSkill"]=herodata.passiveSkill--(卡牌已激活被动技能数据)
	heroInfo["reservedSkill"]=herodata.reservedSkill--(卡牌未激活被动技能数据)
	heroInfo["attrPointPlan"]=herodata.attrPointPlan--(配点数据)--]]
	Dispatcher.dispatchEvent(EventType.cardView_updateInfo, {type = upType, heroUid =heroUid} )
	ModelManager.CardLibModel:redCheck()
end

function CardLibModel:setInitInfos(heroInfos)
	self:setCardAutoDecom(heroInfos.hero.autoDecomposeParam)
	self.freeResetHeroTimes = heroInfos.hero.freeResetHeroTimes and heroInfos.hero.freeResetHeroTimes or 0
end


--下推卡牌信息
function CardLibModel:setHeroInfos(heroInfos)
	for k, herodata in pairs(heroInfos.heroList) do
		  local hero=DynamicConfigData.t_hero[herodata.code]--读表的数据
		  if not hero then
			break;
		  end
		  local temp = herodata
		  --herodata["heroId"]=hero.heroId
		  --herodata['heroDataConfiger']=hero;
			HeroConfiger.initHeroInfo(herodata)
		  local heroList=self.__heroInfos[hero.category] or {}
		  heroList[herodata.uuid]=herodata;
		  self.__heroInfos[hero.category]=heroList
	end
	
	
	--self:redCheck()
	
	GlobalUtil.delayCallOnce("CardLibModel:setHeroInfos", function()
		local RedConst = require "Game.Consts.RedConst"
		RedConst.initCardMap()
		ModelManager.CardLibModel:redCheck()
		-- Dispatcher.dispatchEvent(EventType.update_cards_fightVal);--战力有刷新
		self.dataInited = true
		Dispatcher.dispatchEvent(EventType.cardView_CardAddAndDeleInfo); 
		Dispatcher.dispatchEvent(EventType.mainui_showHeroChange) --发个通知去更新主界面的立绘
	end, self, 0.5)
	
	
	
	--local RedConst = require "Game.Consts.RedConst"
	--RedConst.initCardMap()
	--printTable(4,"yfyfyyfheroInfos",self.__heroInfos)
end

--判断升级材料是否够
function CardLibModel:isMaterialEnough(materials,heroInfo)
	local enough = true
	
	local battle=ModelManager.BattleModel:getArrayInfo();
	local hasBattle=false;
	if battle then
		 hasBattle=battle.array;
	end
	local hasChooseList={}
	for _,v in pairs(materials) do
		local type=v.type;
		local star=v.star;
		local category=heroInfo.heroDataConfiger.category;
		local categoryInfo
		local num = v.num
		
		if type==1 then
			categoryInfo = self.__heroInfos[tonumber(category)]
			for key, value in pairs(categoryInfo) do
				local isInHeroPalace = ModelManager.HeroPalaceModel:isInHeroPalace(value.uuid)
				if not isInHeroPalace and value.star==star and value.code==heroInfo.code and hasBattle and hasBattle[key]==nil and heroInfo.uuid ~=key and hasChooseList[key]==nil then
					hasChooseList[key]=value
					num = num - 1
					if num == 0 then 
						break
					end
				end 
			end
		elseif type==2 then
			categoryInfo = self.__heroInfos[tonumber(category)]
			for key, value in pairs(categoryInfo) do
				local isInHeroPalace = ModelManager.HeroPalaceModel:isInHeroPalace(value.uuid)
				if not isInHeroPalace and value.star==star and hasBattle and hasBattle[key]==nil and heroInfo.uuid ~=key and hasChooseList[key]==nil then
					hasChooseList[key]=value
					num = num - 1
					if num == 0 then 
						break
					end
				end 
			end
		elseif type==3 then
			categoryInfo = self:getCardByCategory(0)
			for key, value in pairs(categoryInfo) do
				local isInHeroPalace = ModelManager.HeroPalaceModel:isInHeroPalace(value.uuid)
				if not isInHeroPalace and value.star==star and hasBattle and hasBattle[value.uuid]==nil and heroInfo.uuid ~=value.uuid and hasChooseList[value.uuid]==nil then
					hasChooseList[key]=value
					num = num - 1
					if num == 0 then 
						break
					end
				end 
			end
		end
		if num > 0 then
			enough = false
			break
		end
	end
	return enough
end
--卡牌消耗是否足够
function CardLibModel:isCostEnough(cost, noBattle)
	local allCard = self:getCardByCategory(0)
	local battle=ModelManager.BattleModel:getArrayInfo();
	local hasBattle=false;
	if battle then
		 hasBattle=battle.array;
	end
	local enough = true
	for _,v in pairs(cost) do
		local num = v.num or 0
		for _,hero in ipairs(allCard) do
			if noBattle and hasBattle and hasBattle[hero.uuid] then
				
			else
				if hero.code == v.heroCode and hero.star == v.star then
					num = num - 1
					if num == 0 then
						break
					end
				end
			end
		end
		if num > 0 then 
			enough = false
			return false --有一个不够就直接返回false
		end
	end
	return enough
end

function CardLibModel:doQuitBattle(arrayType, uuid, callBack)
	local params = {}
	params.uuid = uuid
	--params.arrayType = arrayType
	--params.operType = 2
	params.onSuccess = function (res )
		--RollTips.show("下阵成功")
		for _,v in pairs(res.battleArrays) do
			ModelManager.BattleModel:quitBattle(v.arrayType,uuid)
		end
		
		if callBack ~= nil then
			callBack()
		end
	end
	RPCReq.Battle_OffAllArray(params, params.onSuccess)
	--RPCReq.Battle_UpdateBattleArray(params, params.onSuccess)
end

--下推专精物品使用限制
function CardLibModel:setZJItemLimitInfos(itemUseLimit)
	self.__skillItemLimit = itemUseLimit
end


--登录下推技能
function CardLibModel:setSkills(skills)

end

--是否自动释放
function CardLibModel:isAutoReleaseSkill(skillId)
	return self.__autoReleaseSkills[skillId]
end

function CardLibModel:setAutoReleaseState(skillId, auto)
	self.__autoReleaseSkills[skillId] = auto
	FileCacheManager.setBoolForKey(getSkillKey(skillId),auto)
end

--获取指定位置的技能信息
function CardLibModel:getSkillByPos(pos)
	return self.__skillByPos[pos]
end

function CardLibModel:getSkillInfoById(skillId)
	return self.__learnedSkills[skillId]
end

--根据pos，index,获取技能数据
function CardLibModel:getSkillByPosIndex(pos,index)
	if self.__posSkills[pos] then
		return self.__posSkills[pos][index]
	end
end

--已经学习的技能
function CardLibModel:getAllLearnedSkills()
	return self.__learnedSkills
end


function CardLibModel:hasLearnSkill(skillId)
	return self.__learnedSkills[skillId] ~= nil
end

function CardLibModel:updateSkill(skillInfo)

end
--技能是否处于cd中
function CardLibModel:isSkillInCD(skillId)
	local rlt = self:isSkillInNormalCD(skillId) or self:isSkillInPublicCD(skillId)
	return rlt
end

function CardLibModel:getCdBySkillId(skillId)
	local skillInfo = self.__learnedSkills[skillId]
	if not skillInfo then
		return 0,0
	end

	return skillInfo.cd, skillInfo.pcd, skillInfo.cdAcc
end

--挂机过程中手动释放的技能
function CardLibModel:setWaitToUseSkill(skill)
	self.__waitToUseSkill = skill
end

function CardLibModel:getWaitToUseSkill()
	return self.__waitToUseSkill
end

--切地图需要移除等待释放的技能
function CardLibModel:clearWaitSkils()
	self.__waitToUseSkill = false
end

--获取技能图标
function CardLibModel:getItemIconByskillId(skillId)
	printTable(5,"打印的技能数据12",skillId);	
	return "Icon/skill/"..skillId..".png"
end

--获取卡牌品质框
function CardLibModel:getCardQualityByStar(star, isSmall)
	local resInfo= DynamicConfigData.t_heroResource[star]
	if resInfo then
		if isSmall then
			return PathConfiger.getCardQuaColor(resInfo.qualityRes);
		end
		return PathConfiger.getCardQualitybg(resInfo.qualityRes);
	end
	if isSmall then
		return PathConfiger.getCardQuaColor(3);
	end
	return PathConfiger.getCardQualitybg(3)
end



function CardLibModel:getCardIconByCategory(category)
	return PathConfiger.getCardCategory(category);
end

--获取卡牌图片
function CardLibModel:getCardQualityByStar1(star,type)
	local resInfo= DynamicConfigData.t_heroResource[star]
	if type == 1 then
		return resInfo.qualityRes
	else
		if resInfo then
			return "Icon/heroCard/cardqualityarticle"..resInfo.qualityRes..'.png';
		end
		return "Icon/heroCard/cardqualityarticle3.png"
	end
end

--获取满阶卡牌数量
function CardLibModel:getFullStepCardNum()
	local num = 0
	for category, groupInfos in pairs(self.__heroInfos) do
		for k, v in pairs(self.__heroInfos[category]) do
			if(v.stage >= 10 ) then
				num = num + 1
			end
		end
	end
	return num
end

--获取满星卡牌数量
function CardLibModel:getFullStarCardNum()
	local num = 0
	for category, groupInfos in pairs(self.__heroInfos) do
		for k, v in pairs(self.__heroInfos[category]) do
			if(v.star >= 18 ) then
				num = num + 1
			end
		end
	end
	return num
end

--获取满星卡牌数量
function CardLibModel:isHeroGot(heroId)
	for category, groupInfos in pairs(self.__heroInfos) do
		for k, v in pairs(self.__heroInfos[category]) do
			if v.code == heroId then
				return true
			end
		end
	end
	return false
end

function CardLibModel:redCheck()
	GlobalUtil.delayCallOnce("CardLibModel:redCheck",function()
		self:updateRedCheck()
		self:starUpRedCheck()
		self:stepUpRedCheck()
		-- self:taletRedCheck()
		self:heroUpStarRedChcek()
		self:matchPointRedCheck()
		TalentModel:checkRed()
		EquipmentModel:redCheck()
		self:segmentRedCheck()
	end, self, 0.5)
end


function CardLibModel:updateRedCheck()
	local allCards = self:getAllCards()
	local battleHero = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
	for i,info in ipairs(allCards) do
		local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
		if not hero then break end
		local canUp = false
		local continue = false
		if battleHero.array[info.uuid] then
			local heroLeveInfo = DynamicConfigData.t_heroLevel[hero.level + 1]
			local isInHeroPalace = ModelManager.HeroPalaceModel:isInGroupB(hero.uuid)
			local maxStep = #(DynamicConfigData.t_heroStage)
			local limitLv = HeroConfiger.getNextLevelLimit(hero.stage, hero.level) + self:getSegmentAddLvMax(hero)
			if heroLeveInfo then 
				if isInHeroPalace then continue = true end
				-- if not continue and hero.stage < heroLeveInfo.stageLimit then continue = true end
				if not continue and hero.level >= limitLv then continue = true end
				--if not continue and hero.star < heroLeveInfo.starLimit then continue = true end
				--if not continue and  (#heroLeveInfo.levelLimit > 0 and not ModelManager.HeroPalaceModel:isCanLvUp(heroLeveInfo.levelLimit[1],heroLeveInfo.levelLimit[2], hero.uuid)) then continue = true end
				local upgradeCost = {
						{type = heroLeveInfo.type1, code = heroLeveInfo.code1, amount = heroLeveInfo.amount1},
						{type = heroLeveInfo.type2, code = heroLeveInfo.code2, amount = heroLeveInfo.amount2},
					}
				if not continue and  ModelManager.PlayerModel:isCostEnough(upgradeCost, false) then
					canUp = true
				end
			end
		end
		RedManager.updateValue("V_CardUpgrade"..hero.uuid, canUp)
	end
	
end
function CardLibModel:heroUpStarRedChcek()
	local StarRule = {{1,2,3,4,5},{2},{3,5},{1,4}}--升星规则
	local redMap = {}
	local categoryRedMap = {}
	local allCards = self:getAllCards()
	local battleHero = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
	for _,info in pairs(allCards) do
		local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
		if not hero then break end
		if hero.star >= 4 then
			local canUp = true
			local starRule = hero.heroDataConfiger.starRule
			local heroStarInfo = DynamicConfigData.t_heroStar[starRule] and DynamicConfigData.t_heroStar[starRule][hero.star]
			local ruldId = 0
			for key,group in pairs(StarRule) do
				for k,v in pairs(group) do
					if v == starRule then
						ruldId = key
					end
				end
			end
			if heroStarInfo then
				local upstarLimit = heroStarInfo.upstarLimit
				if upstarLimit and #upstarLimit > 0 then
					for _,v in pairs(upstarLimit) do
						if v.type == 1 then
							if hero.level < v.num then
								canUp = false
							end
						elseif v.type == 2 then
							if ModelManager.HeroPalaceModel:getLevel() < v.num then
								canUp = false
							end
						elseif v.type == 3 then
							if not ModelManager.CardLibModel:isStarHeroEnough(v.num, v.num2) then
								canUp = false
							end
						end
					end		
				end
				if canUp then
					local cost = heroStarInfo.material
					local material = self:getUpStarMaterials(hero.code,hero.star)
					if material and (not self:isMaterialEnough(material,hero) or not ModelManager.PlayerModel:isCostEnough(cost, false)) then
						canUp = false
					end
				end
			else
				canUp = false	
			end
			RedManager.updateValue("V_HERO_LVELEUP"..info.uuid,canUp)
			table.insert(redMap,"V_HERO_LVELEUP"..info.uuid)
			if canUp then
				if not categoryRedMap[hero.heroDataConfiger.category] then
					categoryRedMap[hero.heroDataConfiger.category] = {}
				end
				categoryRedMap[hero.heroDataConfiger.category][ruldId] = true
			end
		end
	end
	RedManager.addMap("M_HERO_LEVELUP", redMap)
	self:heroUpStarRedHandle(categoryRedMap)
end
--侦探社红点需求
function CardLibModel:heroUpStarRedHandle(categoryRedMap)
	for i = 0,5 do
		for j = 1,4 do
			RedManager.updateValue("V_HERO_LVELEUP_CATEGORY"..i .."_" ..j,false)
		end
	end
	for category,group in pairs(categoryRedMap) do
		for ruldId,value in pairs(group) do
			if not RedManager.getTips("V_HERO_LVELEUP_CATEGORY"..category .."_" .. ruldId) then
				RedManager.updateValue("V_HERO_LVELEUP_CATEGORY"..category .."_" .. ruldId,true)
				RedManager.updateValue("V_HERO_LVELEUP_CATEGORY"..category .."_1",true)--有种族红点那所有按钮肯定有红点
				RedManager.updateValue("V_HERO_LVELEUP_CATEGORY0_1",true)--有种族红点那所有按钮肯定有红点
				RedManager.updateValue("V_HERO_LVELEUP_CATEGORY0" .."_"..ruldId,true)--所有按钮下面的种族红点
			end
		end
	end
end
function CardLibModel:starUpRedCheck()
	local allCards = self:getAllCards()
	local battleHero = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
	for _,info in pairs(allCards) do
		local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
		if not hero then break end
		local canUp = true
		if battleHero.array[info.uuid] then
			if hero.star >= 5 then
				local starRule = hero.heroDataConfiger.starRule
				local heroStarInfo = DynamicConfigData.t_heroStar[starRule][hero.star]
				if heroStarInfo then
					local upstarLimit = heroStarInfo.upstarLimit
					if upstarLimit and #upstarLimit > 0 then
						for _,v in pairs(upstarLimit) do
							if v.type == 1 then
								if hero.level < v.num then
									canUp = false
								end
							elseif v.type == 2 then
								if ModelManager.HeroPalaceModel:getLevel() < v.num then
									canUp = false
								end
							elseif v.type == 3 then
								if not ModelManager.CardLibModel:isStarHeroEnough(v.num, v.num2) then
									canUp = false
								end
							end
						end		
					end
					if canUp then
						local cost = heroStarInfo.material
						local material = self:getUpStarMaterials(hero.code,hero.star)
						if material and (not self:isMaterialEnough(material,hero) or not ModelManager.PlayerModel:isCostEnough(cost, false)) then
							canUp = false
						end
					end
					--[[local cost = heroStarInfo.material
					local material = self:getUpStarMaterials(hero.code,hero.star)
					--local 
					if material and self:isMaterialEnough(material,hero) and ModelManager.PlayerModel:isCostEnough(cost, false) then
						canUp = true
					end--]]
				else
					canUp = false
				end
			else
				canUp = false
			end		
		else
			canUp = false
		end
		RedManager.updateValue("V_CardStarUp"..info.uuid, canUp)
	end
end

function CardLibModel:stepUpRedCheck()
	local allCards = self:getAllCards()
	local battleHero = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
	for _,info in pairs(allCards) do
		local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
		if not hero then break end
		local canUp = false
		local continue = false
		if battleHero.array[info.uuid] then
			local heroStageInfo=DynamicConfigData.t_heroStage[(hero.stage+1)]--读表的数据
			local heroLeveInfo = DynamicConfigData.t_heroLevel[hero.level + 1]
			local isInHeroPalace = ModelManager.HeroPalaceModel:isInGroupB(hero.uuid)
			local maxStep = #(DynamicConfigData.t_heroStage)
			if heroLeveInfo and heroStageInfo and hero.star >= heroStageInfo.StarLimit then 
				if isInHeroPalace then continue = true end
				--if not continue and #heroLeveInfo.levelLimit > 0 and  not ModelManager.HeroPalaceModel:isCanLvUp(heroLeveInfo.levelLimit[1],heroLeveInfo.levelLimit[2], hero.uuid) then continue = true end
				if not continue and hero.stage >= heroLeveInfo.stageLimit then continue = true end
				if not continue and hero.stage >= 6 then continue = true end  --最高能升到6阶
				if not continue and ModelManager.PlayerModel:isCostEnough(heroStageInfo.costList, false) then
					canUp = true
				end
			end
		end
		RedManager.updateValue("V_CardStepUp"..hero.uuid, canUp)
	end
end

function CardLibModel:taletRedCheck()
	-- local allCards = self:getAllCards()
	-- local battleHero = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
	-- for _,info in pairs(allCards) do
	-- 	local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
	-- 	if hero --[[ and hero.level >= 140]] then
	-- 		for _,skillId in ipairs(hero.heroDataConfiger.passiveSkill) do
	-- 			--needCheckSkill[skillId] = 1
	-- 			local skillInfo = DynamicConfigData.t_passiveSkill[skillId]
	-- 			local activeCost = skillInfo.activeCost
	-- 			local canUp = (battleHero.array[info.uuid] ~= nil) 
	-- 							and (hero.reservedSkill[skillId])
	-- 							and (ModelManager.PlayerModel:isCostEnough(activeCost, false));
	-- 			RedManager.updateValue("V_passiveSkill"..hero.uuid.."_"..skillId, canUp)
	-- 		end
	-- 	end
	-- end
end

function CardLibModel:matchPointRedCheck()
	local allCard = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
	for _,info in pairs(allCard.array) do
		local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
		if not hero then break end
		local canUp = hero.attrPointPlanNew and hero.attrPointPlanNew[hero.attrPointId] and hero.attrPointPlanNew[hero.attrPointId].attrPointNum > 0
		RedManager.updateValue("V_CardMatchPoint"..hero.uuid, canUp)
	end
end

function CardLibModel:jewelryRedCheck()
	local allCards = self:getAllCards()
	local battleHero = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
	local jeBagLen = TableUtil.GetTableLen(PackModel:getJewelryBag().__packItems);
	for _,info in pairs(allCards) do
		local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid);
		if not hero then break end
		if (battleHero.array[info.uuid] ~= nil) then
			local hasJewelry = false
			for i = 1, 2 do
				local status = false;
				if (i == 1 and hero.level >= JewelryModel.GirdLeftLimit) then
					status = true;
				end
				if (i == 2 and hero.star >= JewelryModel.GirdRightLimit) then
					status = true;
				end
				if (status) then
					local je = hero.jewelryMap[i];
					if ((not je or (je and not je.uuid))  -- 没有装备饰品
						 and jeBagLen > 0) then
						hasJewelry = true	
						-- RedManager.updateValue("V_CardEquip"..hero.uuid, true);
						RedManager.updateValue("V_Jewelry"..hero.uuid..i, true);
					else
						RedManager.updateValue("V_Jewelry"..hero.uuid..i, false);
					end
				end
			end
			RedManager.updateValue("V_Jewelry"..hero.uuid, hasJewelry);
		end
	end
end

--获取英雄背包是否满了
--willAddNum 准备要添加多少，如果没添加可以不传
function CardLibModel:isBagFull(willAddNum)
	if not willAddNum then willAddNum  =  0 end
	local cardNumber=ModelManager.CardLibModel:getActivationCardNumber();
	local cardAllNumber= 200 + VipModel:getVipPrivilige(15);--#(DynamicConfigData.t_hero);
	return (cardNumber + willAddNum) > cardAllNumber
end
--获取备战英雄列表
function CardLibModel:getFightHeroList(mapConfig)
	local arrayType = mapConfig.configType
	local heroList = {}
	local allCard 
	--次元裂缝只能拿共生殿里面的英雄
	if arrayType == GameDef.BattleArrayType.GuildWorldBossNumOne 
		or arrayType == GameDef.BattleArrayType.GuildWorldBossNumTwo 
		or arrayType == GameDef.BattleArrayType.GuildWorldBossNumThree
		or arrayType == GameDef.BattleArrayType.NewHeroCopy  then
		allCard = ModelManager.HeroPalaceModel:getChooseUuids()
		for _,uuid in ipairs(allCard) do
			local v = ModelManager.CardLibModel:getHeroByUid(uuid)
			if v then
				local heroInfo = {}
				heroInfo['level'] = v.level
				heroInfo['star'] = v.star
				heroInfo['code'] = v.heroId
				heroInfo['maxHp'] = v.attrs[1] and v.attrs[1].value or 0
				heroInfo['hp'] = v.attrs[1] and v.attrs[1].value or 0
				heroInfo['uuid'] = v.uuid
				heroInfo['combat'] = v.combat
				heroInfo['fashion'] = v.fashion and v.fashion.code
				heroInfo["uniqueWeapon"] = v.uniqueWeapon and v.uniqueWeapon.level or -1
				heroList[v.uuid] = heroInfo
				
			end
		end
	elseif arrayType == GameDef.BattleArrayType.EndlessRoad then
		--远征的只选某种族或者某职业的
		allCard = self:getAllCards()
		for _,v in ipairs(allCard) do
			if v.category == mapConfig.zhongzu or v.professional == mapConfig.zhiye then
				local heroInfo = {}
				heroInfo['level'] = v.level
				heroInfo['star'] = v.star
				heroInfo['code'] = v.heroId
				heroInfo['maxHp'] = v.attrs[1] and v.attrs[1].value or 0
				heroInfo['hp'] = v.attrs[1] and v.attrs[1].value or 0
				heroInfo['uuid'] = v.uuid
				heroInfo['combat'] = v.combat
				heroInfo['fashion'] = v.fashion and v.fashion.code
				heroInfo["uniqueWeapon"] = v.uniqueWeapon and v.uniqueWeapon.level or -1
				heroList[v.uuid] = heroInfo
			end
		end
	elseif (arrayType == GameDef.BattleArrayType.Boundary or 
			arrayType == GameDef.BattleArrayType.BoundaryAssassin or
			arrayType == GameDef.BattleArrayType.BoundaryStriker or
			arrayType == GameDef.BattleArrayType.BoundaryWarrior or
			arrayType == GameDef.BattleArrayType.BoundaryMage) and mapConfig.vocation and next(mapConfig.vocation) then
		allCard = self:getAllCards()
		for key,vocationId in pairs(mapConfig.vocation) do
			for _,v in ipairs(allCard) do
				if v.heroDataConfiger.professional == vocationId then
					local heroInfo = {}
					heroInfo['level'] = v.level
					heroInfo['star'] = v.star
					heroInfo['code'] = v.heroId
					heroInfo['maxHp'] = v.attrs[1] and v.attrs[1].value or 0
					heroInfo['hp'] = v.attrs[1] and v.attrs[1].value or 0
					heroInfo['uuid'] = v.uuid
					heroInfo['combat'] = v.combat
					heroInfo['fashion'] = v.fashion and v.fashion.code
					heroInfo["uniqueWeapon"] = v.uniqueWeapon and v.uniqueWeapon.level or -1
					heroList[v.uuid] = heroInfo
				end
			end
		end
	else
		allCard = self:getAllCards()
		for _,v in ipairs(allCard) do
			local heroInfo = {}
			heroInfo['level'] = v.level
			heroInfo['star'] = v.star
			heroInfo['code'] = v.heroId
			heroInfo['maxHp'] = v.attrs[1] and v.attrs[1].value or 0
			heroInfo['hp'] = v.attrs[1] and v.attrs[1].value or 0
			heroInfo['uuid'] = v.uuid
			heroInfo['combat'] = v.combat
			heroInfo['fashion'] = v.fashion and v.fashion.code
			heroInfo["uniqueWeapon"] = v.uniqueWeapon and v.uniqueWeapon.level or -1
			heroList[v.uuid] = heroInfo
		end
	end
	return heroList
end

function CardLibModel:getSegmentAddLvMax(heroInfo)
    local heroConf = DynamicConfigData.t_hero[heroInfo.code];
	local category = (heroConf.category == 1 or heroConf.category == 2) and 2 or 1;
    local conf = DynamicConfigData.t_HeroSegmentAttr[category];
	local value = 0 -- HeroConfiger.getNextLevelLimit(self.hero.stage, self.hero.level);
	local info
	if heroInfo.starSegment then
		info = heroInfo.starSegment[heroInfo.star] or heroInfo.starSegment[heroInfo.star - 1]
	end
    local starSegment = info or false
	local segment = starSegment and starSegment.starSegment or {};

    for starlv, attrConf in pairs(conf) do
        if (starlv <= heroInfo.star) then
            for id, d in pairs(segment) do
                local c = attrConf[id]
                if (c and d.isActivate) then
                    value = value + c.addlevel;
                end
            end
        end
    end
    return value
end

function CardLibModel:clear()
	--if handle then
		--Scheduler.unschedule(handle)
		--handle = false
	--end
	--self:init()
end
--if handle==false then
	--CardLibModel:init()
--end

-- 英雄20星红点
function CardLibModel:segmentRedCheck()
	local str = ModuleUtil.getModuleOpenTips(ModuleId.CardStarUp20.id)
	if (not ModuleUtil.getModuleOpenTips(ModuleId.CardStarUp20.id)) then

		local allCards = self:getAllCards()
		local battleHero = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
		local jeBagLen = TableUtil.GetTableLen(PackModel:getJewelryBag().__packItems);
		for _,info in pairs(allCards) do
			if (battleHero.array[info.uuid] ~= nil) then
				local baseFlag = RedManager.getTips("V_CardStarUp"..info.uuid);
				local segmentFlag = false;
				local star = info.star--19
				-- if (info.starSegment and info.starSegment[info.star]) then
					local segment = info.starSegment and info.starSegment[star] or false
					if (not segment and not DynamicConfigData.t_HeroSegment[star]) then
						segmentFlag = false;
						for i = 1, 4 do
							RedManager.updateValue("V_CardStarUp_"..info.uuid.."_"..i, false);
						end
					else
						local se = segment and segment.starSegment or {};
						for i = 1, 4 do
							local isActivate = se[i] and se[i].isActivate or false;
							if (not isActivate) then -- 没激活
								local canUp = true;
								local material = self:getMaterialsList20Segment(info, i, true);
								for _, cost in pairs(material) do
									if (cost.star) then
										local chooseList = self:getStarCanChooseInfo20Segment(cost, info);
										if (cost.num > #chooseList) then
											canUp = false;
										end
									else
										if (not ModelManager.PlayerModel:checkCostEnough(cost, false)) then
											canUp = false;
										end
									end
								end
								RedManager.updateValue("V_CardStarUp_"..info.uuid.."_"..i, canUp);
								segmentFlag = canUp or segmentFlag;
							else
								RedManager.updateValue("V_CardStarUp_"..info.uuid.."_"..i, false);
								segmentFlag = false;
							end
						end
					end
					
				-- end
				RedManager.updateValue("V_CardStarUp"..info.uuid, baseFlag or segmentFlag);
			end
		end

	end
end


function CardLibModel:getStarCanChooseInfo20Segment(materials, heroInfo, excludeUuid)
	local chooseList={};
	local type = materials.type;
    local star = materials.star;
	
	local heroConf = DynamicConfigData.t_hero
	local hasChooseList = excludeUuid or {}
	local category = heroConf[heroInfo.code].category;
	local hasBattle = ModelManager.BattleModel:getArrayType(heroInfo.uuid);
	
	local backConf = DynamicConfigData.t_BackstarItem;
    local categoryInfo = self.__heroInfos[tonumber(category)]
    
	if type==1 then
		for key, value in pairs(categoryInfo) do
			if value.star==star and value.code==heroInfo.heroId and heroInfo.uuid ~=key and hasChooseList[key]==nil then
				chooseList[#chooseList+1]=value	;
			end 
		end
	elseif type==2 then
		-- 可以使用相同种族和星级的替身
		local replaceConf = backConf[category][star];
		if (replaceConf) then
			local replaceCount = (replaceConf and replaceConf.id) and ModelManager.PackModel:getItemsFromAllPackByCode(replaceConf.id) or 0;
			local choosedCount = hasChooseList[replaceConf.id] or 0;
			replaceCount = math.max(replaceCount - choosedCount, 0);
			for i = 1, replaceCount do
				chooseList[#chooseList+1]={code=replaceConf.id, type=GameDef.GameResType.Item, amount=1, category = category, star = star, idx = #chooseList+1};
			end
		end
		-- 同种族英雄
		for key1, value in pairs(categoryInfo) do
			if value.star==star and heroInfo.uuid ~=key1 and hasChooseList[key1]==nil then
				chooseList[#chooseList+1]=value	;
			end 
		end
		if star == 5 then -- 需要5星卡牌时，增加快捷合成
			-- 获取4星级同阵营中拥有足够合成材料的探员
			local heros = {}
			local heroIds = {} -- 同一个探员只显示一个
			for key, value in pairs(categoryInfo) do
				value.quickUp = false 
				if value.star == 4 and hasChooseList[key] == nil then
					local _materials = self:getUpStarMaterials(value.code, value.star)
					if self:isMaterialEnough(_materials, value) and not heroIds[value.heroId] then -- 拥有足够合成材料
						value.quickUp = true
						table.insert(heros, value)
						heroIds[value.heroId] = true
					end
				end
			end
			for k, v in ipairs(heros) do
				table.insert(chooseList, 1, v)
			end
		end
	elseif type==3 then
		-- 替换材料
		for m = 0, 5 do
			local replaceConf = backConf[m][star];
			if (replaceConf) then
				local replaceCount = (replaceConf and replaceConf.id) and ModelManager.PackModel:getItemsFromAllPackByCode(replaceConf.id) or 0;
				local choosedCount = hasChooseList[replaceConf.id] or 0;
				replaceCount = math.max(replaceCount - choosedCount, 0);
				for i = 1, replaceCount do
					chooseList[#chooseList+1]={code=replaceConf.id, type=GameDef.GameResType.Item, amount=1, category = m, star = star, idx = #chooseList+1};
				end
			end
		end
		-- 英雄材料
		categoryInfo = self:getCardByCategory(0)
		for key1, value in pairs(categoryInfo) do
			if value.star==star and heroInfo.uuid ~=value.uuid and hasChooseList[value.uuid]==nil then
				chooseList[#chooseList+1]=value	;
			end 
		end
	end
	return chooseList;
end

function CardLibModel:getMaterialsList20Segment(heroInfo, pos, haveMaterial)
    haveMaterial = haveMaterial or false;
    local heroCode = heroInfo.code;
    local conf = DynamicConfigData.t_HeroSegment[heroInfo.star];
    local c = conf and conf[pos] or {};
	local temp = {}
	if (conf) then
		if (#c.self > 0) then  -- 本卡牌id
			for k, d in ipairs(c.self) do
				d.type = 1
				d.hero = heroCode
				table.insert(temp, d)
			end
		end
		if (#c.faction > 0) then  -- 本种族
			for k, d in ipairs(c.faction) do
				d.type = 2
				table.insert(temp, d)
			end
		end
		if (#c.free > 0) then  -- 无规则限制
			for k, d in ipairs(c.free) do
				d.type = 3
				table.insert(temp, d)
			end
		end
		if (#c.special > 0) then  -- 特殊要求
			for k, d in ipairs(c.special) do
				d.type = 1
				table.insert(temp, d)
			end
		end
		if (#c.exclusive) then
			for k, d in ipairs(c.exclusive) do
				table.insert(temp, d)
			end
		end
		if (haveMaterial and #c.material) then
			for k, d in ipairs(c.material) do
				table.insert(temp, d)
			end
		end
	end
    return temp;
end

function CardLibModel:isActivateSegment(heroInfo)
	if (not heroInfo) then return false end
	--if (heroInfo.star > 19) then return true end
	local starSegment = heroInfo.starSegment and heroInfo.starSegment[heroInfo.star] or false;
	local segment = starSegment and starSegment.starSegment or false;
	if (segment) then
		for i = 1, 4 do
			if (segment[i] and segment[i].isActivate) then
				return true;
			end
		end
	end
	return false;
end

return CardLibModel
