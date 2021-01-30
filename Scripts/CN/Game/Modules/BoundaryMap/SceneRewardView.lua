local SceneRewardView = class("SceneRewardView",Window)
function SceneRewardView:ctor(args)
 	self._packName 	= "BoundaryMap"
 	self._compName 	= "SceneRewardView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.layer = args.layer
	self.difficulty = args.difficulty

	self.t_BoundaryReward = BoundaryMapModel:getBoundaryReward()[args.difficulty]
end
function SceneRewardView:_initUI()
	RedManager.updateValue("V_Boundary_Reward",false)
	FileCacheManager.setBoolForKey("V_Boundary_Reward"..PlayerModel.userid..self._args.difficulty,false)
	self.view:getChildAutoType("closeButton"):addClickListener(function()
		self:closeView()
	end)
	self.diff_str = self.view:getChildAutoType("diff_str")
	self.diff_str:setText(string.format(Desc.Boundary_desc2,self.difficulty))

	self.effet_str = self.view:getChildAutoType("effet_str")

	self.list = self.view:getChildAutoType("list")
	self.list:setItemRenderer(handler(self,self.listHandle))
	self.list:setVirtual()
	self.list:setData(self.t_BoundaryReward)

	if self.difficulty ~= table.nums(DynamicConfigData.t_BoundaryNode) then
		BoundaryMapModel:getPowerDifficult()
		local config = DynamicConfigData.t_BoundaryDifficulty[self.difficulty + 1].unlock
		self.effet_str:setText(string.format(Desc.Boundary_desc14,config[1],config[2]))
	else
		self.effet_str:setText(Desc.Boundary_desc15)
	end
end
local function _handler(obj,method,data)
    return function(...)
        return method(obj,data,...)
    end
end
function SceneRewardView:listHandle(index, obj)
	local monsterReward = self.t_BoundaryReward[index + 1].monsterReward
	local bossReward = self.t_BoundaryReward[index + 1].bossReward

	local littleReward = obj:getChildAutoType("littleReward")
	littleReward:setItemRenderer(_handler(self,self.littleRewardHandle,monsterReward))
	littleReward:setData(monsterReward)

	local bossRewardObj = obj:getChildAutoType("bossReward")
	bossRewardObj:setItemRenderer(_handler(self,self.bossRewardHandle,bossReward))
	bossRewardObj:setData(bossReward)

	local tittle = obj:getChildAutoType("tittle")
	tittle:setText(index + 1)
end
function SceneRewardView:littleRewardHandle(data,index,obj)
	local itemcell = BindManager.bindItemCell(obj)
	local itemData = ItemsUtil.createItemData({data = data[index  + 1]})
	itemcell:setItemData(itemData)
end
function SceneRewardView:bossRewardHandle(data,index,obj)
	local itemcell = BindManager.bindItemCell(obj)
	local itemData = ItemsUtil.createItemData({data = data[index  + 1]})
	itemcell:setItemData(itemData)
end
function SceneRewardView:_exit()
end
return SceneRewardView