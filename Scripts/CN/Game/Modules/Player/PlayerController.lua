local PlayerController = class("PlayerController",Controller)
local MoneyUtil = require "Game.Utils.MoneyUtil"
local OpenParam=require "Game.Consts.OpenParam"
local ModuleType = GameDef.ModuleType
function PlayerController:init()
	-- self.emblemList = {};
end


function PlayerController:player_openInfoView()
    SoundManager.playSound(4,false)
	ViewManager.open("PlayerInfoView")
end

function PlayerController:player_openHeadView()
	ViewManager.open("PlayerHeadView")
end

function PlayerController:Battle_AllBattleArrays(_,args)
	printTable(33,"battleArray = ",args)
	PlayerModel.firstBattleArray = args
end


function PlayerController:Chat_SendBanChatTime(_,args)
    if args then
        PlayerModel:setBanChatTime(args.banChatTime)
    end
end

function PlayerController:Boundary_Info(_,args)
    if args and args.data then
        PlayerModel:setBoundaryTime(args.data.round)
    end
end


--货币下推  服务器协议事件监听
function PlayerController:Money_Update( e,args )
    LuaLogE(1,"PlayerController Money_Update")
    --printTable(1,args)
    local moneyUpdateInfo = args.moneyUpdateInfo
    local updateCode = args.updateCode
    local moneyChangeTb = {}
    for k, v in pairs( moneyUpdateInfo ) do
        local preAmount =ModelManager.PlayerModel:getMoneyByType(v.type)
        ModelManager.PlayerModel:updateMoney(v.type,v.amount)
        moneyChangeTb[v.type] = {}
        local moneyDesc = MoneyUtil.getMoneyName(v.type)
        if moneyDesc and moneyDesc ~= "" then
            local desc
            local diff = v.amount - preAmount
            if diff ~= 0 then
            else
            end
            table.insert(moneyChangeTb[v.type], diff)
        end
    end
    Dispatcher.dispatchEvent(EventType.money_change, moneyChangeTb)
end

--角色最大战力更新
function PlayerController:Player_UpdateMaxCombat(_,params)
    print(1,"角色战力协议数据",params)
    RollTips.showAddFightPoint(params.updateValue)
end


-- 手动注册方法
function PlayerController:_initListeners()
	
end

function PlayerController:Attr_UpdateRoleInfo(_,info)
	printTable(1,"Attr_UpdateRoleInfo = ",info)
	
	info.beforeLevel = PlayerModel.level
	info.isUpgrade = false
	PlayerModel.level = info.level
    PlayerModel.exp = info.exp
	if info.level > info.beforeLevel then
		if info.level >=30 or info.level%5 == 0 then
			--升级时提交玩家数据到api中心
			PHPUtil.updatePlayer()
		end
		info.isUpgrade = true
		--Dispatcher.dispatchEvent(EventType.player_levelUp)  --等出完升级动画后再发
		SDKUtil.recordRoleInfo(AgentConfiger.SDK_RECORD_LEVEL_UPDATE)
		Dispatcher.dispatchEvent(EventType.module_check, ModuleType.Level , info.level)
	end
	

	
	Dispatcher.dispatchEvent(EventType.player_updateRoleInfo, info)
    
end


--货币不足
function PlayerController:money_not_enough( e,params )
    params = params or {}
    print(1,"货币"..params.moneyName.."不足")
    -- Alert.show({
    --     -- 需要一个类型FileDataType的文件，防止重复
    --     id = AlertId.RECHARGE,
    --     title = "标题",
    --     text = params.moneyName.."不足",
    --     type = "yes_no",
    --     mask = true,
    --     onClose = function(detail)
    --         if detail == "yes" then
    --             ViewManager.open("RechargeView", { key = "recharge", selected = "recharge" })
    --         end
    --     end
    -- })
end

