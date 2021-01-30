-- added by wyz
-- 特权购买配置
local PriviligeGiftConfiger = {}

function PriviligeGiftConfiger.getDataByID(id)
	local conf = DynamicConfigData.t_PriviligeGift
	return conf[id]
end

function PriviligeGiftConfiger.getAllConf()
	local conf = DynamicConfigData.t_PriviligeGift
	return conf
end
return PriviligeGiftConfiger