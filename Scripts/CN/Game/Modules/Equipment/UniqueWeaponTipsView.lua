--added by wyang
--专武图标
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local UniqueWeaponTipsView = class("UniqueWeaponTipsView",Window)
function UniqueWeaponTipsView:ctor(data)
	self._packName = "Equipment"
	self._compName = "UniqueWeaponTipsView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.uniqueWeaponCell = false
	self.blackbg1 = false		
	self.btn_upgrade = false	
	self.btn_full = false	
	self.showFullCtrl = false	
	
	self.heroInfo = data.heroInfo or false
	self.attribute  = false
	self.showSkill = false
	
	if self.heroInfo then
		self.heroId = self.heroInfo.heroDataConfiger.heroId
		self.equipId = self.heroInfo.heroDataConfiger.uniqueWeapon
		self.level = self.heroInfo.uniqueWeapon and self.heroInfo.uniqueWeapon.level or -1
	else
		self.heroId = data.heroId or data.code
		local heroConf = DynamicConfigData.t_hero[data.heroId or data.code];
		self.equipId = heroConf.uniqueWeapon
		self.level = DynamicConfigData.t_UniqueWeaponConfig[self.equipId][#DynamicConfigData.t_UniqueWeaponConfig[self.equipId]].level
	end
	self.config = DynamicConfigData.t_UniqueWeaponConfig[self.equipId][self.level] or false
	
	self.nextConfig = DynamicConfigData.t_UniqueWeaponConfig[self.equipId][self.level + 1] or false
	self.configFull = DynamicConfigData.t_UniqueWeaponConfig[self.equipId][#DynamicConfigData.t_UniqueWeaponConfig[self.equipId]] or false
end

-------------------常用------------------------
--UI初始化
function UniqueWeaponTipsView:_initUI( ... )
	self.blackbg1 = self.view:getChildAutoType("blackbg1")
	self.btn_upgrade = self.view:getChildAutoType("btn_upgrade")
	self.btn_full = self.view:getChildAutoType("btn_full")
	self.closeFullBtn = self.view:getChildAutoType("closeFullBtn")
	self.list_attr = self.view:getChildAutoType("list_attr")
	self.listSkill = self.view:getChildAutoType("list_skill")	
	self.list_attrFull = self.view:getChildAutoType("list_attrFull")	
	self.txt_name = self.view:getChildAutoType("txt_name")	
	self.bgLoader = self.view:getChildAutoType("bgLoader")	
	self.txt_heroName = self.view:getChildAutoType("txt_heroName")	
	self.txt_combat = self.view:getChildAutoType("txt_combat")	
	self.txt_openStar = self.view:getChildAutoType("txt_openStar")	
	self.btn_showHelp = self.view:getChildAutoType("btn_showHelp")
	self.txt_attrName2 = self.view:getChildAutoType("txt_attrName2")
	self.showFullCtrl = self.view:getController("showFullCtrl")	
	self.statusCtrl = self.view:getController("statusCtrl")	
	
	local heroConf = DynamicConfigData.t_hero[self.heroId];
	self.txt_name:setText(self.config and self.config.name or self.nextConfig.name)
	self.txt_heroName:setText(heroConf.heroName)
	
	
	
	local color = self.config and self.config.rank or self.nextConfig.rank
	self.txt_name:setColor(ColorUtil.getItemTipsColor(color + 3))
	--self.txt_heroName:setColor(ColorUtil.getItemTipsColor(self.config.rank + 3))
	--self.txt_combat:setColor(ColorUtil.getItemTipsColor(self.config.rank + 3))
	
	self.bgLoader:setURL(PathConfiger.getItemTipsHeadBg(color + 3))
	
	
	local uniqueWeaponCell = self.view:getChildAutoType("uniqueWeaponCell")
	self.uniqueWeaponCell = BindManager.bindUniqueWeaponCell(uniqueWeaponCell)
	self.uniqueWeaponCell:setData(self.equipId, self.level)
	
	self.btn_showHelp:addClickListener(function ()
		RollTips.showHelp(Desc.help_StrTitle253, Desc.help_StrDesc253)
	end)
	
	self.btn_upgrade:addClickListener(function ()
		ViewManager.open("UniqueWeaponUpgradeView",{equipId = self.equipId, heroInfo = self.heroInfo} )
		self:closeView()
	end)
	
	self.blackbg1:addClickListener(function ()
		self:closeView()
	end)

	self.btn_full:addClickListener(function ()
		self.showFullCtrl:setSelectedIndex(1)
	end)
	
	self.closeFullBtn:addClickListener(function ()
		self.showFullCtrl:setSelectedIndex(0)
	end)
	
	self.btn_upgrade:setTouchable(self.nextConfig ~= false)
	self.btn_upgrade:setGrayed(not self.nextConfig)
	
	self.list_attr:setItemRenderer(function(idx,obj)
		local attr = self.attribute[idx + 1]
		local txt_name = obj:getChildAutoType("txt_name")
		local txt_value = obj:getChildAutoType("txt_value")
		txt_name:setText(GMethodUtil:getFightAttrName(attr.key))
		txt_value:setText("+"..GMethodUtil:getFightAttrName(attr.key,attr.value))
	end)

	self.list_attrFull:setItemRenderer(function(idx,obj)
		local attr = self.configFull.attribute[idx + 1]
		local txt_name = obj:getChildAutoType("txt_name")
		local txt_value = obj:getChildAutoType("txt_value")
		txt_name:setText(GMethodUtil:getFightAttrName(attr.key))
		txt_value:setText("+"..GMethodUtil:getFightAttrName(attr.key,attr.value))
	end)
	
	
	self.list_attrFull:setNumItems(#self.configFull.attribute)
	self.attribute = self.config and self.config.attribute or self.nextConfig.attribute
	self.list_attr:setNumItems(#self.attribute)
	
	
	self.listSkill:setItemRenderer(function(idx,obj)
		local skill = self.showSkill[idx + 1]
		local skillConfig = SkillConfiger.getSkillById(skill.skillId)
		local txt_desc = obj:getChildAutoType("txt_desc")
		if skill.level == 0 then
			txt_desc:setText(Desc.equipment_unlock..skillConfig.showName)
		else
			txt_desc:setText(string.format(Desc.equipment_unlockLevel, skill.level)..skillConfig.showName)
		end
		local curLevel = self.heroInfo and self.heroInfo.uniqueWeapon and self.heroInfo.uniqueWeapon.level or -1
		if not self.heroInfo then curLevel = 9999999 end
		obj:getController("grayCtrl"):setSelectedIndex(curLevel >= skill.level and 0 or 1)  --根据专武的等级来判断是否已经激活 
	end)
	
	
	self.showSkill = self.config and self.config.showSkill or self.nextConfig.showSkill
	self.listSkill:setNumItems(#self.showSkill)
	
	
	local config = self.config or self.nextConfig
	local power = 0
	for k, v in pairs(config.attribute) do 
		local param = HeroConfiger.GetAttrCombatParam(v.key)
		power = power + v.value * param / 100
	end
	power = power + config.fightPlus
	self.txt_combat:setText(StringUtil.transValue(math.floor(power)))
	
	
	if self.heroInfo then
		RedManager.register("V_CardUniqueWeapon"..self.heroInfo.uuid, self.btn_upgrade:getChildAutoType("img_red"))
	end
	
	if self.heroInfo then
		local opemStr = ModuleUtil.getModuleOpenTips(ModuleId.UniqueWeapon.id, self.heroInfo.star) 
		if opemStr then 
			self.statusCtrl:setSelectedIndex(0)
			self.txt_openStar:setText(opemStr.."解锁")
		elseif self.nextConfig then
			self.statusCtrl:setSelectedIndex(1)
			self.btn_upgrade:setTitle(self.nextConfig.level == 0 and "解 锁" or "强 化")
		else
			self.statusCtrl:setSelectedIndex(2)
		end
		
		if self._args.onlyShow then
			self.statusCtrl:setSelectedIndex(3)
		end
	else
		self.statusCtrl:setSelectedIndex(3)
	end
end

--事件初始化
function UniqueWeaponTipsView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function UniqueWeaponTipsView:_enter( ... )
	print(1,"RankView _enter")
end


--页面退出时执行
function UniqueWeaponTipsView:_exit( ... )

	print(1,"RankView _exit")
end

return UniqueWeaponTipsView