--added by wyang
--奖励框封裝（同时支持物品和英雄（英雄要显示不同星级））
local RewardCell = class("RewardCell",BindView)
function RewardCell:ctor(view)
	self.view = view
	self.typeCtrl = false
	
	self.heroCell = false
	self.itemCell = false
end

function RewardCell:init( ... )
	self.typeCtrl = self.view:getController("typeCtrl")
end


--直接设设置code的数据
function RewardCell:setData(data)
	if data.type == 4 then
		self.typeCtrl:setSelectedIndex(0)
		self.heroCell = BindManager.bindHeroCellShow(self.view:getChildAutoType("heroCell"))
		local tempdata = {}
		tempdata.code = data.code or data.heroId
		local config = DynamicConfigData.t_hero[tempdata.code]
		tempdata.category = config and config.category or 1
		tempdata.star = data.heroStar or (config and config.heroStar or 1)
		tempdata.level = 1
		tempdata.name = config and config.heroName or ""
		self.heroCell:setData(tempdata)
	else
		self.typeCtrl:setSelectedIndex(1)
		self.itemCell = BindManager.bindItemCell(self.view:getChildAutoType("itemCell"))
		self.itemCell:setData(data.code, data.amount, data.type)
	end
end



--退出操作 在close执行之前 
function RewardCell:__onExit()
     print(086,"RewardCell __onExit")
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return RewardCell