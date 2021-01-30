local EquipTargetController = class("EquipTargetController", Controller)

-- 服务端Odm数据下推回调
function EquipTargetController:Activity_UpdateData( _, params)
	if params.type ~= GameDef.ActivityType.EquipMission then
		return
	end
	if params.endState then --如果是true 直接结束
		ModelManager.ActivityModel:speDeleteSeverData(params.type)
		return
	end
	printTable(8848,">>>params.equipMission>>>",params.equipMission)
	ModelManager.EquipTargetModel:initData(params.equipMission)
end

return EquipTargetController