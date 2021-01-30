local MathUtil = {}

local MATH_COS = math.cos
local MATH_SIN = math.sin

function MathUtil.angle2Radian(angle)
	return math.pi/180 * angle
end

--根据角度获取朝向向量
function MathUtil.getOrientationVector(angle)
	angle = angle % 360
	local radian = angle2Radian(angle)

	return {MATH_COS(radian), MATH_SIN(radian)}
end

--点积
function MathUtil.getDotProduct(pointA, pointB)
	return pointA.x*pointB.x + pointA.y*pointB.y
end

--叉积
function MathUtil.getCrossProduct(pointA, pointB)
	return pointA.x*pointB.y - pointB.x*pointA.y
end

--点是否在矩形内
function MathUtil.isPointInRect(pointP, pointA, pointB, pointC, pointD)
	local PA = pointA - pointP
	local PB = pointB - pointP
	local PC = pointC - pointP
	local PD = pointD - pointP

	local rlt1 = getCrossProduct(PA,PB)
	local rlt2 = getCrossProduct(PB,PC)
	local rlt3 = getCrossProduct(PC,PD)
	local rlt4 = getCrossProduct(PD,PA)

	return rlt1 >= 0 and rlt2 >= 0 and rlt3 >= 0 and rlt4 >= 0
end

--四捨五入保留n位小数
function MathUtil.getPreciseDecimal(decimal,n)
    decimal = decimal * (10^n)
    local ret = math.floor(decimal+0.5)
    return  ret*(0.1^n)
end


function MathUtil.buildMatrix(xAxis, yAxis, zAxis, displacement)
	return {
		xAxis[1],xAxis[2],xAxis[3],displacement[1],
		yAxis[1],yAxis[2],yAxis[3],displacement[2],
		zAxis[1],zAxis[2],zAxis[3],displacement[3],
		0,0,0,1
	}
end


--把数字转换成分节的字符串，eg:1001.99转成 1,001.99
function MathUtil.toSectionStr(num, noSimplify)
	local stringAdd = ""
	if not noSimplify then
		if num <= 99999 then
			stringAdd = ""
		elseif num <= 99999999 then
			num = math.floor(num/1000)/10
			stringAdd = Desc.common_w
		elseif num <= 999999999999 then
			num = math.floor(num/10000000)/10
			stringAdd = Desc.common_y
		else
			num = math.floor(num/100000000000)/10
			stringAdd = Desc.common_wy
		end
	end
	
	return num..stringAdd
	--local numStr = tostring(num)
	--local decimalSplit = string.split(numStr, ".")
	--local digitSplit = string.split(decimalSplit[1], "")
	
	--[[local resultStr = ""
	if decimalSplit[2] then
		resultStr = "."..decimalSplit[2]
	end
	local index = 0
	for i = #digitSplit,1,-1 do
		resultStr = digitSplit[i]..resultStr
		if math.mod(#digitSplit - i - 2, 3) == 0 and i > 1 then
			resultStr = ","..resultStr
		end
	end
	return resultStr..stringAdd--]]
end

return MathUtil