--Name : SecretWeaponsModel.lua
--Author : generated by FairyGUI
--Date : 2020-7-28
--Desc : 


local SecretWeaponsModel = class("SecretWeaponsModel", BaseModel)

local __MY_SEATID = 141 -- 我的秘武的位置
local __OTHER_SEATID = 241 -- 别人秘武的位置

function SecretWeaponsModel:ctor()
	self.secretWeaponsInfo= {}--所有的秘武数据
	self.secretOldLevel=1
	self.chooseInfo={}
	self.bothBattlePreEquipInfo={}--秘武备战界面双方装配秘武数据
	self.bothBattleEquipInfo={}--秘武战斗界面双方装配秘武数据
	self.secretFightRound = {}
	self.battleround = {}
	self.secretWeaponsTaskInfo = {}--秘武幻化任务数据
	self.isShowJingdutiaoAnim=false
end

function SecretWeaponsModel:updateSecretWeaponsTaskInfo(taskInfo)
	if taskInfo.gamePlayType ~= GameDef.GamePlayType.GodArms then
		return
	end
	self.secretWeaponsTaskInfo[taskInfo.recordId] = taskInfo
	self:onCheckIllusionRewardRed()
end

function SecretWeaponsModel:getSecretWeaponsTaskInfo(taskId)
	return self.secretWeaponsTaskInfo[taskId] or {}
end

function SecretWeaponsModel:getAllTaskGotInfo(id)
	local config = DynamicConfigData.t_godArmsMission[id]
	if not config then 
		return false
	end
	local gotNum = 0
	local num = 0
	for _,v in pairs(config) do
		num = num + 1
		local taskId = v.taskId
		local taskInfo = self.secretWeaponsTaskInfo[taskId] or {}
		if taskInfo.got then 
			gotNum = gotNum + 1
		end
	end
	return gotNum == num
end

function SecretWeaponsModel:jingdutiaoAnim(com,pos)
	local animation=false
	if not pos then
		pos=Vector2.zero	
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "ui_jindutiaoshengji_up", "Effect/UI", "efx_shengqizhanshi", "efx_shengqizhanshi",false) 
	animation:setAnimation(0, "ui_jindutiaoshengji_up", false)
	return animation
end

function SecretWeaponsModel:dengjishengjiAnim(com,pos)
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "ui_dengjitisheng_up", "Effect/UI", "efx_shengqizhanshi", "efx_shengqizhanshi",false) 
	animation:setAnimation(0, "ui_dengjitisheng_up", false)
	return animation
end

function SecretWeaponsModel:getskillLvDesc()
	local isShow=true
	local skillLv=1
	local serverInfo = self.secretWeaponsInfo
    if not serverInfo then
        skillLv=1
	end
	local equipMap = serverInfo.godArmsMap
	if not equipMap then
		return false ,skillLv ,""
	end
	if not equipMap[1] then
		return false ,skillLv ,""
	end
	skillLv=equipMap[1].level
	local configInfo= DynamicConfigData.t_GodArmsSkillLevel
	local max= #configInfo
	if skillLv>=max then
		return  isShow,skillLv,DescAuto[260] -- [260]="(已满级)"
	else
		local str= configInfo[skillLv+1].godArmsLevel
		return  isShow, skillLv,string.format(DescAuto[261],str) -- [261]="(解锁下级技能需要秘武系统达到Lv%s)"
	end 
end

-- 秘武当前回合的冷却总数
function SecretWeaponsModel:getCurrentCD(id,type,level,roundNum,args)
    local skillId = DynamicConfigData.t_godArms[id][level].skillId -- 技能id
	local coolRound = DynamicConfigData.t_skill[skillId].coolRound -- 技能冷却回合
    if not coolRound then coolRound = 0 end
	local secretFightRound = ModelManager.SecretWeaponsModel:initFightData(args) or {}
	secretFightRound = secretFightRound[type] or {} 
	if self.battleround[args.arrayType] then
    self.battleround[args.arrayType][type] = coolRound
		for k,v in pairs(secretFightRound) do
			if k <= roundNum then
				if v and (roundNum <= self:getLastRoundNum(args)) then
					self.battleround[args.arrayType][type] = coolRound + self.battleround[args.arrayType][type]
				end
			end
		end
	end
end

