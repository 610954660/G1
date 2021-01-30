--added by wyang
--专武图标
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
local UniqueWeaponUpgradeView = class("UniqueWeaponUpgradeView",Window)
function UniqueWeaponUpgradeView:ctor(data)
	self._packName = "Equipment"
	self._compName = "UniqueWeaponUpgradeView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.btn_upgrade = false
	self.txt_heroName = false
	self.txt_name = false
	self.txt_level = false
	self.txt_skillDesc = false
	self.uniqueWeaponCell = false
	self.costBar = false
	self.fullCtrl = false
	self.skillCtrl = false
	self.effectLoader = false
	self.attrEffectLoader = false
	
	
	self.upgradeEffect = false
	
	self.uniqueWeaponId = data.equipId
	self.config = false
	self.nextConfig = false
	self.heroInfo = data.heroInfo
	self.cost = false
	self.attr = {}
end

-------------------常用------------------------
--UI初始化
function UniqueWeaponUpgradeView:_initUI( ... )
	local uniqueWeaponCell = self.view:getChildAutoType("uniqueWeaponCell")
	self.btn_upgrade = self.view:getChildAutoType("btn_upgrade")
	self.list_attr = self.view:getChildAutoType("list_attr")
	self.txt_heroName = self.view:getChildAutoType("txt_heroName")
	self.txt_name = self.view:getChildAutoType("txt_name")
	self.txt_level = self.view:getChildAutoType("txt_level")
	self.txt_skillDesc = self.view:getChildAutoType("txt_skillDesc")
	self.effectLoader = self.view:getChildAutoType("effectLoader")
	self.attrEffectLoader = self.view:getChildAutoType("attrEffectLoader")
	self.fullCtrl = self.view:getController("fullCtrl")
	self.skillCtrl = self.view:getController("skillCtrl")
	local costBar = self.view:getChildAutoType("costBar")
	self.costBar = BindManager.bindCostBar(costBar)
	
	self.uniqueWeaponCell = BindManager.bindUniqueWeaponCell(uniqueWeaponCell)
	
	
	self.btn_upgrade:addClickListener(function ()
		if PlayerModel:isCostEnough(self.cost,true) then
			local params = {}
			params.uuid = self.heroInfo.uuid
			local oldCombat = self.heroInfo.combat
			params.onSuccess = function (res )
				printTable(69, res)
				if res then
					--RollTips.showAddFightPoint()
					--self.heroInfo
					self:playUpgradeEffect()
					self.heroInfo.uniqueWeapon.level = res.level
					self.heroInfo.combat = res.maxCombat
					RollTips.showAddFightPoint(res.maxCombat - oldCombat, true)
					self:updateInfo()
					Dispatcher.dispatchEvent(EventType.equipment_uniqueWeapon, self.heroInfo.uuid)
					if not DynamicConfigData.t_UniqueWeaponConfig[self.uniqueWeaponId][res.level + 1] then
						self:closeView()
					end
				end
			end
			RPCReq.UniqueWeapon_UpdateLevel(params, params.onSuccess)
		end
	end)
	
	self.list_attr:setItemRenderer(function(idx,obj)
		local attr = self.attr[idx + 1]
		local txt_name = obj:getChildAutoType("txt_name")
		local txt_old = obj:getChildAutoType("txt_old")
		local txt_new = obj:getChildAutoType("txt_new")
		if attr.key == -1 then
			txt_old:setText("+"..(self.config and self.config.level or 0))
			txt_new:setText("+"..attr.value)
		else
			txt_name:setText(GMethodUtil:getFightAttrName(attr.key))
		
			local oldValue = "0"
			if self.config then
				for _,v in ipairs(self.config.attribute) do
					if v.key == attr.key then
						oldValue = GMethodUtil:getFightAttrName(attr.key,v.value)	
						break
					end
				end
			else
				oldValue = 0
			end
			txt_old:setText("+"..oldValue)
			txt_new:setText("+"..GMethodUtil:getFightAttrName(attr.key,attr.value))
		end
		
	end)
	
		
	self:updateInfo()
