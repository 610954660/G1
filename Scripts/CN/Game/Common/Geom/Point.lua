local Point = {}
local MATH_ABS = math.abs
local MATH_COS = math.cos
local MATH_SIN = math.sin
local MATH_SQRT = math.sqrt
local MATH_ATAN2 = math.atan2

local mt = {}

--重定义+运算
function mt.__add(p1, p2)
	return new(p1.x + p2.x, p1.y + p2.y)
end
--重定义-运算
function mt.__sub(p1, p2)
	return new(p1.x - p2.x, p1.y - p2.y)
end
--重定义==运算
function mt.__eq(p1, p2)
	return p1.x == p2.x and p1.y == p2.y
end
--返回包含 x 和 y 坐标的值的字符串
function mt.__tostring(p)
	return string.format("[Point (%d, %d)]", p.x, p.y)
end

--------------------------------------------------------------- 

--创建一个新点
function Point.new(x, y)
	local p = {x=0, y=0}
	setmetatable(p, mt)
	if type(x) == "number" then p.x = x end
	if type(y) == "number" then p.y = y end
	
	--创建此 Point 对象的副本
	function p:clone()
		return new(self.x, self.y)
	end
	--按指定量偏移 Point 对象
	function p:offset(dx, dy)
		assert(type(dx) == "number", "[Error Point.offset] #1 number expected, got a "..type(dx))
		assert(type(dy) == "number", "[Error Point.offset] #2 number expected, got a "..type(dy))
		self.x = self.x + dx
		self.y = self.y + dy
	end
	--将 (0,0) 和当前点之间的线段缩放为设定的长度
	function p:normalize(len)
		assert(type(len) == "number", "[Error Point.normalize] #1 number expected, got a "..type(len))
		
		local atan = MATH_ATAN2(self.y, self.x)
		return new(MATH_COS(atan) * len, MATH_SIN(atan) * len)
	end
	--将 Point 的成员设置为指定值
	function p:setTo(xa, ya)
		assert(type(xa) == "number", "[Error Point.offset] #1 number expected, got a "..type(xa))
		assert(type(ya) == "number", "[Error Point.offset] #2 number expected, got a "..type(ya))
		self.x = xa
		self.y = ya
	end
	--从 (0,0) 到此点的线段长度
	function p:length()
		return distance(self, new(0, 0))
	end
	
	return p
end

--[静态] 返回 p1 和 p2 之间的距离
function Point.distance(p1, p2)
	return MATH_SQRT((p1.x - p2.x)^2 + (p1.y - p2.y)^2)
end


function Point.distanceCQ(p1,p2)
	local disX = MATH_ABS(p2.x - p1.x)
	local disY = MATH_ABS(p2.y - p1.y)

	if disX > disY then
		return disX
	end
	return disY
end

--[静态] 返回 p1 和 p2 之间的距离平方
function Point.distanceSquare(p1, p2)
	return (p1.x - p2.x)^2 + (p1.y - p2.y)^2
end

return Point