function SecretWeaponsModel:initFightData(args)
	local battleData    = FightManager.getBettleData(args.arrayType)      -- 战报数据
	if not battleData or not battleData.roundDataSeq then return {} end
	local roundDataSeq  = battleData.roundDataSeq
	for iIndex,iVal in pairs(roundDataSeq) do
		for i=1,2 do 
			if not self.secretFightRound[i] then
				self.secretFightRound[i] = {}
			end
		end
		local findMySeatId = false
		local findOtherSeatId = false
		for kIndex,kVal in pairs(iVal.dataSeq) do
			local fightObjDataSeq = kVal.fightObjDataSeq
			local seatId = fightObjDataSeq[1].id
			if seatId == __MY_SEATID then
				findMySeatId = true
			end
			if seatId == __OTHER_SEATID then
				findOtherSeatId = true
			end
		end
		self.secretFightRound[1][iIndex] = findMySeatId
		self.secretFightRound[2][iIndex] = findOtherSeatId
	end
	return self.secretFightRound
end

function SecretWeaponsModel:getLastRoundNum(args)
	local battleData    = FightManager.getBettleData(args.arrayType)      -- 战报数据
	if not battleData or not battleData.roundDataSeq then return 1 end
	local roundDataSeq  = battleData.roundDataSeq
	return TableUtil.GetTableLen(roundDataSeq)
end


function SecretWeaponsModel:getEquipById(id)
    return string.format("%s%s.png", "UI/SecretWeapons/SecretWeaponsEqui_",id)  
end

function SecretWeaponsModel:getSecretWeaponsGetbg()
    return string.format("%s", "UI/SecretWeapons/SecretWeaponsGetbg.png")  
end

function SecretWeaponsModel:getItemSucceeStarts( attrMap, curStage)
	local index=false
	for i = 1, #attrMap, 1 do
		local id= attrMap[i]
		if id==curStage then
			index=true
		end
	end
	return index
end

function SecretWeaponsModel:getItemIndex(attrMap, curStage)
	local index=0
	for i = 1, #attrMap, 1 do
		local id= attrMap[i]
		if id<=curStage then
			index=i
		end
	end
	return index
end

function SecretWeaponsModel:getOneEquipSkillLvAttr(id)
	local lv= self:getEquipSkillLv(id)
	local ConfigSkill=DynamicConfigData.t_godArms
	local configOd= ConfigSkill[id]
	if lv==0 then
		lv=1
	end
	if not configOd[lv] then
		return {}
	end
	return  configOd[lv].addAttr
end

function SecretWeaponsModel:getPromoteRed()--秘武炼化提升红点
	local red=false
	local configInfo=DynamicConfigData.t_godArmsCost
	local cost=configInfo[3].cost
	local count= self:getAscendingnumber()
	local maxLimit=configInfo[3].param
	local  enough =GMethodUtil:getGoodsEnough(cost[1])
	if enough and count<maxLimit then
		red=true
	end
	RedManager.updateValue("V_SECRETWEAPONSPROMOTERED",red);  	
end

function SecretWeaponsModel:redCheck()
	GlobalUtil.delayCallOnce("SecretWeaponsModel:redCheck", function()
		local canUpgrade = false
		local secretWeaponsInfo = self.secretWeaponsInfo
		if not secretWeaponsInfo then return end
		local costInfo = DynamicConfigData.t_GodArmsForgeCost[(secretWeaponsInfo.refineLv or 0)+1]
		if costInfo then			
			canUpgrade = ModelManager.PlayerModel:isCostEnough(costInfo.cost, false)
		end
		RedManager.updateValue("V_SECRETWEAPON_REFINE", canUpgrade)	
	end, self, 0.5)
end


function SecretWeaponsModel:getSkillLvRed()--秘武技能点>0并且满足消耗红点
	-- local upRed1=false--升级红点--已激活技能点大于零并且未满级
	-- local Remine= self:getRemineSkillPoint()--剩余技能点
	-- local configInfo = DynamicConfigData.t_godArmsTrigger
    -- for i = 1, #configInfo, 1 do
	-- 	local configItem = configInfo[i]
	-- 	local id= configItem.id
	-- 	local yijihuo =self:getEquipOpen(id)--已激活
	-- 	local lv= self:getEquipSkillLv(id)
	-- 	local ConfigSkill=DynamicConfigData.t_godArms
	-- 	local configOd= ConfigSkill[id]
	-- 	local max=#configOd
	-- 	if not configOd[lv] then
	-- 		break
	-- 	end
	-- 	local curCost=configOd[lv].point
	-- 	if Remine>0 and Remine>=curCost and yijihuo==true and lv<max then
	-- 		upRed1=true
	-- 		break
	-- 	end
	-- end
	-- printTable(150,"@@@@@@@#",upRed1)
	-- RedManager.updateValue("V_SECRETWEAPONSSKILLDIANRED",upRed1);  	
