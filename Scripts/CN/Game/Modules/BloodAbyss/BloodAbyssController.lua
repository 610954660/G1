--Date :2020-12-17
--Author : generated by FairyGUI
--Desc : 

local BloodAbyssController = class("BloodAbyss",Controller)

function BloodAbyssController:init()
	
end

function BloodAbyssController:Activity_UpdateData(_, params)
	if params.type == GameDef.ActivityType.BloodAbyss then
		
		BloodAbyssModel:initData(params.bloodAbyss)
		
		--Dispatcher.dispatchEvent("CustomizedGifts_refreshPanal")
	end
end


function BloodAbyssController:bloodAbyss_battle( _,eventData )
    local status,time = BloodAbyssModel:getStatus() 
    if status == 2 then
        RollTips.show(Desc.bloodAbyss_status2:format(time/60))
        return
    elseif status == 3 then
        RollTips.show(Desc.bloodAbyss_status3)
        return 
    elseif status == 4 then
        RollTips.show(Desc.bloodAbyss_status4)
        return 
    end
	local function battleHandler(eventName,args)
		if eventName == "begin" then
			if BloodAbyssModel.isSend then RollTips.show(Desc.common_networktips) return  end
			BloodAbyssModel.isSend = true
			local params = {}
			params.activityId = BloodAbyssModel:getActivityId()
			params.boss = BloodAbyssModel.rankBossInfo.bossId
			printTable(33,"send Activity_BloodAbyss_Challenge",params)
			RPCReq.Activity_BloodAbyss_Challenge(params,function(data)
					BloodAbyssModel.curBoss = BloodAbyssModel.rankBossInfo
					printTable(33,"Activity_BloodAbyss_Challenge call",data)
					local result = {}
					result.isWin = true
					result.reward = data.rewards
					result.curScore = data.score
					result.type = GameDef.GamePlayType.BloodAbyss
					result.maxScore = BloodAbyssModel.curBoss.maxScore
					result.maxHurt = BloodAbyssModel.curBoss.maxHurt
					result.boss = BloodAbyssModel.curBoss
                    result.selfHurt = data.selfHurt or 0
                    
					ModelManager.PlayerModel:set_awardData(result)

					BloodAbyssModel.isSend = false
				end,function (errorData)
					RollTips.showError(errorData)
					BloodAbyssModel.isSend = false
				end)
		elseif eventName == "next" then
			--Dispatcher.dispatchEvent(EventType.battle_end,args)
		end
	end

	
	print(33,"BloodAbyssMainView dispatchEvent.battle_requestFunc")
	Dispatcher.dispatchEvent(EventType.battle_requestFunc,battleHandler,{fightID=DynamicConfigData.t_BloodAbyssMonster[BloodAbyssModel.rankBossInfo.bossId][BloodAbyssModel.rankBossInfo.difficulty].fightId,configType=GameDef.BattleArrayType.BloodAbyss})
	
end

return BloodAbyssController