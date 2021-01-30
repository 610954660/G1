--added by wyang
--const读取
ConstConfiger = {}

function ConstConfiger.getValueByKey(key)
	local config = DynamicConfigData.t_const[key]
	if config then
		return config.value
	end
	return 0
end


function ConstConfiger.getValueStrByKey(key)
	local config = DynamicConfigData.t_const[key]
	if config then
		return config.valueStr
	end
	return 0
end
