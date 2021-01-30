--Date :2020-12-23
--Author : generated by FairyGUI
--Desc : 

local SecretWeaponActiveView,Super = class("SecretWeaponActiveView", Window)

function SecretWeaponActiveView:ctor()
	--LuaLog("SecretWeaponActiveView ctor")
	self._packName = "SecretWeapons"
	self._compName = "SecretWeaponActiveView"
    self._rootDepth = LayerDepth.PopWindow
    self.secretWeaponId = false
    self.info = {}
end

function SecretWeaponActiveView:_initEvent( )
	
end

function SecretWeaponActiveView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:SecretWeapons.SecretWeaponActiveView
	self.btn_seeAttr = viewNode:getChildAutoType('$btn_seeAttr')--GButton
	self.img_equip = viewNode:getChildAutoType('$img_equip')--GLoader
	self.skillCel = viewNode:getChildAutoType('$skillCel')--GButton
	self.txt_name = viewNode:getChildAutoType('$txt_name')--GRichTextField
	self.blackBg = viewNode:getChildAutoType('blackBg')--GButton
	self.btnStateCtr = viewNode:getController('btnStateCtr')--Controller
	self.btn_Active = viewNode:getChildAutoType('btn_Active')--GButton
	self.btn_get = viewNode:getChildAutoType('btn_get')--GButton
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.itemCell = viewNode:getChildAutoType('itemCell')--GButton
	self.txt_Decs = viewNode:getChildAutoType('txt_Decs')--GTextField
	self.txt_skillDecs = viewNode:getChildAutoType('txt_skillDecs')--GTextField
	self.txt_skillName = viewNode:getChildAutoType('txt_skillName')--GTextField
	--{autoFieldsEnd}:SecretWeapons.SecretWeaponActiveView
	--Do not modify above code-------------
end

function SecretWeaponActiveView:_initListener( )
	self.btn_seeAttr:addClickListener(function()
		ViewManager.open("SecretWeaponAddattrView", {type = 1, id = self.secretWeaponId})
	end)
	self.btn_Active:addClickListener(function()
		local params = {}
		params.id = self.secretWeaponId
		params.onSuccess = function (args)
			ViewManager.close("SecretWeaponActiveView")
			ViewManager.open("SecretWeaponStrainView", {id = self.secretWeaponId})
			ViewManager.open("SecretWeaponsGetView",{id = self.secretWeaponId})
		end
		printTable(6,"激活秘武params",params)
		RPCReq.GodArms_TriggerGodArms(params,params.onSuccess)
	end)
	self.btn_get:addClickListener(function()
		local jump = self.info.jump
    	if jump ~= "" then 
	    	ModuleUtil.openModule(jump , true )
			ViewManager.close("SecretWeaponActiveView")
		end
	end)
end

function SecretWeaponActiveView:_initUI( )
	self:_initVM()
	self:_initListener()
    self.secretWeaponId = self._args.id
    local equipurl = SecretWeaponsModel:getEquipById(self.secretWeaponId)
    self.img_equip:setURL(equipurl)
    self:setSkill()
    self.info = DynamicConfigData.t_godArmsTrigger[self.secretWeaponId]
   	local itemCell = BindManager.bindItemCell(self.view:getChildAutoType('itemCell'))
   	local itemCost = self.info.itemCost[1]
	itemCell:setIsMid(true)
	itemCell:setData(itemCost.code,itemCost.amount,itemCost.type)
    self.txt_name:setText(self.info.name)
   	self.txt_skillDecs:setText(self.info.activeDesc)
   	local haveNum = PackModel:getItemsFromAllPackByCode(itemCost.code)
   	self.btn_Active:getChildAutoType("img_red"):setVisible(true)
   	if haveNum < itemCost.amount then 
   		self.btnStateCtr:setSelectedIndex(0)
   	else
   		self.btnStateCtr:setSelectedIndex(1)
   	end
   	self.txt_Decs:setText(self.info.gainDesc)
end

function SecretWeaponActiveView:setSkill( )
	local lv = 1 --写死读level1的技能名字和图标,描述读
    local godArmsConfig = DynamicConfigData.t_godArms[self.secretWeaponId]
    if not godArmsConfig[lv] then
        return
    end
    local skillId = godArmsConfig[lv].skillId
    local max = #godArmsConfig
    local conf = DynamicConfigData.t_skill[skillId]
    local cell = BindManager.bindSkillCell(self.skillCel)
    cell:setData(skillId)
   	self.txt_skillName:setText(conf.skillName)
end

return SecretWeaponActiveView