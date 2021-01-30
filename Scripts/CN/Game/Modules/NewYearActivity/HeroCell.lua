--added by xhd
--HeroCell封裝
local HeroCell = class("HeroCell",BindView)
function HeroCell:ctor(view)
	self.view = view
	self.data = false
	self.pos = {x = 0, y = 0}
	self.level = 0
end

function HeroCell:init( ... )
	self.node = self.view:getChildAutoType("node")
	self.name = self.view:getChildAutoType("name")
end

function HeroCell:setData(data)
	self.data = data
	self.level = self.data.level
	self:createHero()
	self:setName()
	self.view:setPosition(self.pos.x,self.pos.y)
end

--创建玩家
function HeroCell:createHero()
	local spine = SpineMnange.createSprineById(self.data.heroOpertion,true,false,nil, self.data.fashionCode)
	spine:setAnimation(0, "stand", true)
	-- spine:setPosition(50,50)
	self.node:displayObject():addChild(spine)
	self.view:setRotation(26.8)
end

function HeroCell:setName()
	self.name:setText(self.data.name)
end

function HeroCell:setPos(x,y)
	self.pos.x = x
	self.pos.y = y
	self.view:setPosition(x,y)
end

function HeroCell:hideHero()
	self.view:setVisible(false)
end

function HeroCell:showHero()
	self.view:setVisible(true)
end

function HeroCell:__onExit()
end

return HeroCell