end

function SecretWeaponsModel:getEquipUpLvRed()--升级突破红点
	-- local upRed1=false--升级红点
	-- local upRed2=false--升级红点
	 local onekeyRed=false--升级红点
	local tupoRed=false--突破红点
	local curLevel, nextLevel, curexp = self:getEquipLvAndExp()
	if self:isMaxLevel() == false and curLevel < nextLevel  then --不满级满级并且当前界面不是突破
		local configInfo=DynamicConfigData.t_godArmsCost
		local param1=configInfo[1].param
		local param2=configInfo[2].param
		local cost=self:getupLevelcost(1)
		local nextExp = self:getEquipBarExp()
		local hasNum1=	GMethodUtil:getGoodsCount(cost[1].type, cost[1].code)
		local hasNum2=	GMethodUtil:getGoodsCount(cost[2].type, cost[2].code)
		 if curexp+hasNum1*param1+param2*hasNum2>=nextExp then
			onekeyRed=true
		 end
		-- upRed1=GMethodUtil:getGoodsEnough(cost[1])
		-- upRed2=GMethodUtil:getGoodsEnough(cost[2])
	end
	-- RedManager.updateValue("V_SECRETWEAPONSUPLVRED1", upRed1);  
	-- RedManager.updateValue("V_SECRETWEAPONSUPLVRED2", upRed2);  
	 RedManager.updateValue("V_SECRETWEAPONONEKEYUP", onekeyRed);  

	if self:isMaxStage() == false and curLevel >= nextLevel then --是否是满阶
	 	local cost=self:getupLevelcost(2)
		local tupoState1=GMethodUtil:getGoodsEnough(cost[1])
		if tupoState1 then
			tupoRed=true
		end
	end
	printTable(150,"1111111111111",curLevel,nextLevel,onekeyRed,tupoRed)
	RedManager.updateValue("V_SECRETWEAPONSTUPORED", tupoRed);  
end

function SecretWeaponsModel:isCurChooseBtn(i)--是否是当前战斗选择方案
	local is=false
	local serverInfo= self.secretWeaponsInfo
	if not serverInfo then
		return is
	end
	if i==serverInfo.index  then
		is=true
	end
	return is
end

function SecretWeaponsModel:getDeployHuihe(equipIdMap,i)--得到回合数
	local huihe=0
	for i = 1, i, 1 do
		if equipIdMap[i] then
			local id=equipIdMap[i]
			local level=self:getEquipSkillLv(id)
			local itemAttr=DynamicConfigData.t_godArms[id]	
			if itemAttr then
				local itemMode=itemAttr[level].round
				huihe=huihe+itemMode
			end
		end
	end
	return huihe
end


function SecretWeaponsModel:getDeployBtnName(i)
	local serverInfo= self.secretWeaponsInfo
	if not serverInfo then
		return 1--没设置
	end
	if serverInfo.plans and serverInfo.plans[i] then
		return serverInfo.plans[i]
	end	
	return 1
end


function SecretWeaponsModel:setChooseItem(index,id)--添加选中
	local indexMap= self.chooseInfo[index]
	if not indexMap then
		indexMap={}
	end
	if self:isChooseTogether(indexMap, id)==false then
		table.insert(indexMap,id)
	end
	self.chooseInfo[index]=indexMap
	printTable(29,"wwwwqqweqweq",index,id,self.chooseInfo)
end

function SecretWeaponsModel:isChooseTogether(indexMap, id)
	for i = 1, #indexMap,1 do
		local mode=indexMap[i]
		if mode==id then
			return true
		end
	end
	return false
end

function SecretWeaponsModel:getChooseItemNum(index)--选中的个数
	local num=0
	local indexMap= self.chooseInfo[index]
	if not indexMap then
		return num
	end
	num= #indexMap
	return num
end

function SecretWeaponsModel:isChooseIdex(indexMap, id)
	local index=0
	for i = 1, #indexMap,1 do
		local mode=indexMap[i]
		if mode==id then
			index=i
		end
	end
	return index
end

