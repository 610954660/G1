--Name : SecretWeaponAddTopView.lua
--Author : generated by FairyGUI
--Date : 2020-7-28
--Desc : 秘武备战界面

local SecretWeaponAddTopView,Super = class("SecretWeaponAddTopView", Window)

function SecretWeaponAddTopView:ctor()
	--LuaLog("SecretWeaponAddTopView ctor")
	self._packName = "SecretWeapons"
	self._compName = "SecretWeaponAddTopView"
	self._rootDepth = LayerDepth.WindowUI
	self.arrayType = false
end

function SecretWeaponAddTopView:_initEvent( )
	
end

function SecretWeaponAddTopView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:SecretWeapons.SecretWeaponAddTopView
	--{vmFieldsEnd}:SecretWeapons.SecretWeaponAddTopView
	--Do not modify above code-------------
end

function SecretWeaponAddTopView:_initUI( )
	self:_initVM()

	self.battlePrepareIsShow  = ModelManager.ElvesSystemModel.battlePrepareIsShow
	local my= SecretWeaponsModel:getMybattlePreEquipInfo()
	local other=  SecretWeaponsModel:getOtherbattlePreEquipInfo()
	self:showEquipItem({my},1)
	self:showEquipItem({other},2)
	--阵法
	TacticalModel:setOpenFlag(false)
	self.fazhenBtn = self.view:getChildAutoType("fazhenBtn")
	self.fazhenBtn:addClickListener(function()
		local openFlag = not TacticalModel:getOpenFlag()
		TacticalModel:setOpenFlag(openFlag)
		Dispatcher.dispatchEvent("showTactial_event",openFlag)
	end)
	self:update_AddTopShow()
end

function SecretWeaponAddTopView:update_AddTopShow( ... )
	local config = BattleModel:getBattleConfig()
	local arrayType = config.configType or GameDef.BattleArrayType.Chapters --当前阵容id(从哪个玩法点进来就是哪个)
	local my = ModelManager.TacticalModel:getCurTactical(arrayType) --当前选中的阵法

	local other = ModelManager.TacticalModel:getPreOtherTacData() 
	self:showTacticalItem(my,1,arrayType)
	self:showTacticalItem(other,2,arrayType)
end

function  SecretWeaponAddTopView:showTacticalItem(tid,index,arrayType)
	local obj = self.view:getChildAutoType("item_0_"..index)
	if index == 1 then
		if ModelManager.TacticalModel:isCurUsing(arrayType, tid) then
			obj:setVisible(true)
			local config = DynamicConfigData.t_TacticalUnlock[tid]
			local iconLoader = obj:getChildAutoType("taticalCell"):getChildAutoType("iconLoader")
			local path = PathConfiger.getTacticalIcon(config.tactical)
			iconLoader:setURL(path)
		else
			obj:setVisible(false)
		end
	elseif index ==2 then
		obj:setVisible(false)
		local config = DynamicConfigData.t_TacticalUnlock[tid]
		if config then
			obj:setVisible(true)
			local iconLoader = obj:getChildAutoType("taticalCell"):getChildAutoType("iconLoader")
			local path = PathConfiger.getTacticalIcon(config.tactical)
			iconLoader:setURL(path)
		else
			obj:setVisible(false)
		end
	end
end


function SecretWeaponAddTopView:showEquipItem(info,type,roundNum)
	-- printTable(8848,">>>>info>>>",info)
	for i = 1, #info, 1 do
		local itemInfo=info[i]
		local key ="item_"..type.."_"..i
		local item=self.view:getChildAutoType(key)
		local tips = ModuleUtil.getModuleOpenTips(ModuleId.SecretWeapon.id)
		if tips==nil then--开了
			item:setVisible(true)
			if type==2 then
				if next(itemInfo)~=nil then
					item:setVisible(true)
				else
					item:setVisible(false)
				end
			end
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
		if type==1 then
			item:removeClickListener(100)	--池子里面原来的事件注销掉
			item:addClickListener(
				function(context)
					ModuleUtil.openModule(ModuleId.SecretWeapon.id, true);
				end
			,100)
		end
	end
end

function SecretWeaponAddTopView:secretWeapons_shuangfangmiwuinfo( )
	local my=   SecretWeaponsModel:getMybattlePreEquipInfo()
	local other= SecretWeaponsModel:getOtherbattlePreEquipInfo()
	self:showEquipItem({my},1)
	self:showEquipItem({other},2)
end

function SecretWeaponAddTopView:secretWeapons_IndexIdChoose(...)--装配
	printTable(31,"装配装配装配装配装配装配装配装配装配装配装配装配装配装配装配")
	local my=   SecretWeaponsModel:getMybattlePreEquipInfo()
	local other= SecretWeaponsModel:getOtherbattlePreEquipInfo()
	self:showEquipItem({my},1)
	self:showEquipItem({other},2)
end

function SecretWeaponAddTopView:_initEvent( )

end

-- function SecretWeaponAddTopView:squadtomodify_change()--点击修改阵容刷新
-- 	ViewManager.close("SecretWeaponAddTopView")
-- end

-- --如果是通关战斗结束这个界面要关掉
-- function SecretWeaponAddTopView:battle_end( )
-- 	ViewManager.close("SecretWeaponAddTopView")
-- end

-- function SecretWeaponAddTopView:battle_enter()
-- 	ViewManager.close("SecretWeaponAddTopView")
-- end

-- function SecretWeaponAddTopView: battle_canCel()
-- 	ViewManager.close("SecretWeaponAddTopView")
-- end

return SecretWeaponAddTopView