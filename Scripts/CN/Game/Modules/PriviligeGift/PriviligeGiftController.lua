local PriviligeGiftController = class("PriviligeGiftController", Controller)


function PriviligeGiftController:Privilege_AllData(_, data)
	-- LuaLogE("***************************** 推送特权礼包信息 ****************************")
	-- printTable(999,"推送特权礼包信息",data)
	PriviligeGiftModel:getDataDynamic(data)
end

return PriviligeGiftController