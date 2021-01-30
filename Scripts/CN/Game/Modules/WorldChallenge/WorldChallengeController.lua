--Name : WorldChallengeController.lua
--Author : generated by FairyGUI
--Date : 2020-5-22
--Desc : 

local WorldChallengeController = class("WorldChallengeController",Controller)

function WorldChallengeController:init()
	
end

function WorldChallengeController:WorldSkyPvp_StateNotify(_, args)
    if args and args.stateInfo then
        WorldHighPvpModel.WorldChallengeGuessRed=args.stateInfo
        local redVisi=false
        if args.stateInfo.newGuess and args.stateInfo.newGuess==1 then
            redVisi=true
        end
        printTable(155, "打印竞猜红点", redVisi)
        WorldHighPvpModel.WorldChallenJingCaiRed=redVisi
        RedManager.updateValue("V_WORLDCHALLENG_JINCAI", redVisi);  
        Dispatcher.dispatchEvent(EventType.worldChallenge_jingcaiRedUp)   
      end
end

function WorldChallengeController:WorldSkyPvp_NotifyActInfo(_, args)
    if args then
        WorldHighPvpModel.WorldChallengeActiveTime=args.actInfo;
        if (WorldChallengeModel.WorldChallengeActiveTime and WorldChallengeModel.WorldChallengeActiveTime.nextStartStamp and args.actInfo.nextStartStamp and WorldChallengeModel.WorldChallengeActiveTime.nextStartStamp < args.actInfo.nextStartStamp) then
            WorldChallengeModel.matchMode = 1
        else
            WorldChallengeModel.matchMode = 0
        end
		Dispatcher.dispatchEvent(EventType.worldChallenge_xiasaijidaojishi)
	end
end

function WorldChallengeController:WorldSkyPvp_JoinStateNotify(_,args)
    printTable(2233, "WorldSkyPvp_JoinStateNotify", args)
    local redVisi=false
    local battleArray=false
    if not args.battleArrayState or args.battleArrayState==false then
        battleArray=true
        WorldHighPvpModel.hasChageRed = true
    end
    if args and args.joinState==true and battleArray==true then
        redVisi=true
    end
    WorldHighPvpModel.hasChange=redVisi
    RedManager.updateValue("V_WORLDCHALLENG_MYCHALL", redVisi);
    Dispatcher.dispatchEvent(EventType.worldChallenge_wodebisaianniu) 
end


function WorldChallengeController:WorldArena_StateNotify(_, args)--竞猜红点
      printTable(31, "打印竞猜红点", args)
      if args and args.stateInfo then
        WorldChallengeModel.WorldChallengeGuessRed=args.stateInfo
        local redVisi=false
        if args.stateInfo.newGuess and args.stateInfo.newGuess==1 then
            redVisi=true
        end
        printTable(155, "打印竞猜红点", redVisi)
        WorldChallengeModel.WorldChallenJingCaiRed=redVisi
        RedManager.updateValue("V_WORLDCHALLENG_JINCAI", redVisi);  
        Dispatcher.dispatchEvent(EventType.worldChallenge_jingcaiRedUp)   
      end
end

function WorldChallengeController:WorldArena_JoinStateNotify(_, args)--我的比赛红点
    printTable(152, "我的比赛打印红点", args)
    local redVisi=false
    local battleArray=false
    if not args.battleArrayState or args.battleArrayState==false then
        battleArray=true
        WorldChallengeModel.hasChageRed = true
    end
    if args and args.joinState==true and battleArray==true then
        redVisi=true
    end
    WorldChallengeModel.hasChange=redVisi
    RedManager.updateValue("V_WORLDCHALLENG_MYCHALL", redVisi);  
    Dispatcher.dispatchEvent(EventType.worldChallenge_wodebisaianniu) 
end

function WorldChallengeController:WorldArena_NotifyActInfo(_, args)
   -- printTable(150, "活动基础信息？？？？?", args)
	if args then
        WorldChallengeModel.WorldChallengeActiveTime=args.actInfo;
        if (not WorldHighPvpModel.WorldChallengeActiveTime or not WorldHighPvpModel.WorldChallengeActiveTime.nextStartStamp or WorldHighPvpModel.WorldChallengeActiveTime.nextStartStamp < args.actInfo.nextStartStamp) then
            WorldChallengeModel.matchMode = 0
        else
            WorldChallengeModel.matchMode = 1
        end
		Dispatcher.dispatchEvent(EventType.worldChallenge_xiasaijidaojishi)
	end
    
end

return WorldChallengeController