function SecretWeaponsModel:deleteChooseItem(index,id)--删除选中
	printTable(29,"wwwwqqweqweq删除",index,id)
	local indexMap= self.chooseInfo[index]
	local Chooseindex= self:isChooseIdex(indexMap,id)
	table.remove(indexMap,Chooseindex)
	self.chooseInfo[index]=indexMap
	printTable(29,"wwwwqqweqweq删除后",index,id,self.chooseInfo)
end

function SecretWeaponsModel:clearChooseItem()
	for key, value in pairs(self.chooseInfo) do
		value=nil
	end
	self.chooseInfo={}
end

function  SecretWeaponsModel:getFanganChoosedIndex()
	local serverInfo = self.secretWeaponsInfo
	if not serverInfo then
		return 1
	end
	return serverInfo.index
end

function  SecretWeaponsModel:getFanganChoosed(index,id)
	local serverInfo = self.chooseInfo
	if not serverInfo then
		return false
	end
	if serverInfo and serverInfo[index] then
		for key, value in pairs(serverInfo[index]) do
			if value==id then
				return true
			end 
		end
	end 
	return  false
end


function  SecretWeaponsModel:getAscendingnumber()--提升次数
	local count=1
	local serverInfo = self.secretWeaponsInfo
	if not serverInfo then
		return count
	end
	return serverInfo.count
end

function  SecretWeaponsModel:getRemineSkillPoint(id)--剩余技能点
	local point=1
	local serverInfo = self.secretWeaponsInfo
	if not serverInfo then
		return point
	end
	return serverInfo.point
end

function  SecretWeaponsModel:getEquipSkillLv(id)
	local level=0
	local serverInfo = self.secretWeaponsInfo
	if not serverInfo then
		return level
	end
	local equipMap = serverInfo.godArmsMap
	if not equipMap or not equipMap[id] then
			return level
	end
		level=equipMap[id].level
		return level
end

function  SecretWeaponsModel:getEquipOpen(id)--已激活
	local serverInfo = self.secretWeaponsInfo
	if not serverInfo then
		return false
	end
	local equipMap = serverInfo.godArmsMap
	if equipMap and equipMap[id] then
		return	true
	end
	return false
end


function  SecretWeaponsModel:getCurLevel()
	local serverInfo=self.secretWeaponsInfo
	local level=1
	if serverInfo and serverInfo.level then
		level=serverInfo.level
	end
	return level
end

function  SecretWeaponsModel:getCurStage()
	local serverInfo=self.secretWeaponsInfo
	local stage=0
	if serverInfo and serverInfo.stage then
		stage=serverInfo.stage
	end
	return stage
end


function  SecretWeaponsModel:getupLevelcost(type) --type1升级--2突破
	local costMap={}
	if type==1 then
	local costConfig=DynamicConfigData.t_godArmsCost
	local cost1=costConfig[1].cost
	local cost2=costConfig[2].cost
	table.insert(costMap,cost1[1])
	table.insert(costMap,cost2[1])
	else
		local stageConfig=DynamicConfigData.t_godArmsStage
		local maxstage=#stageConfig
		local serverInfo=self.secretWeaponsInfo
		local stage=0
		if serverInfo and serverInfo.stage~=nil then
			stage=serverInfo.stage
		end
		if maxstage==nil then
			maxstage=100
		end
		if stage>=maxstage then
			stage=maxstage
		end
		if stageConfig[stage] then
			table.insert(costMap,stageConfig[stage].cost[1])	
		end
	end
	return costMap
end


function SecretWeaponsModel:isMaxLevel()--是否是满级
	local serverInfo=self.secretWeaponsInfo
	if not serverInfo then
		return 
	end
	local configInfo=DynamicConfigData.t_godArmsLevel
	if serverInfo.level and serverInfo.level>=#configInfo then
		return true
	end
	return false
end

function SecretWeaponsModel:isMaxStage()--是否是满阶
	local serverInfo=self.secretWeaponsInfo
	if not serverInfo then
		return 
	end
	local configInfo=DynamicConfigData.t_godArmsStage
	if serverInfo.stage>=#configInfo then
		return true
	end
	return false
end

function SecretWeaponsModel:getEquipBarExp()
	local serverInfo=self.secretWeaponsInfo
	if not serverInfo then
		return  0
	end
	local curLevel= serverInfo.level--#神器系统等级
	local info=DynamicConfigData.t_godArmsLevel[curLevel]
	if info then
		return info.nextExp
	end
	return 0
end

