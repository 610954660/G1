local BoundaryMapController = class("BoundaryMapController", Controller)

function BoundaryMapController:ctor()
end

function BoundaryMapController:Boundary_PostBuff(_, args)
	
end
function BoundaryMapController:Boundary_PostBlessingBuff(_, args)
	BoundaryMapModel:setBlessing(args.skill)
end
function BoundaryMapController:Boundary_Info(_, args)
	BoundaryMapModel:setServerData(args.data)
	BoundaryMapModel:setMonsterBuff(args.monsterBuff)
	BoundaryMapModel:setBossBuff(args.bossBuff)
end
return BoundaryMapController