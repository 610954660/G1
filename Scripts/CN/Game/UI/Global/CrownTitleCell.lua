--added by wyang
--道具框封裝
local CrownTitleCell = class("CrownTitleCell",BindView)
local BagType = GameDef.BagType
function CrownTitleCell:ctor(view,noClick)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	self.titleLoader = false
	self.skeletonNode = false
	self.isGrayed = false
end

function CrownTitleCell:init( ... )
	self.titleLoader = self.view:getChildAutoType("titleLoader")
	if __IS_RELEASE__ then
		self.view:getController("c1"):setSelectedIndex(0)
	end
end


function CrownTitleCell:setData(id)
	self.titleLoader:displayObject():removeAllChildren()
	self.skeletonNode = false
	local config = DynamicConfigData.t_CrownTitle[id]
	if config then
		self.skeletonNode = SpineUtil.createSpineObj(self.titleLoader, vertex2(0,0), "animation", "Spine/ui/CrownTitle", config.icon, config.icon,true)
	end
	self:setGrayed(self.isGrayed)
end


function CrownTitleCell:stopEffect(id)
	if self.skeletonNode then 
		self.skeletonNode:pause()
	end
end


function CrownTitleCell:resumeEffect(id)
	if self.skeletonNode then 
		self.skeletonNode:resume()
	end
end


function CrownTitleCell:setGrayed(isGray)
	self.isGrayed = isGray
	if self.skeletonNode then 
		if not isGray then
			self.skeletonNode:setColor({r=255,g=255,b=255})
		else
			self.skeletonNode:setColor({r=100,g=100,b=100})
		end
	end
end


--退出操作 在close执行之前 
function CrownTitleCell:__onExit()
     print(086,"CrownTitleCell __onExit")
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return CrownTitleCell