function SecretWeaponsModel:getEquipLvAndExp()
	local curLevel=0
	local curexp=0
	local curStage=0
	local serverInfo=self.secretWeaponsInfo
	if not serverInfo then
		return 
	end
	local maxstage=#DynamicConfigData.t_godArmsStage
	 curLevel= serverInfo.level--#神器系统等级
	 curStage= serverInfo.stage--#神器突破等级
	 curexp= serverInfo.curExp
	if curStage==maxstage then
		curStage=maxstage
	end
	local StageInfo=DynamicConfigData.t_godArmsStage[curStage]
	local nextLevel=0
	if StageInfo then
		nextLevel=StageInfo.maxLevel
	end
	 return curLevel,nextLevel,curexp
end

function SecretWeaponsModel:getEquipOpenDesc(id)
    local configInfo=DynamicConfigData.t_godArmsTrigger
    local item=configInfo[id]
    local limit=item.condtion
    for i = 1, #limit, 1 do
        local type=limit[1]
        local lv=limit[2]
        if type==1 then
            return DescAuto[262]..lv..DescAuto[263] -- [262]="玩家等级" -- [263]="解锁"
        elseif type==2 then
            local desc=self:getPushMapDesc(lv)
            return DescAuto[264]..desc..DescAuto[263] -- [264]="通关" -- [263]="解锁"
        elseif type == 3 then
        	return item.name
        end
    end
end

function SecretWeaponsModel:getPushMapDesc(limit)

    local config=DynamicConfigData.t_chaptersPoint
	for key, value in pairs(config) do
		for k, v in pairs(value) do
			if k==1 then
				--printTable(29,"wwwwwww",v)
			end
			for k1, v1 in pairs(v) do
				if v1.auto==limit then
					return v1.sidname
				end 
			end
		end
    end
    return "1-1-1"
end

--秘武总属性（系统属性+秘武激活属性+炼化属性+特殊等级突破属性）
function SecretWeaponsModel:getAllattr()
	local allattr={}
	local curLv= self:getCurLevel()	--系统属性(升级属性+突破属性)
	local configLv= DynamicConfigData.t_godArmsLevel[curLv]
	local lvAttrMap=configLv.addAttr--升级属性
	local curStage= self:getCurStage()
	local configstage= DynamicConfigData.t_godArmsStage[curStage]
	local stageAttrMap=configstage.addAttr--突破属性
	local stageSpiceAttrMap={}--特殊突破属性
	if next(stageSpiceAttrMap)~=nil  then
		stageSpiceAttrMap=configstage.exAttr
	end

	for key, value in pairs(lvAttrMap) do
		if not allattr[value.type] then
			allattr[value.type]=0
		end
		allattr[value.type]= allattr[value.type]  +value.value
	end

	for key, value in pairs(stageAttrMap) do
		if not allattr[value.type] then
			allattr[value.type]=0
		end
		allattr[value.type]= allattr[value.type]  +value.value
	end

	for key, value in pairs(stageSpiceAttrMap) do
		if not allattr[value.type] then
			allattr[value.type]=0
		end
		allattr[value.type]= allattr[value.type]  +value.value
	end

	local serverInfo = self.secretWeaponsInfo
    if not serverInfo then
        return allattr
    end
    local equipMap = serverInfo.godArmsMap--技能升级属性
	for key, value in pairs(equipMap) do
		local level=value.level
		local itemAttr=DynamicConfigData.t_godArms[key]
		if itemAttr then
		 local itemMode=itemAttr[level].addAttr
			for key, value in pairs(itemMode) do
				if not allattr[value.type] then
					allattr[value.type]=0
				end
				allattr[value.type]= allattr[value.type]  +value.value
			end
		end
	end
	local count=self:getAscendingnumber()--提升次数
	local configcount=DynamicConfigData.t_godArmsCost
    local countAttrMap=configcount[3].addAttr
	for key, value in pairs(countAttrMap) do
		if not allattr[value.type] then
			allattr[value.type]=0
		end
		allattr[value.type]= allattr[value.type]  +(value.value*count)
	end
	-- printTable(30,"wqwwwwwwwwwwwwwwwwwwlvAttrMap",lvAttrMap)
	-- printTable(30,"wqwwwwwwwwwwwwwwwwwwstageAttrMap",stageAttrMap)
	-- printTable(30,"wqwwwwwwwwwwwwwwwwwwstageSpiceAttrMap",stageSpiceAttrMap)
	-- printTable(30,"wqwwwwwwwwwwwwwwwwwwequipMap",equipMap)
	-- printTable(30,"wqwwwwwwwwwwwwwwwwwwcountAttrMap",countAttrMap)
	return allattr
