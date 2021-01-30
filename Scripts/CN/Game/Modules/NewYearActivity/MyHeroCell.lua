--added by xhd
--MyHeroCell封裝
local MyHeroCell = class("MyHeroCell",BindView)
function MyHeroCell:ctor(view)
	self.view = view
	self.data = false
	self.pos = {x = 0, y = 0}
end

function MyHeroCell:init( ... )
	self.spineMc = self.view:getChildAutoType("spine")
	self.spineMc_down = self.view:getChildAutoType("spine_down")
	self.spineMc_up = self.view:getChildAutoType("spine_up")
	self.name = self.view:getChildAutoType("name")
end

function MyHeroCell:setData(data)
	self.data = data
	self:createMyHero()
	self:setName()
	self.view:setPosition(self.pos.x,self.pos.y)
end

--创建玩家
function MyHeroCell:createMyHero()
	local spine = SpineMnange.createSprineById(self.data.heroId,true,false,nil, self.data.fashionId)
	spine:setAnimation(0, "stand", true)
	spine:setPosition(100,40)
	self.spineMc:displayObject():addChild(spine)
	self.view:setRotation(26.8)
end

function MyHeroCell:setName()
	self.name:setText(self.data.name)
end

function MyHeroCell:setPos(x,y)
	self.pos.x = x
	self.pos.y = y
	self.view:setPosition(x,y)
end

function MyHeroCell:playInEffect(endFunc)
	SpineUtil.createSpineObj(self.spineMc_down, vertex2(50,0), "mijing_cx_down", "Spine/ui/mijing", "efx_mijing", "efx_mijing",false)
		
	self.spineMc:getTransition("in"):play(function( ... )
		
	end)
	
	local spineNode = SpineUtil.createSpineObj(self.spineMc_up, vertex2(50,0), "mijing_cx_up", "Spine/ui/mijing", "efx_mijing", "efx_mijing",false)
	spineNode:setCompleteListener(function(name)
		Scheduler.scheduleNextFrame(function()
			if endFunc then endFunc() end
		end)
	end)
end

function MyHeroCell:playOutEffect(endFunc)
	SpineUtil.createSpineObj(self.spineMc_down, vertex2(50,0), "mijing_xs_down", "Spine/ui/mijing", "efx_mijing", "efx_mijing",false)
	
	self.spineMc:getTransition("out"):play(function( ... )

	end)

	local spineNode = SpineUtil.createSpineObj(self.spineMc_up, vertex2(50,0), "mijing_xs_up", "Spine/ui/mijing", "efx_mijing", "efx_mijing",false)
	spineNode:setCompleteListener(function(name)
		Scheduler.scheduleNextFrame(function()
			if endFunc then endFunc() end
		end)
	end)
end

--退出操作 在close执行之前 
function MyHeroCell:__onExit()
end

return MyHeroCell