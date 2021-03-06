--Name : SecretWeaponBattleView.lua
--Author : generated by FairyGUI
--Date : 2020-7-28
--Desc : 秘武战斗界面

local SecretWeaponBattleView,Super = class("SecretWeaponBattleView", Window)
function SecretWeaponBattleView:ctor()
	--LuaLog("SecretWeaponBattleView ctor")
	self._packName = "SecretWeapons"
	self._compName = "SecretWeaponBattleView"
	self._rootDepth = LayerDepth.WindowUI
	
	self.roundNum = {0,0} 	-- 倒计时刷新
	self.secretFightRound = {}
	self.fightData = {}
	self.fazhenBtn = false
end

function SecretWeaponBattleView:_initEvent( )
	-- local fightInfo= BattleManager:getInstance():getFightObjData()
	-- printTable(8848,">>fightInfo>>",fightInfo)
end

function SecretWeaponBattleView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:SecretWeapons.SecretWeaponBattleView
	--{vmFieldsEnd}:SecretWeapons.SecretWeaponBattleView
	--Do not modify above code-------------
end

function SecretWeaponBattleView:_initUI( )
	self:_initVM()
	self.fazhenBtn = self.view:getChildAutoType("fazhenBtn")
	self.fazhenBtn:setSelected(false)
	if TacticalModel:getOpenFlag() then
		self.fazhenBtn:setSelected(true)
	end

	self.fazhenBtn:addClickListener(function()
		local openFlag = not TacticalModel:getOpenFlag()
		TacticalModel:setOpenFlag(openFlag)
		Dispatcher.dispatchEvent("showTactial_event",openFlag)
	end)
end

function SecretWeaponBattleView:battle_tacticalUpdate(_,params)
	self.view:getChildAutoType("item_0_1"):setVisible(false)
	self.view:getChildAutoType("item_0_2"):setVisible(false)
	for i = 1, #params  do
		if params[i].side == 1 and params[i].tacticalInfo then
			self:showTacticalItem(params[i].tacticalInfo.id,1)
		end

		if params[i].side == 2 and params[i].tacticalInfo then
			self:showTacticalItem(params[i].tacticalInfo.id,2)
		end	
	end
end

function  SecretWeaponBattleView:showTacticalItem(tid,index)
	local obj = self.view:getChildAutoType("item_0_"..index)
	obj:setVisible(true)
	local config = DynamicConfigData.t_TacticalUnlock[tid]
	local iconLoader = obj:getChildAutoType("taticalCell"):getChildAutoType("iconLoader")
	local path = ""
	if config then
		path = PathConfiger.getTacticalIcon(config.tactical)
	end
	iconLoader:setURL(path)
end

function SecretWeaponBattleView:SecretWeaponBattleView_fightFresh(_,params)
	local id = params.id - 140
	local roundNum      = ModelManager.BattleModel.roundNum
	roundNum = (roundNum == 0) and 1 or roundNum
	local my = SecretWeaponsModel:getMybattleEquipInfo()
	local other =  SecretWeaponsModel:getOtherbattleEquipInfo()
	self:showEquipItem({my},1,roundNum)
	self:showEquipItem({other},2,roundNum)
end

function SecretWeaponBattleView:battle_roundEnd(_,args)
	local roundNum      = ModelManager.BattleModel.roundNum
	roundNum = roundNum + 1
	self:initRoundNum(roundNum,args)
	local my = SecretWeaponsModel:getMybattleEquipInfo()
	local other =  SecretWeaponsModel:getOtherbattleEquipInfo()
	self.fightData = args
	if (roundNum <= ModelManager.SecretWeaponsModel:getLastRoundNum(self.fightData)) then
		self:showEquipItem({my},1,roundNum)
		self:showEquipItem({other},2,roundNum) 
	end
end

function SecretWeaponBattleView:battle_roundStar(_,args)
	local roundNum      = ModelManager.BattleModel.roundNum
	self.fightData = args
	local arrayType = args.arrayType
	if not SecretWeaponsModel.battleround[arrayType] then
		SecretWeaponsModel.battleround[arrayType] = {}
		SecretWeaponsModel.battleround[arrayType][1] = 0
		SecretWeaponsModel.battleround[arrayType][2] = 0
	end
	local my=   SecretWeaponsModel:getMybattleEquipInfo()
	local other= SecretWeaponsModel:getOtherbattleEquipInfo()
	local roundNum      = ModelManager.BattleModel.roundNum
	roundNum = (roundNum == 0) and 1 or roundNum
	self.secretFightRound = ModelManager.SecretWeaponsModel:initFightData(args)
	self:initRoundNum(roundNum,args)
	self:showEquipItem({my},1,roundNum,args)
	self:showEquipItem({other},2,roundNum,args)
end