end

function UniqueWeaponUpgradeView:updateInfo()
	local uniqueWeaponConfig = DynamicConfigData.t_UniqueWeaponConfig[self.uniqueWeaponId]
	local level = self.heroInfo.uniqueWeapon and self.heroInfo.uniqueWeapon.level or -1
	self.config = uniqueWeaponConfig and uniqueWeaponConfig[level] or false
	self.nextConfig = uniqueWeaponConfig and uniqueWeaponConfig[level + 1] or false
	if self.config then
		self.txt_name:setColor(ColorUtil.getItemColor(self.config.rank + 3))
	else
		self.txt_name:setColor(ColorUtil.getItemColor(self.nextConfig.rank + 3))
	end
	if level == -1 then
		self.btn_upgrade:setTitle("解 锁")
	else
		self.btn_upgrade:setTitle("强 化")
	end
	if self.nextConfig then
		self.fullCtrl:setSelectedIndex(0)
		self.cost = self.nextConfig and self.nextConfig.cost or false
		local heroConf = DynamicConfigData.t_hero[self.heroInfo.code];
		--self.iconLoader:setURL(PathConfiger.getUniqueWeaponIcon(heroConf.uniqueWeapon))
		self.uniqueWeaponCell:setData(self.uniqueWeaponId, level)
		local heroName = heroConf.heroName;
		
		local nextOpenEffect,nextSkill
		for _,v in ipairs(self.nextConfig.showSkill) do
			if v.level > level then
				if not nextOpenEffect or nextOpenEffect >  v.level then
					nextOpenEffect = v.level
					nextSkill = v.skillId
				end
			end
		end
		local str = "[强化+%s]%s"
		
		if nextOpenEffect then
			local skillConfig = DynamicConfigData.t_skill[nextSkill]
			self.txt_skillDesc:setText(string.format(str, nextOpenEffect, skillConfig.showName))
			self.skillCtrl:setSelectedIndex(0)
		else
			self.skillCtrl:setSelectedIndex(1)
		end
		self.txt_heroName:setText(heroName)
		self.txt_name:setText(self.nextConfig.name)
		self.txt_level:setText("Lv."..level)
		
		if self.cost then
			self.costBar:setData(self.cost,false)
		end
		self.attr = {}
		table.insert(self.attr, {key = -1, value = self.nextConfig.level })
		for _,v in ipairs(self.nextConfig.attribute) do
			table.insert(self.attr, v)
		end
		self.list_attr:setNumItems(#self.attr)
	else
		self.fullCtrl:setSelectedIndex(1)
	end
end

--事件初始化
function UniqueWeaponUpgradeView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end


function UniqueWeaponUpgradeView:playUpgradeEffect( ... )
	if not self.upgradeEffect then
		self.upgradeEffect = SpineUtil.createSpineObj(self.effectLoader,Vector2(0,0),"ui_zhuanwuqianghua", "Spine/ui/zhuanwuqianghua", "efx_zhuanwuqianghua", "efx_zhuanwuqianghua", false)
	else
		self.upgradeEffect:setAnimation(0,"ui_zhuanwuqianghua",false)
	end
	
	local interTime = 0.2
	local dis = 30
	local len = #self.attr
	if len > 5 then len = 5 end
	for index = 0, len -1 do
		Scheduler.scheduleOnce(index*interTime, function( ... )
			if self.attrEffectLoader and  (not tolua.isnull(self.attrEffectLoader)) then
				SpineUtil.createSpineObj(self.attrEffectLoader,Vector2(0,-dis * index),"ui_jiachengsaoguang", "Spine/ui/zhuanwuqianghua", "efx_zhuanwuqianghua", "efx_zhuanwuqianghua", false)
			end
		end)
	end
	
	
end

--initEvent后执行
function UniqueWeaponUpgradeView:_enter( ... )
	print(1,"RankView _enter")
end


--页面退出时执行
function UniqueWeaponUpgradeView:_exit( ... )

	print(1,"RankView _exit")
end

return UniqueWeaponUpgradeView