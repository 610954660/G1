--秘武配置读取器
local SecretWeaponConfiger = {}
local newGodArmsTrigger = {}
local newGodArmsMission = {}
local isAllInit = false
function SecretWeaponConfiger.initAllConfigs()
	isAllInit = true
	--秘武表
	local godArmsTrigger = DynamicConfigData.t_godArmsTrigger
	for _,v in pairs(godArmsTrigger) do
		newGodArmsTrigger[v.type] = newGodArmsTrigger[v.type] or {}
		table.insert(newGodArmsTrigger[v.type],{triggerType = v.triggerType, info = v})
		TableUtil.sortByMap(newGodArmsTrigger[v.type] , {{key="triggerType",asc=false}})	
	end

	--秘武任务表
	-- local godArmsMission = DynamicConfigData.t_godArmsMission
	-- for i,v in pairs(godArmsMission) do
	-- 	newGodArmsMission[v.id] = newGodArmsMission[v.id] or {}
	-- 	table.insert(newGodArmsMission[v.id],v)
	-- 	TableUtil.sortByMap(newGodArmsMission[v.id] , {{key="taskId",asc=false}})	
	-- end
end

function SecretWeaponConfiger.getSecretWeaponsInfo(SecretWeaponType)
	if not isAllInit then SecretWeaponConfiger.initAllConfigs() end
	return newGodArmsTrigger[SecretWeaponType] and newGodArmsTrigger[SecretWeaponType].info or {}
end

-- function SecretWeaponConfiger.getGodArmsMissionInfo(id)
-- 	if not isAllInit then SecretWeaponConfiger.initAllConfigs() end
-- 	return newGodArmsMission[SecretWeaponType] or false
-- end
return SecretWeaponConfiger