function SecretWeaponBattleView:initRoundNum(roundNum,args)
	local my = SecretWeaponsModel:getMybattleEquipInfo()
	local other =  SecretWeaponsModel:getOtherbattleEquipInfo()
	if my.id then
		-- self:setRoundNum(my.id,1,my.level,roundNum,args)
		SecretWeaponsModel:getCurrentCD(my.id,1,my.level,roundNum,args)
	end
	if other.id then
		-- self:setRoundNum(other.id,2,other.level,roundNum,args)
		SecretWeaponsModel:getCurrentCD(other.id,2,other.level,roundNum,args)
	end
end

function SecretWeaponBattleView:setRoundNum(id,type,level,roundNum,args)
	local skillId = DynamicConfigData.t_godArms[id][level].skillId -- 技能id
	local coolRound = DynamicConfigData.t_skill[skillId].coolRound -- 技能冷却回合
	if not coolRound then coolRound = 0 end
	-- printTable(8848,">>.roundNum>>getLastRoundNum()>>>",roundNum,ModelManager.SecretWeaponsModel:getLastRoundNum())
	local arrayType = self.fightData.arrayType
	if SecretWeaponsModel.battleround[arrayType][type] - roundNum == 0  or roundNum == 1 and (roundNum <= ModelManager.SecretWeaponsModel:getLastRoundNum(self.fightData)) then
		SecretWeaponsModel.battleround[arrayType][type] = coolRound + SecretWeaponsModel.battleround[arrayType][type]
	end
end

function SecretWeaponBattleView:showEquipItem(info,type,roundNum,args)
	for i = 1, #info, 1 do
		local itemInfo=info[i]
		local key ="item_"..type.."_"..i
		local item=self.view:getChildAutoType(key)

		local interfaceCtrl = item:getController("interfaceCtrl")
		local cdCtrl 	= item:getController("cdCtrl")
		local txt_CD 	= item:getChildAutoType("txt_CD")
		local cdNum 	= 0 
		cdCtrl:setSelectedIndex(1)
		interfaceCtrl:setSelectedIndex(1)
		if itemInfo.id then
			local arrayType = self.fightData.arrayType
			if (roundNum <= ModelManager.SecretWeaponsModel:getLastRoundNum(self.fightData)) and SecretWeaponsModel.battleround and  SecretWeaponsModel.battleround[arrayType] and SecretWeaponsModel.battleround[arrayType][type] then
				cdNum = SecretWeaponsModel.battleround[arrayType][type] - roundNum
			end
			txt_CD:setText(cdNum)
			if ModelManager.GuideModel:IsGuiding() then
				cdCtrl:setSelectedIndex(1)
			else
				if self.secretFightRound and self.secretFightRound[type] and self.secretFightRound[type][roundNum] then
					cdCtrl:setSelectedIndex(1)
				else
					cdCtrl:setSelectedIndex(0)
				end
			end
		end

		local tips = ModuleUtil.getModuleOpenTips(ModuleId.SecretWeapon.id)
		if tips==nil and next(itemInfo)~=nil then--开了
			item:setVisible(true)
		else
			item:setVisible(false)
		end
		local gCtr1 = item:getController("c1")
		local equImg = item:getChildAutoType("img_goods")
		if itemInfo and itemInfo.id then
			local equipurl = SecretWeaponsModel:getEquipById(itemInfo.id)
			equImg:setURL(equipurl)
			gCtr1:setSelectedIndex(0)
		else
			gCtr1:setSelectedIndex(1)
		end
	end
end

function SecretWeaponBattleView:secretWeapons_shuangfangmiwuinfo( )
	local my=   SecretWeaponsModel:getMybattleEquipInfo()
	local other= SecretWeaponsModel:getOtherbattleEquipInfo()
	local roundNum      = ModelManager.BattleModel.roundNum
	roundNum = (roundNum == 0) and 1 or roundNum
	self:showEquipItem({my},1,roundNum)
	self:showEquipItem({other},2,roundNum)
end

function SecretWeaponBattleView:secretWeapons_IndexIdChoose(...)--装配
end

function SecretWeaponBattleView:_initEvent( )

end

function SecretWeaponBattleView:_exit()
	local arrayType =self.fightData.arrayType
	if SecretWeaponsModel.battleround and SecretWeaponsModel.battleround[arrayType] and SecretWeaponsModel.battleround[arrayType][1] and SecretWeaponsModel.battleround[arrayType][2] then
		SecretWeaponsModel.battleround[arrayType][1] = 0
		SecretWeaponsModel.battleround[arrayType][2] = 0
	end
end

-- --如果是通关战斗结束这个界面要关掉
-- function SecretWeaponBattleView:battle_end( )
-- 	ViewManager.close("SecretWeaponBattleView")
-- end

-- -- function SecretWeaponBattleView:battle_enter()
-- -- 	ViewManager.close("SecretWeaponBattleView")
-- -- end

-- function SecretWeaponBattleView: battle_canCel()
-- 	ViewManager.close("SecretWeaponBattleView")
-- end

return SecretWeaponBattleView