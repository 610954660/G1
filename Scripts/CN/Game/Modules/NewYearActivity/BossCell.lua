--added by xhd
--BossCell封裝
local BossCell = class("BossCell",BindView)
function BossCell:ctor(view)
	self.view = view
	self.data = false
end

function BossCell:init( ... )
	self.node = self.view:getChildAutoType("node")
	self.name = self.view:getChildAutoType("name")
end

function BossCell:setData(data)
	self.data = data
	self:createBoss()
	self:setName()
end

function BossCell:createBoss()
	local spine = SpineMnange.createSprineById(self.data.bossId,false,false,nil,nil)
	spine:setPosition(15,0)
	spine:setAnimation(0, "stand", true)
	self.node:displayObject():addChild(spine)
	self.view:setRotation(26.8)
end

function BossCell:setName()
	self.name:setText(self.data.name)
end

function BossCell:__onExit()
end

return BossCell