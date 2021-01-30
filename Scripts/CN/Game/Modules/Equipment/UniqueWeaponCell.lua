--added by wyang
--专武图标
local UniqueWeaponCell = class("UniqueWeaponCell",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"
local BagType = GameDef.BagType
function UniqueWeaponCell:ctor(view,noClick)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	self.statusCtrl = false
	
	self.heroInfo = false
	self.iconLoader = false
	self.txt_level = false
	self.equipId = 0 --专武id
	self.equipLevel  = -2 --专武等级
	self.status = 0 --当前的状态  -2没有专武， -1未激活  0 激活了， >0 升级了
	
	self.config = false -- 秘武配置
	self.level = false
end

function UniqueWeaponCell:init( ... )
	self.statusCtrl = self.view:getController("statusCtrl")
	self.iconLoader = self.view:getChildAutoType("iconLoader")
	self.txt_level = self.view:getChildAutoType("txt_level")
	self.frame = self.view:getChildAutoType("frame")
	self.frame:addClickListener(function ()
		self:onClickItem()
	end)
	
	
end


function UniqueWeaponCell:setData(heroInfo)
	if not heroInfo then 
		self.view:setVisible(false)
		return
	end
	self.heroInfo = heroInfo or false
	
	if heroInfo.heroDataConfiger.uniqueWeapon == "" then  --这件装备没有专武
		self.view:setVisible(false)
	elseif heroInfo.heroDataConfiger.uniqueWeapon == -1 then --这件装备是有的，但还没实现
		self.view:setVisible(true)
		self.status = -2
		return
	end
	
	if heroInfo.uniqueWeapon and heroInfo.uniqueWeapon.id and heroInfo.uniqueWeapon.id > 0 then
		self.view:setVisible(true)
		self.equipId = heroInfo.uniqueWeapon.id or 1
		self.level = heroInfo.uniqueWeapon.level or 0
		local uniqueWeaponConfig = DynamicConfigData.t_UniqueWeaponConfig[self.equipId]
		self.config = uniqueWeaponConfig and uniqueWeaponConfig[self.level] or false
		self.txt_level:setText("Lv."..self.level)
		if self.level == -1 then
			self.status = -1 
			self.statusCtrl:setSelectedIndex(0)
			self.iconLoader:setURL(nil)
		elseif self.level == 0 then
			self.status = 0
			self.statusCtrl:setSelectedIndex(1)
			if self.config then
				self.iconLoader:setURL(PathConfiger.getUniqueWeaponIcon(self.equipId))
			end
		else
			self.status = 1
			self.statusCtrl:setSelectedIndex(2)
			
			if self.config then
				self.iconLoader:setURL(PathConfiger.getUniqueWeaponIcon(self.equipId))
			end
		end
	else
		self.status = -1 
		if heroInfo.heroDataConfiger.uniqueWeapon ~= "" and heroInfo.heroDataConfiger.uniqueWeapon >= 0 then
			self.config = DynamicConfigData.t_UniqueWeaponConfig[tonumber(heroInfo.heroDataConfiger.uniqueWeapon)][0] or false
		end
		self.statusCtrl:setSelectedIndex(0)
		if self.config then
			local path = PathConfiger.getUniqueWeaponIcon(self.config.id)
			self.iconLoader:setURL(PathConfiger.getUniqueWeaponIcon(self.config.id))
		else
			self.iconLoader:setURL(nil)	
		end
	end
end

function UniqueWeaponCell:onClickItem()
	if self.status == -2 then --未实现
		RollTips.show(Desc.equipment_making)
	elseif self.status == -1 then --未激活
		if self.config then
			ViewManager.open("UniqueWeaponTipsView", {heroInfo = self.heroInfo, config = self.config})
		end
	elseif self.status == 0 then  --已激活，未升级
		if self.config then
			ViewManager.open("UniqueWeaponTipsView", {heroInfo = self.heroInfo, config = self.config})
		end
	elseif self.status > 0 then  --已激活，已升级
		if self.config then
			ViewManager.open("UniqueWeaponTipsView", {heroInfo = self.heroInfo, config = self.config})
		end
	end
end
	
function UniqueWeaponCell:updateLevel()

	--如果功能未开放，显示锁
	if not ModuleUtil.hasModuleOpen(ModuleId.Equipment.id) then
		self.statusCtrl:setSelectedIndex(0)
	else
		self.statusCtrl:setSelectedIndex(self.heroInfo.level + 2)
	end
end

function UniqueWeaponCell:equipment_uniqueWeapon(_,uuid)
	if uuid == self.heroInfo.uuid then
		self:setData(self.heroInfo)
	end
end


--退出操作 在close执行之前 
function UniqueWeaponCell:__onExit()
     print(086,"UniqueWeaponCell __onExit")
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return UniqueWeaponCell