-- added by wyz
-- 首充礼包配置

local FirstChargeConfiger = {}

function FirstChargeConfiger.getConfig(accType,dayIndex)
	local conf = DynamicConfigData.t_FirstCharge
	return conf[accType][dayIndex]
end

return FirstChargeConfiger