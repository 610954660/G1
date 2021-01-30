--added by wyang
--属性雷达
local AttrRadar = class("AttrRadar",BindView)
function AttrRadar:ctor(view,noClick)
	
	self.r = 103
end

function AttrRadar:init( ... )
	--self:drawBase()
end

function AttrRadar:setAttrNames(nameList)
	for i = 1,5,1 do
		self.view:getChildAutoType("txt_attrName"..i):setText(nameList[i])
	end
end

function AttrRadar:setAttrVal(attrVarList)
	for i = 1, 5 do
		self.view:getChildAutoType("txt_attrVar"..i):setText(attrVarList[i])
	end
end

function AttrRadar:setAttrs(attrList)
	local maxValue = 0
	for _,v in ipairs(attrList) do
		if maxValue < v then
			maxValue = v
		end
	end
	local percentList = {1,1,1,1,1}
	if maxValue ~= 0 then
		for i = 1,5,1 do
			percentList[i] = attrList[i]--/maxValue
		end
	end
	self:drawBase(percentList)
end

function AttrRadar:drawBase(percentList)
	local points = {}
	local angel = math.pi*2/5
	points[1] = ccp(0, self.r * percentList[1])
	points[2] = ccp(self.r * math.sin(angel)* percentList[2], self.r * math.cos(angel) * percentList[2])
	points[3] = ccp(self.r * math.sin(angel/2)* percentList[3], -self.r * math.cos(angel/2) * percentList[3])
	points[4] = ccp(-self.r * math.sin(angel/2)* percentList[4], -self.r * math.cos(angel/2) * percentList[4])
	points[5] = ccp(-self.r * math.sin(angel)* percentList[5], self.r * math.cos(angel) * percentList[5])

	local color = ccc4f(124.0/255,181.0/255,211.0/255,0.7)

	self.holder = self.holder or fgui.GGraph:create();
	self.holder:drawPolygon(1,color,color,points, #points)
	self.holder:setPosition(self.view:getWidth()/2 + 2, self.view:getHeight()/2 + 4)
	self.view:addChild(self.holder);
end

function AttrRadar:drawAttr()
	local pointList = {1,1,0.7,0.5,0.3}
end


--退出操作 在close执行之前 
function AttrRadar:__onExit()
  --   print(1,"AttrRadar __onExit")
  -- self:_exit() --执行子类重写
  --  self:clearEventListeners()
  --  for k,v in pairs(self.baseCtlView) do
  --  		v:__onExit()
  --  end
end

return AttrRadar