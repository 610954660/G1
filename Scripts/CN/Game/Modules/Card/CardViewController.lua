---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger";
local CardViewController = class("CardViewController",Controller)
local RedConst = require "Game.Consts.RedConst"


function CardViewController:cardView_showDetial()
	--打开卡牌详情
	ViewManager.open("CardInfoView")
end

function CardViewController:Hero_UpdateInfo(_,data)
	if data==nil then
		return;
	end
	-- if CardLibModel.cardfight==0 then
	-- 	CardLibModel.cardfight=CardLibModel:getFightVal() or 0
	-- end
	-- printTable(1,"卡牌更新删除返回yfyf",data)
	--SoundManager.playSound(3,false)
	for key, value in pairs(data.updateList) do
		--	printTable(5,"卡牌更新删除返回yfyf11",key,value)
		if value.updateType==1  then--添加
			local heroCode=value.heroInfo.code;
				local hero=DynamicConfigData.t_hero[heroCode]--读表的数据
				HeroConfiger.initHeroInfo(value.heroInfo)
				--value.heroInfo["heroId"]=hero.heroId
				--value.heroInfo['heroDataConfiger']=hero;
				local heroList=ModelManager.CardLibModel.__heroInfos[hero.category] or {}
				heroList[value.heroInfo.uuid]=value.heroInfo;
				ModelManager.CardLibModel.__heroInfos[hero.category]=heroList
		elseif value.updateType==2 then--删除
				local list=ModelManager.CardLibModel.__heroInfos
				local heroUid=value.uuid;
				local heroCode=false
				local cardItem=false
				for l, cardInfo in pairs(list) do
					local card=cardInfo[heroUid]
					cardItem=card
					if card then 
						heroCode=card.code;
						break
					end
				end
				local category=DynamicConfigData.t_hero[heroCode].category--读表的数据 --cardItem.heroDataConfiger.category;-- string.sub(heroCode,0,1);-
				list[tonumber(category)][heroUid]=nil;
				Dispatcher.dispatchEvent("card_delete_event",heroUid)
				printTable(5,'>>>>>>>>>>nuilllllllll',list);
		elseif value.updateType==3 then--更新属性
			-- printTable(1,"卡牌更新删除返回yfyf111",value)
			-- printTable(1,"卡牌更新删除返回yfyf111")
				local herodata=value.heroInfo;
				local heroId=herodata.code;
				local heroUid=value.uuid;
				local category=DynamicConfigData.t_hero[heroId].category --string.sub(heroId,0,1)
				local cardInfo= ModelManager.CardLibModel.__heroInfos[tonumber(category)]
				
				if cardInfo then
					local heroInfo= cardInfo[heroUid];	
						
					if heroInfo then
						local oldLevel = heroInfo.level		
						--[[local addNum = herodata.combat - heroInfo["combat"]
						if addNum > 0 then
							RollTips.showAddFightPoint(addNum)
						end--]]
						
						for p,v in pairs(herodata) do
							heroInfo[p] = v
						end
						
						heroInfo["uuid"]=heroUid--拼接服务端同步的数据
						--[[heroInfo["attrs"]=herodata.attrs--拼接服务端同步的数据
						heroInfo["level"]=herodata.level--(等级)
						heroInfo["star"]=herodata.star--(星级)
						heroInfo["stage"]=herodata.stage--(阶级)
						heroInfo["combat"]=herodata.combat--(战力)
						heroInfo["attrPointNum"]=herodata.attrPointNum--(剩余可分配属性点)
						heroInfo["passiveSkill"]=herodata.passiveSkill--(卡牌已激活被动技能数据)
						heroInfo["reservedSkill"]=herodata.reservedSkill--(卡牌未激活被动技能数据)--]]
						
						-- if heroInfo.level == 140 and oldLevel < 140 then
						-- 	RedManager.updateValue("V_CardTaletLevel"..heroUid, true)  --达到120级时，要红点提醒一下特性
						-- end
					end
					
					
				end
				
				
		end
    end
	if ModelManager.CardLibModel.curCardStepInfo then
		ModelManager.CardLibModel:setChooseUid(ModelManager.CardLibModel.curCardStepInfo.uuid) --加了或者减了，需要选回之前的卡牌，不然它的index不对
	end
	RedConst.initCardMap()
	ModelManager.CardLibModel:redCheck()
	printTable(151,"data.combat11111111111111111111",data.combat,data.updateCode,CardLibModel.cardfight)
	-- if data.combat and data.combat-CardLibModel.cardfight>0  and data.updateCode and data.updateCode==GameDef.UpdateCode.GodArms_AddExp 
	-- or data.updateCode==GameDef.UpdateCode.GodArms_UpStage or data.updateCode==GameDef.UpdateCode.GodArms_UpCount then
	-- 	local addNum=data.combat-CardLibModel.cardfight
	-- 	RollTips.showAddFightPoint(addNum)
	-- 	CardLibModel.cardfight=data.combat
	-- else
	-- 	if data.combat then
	-- 		CardLibModel.cardfight=data.combat
	-- 	end
	-- end	
	-- Dispatcher.dispatchEvent(EventType.update_cards_fightVal);--战力有刷新
	Dispatcher.dispatchEvent(EventType.cardView_CardAddAndDeleInfo,data); 
end

--登陆时推送过来的卡牌列表
function CardViewController:Hero_HeroList(_,data)
	ModelManager.CardLibModel:setHeroInfos(data)
	EquipmentModel:revData(data)
end

--
function CardViewController:Hero_FreeResetHeroInfo(_,data)
	ModelManager.CardLibModel.freeResetHeroTimes = data.freeResetHeroTimes
	Dispatcher.dispatchEvent(EventType.cardView_freeResetTimesChange)
end

function CardViewController:Hero_RefreshChangeAttrPointPlan(_,data)
	for _,uuid in pairs(data.uuids) do
		local hero = ModelManager.CardLibModel.getHeroByUid(uuid)
		if hero then
			hero.changePointNum = 0
		end
		
	end
end

-- 战力刷新
function CardViewController:Hero_ModuleInfoUpdate(_, param)
	CardLibModel.maxCombat = param.maxCombat or 0;
	Dispatcher.dispatchEvent(EventType.update_cards_fightVal);--战力有刷新
end

function CardViewController:money_change()
	ModelManager.CardLibModel:redCheck()
end

function CardViewController:pack_item_change()
	ModelManager.CardLibModel:redCheck()
end

return CardViewController
