--Pata控制器
local PataController = class("PataController",Controller)
local ViewArrayType = require "Game.Consts.ViewArrayType"
--function PataController:update_cardListTime()
	--print(086 , "PataController : UpateLimit")
	--ModelManager.PataModel:updateRed()
--end

function PataController:materialCopy_addCopyNum(_,copytype)
	print(086,"materialCopy_addCopyNum",copytype)
	--ModelManager.PataModel:updateRed()
end


function PataController:materialCopy_updata(_,data)
	print(086,"materialCopy_updata");
	ModelManager.PataModel:updateRed()
end

function PataController:materialCopy_pass(_,copytype)
	print(086,"点击扫荡2");

end

function PataController:materialCopy_resetDay(_,copytype)
	print(086,"跨天重置2")
end


--开始挑战
function PataController:pata_beginChallege(_,activeType,arrayType)

	--local activeType=challData.activeType
	
	activeType=activeType or PataModel.activeType
	arrayType=arrayType or PataModel.arrayType
	
	local curFloor = ModelManager.PataModel:getPataFloor(activeType)
	local cfg_tower = DynamicConfigData.t_tower[activeType]



	local floorInfo = cfg_tower[curFloor] or DT


	--特殊塔，这里需要验证
	local canFight = true
	if activeType ~=2000 then
		local copyInfo = ModelManager.MaterialCopyModel:getCopyInfo(activeType)
		-- printTable(1 , "副本信息" , copyInfo )
		if copyInfo ~= nil and copyInfo.dailyInfo ~= nil and copyInfo.dailyInfo.times>=10  then
			canFight = false
		end
	end
	if canFight==false then
		RollTips.show("种族塔每天最多只能挑战10层")
		return
	end
	local params={
		gamePlayType=activeType
	}
	RPCReq.Copy_TowerBackResult(params,function(data)
			printTable(0866,data)
			print(5656,"Copy_TowerBackResult")
			if curFloor>DynamicConfigData.t_const["TowerNoBattleLevel"].value and data.isSuccess then
				RollTips.show(Desc.pata_desc2)
				PataModel:setSuccess(activeType)
				PataModel.__floor=data.level
			else
				printTable(4,floorInfo,"floorInfo")
				print(4,floorInfo.fightId,"floorInfo.fightId")
				
				local viewNode=ViewManager.getView(ViewArrayType[arrayType].view)
				--if  not viewNode  then
					--ModelManager.PataModel:enterCopy(activeType)
					--return
				--end

				
				Dispatcher.dispatchEvent(EventType.battle_requestFunc,function(eventName)
						if eventName == "begin" then
							Dispatcher.dispatchEvent(EventType.pata_scrollToCurFloor)
							ModelManager.PataModel:enterCopy(activeType)
						elseif eventName == "end" then

							local awardData = ModelManager.PlayerModel:get_awardData(activeType)
							if awardData then
								local function againChallege(activeType,arrayType)
									Dispatcher.dispatchEvent(EventType.pata_beginChallege,activeType,arrayType)--继续挑战下一层
								end
								ViewManager.open("ReWardView",{page=4,type=1,data=awardData,isWin=awardData.isWin,activeType=activeType,againFunc=againChallege})
							end
						end
					end,{fightID = floorInfo.fightId,configType = arrayType,activeType = activeType,skipArray=PataModel:checkSkipArray(GameDef.BattleArrayType.Tower) or not viewNode })
			end
		end)
end




return PataController