--奖励统一发送
function PlayerController:Agent_PostGameRewardRes( _,params )
    print(5656,"Agent_PostGameRewardRes")
    printTable(5656,params)
    --差异化奖励展示界面
    local typeView = {}
    if params.show ==1 then --  是否马上显示 1 马上显式　0延长显示
		--爬塔出现战力压制的情况直接弹奖励
        if params.type == 5033  then
			Dispatcher.dispatchEvent(EventType.PveStarTemple_HandleAutoItem,params)
			if ModelManager.PveStarTempleModel:getAuto() then
				return 
			end
            return
        end

		if params.type == 2000 or params.type == 2001 or params.type == 2002 or params.type == 2003 then
			params.closeCallBack = function()
				Dispatcher.dispatchEvent(EventType.pata_showNext)
			end
			local function againChallege(activeType,arrayType)
				Dispatcher.dispatchEvent(EventType.pata_beginChallege,activeType,arrayType)--继续挑战下一层
			end
			local data = params
			ModelManager.PlayerModel:set_awardData(params)
			ViewManager.open("ReWardView",{page=4,type=1,data=data,isWin=true,hasMvp = false,arrayType=OpenParam.PataParam[params.type].type,activeType=params.type,againFunc=againChallege})
		    return 			
        end
        

        local viewName = typeView[params.type] 
        if viewName == nil then 
            viewName = "AwardShowView"
        end
		if viewName == "AwardShowView" then
			RollTips.showReward(params.reward, nil,nil,nil,params) --因为要优先显示时装，把时装分开显示的处理在RollTips.showReward里面，所以这里不直接出奖励提示了
		else
			ViewManager.open(viewName,params)   
		end
    elseif params.show ==0 then
        ModelManager.PlayerModel:set_awardData(params)
    end
    -- self.emblemList = {}
end

--前端响应显示页面通知
function PlayerController:show_gameReward(_,params)
    print(1,"show_gameReward")
    -- body
    local data = ModelManager.PlayerModel:get_awardData(params and params.gamePlayType)
	-- printTable(1,"show_gameReward",data)
	if data and data.type then
        if data.type == GameDef.GamePlayType.Maze  then --迷宫 特殊处理 推图
                ViewManager.open("ReWardView",{page=4,type=1,data=data,isWin=data.isWin})
		elseif data.type == GameDef.GamePlayType.FairyLand  then --秘境，无论输赢都出结算
                ViewManager.open("ReWardView",{page=4,type=1,data=data,isWin=data.isWin})
        elseif data.type == GameDef.GamePlayType.Hallow  then --圣器副本
				ViewManager.open("ReWardView",{page=4,type=1,data=data,isWin=data.isWin})
		elseif data.type == GameDef.GamePlayType.EndlessRoad  then --远征
			ViewManager.open("ReWardView",{closefuc = data.closefuc,page=4,type=1,data=data,isWin=data.isWin})
		elseif data.type >= GameDef.GamePlayType.NormalTower and data.type <= GameDef.GamePlayType.FairyDemonTower or data.type==GameDef.GamePlayType.FairyDemonTower then --爬塔
			   --ViewManager.open("ReWardView",{page=4,type=1,data=data,isWin=data.isWin})
			   print(086,"爬塔拿出去处理")
        elseif data.type == GameDef.GamePlayType.Boundary  then --临界
        elseif data.type == GameDef.GamePlayType.BloodAbyss  then --临界
            ViewManager.open("ReWardView",{page=12,type=1,data=data,isWin=data.isWin})
        elseif data.type == GameDef.GamePlayType.ActivityTrial  then --阵营试炼
            ViewManager.open("ReWardView",{page=4,type=1,data=data,isWin=data.isWin})
        elseif data.type == GameDef.GamePlayType.ActivityGodMarket  then --神虚历险
            ViewManager.open("ReWardView",{page=16,type=1,data=data,isWin=data.isWin})
        elseif data.type >= GameDef.GamePlayType.CoinCopy and data.type <= GameDef.GamePlayType.JewelryCopy  then --材料副本
            ViewManager.open("ReWardView",{page=4,type=1,data=data,isWin=data.isWin})
        elseif data.type == GameDef.GamePlayType.DreamPvp  then --临界
            local view = ViewManager.open("AwardShowView",data)
            local text = fgui.GRichTextField:create()
            text:setColor({r = 255,g = 255,b = 255})
            text:setFontSize(22)
            text:setAutoSize(1)
            text:setText(Desc.DreamMasterPvp_kfhjs:format( DreamMasterPvpModel:getAwardTex()))
            text:setUBBEnabled(true)
            local a_node = view.view:getChildAutoType("n11")
            text:setPosition(a_node:getWidth()/2 -text:getWidth()/2,-390)
            a_node:addChild(text)
        elseif  data.type == GameDef.GamePlayType.CrossSuperMundane  then --超凡段位赛
            ViewManager.open("ReWardView",{page=14,type=1,data=data,isWin=data.isWin})
		elseif  data.type == GameDef.GamePlayType.PowerPlan  then --异能计划
			ViewManager.open("ReWardView",{page=4,type=1,data=data,isWin=true})
        else
			if data.reward then
				ViewManager.open("AwardShowView",data)
			end
        end
     	
	end