end

function SecretWeaponsModel:setInfo(data)
	self.secretWeaponsInfo=data
	self:redCheck()
	local plans=data.plans
	if (plans) then
		for key, value in pairs(plans) do
			if value.records then
				for k, id in pairs(value.records) do
					self:setChooseItem(key,id)
				end
			end
		end
	end
end

function SecretWeaponsModel:getMybattleEquipInfo()
	if self.bothBattleEquipInfo.myGodArms==nil then
		self.bothBattleEquipInfo.myGodArms={}
	end 
	return 	self.bothBattleEquipInfo.myGodArms
end

function SecretWeaponsModel:getOtherbattleEquipInfo()
	if self.bothBattleEquipInfo.enemyGodArms==nil then
		self.bothBattleEquipInfo.enemyGodArms={}
	end 
	return 	self.bothBattleEquipInfo.enemyGodArms
end
--秘武备战界面双方装配秘武数据
function SecretWeaponsModel:getMybattlePreEquipInfo()
	if self.bothBattlePreEquipInfo.myGodArms==nil then
		self.bothBattlePreEquipInfo.myGodArms={}
	end 
	return 	self.bothBattlePreEquipInfo.myGodArms
end

function SecretWeaponsModel:getOtherbattlePreEquipInfo()
	if self.bothBattlePreEquipInfo.enemyGodArms==nil then
		self.bothBattlePreEquipInfo.enemyGodArms={}
	end 
	return 	self.bothBattlePreEquipInfo.enemyGodArms
end

--获取神器信息
function SecretWeaponsModel:godArmsGetInfo()
	local function success(data)
		if data.data then
			--self:setInfo(data.data)暂时注释不知道策划那天脑子又加回来了
			self.secretWeaponsInfo=data.data
			self.secretWeaponsTaskInfo = data.data.taskRecords or {}
			self:redCheck()
			if data.data.level then
				self.secretOldLevel=data.data.level
			end
		end
		self:getEquipUpLvRed()--升级突破红点
		self:getPromoteRed()--秘武炼化提升红点
		self:onCheckIllusionRewardRed()--秘武幻化红点
		self:onCheckIllusionActiveRed()
	--	self:getSkillLvRed()
		Dispatcher.dispatchEvent(EventType.secretWeapons_getInfo); 
	end
	local info = {
	}
	printTable(9,"获取神器信息",info)
	RPCReq.GodArms_GetInfo(info,success)
end

function SecretWeaponsModel:onCheckIllusionRewardRed()
	local redDot = false
	local configInfo=DynamicConfigData.t_GodArmsMission
	for key, value in pairs(configInfo) do
		local isOpen=self:getEquipOpen(key)
		for k, v in pairs(value) do
			local taskData = self:getSecretWeaponsTaskInfo(v.taskId)
			if not isOpen and taskData and taskData.finish and  not taskData.got   then
				redDot = true
				break
			end
		end
	end
	-- for _,v in pairs(self.secretWeaponsTaskInfo) do
	-- 	local finish = v.finish or false
	-- 	local got = v.got or false
	-- 	if finish and not got then 
	-- 		redDot = true
	-- 		break
	-- 	end
	-- end
	RedManager.updateValue("V_SECRETWEAPON_ILLUSION_REWARD",redDot)
	Dispatcher.dispatchEvent(EventType.SecretWeapons_reward)
end

function SecretWeaponsModel:onCheckIllusionActiveRed()
	local redDot = false
	local info = DynamicConfigData.t_godArmsTrigger
	for _,v in pairs(info) do
		local isOpen=self:getEquipOpen(v.triggerType)
		if not isOpen then --没有激活
			if v.condtion and v.condtion[1] == 3 then 
				local itemCost = v.itemCost[1]
				local haveNum = PackModel:getItemsFromAllPackByCode(itemCost.code)
				if haveNum >= itemCost.amount then 
					redDot = true
					break
				end
			end
		end
	end
	RedManager.updateValue("V_SECRETWEAPON_ILLUSION_ACTIVE",redDot)
	Dispatcher.dispatchEvent(EventType.SecretWeapons_active)
end

