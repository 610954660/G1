----------------------------------------------------
-- 检测机型，解决花屏问题，部分安卓机型强制读rgd
----------------------------------------------------

--[[
	根据机型进行shader精度设置(模型马赛克问题), 防止不必要的效率影响
	needGreaterPrecision 记录需要设置高精度shader的机型
]]

local needGreaterPrecision = {"Xiaomi MI 3","NVIDIA deovo V5","LGE Optimus 4X HD","Ramos Ramosi9","Meitu MK150"}
--需要把RGD转换成PNG的机型
local needEncodeRGD2PngTargets = {"samsung GT-I9152", "samsung GT-I9082i"}
--把RGD转换成PNG的机型
local function needEncodeRGD2Png()
	local model = gy.GYDeviceUtil:getDeviceModel()
	for k, v in ipairs(needEncodeRGD2PngTargets) do
		if v == model then
			return true
		end
	end
	return false
end


local PhoneCheck = {}

--解决模型马赛克问题
function PhoneCheck.checkShaderPrecision()
	local model = gy.GYDeviceUtil:getDeviceModel()
	for k, v in pairs(needGreaterPrecision) do
		if string.find(v, model) ~= nil then
			cc.GLProgramCache:setPrecisionHeightShader()
			break
		end
	end
end

--检测以强制读取rgd
function PhoneCheck.check2ForceLoadRGD()
	if device.platform == "android" then
		if needEncodeRGD2Png() then
			cc.Image:setLoadDecodeETCWithRGBA8888(false)
			cc.Image:setLoadDecodeETC(true)
		end
	end
end


return PhoneCheck