end

function PlayerController:GamePlay_Modules_Rename_Succese(_,info)
	print(33,"PlayerInfoView GamePlay_Modules_Rename_Succese")
	printTable(33,info)
	PlayerModel.username = info.newName
	PlayerModel.nameFlag = true
	--提交玩家数据到api中心
	PHPUtil.updatePlayer()
    Dispatcher.dispatchEvent(EventType.player_rename_success,info.newName)
    if not GuideModel:IsGuiding() then
        Alert.show(Desc.player_changesuccess)
    end
end

function PlayerController:Bag_HeadBorder_Update(_,info)
	PlayerModel.headBorder = info.headBorder
	Dispatcher.dispatchEvent(EventType.player_headreset)
end

--服务器推送的提示消息
function PlayerController:Player_TipsNotify(_,info)
    printTable(1,"背包推送",info)
	if info then
		local config = DynamicConfigData.t_TipsContent[info.code]
		if config then
			if config.type == 1 then
				RollTips.show(config.content)
            else
                --抽卡特殊情况 卡牌背包已满 由前端判定			
                if ViewManager.getView("GetCardsView") and config.code == 1 then
                    return
                end
				GlobalUtil.delayCallOnce(config.content, function()
					ModelManager.PlayerModel.TipsNotifyId  = Alert.show(config.content)
				end, self, 1)
			end
		end
	end
end

--
function PlayerController:Player_CloseClientModule(_,info)
	printTable(33,"Player_CloseClientModule",info)
	ModuleUtil.setCloseModuleId(info.idList)
	Dispatcher.dispatchEvent(EventType.module_check)
	
	local view = ViewManager.getView("MainUIView")
	if view then
		view:upOpenNodeBtns()
	end
	
end


function PlayerController:Stat_Update(_,info)
	ModelManager.PlayerModel:updateStat(info.type, info.value)
end

function PlayerController:DailyStat_Update(_,info)
	ModelManager.PlayerModel:updateDailyStat(info.type, info.value)
end

--登陆游戏的时候检查头像是否还能用（时装会失效），时装失效的时候也要检测
function PlayerController:public_enterGame()
	self:checkHead()
end

function PlayerController:pack_fashion_change()
	self:checkHead()
end

function PlayerController:mainui_showHeroChange()  --因为图鉴数据比较慢，数据来了要检查一次
	self:checkHead()
end

function PlayerController:checkHead()
	--当头像过期后换成板娘的（一定是可用的）
	if LoginModel.hadEnterGame and ModelManager.HandbookModel.heroOpertion ~= 0 then  --登陆时可能板娘数据还没拿到 
		if DynamicConfigData.t_HeadEx[PlayerModel.head] and not ModelManager.PackModel:getFashionBag():getIsHaveFashion(PlayerModel.head) then 
			local newHead = ModelManager.HandbookModel.heroOpertion
			RPCReq.GamePlay_Modules_Rename_head({id = newHead},function(args)
						if args.ret == 0 then
							PlayerModel.head = newHead
							Dispatcher.dispatchEvent(EventType.player_headreset,newHead)
						else
							--RollTips.show("error.code = "..args.ret)
						end
					end)
		end
	end
end

return PlayerController