--增加经验
function SecretWeaponsModel:godArmsAddExp(costType,amount)
	--CardLibModel.cardfight=CardLibModel:getFightVal() or 0
	local function success(data)
		printTable(28,"增加经验返回",data)
		self.secretWeaponsInfo=data.data
		self:redCheck()
		self:getEquipUpLvRed()--升级突破红点
		if self.secretOldLevel~=data.data.level then
			Dispatcher.dispatchEvent(EventType.secretWeapons_UpLevel,data.data.level); 
			self.secretOldLevel=data.data.level
		end
		if  data.addCombat and data.addCombat>0 then
			RollTips.showAddFightPoint(data.addCombat)
		end
		Dispatcher.dispatchEvent(EventType.secretWeapons_AddExp); 
	end
	local function onFailed(errorTable)
		RollTips.showError(errorTable)
	end
	local info = {
        costType=costType,
        amount=amount
	}
	printTable(150,"增加经验",info)
	RPCReq.GodArms_AddExp(info,success,onFailed)
end


--一键升级
function SecretWeaponsModel:godArmsOnekeyUpLevel()
	local function success(data)
		self.secretWeaponsInfo=data.data
		self:redCheck()
		self:getEquipUpLvRed()--升级突破红点
		if self.secretOldLevel~=data.data.level then
			self.isShowJingdutiaoAnim=true
			Dispatcher.dispatchEvent(EventType.secretWeapons_UpLevel,data.data.level); 
			self.secretOldLevel=data.data.level
		end
		if  data.addCombat and data.addCombat>0 then
			RollTips.showAddFightPoint(data.addCombat)
		end
		Dispatcher.dispatchEvent(EventType.secretWeapons_AddExp); 
	end
	local function onFailed(errorTable)
		RollTips.showError(errorTable)
	end
	local info = {
	}
	RPCReq.GodArms_UpLevel(info,success,onFailed)
end

--升阶 突破
function SecretWeaponsModel:godArmsUpStage()
	--CardLibModel.cardfight=CardLibModel:getFightVal() or 0
	local function success(data)
		printTable(30,"升阶突破返回",data)
		self.secretWeaponsInfo=data.data
		self:redCheck()
		local curStage=self:getCurStage()
		local config=DynamicConfigData.t_godArmsStage
		if curStage<=#config then
			ViewManager.open("SecretWeaponsBreakView")
		end
		self:getEquipUpLvRed()--升级突破红点
		if data.addCombat and data.addCombat>0 then
			RollTips.showAddFightPoint(data.addCombat)
		end
		Dispatcher.dispatchEvent(EventType.secretWeapons_UpStage); 
	end
	local function onFailed(errorTable)
		RollTips.showError(errorTable)
	end
	local info = {
	}
	printTable(150,"升阶突破",info)
	RPCReq.GodArms_UpStage(info,success,onFailed)
end


--#炼化
function SecretWeaponsModel:godArmsUpCount()
	--CardLibModel.cardfight=CardLibModel:getFightVal() or 0
	local function success(data)
		printTable(28,"炼化返回",data)
		self.secretWeaponsInfo=data.data
		self:redCheck()
		self:getPromoteRed()--秘武炼化提升红点
		if data.addCombat and data.addCombat>0 then
			RollTips.showAddFightPoint(data.addCombat)
		end
		Dispatcher.dispatchEvent(EventType.secretWeapons_Lianhua); 
	end
	local function onFailed(errorTable)
		RollTips.showError(errorTable)
	end
	local info = {
	}
	printTable(150,"炼化",info)
	RPCReq.GodArms_UpCount(info,success,onFailed)
end


--#方案修改
function SecretWeaponsModel:godArmsChangePlans(plans)
	local function success(data)
		printTable(29,"方案修改返回",data)
		if data and data.data then
			self:setInfo(data.data)
		end
	 	Dispatcher.dispatchEvent(EventType.secretWeapons_fanganxiugai); 
	end
	local info = {
		plans=plans
	}
	printTable(28,"方案修改",info)
	RPCReq.GodArms_ChangePlans(info,success)
end

--重置技能点
function SecretWeaponsModel:godArmsResetSkill()
	local function success(data)
		printTable(28,"重置技能点返回",data)
		self.secretWeaponsInfo=data.data
		self:redCheck()
		self:getSkillLvRed()
		Dispatcher.dispatchEvent(EventType.secretWeapons_chongzhijinengdian); 
	end
	local info = {
	}
	printTable(28,"重置技能点",info)
	RPCReq.GodArms_ResetSkill(info,success)
