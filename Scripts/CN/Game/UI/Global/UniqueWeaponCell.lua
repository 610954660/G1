--added by wyang
--道具框封裝
local UniqueWeaponCell = class("UniqueWeaponCell",BindView)
function UniqueWeaponCell:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	self.frameBg = false
	self.effectLoaderUp = false
	self.iconLoader = false
	self.effectLoaderDown = false
	self.config = false
	self.effectColorStr = {"zi","huang", "hong"}
end

function UniqueWeaponCell:init( ... )
	self.frameBg = self.view:getChildAutoType("frameBg")
	self.effectLoaderUp = self.view:getChildAutoType("effectLoaderUp")
	self.iconLoader = self.view:getChildAutoType("iconLoader")
	self.effectLoaderDown = self.view:getChildAutoType("effectLoaderDown")
end


function UniqueWeaponCell:setData(id,level)
	if level < 0 then level = 0 end
	self.config = DynamicConfigData.t_UniqueWeaponConfig[id][level]
	self.effectLoaderUp:displayObject():removeAllChildren()
	local color = self.config.rank
	
	self.frameBg:setURL(PathConfiger.getUniqueWeaponFrame(color))
	self.iconLoader:setURL(PathConfiger.getUniqueWeaponIcon(id,level))
	SpineUtil.createSpineObj(self.effectLoaderUp,Vector2(0,0),self.effectColorStr [color].."_up", "Spine/ui/zhuangbei", "efx_zhuanwu", "efx_zhuanwu", true)
	self.effectLoaderDown:displayObject():removeAllChildren()
	SpineUtil.createSpineObj(self.effectLoaderDown,Vector2(0,0),self.effectColorStr [color].."_down", "Spine/ui/zhuangbei", "efx_zhuanwu", "efx_zhuanwu", true)
	
end

function UniqueWeaponCell:getColorByLevel(level)
	if level <= 9 then
		return 1
	elseif level <= 9 then
		return 2
	else
		return 3
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