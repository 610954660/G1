--货币帮助类
local MoneyUtil = {}
local MoneyType = GameDef.MoneyType

local unitName = {
	[MoneyType.Gold]              = "金币",
	[MoneyType.Diamond]          = "钻石",
}

--获取货币名称
function MoneyUtil.getMoneyName(mtype)
	return unitName[mtype] or ""
end

--获取货币icon
function MoneyUtil.getMoneyIcon( mtype )
	-- body
end

--是否有足够的钱
function MoneyUtil.isEnoughMoney(num,type)
	if type == MoneyType.Gold then 
		if num <= ModelManager.PlayerModel:getMoneyByType(type) then 
			return true
		else 
			if num <= (ModelManager.PlayerModel:getMoneyByType(type) 
				+ ModelManager.PlayerModel:getMoneyByType(MoneyType.Money)) then 
				return true
			end 
			return false
		end 
	elseif type == MoneyType.Money then 
		if num <= ModelManager.PlayerModel:getMoneyByType(type) then 
			return true
		else 
			return false
		end
	end
end

return MoneyUtil