end

--#升级技能
function SecretWeaponsModel:godArmsUpSkill(id)
	local function success(data)
		printTable(28,"升级技能返回",data)
		self.secretWeaponsInfo=data.data
		self:redCheck()
		self:getSkillLvRed()
		Dispatcher.dispatchEvent(EventType.secretWeapons_shengjijinengdian); 
	end
	local info = {
        id=id
	}
	printTable(28,"升级技能",info)
	RPCReq.GodArms_UpSkill(info,success)
end


--#方案改名
function SecretWeaponsModel:godArmsChangeName(index,newName)
	local function success(data)
		printTable(29,"方案改名返回",data)
		if data and data.data then
			self.secretWeaponsInfo=data.data
			self:redCheck()
		end
		Dispatcher.dispatchEvent(EventType.secretWeapons_fangangaiming); 
	end
	local info = {
        index =index,		--0:integer      #方案序号
		newName  = newName --1:string       #新名字 检查一下不能改为空 并且字库检查 不能违法
	}
	printTable(29,"方案改名",info)
	RPCReq.GodArms_ChangeName(info,success)
end


--#方案选择
function SecretWeaponsModel:godArmsChoiceIndex(index)
	local function success(data)
		printTable(28,"方案选择返回",data)
		if data and data.data then
			self:setInfo(data.data)
		end
		Dispatcher.dispatchEvent(EventType.secretWeapons_fanganChoose); 
	end
	local info = {
        index=index
	}
	printTable(9,"方案选择",info)
	RPCReq.GodArms_ChoiceIndex(info,success)
end

--选中的秘武
function SecretWeaponsModel:godArmsChoice(id)
	local function success(data)
		printTable(31,"选中的秘武返回",data)
		if data and data.data then
			self.secretWeaponsInfo=data.data
			self:redCheck()
			if self.bothBattlePreEquipInfo.myGodArms==nil then
				self.bothBattlePreEquipInfo.myGodArms={}
			end 
			if data.data.godArmsMap and data.data.godArmsMap[data.data.curId] then
				self.bothBattlePreEquipInfo.myGodArms=data.data.godArmsMap[data.data.curId]
			else
				self.bothBattlePreEquipInfo.myGodArms={}
			end
		end
		Dispatcher.dispatchEvent(EventType.secretWeapons_IndexIdChoose); 
	end
	local info = {
        id=id
	}
	printTable(31,"选中的秘武",info)
	RPCReq.GodArms_Choice(info,success)
end

 
--id              1:integer       #战斗位置ID  141
--code            2:integer       #角色code 或者 秘武的code对应秘武的  --這個是秘武的id 
--level            2:integer       #角色code 或者 秘武的code对应秘武的
function SecretWeaponsModel:setArmsChoice(myGodArms)
		local postion={}
	for k, data in pairs(myGodArms) do
		local info={}
		if data.heroPos==BattleModel.HeroPos.player then
			--左
			info["id"]=data.code
			info["level"]=data.level
			postion["myGodArms"]=info
		else
			--右
			info["id"]=data.code
			info["level"]=data.level
			postion["enemyGodArms"]=info
		end
	end
	printTable(0933,myGodArms)
	self.bothBattleEquipInfo.myGodArms=postion["myGodArms"]
	self.bothBattleEquipInfo.enemyGodArms=postion["enemyGodArms"]
	Dispatcher.dispatchEvent(EventType.secretWeapons_IndexIdChoose);
end


--#获得战斗时候敌方秘武信息
function SecretWeaponsModel:GodArmsGetBattleGodArms(fightId,playerId,gamePlay,index)
	local function success(data)
		printTable(31,"获得战斗时候敌方秘武信息返回",data)
		if data then
			self.bothBattleEquipInfo=data
			self.bothBattlePreEquipInfo=TableUtil.DeepCopy(data)
		end
		Dispatcher.dispatchEvent(EventType.secretWeapons_shuangfangmiwuinfo); 
	end
	local info = {
		fightId	=fightId,			--1:integer			#战斗id
		playerId=playerId,			--2:integer			#玩家id
		gamePlay=gamePlay,			--3:integer   		#玩法（阵容类型）
		index=index			--4:integer 			#事件index
	}
	printTable(31,"获得战斗时候敌方秘武信息的秘武",info)
	RPCReq.GodArms_GetBattleGodArms(info,success)

end




return SecretWeaponsModel