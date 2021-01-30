--added by xhd
--MonsterCell封裝
local MonsterCell = class("MonsterCell",BindView)
function MonsterCell:ctor(view)
	self.view = view
	self.data = false
end

function MonsterCell:init( ... )
	self.node = self.view:getChildAutoType("node")
	self.name = self.view:getChildAutoType("name")
end

function MonsterCell:setData(data)
	self.data = data
	self:createMonster()
	self:setName()
end

function MonsterCell:createMonster()
	local spine = SpineUtil.createSpineObj(self.node, cc.p(x1, y1), "guan", "Effect/UI", "efx_juesuo", "efx_juesuo", false)
	self.node:displayObject():addChild(spine)
end

function MonsterCell:setName()
	self.name:setText(self.data.name)
end

function MonsterCell:playEffect()
	SpineUtil.createSpineObj(self.node, cc.p(x1, y1), "kai", "Effect/UI", "efx_juesuo", "efx_juesuo", false)
end

function MonsterCell:__onExit()
end

return MonsterCell