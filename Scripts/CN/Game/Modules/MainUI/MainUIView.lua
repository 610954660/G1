--added by xhd 主界面view
local MainUIView,Super = class("MainUIView",View)
local MoneyType = GameDef.MoneyType
local MainAdBoard = require "Game.Modules.MainUI.MainAdBoard"
local MainMsgBoard = require "Game.Modules.MainUI.MainMsgBoard"
local  MazeConfiger = require "Game.ConfigReaders.MazeConfiger"
local ActivityMap = require "Game.Modules.Activity.ActivityMap"
local ItemCell = require "Game.UI.Global.ItemCell"

function MainUIView:ctor()
	self._packName = "MainUI"
	self._compName = "MainUIView"
	self._rootDepth = LayerDepth.MainUI
	self._isFullScreen = true
	self._showParticle = true
	self._action="xuehua_guangqia"
	self.__reloadPacket = true
	self.msgId = 1

	self._isAsync = false

	self.avatar = false
	self.duty = false
	self.mainUITabPanel = false
	self.fuliBtn = false  --福利按钮
	self.ActBtn = false --精彩活动
	self.emailBtn = false
	self.friendBtn = false
	self.chatBtn = false
	self.popBtn=false
	self.settingBtn=false
	self.load_bg = false
	self.list_reminder=false
	self.rankBtn=false
	self.bagBtn=false
	self.guildBtn=false
	self.heroBtn=false
	self.shopBtn=false
	self.btn_vip = false;
	self.btn_loginSend = false
	self.btnListLeftTop = false

	self.btn_newEvent = false

	self.zhaohuanBtn=false
	self.tuituBtn=false
	self.image_battle=false---战斗小标记暂时只有推图有
	self.jinjichangBtn=false
	self.btn_test=false
	self.btn_jinji = false
	self.btn_pata = false
	self.btn_guild = false

	self.duanzaoBtn = false
	self.lilianBtn=false

	self.exitBtn=false
	self.isFirstShow = true --是否首次显示
	self.shrinkActivtyBtns = false --是否收起活动按钮


	self.avatorIcon=false
	self.avatorFrameIcon=false
	self.avatorName=false
	self.avatorLevel=false
	self.fightVal=false
	self.taskBtn = false
	self.adBoard = false
	self.quickUseGroup = false
	self.adBoradObj = false
	self.list_active = false
	self.list_subBtns = false
	self.subBtns = false
	self.btn_service = false
	self.subCloseBtn=false
	self.btn_openTest=false
	self.btn_funcManual = false -- 功能手册入口
	self.btn_actShow = false  --隐藏活动按钮

	self._curFightPoint = 0 --当前显示的战力

	self.bottomBtns = false;
	self.bottomBtnRowCount = 6; -- 底部伸缩按钮一排显示个数
	self.btn_hookAward = false;
	self.hookScheduler = false;
	self.onhookAnim = false;
	self.ex_progress = false;
	self.txt_curMap = false;

	--RedRes
	self.img_redTask = false
	self.img_redHero = false
	self.img_redBag = false
	self.img_redShop = false
	self.img_redGuild = false
	
	

	self._mainMsgBoard = false

	self._bgTargetX = 0  --重力感应目标移动位置
	self._bgTargetY= 0 --重力感应目标移动位置
	self._accelerationTimer = false  --重力感应移动定时器
	self._accelerationLayer = false  --重力感应监听事件用Layer

	self.leftTopBtnData = false --左上角按钮数据
	self.reminderAni={}--快捷入口特效

	self._subBtnData = {
		--{name = "图鉴", type="Handbook", icon = "", redType= "M_HANDBOOK",mid=ModuleId.Handbook.id},
		-- {name = "问卷", type ="wenjuan", icon = "", redType = ""},
		-- {name = "帮助", type = "help", icon = "", redType = ""},
		-- {name = "客服", type = "service", icon = "", redType = ""},
		-- {name = "限时升级", type = "shengji", icon = "", redType = ""},
		-- {name = "创角", type = "roleChose", icon = "", redType = ""},
		-- {name = "首充礼包", type = "firstCharge", icon = "", redType = ""},
		-- {name = "登录就送",type = "LoginSendView", icon = "",redType =""},
		-- {name = "每周礼包",type = "WeeklyGiftBagView", icon = "",redType =""},
		-- {name = "每月礼包",type = "MonthlyGiftBagView", icon = "",redType =""},
		-- {name = "集物活动", type = "jiwu", icon = "", redType = ""},
		-- {name = "无尽试炼", type = "EndlessTrialMainView", icon = "", redType = ""},
		-- {name = "超值基金", type = "SuperFundView", icon = "", redType = ""},
		-- {name = "周卡", type = "WeekCardView",icon = "",redType = ""},
		-- {name = "纹章", type = "shengqi",icon = "",redType = ""},
		-- {name = "无尽试炼",type = "EndlessTrialSecondView",icon="",redType=""},
		-- {name = "限时召唤",type = "TimeSummonView",icon="",redType=""},
		-- {name = "圣所探险",type = "SanctuaryAdventureView",icon="",redType=""},
		-- {name = "升星觉醒",type="LStarAwakeningView",icon="",redType="" },
		-- {name = "每周签到",type="WeeklySignInView",icon="",redType="" },
		-- {name = "精灵系统",type="ElvesSystemBaseView",icon="",redType="" },
		-- {name = "装备升星",type="texing",icon="",redType=""},
		-- {name = "装备目标",type="EquipTarget",icon="",redType=""},
		-- {name = "新周卡",type = "NewWeekCard",icon="",redType=""},
		-- {name = "魔灵山",type = "GuildMagicLingShan",icon="",redType=""},
		-- {name = "扭蛋任务",type = "TwistEggTaskView",icon="",redType=""},
		--{name = DescAuto[186],type = "CrossPVPView",icon="",redType=""}, -- [186]="天域"
		-- {name = "探员试炼",type = "DetectiveTrialView",icon="",redType = ""},
		-- {name = "临界",type = "BoundaryMapView",icon="",redType=""},
		{name = DescAuto[187], type = "liansai",icon = "",redType = ""}, -- [187]="圣诞登录"
		{name = DescAuto[188],type="CrossTeamPVPMainView",icon="",redType=""}, -- [188]="组队竞技"
		{name = DescAuto[189],type = "HeroFettersView",icon="",redType=""}, -- [189]="羁绊"
		--{name = DescAuto[190],type = "CrossArenaPVPView",icon="",redType=""}, -- [190]="跨服"
		{name = "跨服天梯",type = "CrossLaddersMainView",icon="",redType=""}, -- [246]="跨服天梯"
		{name = "封魔之路",type = "SealDevilView",icon="",redType=""},
		{name = "超凡段位赛",type = "ExtraordinarylevelMainView",icon="",redType=""},
		{name = "天 冠",type = "CrossLaddersChampMainView",icon="",redType=""},
		{name = "神墟",type = "GodMarketView",icon="",redType=""},
	}

	self._subBtnShowData = false --子按钮页签数据

	self:updateSubBtn()
	--符文系统强行初始化一次 为了卡牌系统的正常使用
	local params = {}
	params.onSuccess = function (res )
	end
	RPCReq.Rune_GetRunePage(params, params.onSuccess)
end

-- [子类重写] 初始化UI方法
function MainUIView:_initUI( ... )
	PHPUtil.reportStep(ReportStepType.ENTER_MAIN_UI)
	--self:playBgm()
	ServiceCommitModel:feedBackMy()
	local allCityNum=#(DynamicConfigData.t_chapters)
	for i = 1, allCityNum, 1 do
		PushMapModel:getOldBattleData(i);
	end
	ChatModel:initFaceConfig()
	ChatModel:initPrivateChatRedMs()
	ChatModel:GetHistoryPrivateContentRecord()
	ChatModel.chatPrivateTag = true
	RelicCopyModel:getCopy()
	RelicCopyModel:setfirstConfigId()
	PushMapModel:getMaxCityAndChapterAndPoint()
	PushMapModel:getTargetReward()
	PushMapModel:upPushMapMofangRed()
	SecretWeaponsModel:godArmsGetInfo()
	PushMapModel.targetRewardGuankaReward=PushMapModel:getTargetRewardGuankaList()
	local fullScreen = self.view:getChildAutoType("load_bg")
	fullScreen:setIcon(PathConfiger.getBg("main_bg.jpg"))

	self.showActiveCtrl = self.view:getController("showActive")
	
	self.leftBtnBoard = self.view:getChildAutoType("leftBtnBoard")
	BindManager.bindButtonList(self.leftBtnBoard)
	-- 功能手册
	self.btn_funcManual = self.leftBtnBoard:getChildAutoType("btn_funcManual")
	--隐藏活动按钮
	self.btn_actShow = self.view:getChildAutoType("btn_actShow")
	self.btn_actShow:setSelected(not self.shrinkActivtyBtns)
	-- --左下块
	self.mainUITabPanel = self.view:getChildAutoType("mainUITabPanel")
	--福利
	self.fuliBtn = self.view:getChildAutoType("fuliBtn")
	--精彩活动
	self.ActBtn = self.view:getChildAutoType("ActBtn")
	--邮件按钮
	self.emailBtn = FGUIUtil.getChild(self.mainUITabPanel,"mailBtn","GButton")
	--好友按钮
	self.friendBtn =  FGUIUtil.getChild(self.mainUITabPanel,"friendBtn","GButton")
	--聊天
	self.chatBtn = FGUIUtil.getChild(self.mainUITabPanel,"chatBtn","GButton")
	self.chatBtn:setSelected(true)
	--弹窗
	self.popBtn = FGUIUtil.getChild(self.mainUITabPanel,"popBtn","GButton")
	
	
	local buoyObject=FGUIUtil.createObjectFromURL("UIPublic", "buoyButton")
	local view = ViewManager.getParentLayer(LayerDepth.OverGame)
	view:addChild(buoyObject)
	buoyObject:setPosition(640,0)
	--浮标按钮绑定
	local buoyButton = BindManager.bindBuoyButton(buoyObject)
	buoyButton:bindOpenModule(ModuleId.BatteSpeedPlugin.id)
	--RedManager.register("M_SPEEDPLUGNIN",buoyObject,ModuleId.BatteSpeedPlugin.id)
	

	--录像
	self.recordBtn = FGUIUtil.getChild(self.mainUITabPanel,"recordBtn","GButton")
	--客服
	self.btn_service = FGUIUtil.getChild(self.mainUITabPanel,"serviceBtn","GButton")
	--活动按钮列表
	self.list_active = FGUIUtil.getChild(self.view,"list_active","GList")

	self.list_subBtns = FGUIUtil.getChild(self.view,"list_subBtns","GList")
	self.subBtns = self.view:getChildAutoType("subBtns")
	self.trainingCom=self.view:getChildAutoType("trainingCom")
	self.trainingSpine=self.view:getChildAutoType("trainingCom/spine")
	self.btn_Trainning = self.view:getChildAutoType("trainingCom/rotaCom/btn_Trainning")
	--ModuleUtil.moduleOpen(ModuleId.Training.id,false)

	local spineNode =  SpineMnange.createByPath("Spine/ui/doumaobang","doumaobang","doumaobang")
	spineNode:setAnimation(0,"animation",true)
	self.trainingSpine:displayObject():addChild(spineNode)

	local sprite= cc.Sprite:create("UI/red.png")
	sprite:setAnchorPoint({x=0.5,y=0.5})
	SpineUtil.addChildToSlot(spineNode,sprite,"guadian")

	RedManager.register("M_TRANNING", sprite)
	RedManager.register("V_SHRINK_ACTIVITY", self.btn_actShow:getChildAutoType("img_red"))
	--RedManager.register("V_TRANNING", self.trainingCom);
	--RedManager.updateValue("M_TRAINING",true)

	--self.trainingCom:setVisible(true)
	--[[local costomServiceUrl = FileCacheManager.getStringForKey("CustomerServiceUrl", "", nil,true)
	if costomServiceUrl ~= "" then--]]
	if AgentConfiger.isAudit() then
		self.btn_service:setVisible(false)
		self.recordBtn:setPosition(self.btn_service:getPosition().x,self.btn_service:getPosition().y)
	else
		self.btn_service:setVisible(true)
	end
	self.btn_service:addClickListener(function ( ... )
			--SDKUtil.openURL(costomServiceUrl)
			ModuleUtil.openModule(ModuleId.ServiceCommitView.id)
		end)
	--[[else
	self.btn_service:setVisible(false)
	end--]]
	--下方4个按钮

	self.btn_openTest = self.view:getChildAutoType("btn_openTest")
	self.btn_openTest:setVisible(not __IS_RELEASE__)

	self.avatar = self.view:getChildAutoType("avatar")
	self.duty = self.view:getChildAutoType("duty")
	self.rankBtn = self.view:getChildAutoType("rankBtn")
	self.bagBtn = self.view:getChildAutoType("bagBtn")
	self.guildBtn = self.view:getChildAutoType("guildBtn")
	self.heroBtn = self.view:getChildAutoType("heroBtn")
	self.shopBtn = self.view:getChildAutoType("rightUpNode/storeBtn");
	self.taskBtn = self.view:getChildAutoType("taskBtn")
	self.runeBtn = self.view:getChildAutoType("runeBtn")
	self.handbookBtn = self.view:getChildAutoType("handbookBtn")
	self.helpBtn = self.mainUITabPanel:getChildAutoType("helpBtn")
	self.settingBtn = self.mainUITabPanel:getChildAutoType("settingBtn")
	self.ex_progress = self.avatar:getChildAutoType("ex_progress");
	self.btn_pushReward = self.view:getChildAutoType("btn_pushReward")
	self.txt_curMap = self.view:getChildAutoType("rightUpNode/tuituBtn/curMap");
	self.img_red_head = self.avatar:getChildAutoType("img_red_head");
	RedManager.register("M_HEAD", self.img_red_head)

	local node = self.btn_pushReward:displayObject()
	local initPos = cc.p(node:getPosition())
	self.btn_pushReward:addClickListener(function()
			ViewManager.open("TimingPushView")
			self.btn_pushReward:setVisible(false)
			node:stopAllActions()
			node:setPosition(initPos)
		end)

	self.btn_vip = self.view:getChildAutoType("btn_vip");
	self.btn_loginSend = self.leftBtnBoard:getChildAutoType("btn_loginSend")
	self.btnListLeftTop = self.view:getChildAutoType("btnListLeftTop")
	
	self.btn_newEvent = self.leftBtnBoard:getChildAutoType("btn_newEvent")
	RedManager.register("V_NEW_EVENT", self.btn_newEvent, ModuleId.EventBrocast.id)
	RedManager.register("M_NEW_EVEN", self.btn_newEvent:getChildAutoType("img_red"), ModuleId.EventBrocast.id)
	

	--红点
	self.img_redTask = self.taskBtn:getChildAutoType("img_red")
	self.img_redHero = self.heroBtn:getChildAutoType("img_red")
	self.img_redBag = self.bagBtn:getChildAutoType("img_red")
	self.img_redShop = self.shopBtn:getChildAutoType("img_red")
	self.img_redGuild = self.guildBtn:getChildAutoType("img_red")
	self.img_redRune = self.runeBtn:getChildAutoType("img_red")
	self.img_redHandBook = self.handbookBtn:getChildAutoType("img_red")
	self.img_redHelp = self.helpBtn:getChildAutoType("img_red")
	self.img_mofangred = self.view:getChildAutoType("img_mofangred")
	--中间一大块
	--召唤入口
	self.zhaohuanBtn = self.view:getChildAutoType("rightUpNode/zaohuanBtn")
	--推图入口
	self.tuituBtn = self.view:getChildAutoType("rightUpNode/tuituBtn")
	self.image_battle=self.tuituBtn:getChildAutoType("image_battle")
	SpineUtil.createBattleFlag(self.image_battle)
	RedManager.register(GameDef.BattleArrayType.Chapters , self.image_battle)

	--竞技场入口
	self.jinjichangBtn = self.view:getChildAutoType("rightUpNode/jinjichangBtn")
	self.btn_test = self.view:getChildAutoType("rightUpNode/btn_test")
	self.btn_test:setVisible(not __IS_RELEASE__)

	-- 下方入口集合
	self.bottomBtns = self.view:getChildAutoType("bottomBtns");
	self.btn_hookAward = self.view:getChildAutoType("btn_hook");

	--爬塔
	self.duanzaoBtn = self.view:getChildAutoType("rightUpNode/duanzaoBtn")
	--历练
	self.lilianBtn = self.view:getChildAutoType("rightUpNode/lilianBtn")
	--退出
	self.exitBtn = self.view:getChildAutoType("rightUpNode/exitBtn")
	
	self.btn_jinji = self.view:getChildAutoType("rightUpNode/btn_jinji")
	self.btn_pata = self.view:getChildAutoType("rightUpNode/btn_pata")
	self.btn_guild = self.view:getChildAutoType("rightUpNode/btn_guild")

	local moneyComp = self.view:getChildAutoType("moneyComp")
	BindManager.bindMoneyBar(moneyComp)

	local modelShow = self.view:getChildAutoType("modelShow")
	self.mainModelShow=BindManager.bindClass("Game.Modules.MainUI.MainModelShow", modelShow)
	self.mainModelShow.playerIcon:setStatic(MainUIModel:isLihuiStatic())
	--挂机倒计时
	self.txt_mofangtime = self.view:getChildAutoType("txt_mofangtime")
	--挂机提示
	self.com_onhooktishi = self.view:getChildAutoType("com_onhooktishi")
	--玩家头像
	self.avatorIcon = self.view:getChildAutoType("avatar/playerIcon")
	self.avatorFrameIcon = self.view:getChildAutoType("avatar/headFrame")


	--名字
	self.avatorName = self.view:getChildAutoType("avatar/name")
	--等级
	self.avatorLevel = self.view:getChildAutoType("avatar/level")
	--战斗力
	self.fightVal = self.view:getChildAutoType("avatar/fight")

	self.subCloseBtn = self.view:getChildAutoType("subCloseBtn")

	self.load_bg = self.view:getChildAutoType("load_bg")
	self.list_reminder = self.view:getChildAutoType("list_reminder")
	local deviceStatus = self.view:getChildAutoType("deviceStatus")
	BindManager.bindDeviceStatus(deviceStatus)
	
	-- self.list_active:setVirtual()
	self.list_active:setItemRenderer(function (index,obj)
			obj:setName(index) ---用于新手引导
			local list = obj:getChildAutoType("list")
			local data = self.list_active._dataTemplate[index+1]
			-- printTable(8848,"list_active:setItemRendere",data)
			list:setItemRenderer(function (index2,obj2)
					obj2:setName(index2) ---用于新手引导
					local timeLab= obj2:getChildAutoType("timeLab")
					local lingquLab= obj2:getChildAutoType("lingquLab")
					timeLab:setText("")
					lingquLab:setText("")
					local dd = data[index2+1].type
					local effect = obj2:getChildAutoType("effect")
					if data[index2+1].type == GameDef.ActivityType.FirstCharge then
						effect:displayObject():removeAllChildren()
						--if not obj2.firstChargeAnimation then
						SpineUtil.createSpineObj(effect, vertex2(effect:getWidth()/2,effect:getHeight()/2), "zhencha_vip", "Effect/UI", "efx_zhencha_2", "efx_zhencha",true)
						--end
					else
						--if obj2.firstChargeAnimation then
						--	SpineUtil.clearEffect(obj2.firstChargeAnimation)
						--	obj2.firstChargeAnimation = nil;
						--end
						effect:displayObject():removeAllChildren()
						if data[index2+1].showContent.effect then
							SpineUtil.createSpineObj(effect, vertex2(effect:getWidth()/2,effect:getHeight()/2), "zhencha_vip", "Effect/UI", "efx_zhencha_2", "efx_zhencha",true)
						end
					end

					if data[index2+1].type==GameDef.ActivityType.EightDayLogin then
						local isActiveOpen ,desc=  OperatingActivitiesModel:getEightDayActivityDesc()
						if isActiveOpen then
							timeLab:setVisible(true)
							lingquLab:setVisible(false)
							timeLab:setText(desc)
						else
							lingquLab:setVisible(false)
							timeLab:setVisible(false)
						end
					elseif data[index2+1].type==GameDef.ActivityType.OnlineReward then
						OperatingActivitiesModel:getOnlineGifBagDesc(timeLab,lingquLab)
					elseif data[index2 + 1].type == GameDef.ActivityType.SurpriseGift then
						TimeLimitGiftModel:timeScheduler(timeLab)  --添加倒计时记得要在clearActivityCountDown加停止处理
					elseif data[index2 + 1].type == GameDef.ActivityType.SurpriseGiftEx then
						backgroundTimeLimitGiftModel:timeScheduler(timeLab)--添加倒计时记得要在clearActivityCountDown加停止处理
					elseif data[index2 + 1].type == GameDef.ActivityType.SurpriseGiftDup then
						TimeLimitGiftDupModel:timeScheduler(timeLab)--添加倒计时记得要在clearActivityCountDown加停止处理
					elseif data[index2 + 1].type == GameDef.ActivityType.HeroTrial then
						DetectiveTrialModel:updateCountTimer(timeLab)--添加倒计时记得要在clearActivityCountDown加停止处理
					elseif data[index2 + 1].type == GameDef.ActivityType.DreamMasterPvp then
						DreamMasterPvpModel:timeScheduler(timeLab)--添加倒计时记得要在clearActivityCountDown加停止处理
					elseif data[index2 + 1].type == GameDef.ActivityType.EveryDayLogin then
						FestivalGiftModel:timeScheduler(timeLab)--添加倒计时记得要在clearActivityCountDown加停止处理
						-- RedManager.register("V_DREAMMASTER_PVP", obj2:getChildAutoType("img_red"))
					end


					if data[index2+1].showContent.activitymark == 2 then
						local mainActiveId = data[index2+1].showContent.mainActiveId
						-- printTable(1,"活动集合类型",mainActiveId,data[index2+1])
						if mainActiveId>1 then
							RedManager.register("M_ACTIVITYFRAME_"..mainActiveId, obj2:getChildAutoType("img_red"))
						end
					else
						RedManager.register("V_ACTIVITY_"..data[index2+1].type, obj2:getChildAutoType("img_red"))
					end

					obj2:setIcon(PathConfiger.getActivityIcon(data[index2+1].iconSrc,1))
					obj2:removeClickListener(33)
					obj2:addClickListener(function ( ... )
							-- printTable(1,"点击打开的活动IDad=",data[index2+1])
							if data[index2+1].showContent.activitymark == 2 then
								local mainActiveId = data[index2+1].showContent.mainActiveId
								local winData = ActivityModel:marketUIWinData(mainActiveId)
								printTable(5656,">>>>>>>>>>>>>>>>>>>>>>1231232",winData,ActivityMap.ActivityFrame[mainActiveId])
								-- ViewManager.open(ActivityMap.ActivityFrame[mainActiveId],{viewData =winData,page = ActivityMap.actWinMap[data[index2+1].showContent.moduleOpen]})
								ViewManager.open(ActivityMap.ActivityFrame[mainActiveId],{viewData =winData,page = ActivityMap.actWinMap[winData[1].actmoduleId],mainActiveId=mainActiveId})
							else
								--问卷星特殊化处理
								if data[index2+1].type == GameDef.ActivityType.QuestionnaireSurveyStar then
									RollTips.showWebPage(data[index2+1].name, data[index2+1].showContent.url)
									-- RollTips.showWebPage(data[index2+1].name,"https://blog.csdn.net/u011874528/article/details/52045723")
									return
								end
								local hasOpen = ModuleUtil.moduleOpen( data[index2+1].showContent.moduleOpen , true )
								if hasOpen then
									--透传参数  actData
									ViewManager.open(ActivityMap.actWinMap[data[index2+1].showContent.moduleOpen],{actData=data[index2+1]})
								end
							end
						end,33)
				end)
			if data then
				list:setData(data)
				list:resizeToFit(#data)
			end
		end)

	self.list_subBtns:setItemRenderer(function (index,obj)

			obj:removeClickListener(333)
			local data = self._subBtnShowData[index + 1]
			RedManager.register(data.redType, obj:getChildAutoType("img_red"),data.mid)
			--print(1,data.name)
			obj:setTitle(data.name)
			obj:addClickListener(function ( ... )
					self.subBtns:setVisible(false)
					self:onSubBtnClick(data)
				end,33)
		end)



	self.quickUseGroup = self.view:getChildAutoType("quickUseGroup")
	BindManager.bindClass("Game.Modules.MainUI.MainQuickUseGroup", self.quickUseGroup)
	-- self.adBoard = self.view:getChildAutoType("adBoard")
	-- self.adBoradObj = MainAdBoard.new(self.adBoard)

	self._mainMsgBoard = MainMsgBoard.new(self.chatBtn,self.mainUITabPanel)
	for k, data in pairs(ChatModel.battleChatList) do
		self._mainMsgBoard:onNewMsg1(data)
	end
	-- self.spineParent = self.view:getChildAutoType("spineParent")
	-- local spineNode = SpineMnange.createSpineByName("yintelihui")
	-- self.spineParent:displayObject():addChild(spineNode)
	-- -- spineNode:setPosition(500,0)
	-- spineNode:setAnimation(0, "stand", true);
	self:initAvatar()
	self:initRedShow()
	self:addAcceleration()
	self:initBottomBtns();
	self:Vip_UpLevel();
	self:player_updateRoleInfo();
	self:initListReminder();
	
	
end

--清空活动倒计时处理
function MainUIView:clearActivityCountDown()
	OperatingActivitiesModel:clearTimeScheduler()
	TimeLimitGiftModel:clearTimeScheduler()
	backgroundTimeLimitGiftModel:clearTimeScheduler()
	TimeLimitGiftDupModel:clearTimeScheduler()
	DetectiveTrialModel:clearTimeScheduler()
	DreamMasterPvpModel:clearTimeScheduler()
	FestivalGiftModel:clearTimeScheduler()
end
--小橘奖励推送
function MainUIView:update_Timing_reward(_,args)
	if args and args.notshow and self.btn_pushReward:isVisible() then 
		self.btn_pushReward:setVisible(false)
		self.btn_pushReward:displayObject():stopAllActions()
		self.com_onhooktishi:setVisible(true)
		self:pushMap_updateInfo()
		return
	end
	local node = self.btn_pushReward:displayObject()
	node:stopAllActions()
	self.btn_pushReward:setVisible(false)
	if TimingPushModel:getState() == 1 then
		self.btn_pushReward:setVisible(true)
		self.com_onhooktishi:setVisible(false)
		local arr = {}
		for i = 1, 3 do
			table.insert(arr,cc.MoveBy:create(0.1,cc.p(10,0)))
			table.insert(arr,cc.MoveBy:create(0.1,cc.p(-10,0)))
		end
		table.insert(arr,cc.DelayTime:create(3))
		node:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))
	else
		self.btn_pushReward:setVisible(false)
		self.com_onhooktishi:setVisible(true)
		self:pushMap_updateInfo()
	end
end

--主界面立绘状态改变
function MainUIView:set_lihuiPos_state(_,args)
	print(5656,"set_lihuiPos_state")
	self.mainModelShow.playerIcon:setStatic(args.static)

end

function MainUIView:module_open()
	--local hadOpen= ModuleUtil.hasModuleOpen(ModuleId.Training.id)
	--local trainOpen= ModuleUtil.moduleOpen(ModuleId.Training.id ,false)
	--self.trainingCom:setVisible(trainOpen)
	self:training_UpdateData()
end

function MainUIView:training_UpdateData()
	local trainOpen= ModuleUtil.moduleOpen(ModuleId.Training.id ,false)
	self.trainingCom:setVisible(trainOpen and (TrainingModel.allFinishTime==0 or TrainingModel.haveReward) )
end


--后台战斗结束
function MainUIView:battle_end()
	self.image_battle:setVisible(false)
end

--初始化红点显示
function MainUIView:initRedShow( ... )
	--迷宫
	local data = ModelManager.MazeModel:getInitData()
	if not data then return end
	local config = MazeConfiger.getConfigByMazeId(data.moveGrid)
	if config then
		if #config.next == 0 and data.successful== 2 then
			RedManager.updateValue("M_MAZE", false)
		else
			RedManager.updateValue("M_MAZE", true)
		end
	end

	--七日
	--ModelManager.SevenDayActivityModel:check_redDot()

	-- 聚能寻宝
	--    TurnTableModel:checkRedPoint();
	-- 委托任务
	DelegateModel:getTaskData();
end

function MainUIView:chat_newMsg(evt, data)
	if(self._mainMsgBoard) then
		self._mainMsgBoard:onNewMsg1(data)
	end
end

--更新活动列表数据
function MainUIView:updateActiveBtns()
	local data = {1,2,2,3,4,5}  --临时数据

end

-- 初始化下方功能入口集合
function MainUIView:initBottomBtns()
	local  buttonconfig= DynamicConfigData.t_Button;
	local confs={}
	for i = 1, #buttonconfig, 1 do
		local configInfo= buttonconfig[i]
		if configInfo.moduleId==ModuleId.RuneSystem.id then
			local tips=ModuleUtil.moduleOpen(configInfo.moduleId,false)
			if tips==true then--前端开启了该功能
				table.insert( confs, configInfo)
			end
		else
			table.insert( confs, configInfo)
		end
	end
	local list_page = self.bottomBtns:getChildAutoType("list_page");
	local switch = self.bottomBtns:getChildAutoType("switch");
	switch:setVisible(#confs >= self.bottomBtnRowCount);

	local page = math.ceil(#confs / self.bottomBtnRowCount)

	local switchRedMap = {} -- 切换按钮红点关系
	list_page:setItemRenderer(function (idx, obj)
			local list = obj:getChildAutoType("list_btns");
			obj:setName(idx)
			list:setItemRenderer(function (idx2, item)
					local conf = confs[idx * self.bottomBtnRowCount + (idx2 + 1)];
					item:setName(idx2)
					item:setIcon(string.format("%s%s.png", "Icon/MainUI/Bottom", conf.moduleId));
					item:setTitle(conf.name);
					item:removeClickListener();
					item:addClickListener(function ()
							if (conf.moduleId == ModuleId.EmblemBag.id and not EmblemModel:checkMainEnter()) then
								RollTips.show(Desc.Emblem_str1);
								return;
							end
							ModuleUtil.openModule(conf.moduleId, true);
						end)
					local c1=item:getController("c1")
					local c1tips= ModuleUtil.moduleOpen(conf.moduleId,false)
					if (conf.moduleId == ModuleId.EmblemBag.id) then
						c1tips = EmblemModel:checkMainEnter()
					end
					if c1tips==true then
						c1:setSelectedIndex(0)
					else
						c1:setSelectedIndex(1)
					end
					--注册主界面红点
					local redStr = false;
					local img_red = item:getChildAutoType("img_red");
					if (conf.moduleId == ModuleId.Task.id) then
						redStr = "M_BTN_TASK";
					elseif (conf.moduleId == ModuleId.Hero.id) then
						redStr = "M_Card";
					elseif (conf.moduleId == ModuleId.Bag.id) then
						redStr = "M_BTN_BAG";
					elseif (conf.moduleId == ModuleId.Shop.id) then
						redStr = "M_BTN_SHOP";
					elseif (conf.moduleId == ModuleId.Guild.id) then
						redStr = "M_BTN_Guild";
					elseif (conf.moduleId == ModuleId.RuneSystem.id) then
						redStr = "M_BTN_RUNE";
					elseif (conf.moduleId == ModuleId.Handbook.id) then
						redStr = "M_HANDBOOK";
					elseif (conf.moduleId == ModuleId.RankMain.id) then
						redStr = "M_TASK_REWARD";
					elseif (conf.moduleId == ModuleId.SecretWeapon.id) then
						redStr = "M_SECRETWEAPONS";
					elseif (conf.moduleId == ModuleId.Elves_Attribute.id) then
						redStr = "M_ELVES";
					--elseif (conf.moduleId == ModuleId.EmblemBag.id) then
						--redStr = "M_Emblem";
					elseif (conf.moduleId == ModuleId.DetectiveAgencyView.id) then
						redStr = "M_DetectiveAgency";
						local dayStr = DateUtil.getOppostieDays()
						local isShow = FileCacheManager.getBoolForKey("M_DetectiveAgency" .. dayStr, false)
						if isShow then
							RedManager.addMap("M_DetectiveAgency",{"M_ELVES","M_HANDBOOK","M_HeroFetters"})
						else
							RedManager.addMap("M_DetectiveAgency",{"M_ELVES","M_HANDBOOK","M_HERO_LEVELUP","M_HeroFetters"})
						end
					elseif (conf.moduleId == ModuleId.HallowSys.id) then
						redStr = "V_HALLOW";
					else
						RedManager.register("", img_red);
						img_red:setVisible(false);
					end
					-- 统一注册红点
					if (redStr) then
						RedManager.register(redStr, img_red, conf.moduleId);
						if (idx > 0) then -- 不是第一行的红点要注册切换按钮红点
							table.insert(switchRedMap, redStr);
						end
					end
				end)
			local num = (idx < page - 1) and self.bottomBtnRowCount or (#confs - (page - 1) * self.bottomBtnRowCount);
			list:setNumItems(num);
		end)
	list_page:setNumItems(page);
	RedManager.addMap("M_BOTTOM_SWITCH", switchRedMap);
	local img_red = switch:getChildAutoType("img_red");
	RedManager.register("M_BOTTOM_SWITCH", img_red);
end

-- 初始化右边4个功能入口集合
function MainUIView:initRightNodeBtns()
	local moduleIdList={ModuleId.PushMap.id,ModuleId.GetCard.id,ModuleId.MainSubBtn.id,ModuleId.Shop.id,ModuleId.MainSubBtn2.id ,ModuleId.Tower.id,ModuleId.Guild.id}
	local btnList={self.tuituBtn,self.zhaohuanBtn,self.jinjichangBtn,self.shopBtn,self.btn_jinji,self.btn_pata,self.btn_guild}
	for i = 1, #moduleIdList, 1 do
		local modeuleId=moduleIdList[i]
		local btn=btnList[i]
		if btn then
			local c3=btn:getController("c3")
			local tips=ModuleUtil.moduleOpen(modeuleId,false)
			if tips==true then--前端开启了该功能
				c3:setSelectedIndex(0)
				btn:removeClickListener(100)
				btn:addClickListener(function ( ... )
						if (modeuleId == ModuleId.Tower.id) then
							local hasOpen = ModuleUtil.moduleOpen(ModuleId.TowerRace.id, false)
							if hasOpen then
								ViewManager.open("PataChooseView")
								return
							end
							ViewManager.open(
							"PataView",
							{
							type = 6,
							name = "第五之塔",
							activeType = 2000,
							towerType = 1,
							rankType = 2,
							space = -15,
							showCount = 6,
							moveCount = 4
							}
							)
							ModuleUtil.openModule(ModuleId.Pata, true)
						else
							ModuleUtil.openModule(modeuleId, false)
						end
					end,100)
			else
				c3:setSelectedIndex(1)
				btn:removeClickListener(100)
				local str= ModuleUtil.getModuleOpenTips(modeuleId)
				if str==nil then
					str=""
				end
				btn:addClickListener(function ( ... )
						printTable(152,"22222222222qqqqqqq")
						RollTips.show(str..DescAuto[191]) -- [191]="开启"
					end,100)
			end
		end
	end
end

function MainUIView:upOpenNodeBtns()
	self:initRightNodeBtns()
	self:initBottomBtns()
	self:initListReminder()
end

function MainUIView:initAvatar( ... )
	self.avatorName:setText(PlayerModel.username)
	self.avatorLevel:setText(PlayerModel.level)

	self.avatorIcon:setURL(PathConfiger.getPlayerHead(PlayerModel.head))
	self.avatorFrameIcon:setURL(PathConfiger.getHeadFrame(PlayerModel.headBorder))

	self:updateFight()
end

function MainUIView:player_levelUp( ... )
	self:updateDutyShow()
end

function MainUIView:update_MainDutyShow( ... )
	self:updateDutyShow()
end

function MainUIView:updateDutyShow( ... )
	-- printTraceback()
	--print(1,"MainUIView:updateDutyShow")
	if not self.duty then
		return
	end
	local avatorBtn = self.avatar:getChildAutoType("avatorBtn")
	local flag = ModuleUtil.hasModuleOpen(51)
	if flag then
		self.duty:getController("showDutyCtrl"):setSelectedIndex(1)
		local dutyTitle = self.duty:getChildAutoType("dutyTitle")
		local dutyProVal = self.duty:getChildAutoType("dutyProVal")
		local itemCellObj = self.duty:getChildAutoType("itemCell")
		local itemNum = self.duty:getChildAutoType("itemNum")
		local dutyPro = self.duty:getChildAutoType("dutyPro")
		--local lightNode = self.duty:getChildAutoType("n63")
		local btn_duty = self.duty:getChildAutoType("btn_duty")
		local effectLoader = self.duty:getChildAutoType("effectLoader")
		if not self.duty.spineNode then
			self.duty.spineNode = SpineUtil.createSpineObj(effectLoader, vertex2(-3,-5), "tongyongyuankuang_chong", "Spine/ui/duty", "efx_tongyongyuankuang", "efx_tongyongyuankuang",true)
			self.duty.spineNode:setScale(0.75,0.75)
		end
		btn_duty:removeClickListener(11)
		btn_duty:addClickListener(function( ... )
				ModuleUtil.openModule(ModuleId.Duty,false)
			end,11)

		local showItem,doneTask,taskCount,des
		local curDutyIndex = DutyModel:getCurDutyIndex()
		local allConfig = DutyModel:getAllDutyConfig()
		if curDutyIndex== #allConfig then --最后一级
			showItem,doneTask,taskCount,des =  DutyModel:getLastMainUIShowNeed()
		else
			showItem,doneTask,taskCount,des =  DutyModel:getMainUIShowNeed()
		end
		-- printTable(1,showItem,doneTask,taskCount,des)
		dutyTitle:setText(des)
		dutyProVal:setText(tostring(math.ceil(doneTask/taskCount*100)).."%")
		-- dutyPro:setFillAmount(doneTask/taskCount)
		dutyPro:getChild("title"):setVisible(false)
		dutyPro:setMax(taskCount)
		dutyPro:setValue(doneTask)
		local beginPosx= 96
		local maxPosx= 234
		-- if doneTask/taskCount>0.15 then
		--     lightNode:setVisible(true)
		--     lightNode:setX(beginPosx+(maxPosx-beginPosx)*doneTask/taskCount)
		-- else
		--     lightNode:setVisible(false)
		-- end
		local itemcell = BindManager.bindItemCell(itemCellObj,true)
		local itemData = ItemsUtil.createItemData({data = showItem[1]})
		itemcell:setAmountVisible( false )
		itemcell:setItemData(itemData)
		itemcell:setSplitCtrl(0)
		if showItem[1].amount>1 then --小于1不要数量
			itemNum:setVisible(true)
			itemNum:setText(itemData:getItemAmount())
		else
			itemNum:setVisible(false)
		end

		local config = DutyModel:getCurDutyConfig()
		if avatorBtn then
			avatorBtn:getController("showDutyCtrl"):setSelectedIndex(1)
			local preName = avatorBtn:getChildAutoType("preName")
			if preName then
				preName:setText(config.dutyName)
			end
		end

	else
		self.duty:getController("showDutyCtrl"):setSelectedIndex(0)
		if avatorBtn then
			avatorBtn:getController("showDutyCtrl"):setSelectedIndex(0)
		end
	end
end

-- [子类重写] 准备事件
function MainUIView:_initEvent( ... )
	--左上角的主角框
	self.avatar:getChildAutoType("avatorBtn"):addClickListener(function()
			Dispatcher.dispatchEvent(EventType.player_openInfoView)
		end)
	self.fuliBtn:addClickListener(function ( ... )
			-- local info = {}
			-- info.text = "该按钮仅供版署测试使用，将临时增加10万钻石、100万金币、100万灵气和1万进阶石，请问是否增加？"
			-- info.yesText = "增加"
			-- info.noText = "取消"
			-- info.type = "yes_no"
			-- info.onYes = function()
			-- 	print(33,"Gm_GetDropItem")
			-- 	RPCReq.Gm_GetDropItem({id = 10001004})
			-- end
			-- Alert.show(info)
			-- ModuleUtil.openModule(ModuleId.DailySign.id,true)
			ViewManager.open("LoginAwardView")
		end)
	--精彩活动固定入口
	self.ActBtn:addClickListener(function( ... )
			local mainActiveId = 1
			local winData = ActivityModel:marketUIWinData(mainActiveId)
			if (winData and (#winData > 0)) then
				printTable(999,"节目数据",winData)
				ViewManager.open(ActivityMap.ActivityFrame[mainActiveId],{viewData =winData,page = winData[1].page})
			else
				RollTips.show(Desc.activity_txt1);
			end
		end)
	self.emailBtn:addClickListener(function ( ... )
			--print(1,"测试")
			ModuleUtil.openModule(ModuleId.Mail, true)
		end)
	self.friendBtn:addClickListener(function ( ... )
			ModuleUtil.openModule(ModuleId.Friend)
		end)

	self.taskBtn:addClickListener(function ( ... )
			ModuleUtil.openModule( ModuleId.Task , true )
		end)

	self.runeBtn:addClickListener(function ( ... )
			ModuleUtil.openModule( ModuleId.RuneSystem , true )
		end)

	self.handbookBtn:addClickListener(function ( ... )
			ViewManager.open("HandbookView")
		end)

	self.helpBtn:addClickListener(function ( ... )
			ModuleUtil.openModule(ModuleId.Help);
		end)

	self.settingBtn:addClickListener(function ( ... )
			-- Dispatcher.dispatchEvent(EventType.BoradWalk_AddMsg,"测试")
			ViewManager.open("SettingView")
			--ViewManager.open("NewsBoardView")
			--ViewManager.open("GodMarketRankView")
		end)


	self.btn_openTest:addClickListener(function ( ... )
			ViewManager.open("CardTestView")
		end)


	self.heroBtn:addClickListener(function ( ... )
			-- ViewManager.open("CardBagView")--打开卡牌库
			ModuleUtil.openModule( ModuleId.Hero.id , true )
		end)

	self.chatBtn:addClickListener(function ( ... )
			-- ViewManager.open("ChatView")
			ModuleUtil.openModule( ModuleId.Chat.id , true )
		end)

	self.recordBtn:addClickListener(function ( ... )
			--ViewManager.open("VideoLibraryView")
			ModuleUtil.openModule( ModuleId.ArenaVideo , true )
		end)

	self.popBtn:addClickListener(function ( ... )

	end)

	
	
	self.bagBtn:addClickListener(function ( ... )
			-- ViewManager.open("BagWindow")
			ModuleUtil.openModule( ModuleId.Bag.id , true )
		end)

	self.rankBtn:addClickListener(function ( ... )
			--[[if ModelManager.PlayerModel.level < 20 then
			RollTips.show(DescAuto[192]) -- [192]="角色等级20级开启"
			return
			end--]]
			-- ViewManager.open("RankMainView")
			ModuleUtil.openModule( ModuleId.RankMain.id , true )
		end)

	self.guildBtn:addClickListener(function ( ... )
			--        ViewManager.open("TestUIViewG1")
			ModuleUtil.openModule( ModuleId.Guild , true )

		end)

	-- self.shopBtn:addClickListener(function ( ... )
	-- 		-- ViewManager.open("ShopView")
	--         ModuleUtil.openModule( ModuleId.Shop.id , true )
	-- 	end)

	-- self.tuituBtn:addClickListener(function ( ... )
	--     ModuleUtil.openModule(ModuleId.PushMap, true)
	-- end)


	self.subCloseBtn:addClickListener(function ( ... )
			self.subBtns:setVisible(false)
		end)
	-- self.jinjichangBtn:addClickListener(function ( ... )
	-- 		--Dispatcher.dispatchEvent(EventType.Arena_open)
	-- 		--
	-- 		--self.subBtns:setVisible(true)
	-- 		--self:showSubBtns()
	--         ViewManager.open("MainSubBtnView")
	--         -- ViewManager.open("ExerciseView")
	-- end)

	self.btn_test:addClickListener(function ( ... )

			--ViewManager.open("BatteSpeedView")
			self:showSubBtns()
		end)
	-- --召唤
	-- self.zhaohuanBtn:addClickListener(function ( ... )
	--         ModuleUtil.openModule(ModuleId.GetCard,true)
	-- end)

	self.btn_hookAward:addClickListener(function ()
			PushMapModel:getHangUpState();
			ViewManager.open("PushMapOnhookRewardView");
		end)
	self.btn_vip:addClickListener(function ()
			ModuleUtil.openModule(ModuleId.Vip.id);
		end)

	self.btn_loginSend:addClickListener(function()
			ModuleUtil.openModule(ModuleId.LoginSend.id,true)
		end)

	self.btn_actShow:addClickListener(function()
		self.shrinkActivtyBtns = not self.shrinkActivtyBtns
		self:upadteActivityBtns()
	end)

	--训练营
	local trainOpen= ModuleUtil.moduleOpen(ModuleId.Training.id ,false)
	--elf.trainingCom:setVisible(trainOpen)
	self:module_open()
	self.btn_Trainning:addClickListener(function()
			ModuleUtil.openModule(ModuleId.Training.id,true)
		end)

	if (self.hookScheduler) then
		Scheduler.unschedule(self.hookScheduler);
		self.hookScheduler = false;
	end
	self.hookScheduler = Scheduler.schedule(function()
			PushMapModel:getHangUpState();
		end, 60);
	PushMapModel:getHangUpState();
	PushMapModel:showPushmapmofangText(self.txt_mofangtime,0)
	Scheduler.scheduleNextFrame(function()
			ModelManager.PlayerModel:startDateCheck()
		end)


	self.btn_newEvent:addClickListener(function ()
		ViewManager.open("EventBrocastView")
	end)


	self.btnListLeftTop:setItemRenderer(function (index,obj)
			local data = self.leftTopBtnData[index + 1]
			RedManager.register(data.red or "", obj:getChildAutoType("img_red"))
			obj:setIcon(PathConfiger.getMainBtn(data.icon))
			obj:removeClickListener(100)
			obj:addClickListener(function()
					if data.type == "downLoadGift" then
						ViewManager.open("DownLoadGiftView")
					elseif data.type == "PriviligeGift" then
						ModuleUtil.openModule(ModuleId.PriviligeGiftView.id);
					elseif data.type == "dailyGift" then
						ModuleUtil.openModule(ModuleId.DailyGiftBag.id)
					elseif data.type == "vipMember" then
						ViewManager.open("VipMemberView")
					end
				end,100)
		end)

	self:mainui_updateLeftTopBtns()
	self:setFuncManual()
end

-- 改变登录就送礼包入口状态
function MainUIView:LoginSend_Entrance()
	self.btn_loginSend:setVisible(not LoginSendModel.state)
end

function MainUIView:DownLoadGift_Entrance()
	self:mainui_updateLeftTopBtns()
end

--充值状态改变可能会影响vip入口显示
function MainUIView:charge_status_change()
	self:mainui_updateLeftTopBtns()
end

--开服天数可能会影响vip入口显示
function MainUIView:serverTime_crossDay()
	self:mainui_updateLeftTopBtns()
end

-- 改变下载礼包入口状态
function MainUIView:mainui_updateLeftTopBtns()
	local btnData = {}
	-- if ModelManager.PriviligeGiftModel.canBuy then
		table.insert(btnData,{type= "PriviligeGift", icon="mainUIBtn_privilige", red = "V_PRIVILIGEGIFT"})
	-- end

	-- 插入每日礼包
	table.insert(btnData,{type= "dailyGift", icon="mainUIBtn_dailygift", red = "V_DAILYGIFTBAG"})

	if not DownLoadGiftModel.state and not AgentConfiger.isAudit() then
		table.insert(btnData,{type= "downLoadGift", icon="mainUIBtn_down", red = "M_DOWNLOADGIFT"})
	end

	local memberData = VipMemberModel:getMemberData()
	if memberData and memberData.href_url then
		table.insert(btnData,{type= "vipMember", icon="mainUIBtn_member", red = "M_VIP_MEMBER"})
		
		local showRed = FileCacheManager.getStringForKey("VipMember_oen"..PlayerModel.userid,"1")
		RedManager.updateValue("M_VIP_MEMBER", showRed == "1")
	
	end


	self.leftTopBtnData = btnData
	self.btnListLeftTop:setData(btnData)
	--self.btn_downloadGift:setVisible(not DownLoadGiftModel.state)
end


--添加红点
function MainUIView:_addRed(...)
	-- --注册主界面红点
	-- RedManager.register("M_BTN_TASK", self.img_redTask, ModuleId.Task.id);
	-- RedManager.register("M_BTN_HERO", self.img_redHero, ModuleId.Hero.id);
	-- RedManager.register("M_BTN_BAG", self.img_redBag, ModuleId.Bag.id);
	RedManager.register("M_BTN_SHOP",self.img_redShop, ModuleId.Shop.id);
	-- RedManager.register("M_BTN_Guild",self.img_redGuild, ModuleId.Guild.id);
	-- RedManager.register("M_BTN_RUNE",self.img_redRune, ModuleId.RuneSystem.id);
	-- RedManager.register("M_HANDBOOK",self.img_redHandBook, ModuleId.Handbook.id);
	RedManager.register("V_MAIN_SHILAIN",self.jinjichangBtn:getChildAutoType("img_red"));
	RedManager.register("M_GETCARD",self.zhaohuanBtn:getChildAutoType("img_red"));  --召喚
	RedManager.register("M_SUBBTN2", self.btn_jinji:getChildAutoType("img_red"), ModuleId.MainSubBtn2.id); -- 铳梦竞技
	RedManager.register("V_TOWER", self.btn_pata:getChildAutoType("img_red")); -- --爬塔
	RedManager.register("M_BTN_Guild", self.btn_guild:getChildAutoType("img_red")); -- 公会

	RedManager.register("M_CHAT",self.chatBtn:getChildAutoType("img_red"), ModuleId.Chat.id);
	RedManager.register("M_MAIL",self.emailBtn:getChildAutoType("img_red"), ModuleId.Mail.id);
	RedManager.register("M_FRIEND",self.friendBtn:getChildAutoType("img_red"), ModuleId.Friend.id);
	RedManager.register("M_SETTINGRED", self.settingBtn:getChildAutoType("img_red"))
	RedManager.register("M_ACTIVITYFRAME", self.ActBtn:getChildAutoType("img_red"))
	RedManager.register("M_ACTIVITYFULI", self.fuliBtn:getChildAutoType("img_red"))
	RedManager.register('M_PUSHMAP', self.tuituBtn:getChildAutoType("img_red"));
	RedManager.register('M_DUTY', self.view:getChildAutoType("duty/img_red"));
	RedManager.register("M_VIP", self.btn_vip:getChildAutoType("img_red"));
	RedManager.register("M_LOGINSEND",self.btn_loginSend:getChildAutoType("img_red"))
	-- RedManager.register("M_HELP", self.helpBtn:getChildAutoType("img_red"));

	RedManager.register("V_PUSHMAPMOFANGRED", self.img_mofangred);
end

function MainUIView:ModuleOpen_CheckFinish()
	self:_addRed();
end 

--子菜单点击处理
function MainUIView:onSubBtnClick(data)

	if(data.type == "wenjuan") then
		ViewManager.open("QuesSurveyView")
	elseif(data.type == "shengqi") then
		ViewManager.open("EmblemEquipView")
	elseif(data.type == "liansai") then
		ViewManager.open("FestivalGiftView")
	elseif(data.type == "Handbook") then
		ViewManager.open("HandbookView")
	elseif(data.type == "service") then
		ViewManager.open("ServiceCommitView")
	elseif(data.type == "shengji") then
		ViewManager.open("UpgradeActivityView");
	elseif(data.type == "roleChose") then
		ViewManager.open("GuideSetNameView")
	elseif(data.type == "firstCharge") then
		ViewManager.open("FirstChargeView")
	elseif(data.type == "jiwu") then
		-- RPCReq.Activity_CollectThings_info({},function(params)
		--     printTable(999,"请求集物活动数据",params)
		ViewManager.open("CollectThingView")
		-- end)
	elseif(data.type == "EndlessTrialMainView") then
		ViewManager.open("EndlessTrialMainView")
	elseif(data.type == "SuperFundView") then
		ViewManager.open("SuperFundView")
	elseif (data.type == "WeekCardView") then
		ViewManager.open("WeekCardView")
	elseif (data.type == "LoginSendView") then
		ModuleUtil.openModule(ModuleId.LoginSend.id)
	elseif (data.type == "WeeklyGiftBagView") then
		ViewManager.open("WeeklyGiftBagView")
	elseif (data.type == "MonthlyGiftBagView") then
		ViewManager.open("MonthlyGiftBagView")
	elseif (data.type == "EndlessTrialSecondView") then
		ModuleUtil.openModule(ModuleId.EndlessTrialSecond.id,true)
		-- ViewManager.open("EndlessTrialSecondView")
	elseif (data.type == "TimeSummonView") then
		ViewManager.open("TimeSummonView")
	elseif (data.type == "SanctuaryAdventureView") then
		ViewManager.open("SanctuaryAdventureView")
	elseif (data.type == "LStarAwakeningView") then
		ViewManager.open("LStarAwakeningView")
	elseif (data.type == "WeeklySignInView") then
		ViewManager.open("WeeklySignInView")
	elseif (data.type == "ElvesSystemBaseView") then
		ModuleUtil.openModule(ModuleId.Elves_Attribute, true);
	elseif (data.type == "texing" ) then
		ViewManager.open("EquipUpStarView");
	elseif (data.type == "EquipTarget") then
		ViewManager.open("EquipTargetView")
	elseif (data.type == "NewWeekCard") then
		ViewManager.open("NewWeekCardView")
	elseif (data.type == "GuildMagicLingShan") then
		ViewManager.open("GuildMLSMainView")
	elseif (data.type == "TwistEggTaskView") then
		ViewManager.open("TwistEggTaskView")
	elseif (data.type == "CrossPVPView") then
		ViewManager.open("CrossPVPView")
	elseif (data.type == "DetectiveTrialView") then
		ViewManager.open("DetectiveTrialView")
	elseif (data.type == "BoundaryMapView") then
		ViewManager.open("BoundaryMapView")
	elseif (data.type == "CrossTeamPVPMainView") then
		CrossTeamPVPModel:getDefTemp()
	elseif (data.type == "HeroFettersView") then
		ViewManager.open("HeroFettersView")
	elseif (data.type == "CrossArenaPVPView") then
		ViewManager.open("CrossArenaPVPView")
	elseif (data.type == "CrossLaddersMainView") then
		ModuleUtil.openModule(ModuleId.CrossLadders.id, true);
	elseif (data.type == "SealDevilView") then
		ViewManager.open("SealDevilView")
	elseif (data.type == "ExtraordinarylevelMainView") then
		ViewManager.open("ExtraordinarylevelMainView")
	elseif (data.type == "CrossLaddersChampMainView") then
		ModuleUtil.openModule(ModuleId.CrossLaddersChamp.id, true)
	elseif (data.type == "GodMarketView") then
		--ModuleUtil.openModule(ModuleId.CrossLaddersChamp.id, true)
		ViewManager.open("GodMarketView")
	end
end

function MainUIView:onActiveBtnClick( data )
	if(data.type == "fuli_Award") then
		ViewManager.open("LoginAwardView")
	end
	if(data.type == "sevenDay") then
		ViewManager.open("SevenDayActView")
	end
end

--这里后面可以做过滤，未开放的按钮可以不显示出来
--因为未显示之前就需要处理红点关系，所以不能等显示子菜单的时候才去处理
function MainUIView:updateSubBtn()
	self._subBtnShowData = self._subBtnData --


	local redMap = {}
	for _,v in ipairs(self._subBtnShowData) do
		if(v.redType and v.redType ~= "") then
			table.insert(redMap, v.redType)
		end
	end
	--RedManager.addMap("V_MAIN_SHILAIN", redMap)

end

--显示子菜单
function MainUIView:initListReminder()
	local moduldList={
		ModuleId.WorldChallengeMainView.id, -- 世界擂台赛
		ModuleId.GuildLeague.id, -- 公会联赛
		ModuleId.DreamMasterPvp.id, -- 梦主
		ModuleId.GuildLeagueOfLegends.id, -- 公会传奇赛
	}
	local openList={}
	for i = 1, #moduldList, 1 do
		local id=moduldList[i]
		local tips = ModuleUtil.getModuleOpenTips(id)
		if not tips then
			if id==ModuleId.WorldChallengeMainView.id  and--功能开启 并且首次登陆 并且有红点
				WorldChallengeModel:getFirstLoginState("worldchallge")==false and
				(WorldChallengeModel.WorldChallenJingCaiRed or WorldHighPvpModel.WorldChallenJingCaiRed) then
				table.insert(openList, id )
			elseif (id == ModuleId.GuildLeague.id and GuildLeagueModel:haveChallengeTime() and GuildLeagueModel.fastEnter) then
				table.insert(openList, id);
			elseif (id == ModuleId.DreamMasterPvp.id and DreamMasterPvpModel:isShowMainIcon()) then
				table.insert(openList, id);
			elseif (id == ModuleId.GuildLeagueOfLegends.id and GuildLeagueOfLegendsModel:canShowFastEnter()) then
				table.insert(openList, id);
			end
		end
		-- table.insert(openList, id )
	end
	self.list_reminder:setItemRenderer(function (index,obj)
			local moduleId = openList[index + 1]
			local iconPath = string.format("UI/MainUI/reminder%d.png", moduleId);
			obj:setIcon(iconPath);
			local effect = obj:getChildAutoType("img_ani")
			if moduleId==ModuleId.WorldChallengeMainView.id or moduleId == ModuleId.GuildLeague.id then
				if not self.reminderAni[moduleId] then
					self.reminderAni[moduleId]  = SpineUtil.createSpineObj(effect, vertex2(effect:getWidth()/2,effect:getHeight()/2), "zhencha_vip", "Effect/UI", "efx_zhencha_2", "efx_zhencha",true)
					self.reminderAni[moduleId]:setScale(0.6,0.6)
				end
			end
			obj:removeClickListener(100)
			obj:addClickListener(function ( ... )
					if moduleId==ModuleId.WorldChallengeMainView.id then
						WorldChallengeModel:getWorldChallengeInfo()
						WorldHighPvpModel:getWorldChallengeInfo()
						WorldChallengeModel:setFirstLoginState("worldchallge")
						SpineUtil.clearEffect(self.reminderAni[moduleId])
						table.remove(openList,table.indexof(openList, moduleId))
						self.list_reminder:setNumItems(#openList)
					elseif moduleId == ModuleId.GuildLeague.id then
						GuildLeagueModel.fastEnter = false;
						SpineUtil.clearEffect(self.reminderAni[moduleId])
						table.remove(openList,table.indexof(openList, moduleId))
						self.list_reminder:setNumItems(#openList)
						GuildLeagueModel:requestBaseInfo()
						ViewManager.open("GuildLeagueFortView");
						return;
					elseif moduleId == ModuleId.DreamMasterPvp.id then
						if not DreamMasterPvpModel:isShowMainIcon() then
							table.remove(openList,table.indexof(openList, moduleId))
							self.list_reminder:setNumItems(#openList)
						end
					elseif moduleId == ModuleId.GuildLeagueOfLegends.id then
						GuildLeagueOfLegendsModel.fastEnter = false;
						SpineUtil.clearEffect(self.reminderAni[moduleId])
						table.remove(openList,table.indexof(openList, moduleId))
						self.list_reminder:setNumItems(#openList)
						GuildLeagueOfLegendsModel:getBaseInfo()
						ViewManager.open("GLLegendsGroupView")
						return;
					end
					ModuleUtil.openModule(moduleId, true)
				end,100)
		end)
	self.list_reminder:setNumItems(#openList)
end

function MainUIView:worldChallenge_jingcaiRedUp()--刷新主界面竞猜红点
	self:initListReminder()
end

function MainUIView:GuildLeague_guildInfoUpdate()--刷新主界面公会联赛快捷入口
	self:initListReminder()
end

function MainUIView:GLOL_MatchInfoUpdate()--刷新主界面公会联赛快捷入口
	self:initListReminder()
end

--显示子菜单
function MainUIView:showSubBtns()
	self.subBtns:setVisible(true)
	self.list_subBtns:setData(self._subBtnShowData)


	local firstItem = self.list_subBtns:getChildAt(0)
	local width = firstItem:getWidth() * (#self._subBtnShowData > 5 and 5 or #self._subBtnShowData)
	local height = firstItem:getHeight() * (math.ceil(#self._subBtnShowData / 5))
	self.list_subBtns:setSize(width, height)
end

function MainUIView:player_updateRoleInfo()
	self.avatorLevel:setText(PlayerModel.level)
	self.avatorName:setText(PlayerModel.username)
	local nextInfo = DynamicConfigData.t_roleAttr[PlayerModel.level+1]
	local nextExp = nextInfo and nextInfo.exp
	if nextExp then
		self.ex_progress:setMax(nextExp)
		self.ex_progress:setValue(PlayerModel.exp);
	end
	self:upOpenNodeBtns();
end

--更新名字 事件
function MainUIView:player_rename_success( ... )
	self.avatorLevel:setText(PlayerModel.level)
	self.avatorName:setText(PlayerModel.username)
end

--更新头像
function MainUIView:player_headreset( ... )
	self.avatorIcon:setURL(PlayerModel:getUserHeadURL(PlayerModel.head))
	self.avatorFrameIcon:setURL(PathConfiger.getHeadFrame(PlayerModel.headBorder))
end

--更新战力
function MainUIView:updateFight( ... )
	local fight = ModelManager.CardLibModel:getFightVal() or 0
	if self._curFightPoint ~= 0 then
		local addNum = fight - self._curFightPoint
		if addNum > 0 then
			--RollTips.showAddFightPoint(addNum)
		end
	end
	self.fightVal:setText(StringUtil.transValue(fight))
	self._curFightPoint = fight
end

--事件 有战力刷新
function MainUIView:update_cards_fightVal( ... )
	--print(1,"MainUIView  update_cards_fightVal")
	self:updateFight()
end

function MainUIView:Vip_UpLevel()
	self.btn_vip:setTitle("v"..VipModel.level);
end

-- 宝箱切换状态  0-0.5   0.5-1   1->12
function MainUIView:pushMap_updateInfo(_, param)
	PushMapModel:showPushmapmofangText(self.txt_mofangtime,0)
	local curstate=PushMapModel:getCurBoxAnimationState()
	if not self.onhookAnim then
		self.onhookAnim= SpineUtil.createSpineObj(self.btn_hookAward:getChild("icon"),{x=60,y=60}, "", "Effect/UI", "emaoxingdong", "emaoxingdong",true)
	end

	if curstate==1 then
		self.com_onhooktishi:setVisible(false)
		self.onhookAnim:setAnimation(0, "animation1", true)
		-- self.img_mofangred:setPosition(118,500)
	elseif curstate==2 then
		self.com_onhooktishi:setVisible(false)
		self.onhookAnim:setAnimation(0, "animation2", true)
		-- self.img_mofangred:setPosition(120,500)
	elseif curstate==3 then
		-- self.img_mofangred:setPosition(125,495)
		self.onhookAnim:setAnimation(0, "animation3", true)
		local serverInfo= PushMapModel.pushMaponHookInfo;
		if not serverInfo then
			self.com_onhooktishi:setVisible(false)
			return
		end
		local curTime=serverInfo.hangUpMax
		if curTime>=12*60*60 then
			self.com_onhooktishi:setVisible(true)
		else
			self.com_onhooktishi:setVisible(false)
		end
	end
	if  PushMapModel.jingbiRunState[1]==true then
		self.onhookAnim:setAnimation(1, "jinbi_sa", false)
		PushMapModel.jingbiRunState[1]=false
	end
	if TimingPushModel:getState() == 1 then
		self.com_onhooktishi:setVisible(false)
	end
end

function MainUIView:pushMap_jingbisa1()
	if not tolua.isnull(self.onhookAnim)  then
		if  PushMapModel.jingbiRunState[1]==true then
			self.onhookAnim:setAnimation(1, "jinbi_sa", false)
			PushMapModel.jingbiRunState[1]=false
		end
	end
end


function MainUIView:pushMap_getCurPassPoint(_, data)
	local str = string.format(DescAuto[193], data.cityId, data.chapterId, data.pointId); -- [193]="当前%d-%d-%d"
	self.txt_curMap:setText(str);
end

-- [子类重写] 添加后执行
function MainUIView:_enter()
end

-- [子类重写] 移除后执行
function MainUIView:_exit()
	if (self.hookScheduler) then
		Scheduler.unschedule(self.hookScheduler);
		self.hookScheduler = false;
	end
	if self.reminderAni then
		SpineUtil.clearEffect(self.reminderAni)
	end
end

function MainUIView:upadteActivityBtns()
	if tolua.isnull(self.view) then
		return
	end
	local showData1,showData2,showData3 = ModelManager.ActivityModel:getAllActDatas(self.shrinkActivtyBtns)
	self.list_active:setVisible(#showData2>0)
	self:clearActivityCountDown()
	self.list_active:setData(showData2)
end

function MainUIView:activity_OnlineGiftActiveupdate()
	self:upadteActivityBtns()
end


function MainUIView:activity_eightdayActiveupdate()
	self:upadteActivityBtns()
end

-- function MainUIView:activity_TimeLimitGiftActiveUpdate()
--     if tolua.isnull(self.view) then
-- 		return
-- 	end
--     local showData1,showData2,showData3 = ModelManager.ActivityModel:getAllActDatas()
--     self.list_active:setVisible(#showData2>0)
--     -- self.adBoard:setVisible(#showData3>0)
--     -- if #showData3>0 then
--     --     self.adBoradObj:setData(showData3)
--     -- end
--     printTable(999,"活动",showData2)
--     self.list_active:setData(showData2)
-- end

--活动入口控制
function MainUIView:activity_update( )
	if tolua.isnull(self.view) then
		return
	end
	self:upadteActivityBtns()


	local winData = ActivityModel:marketUIWinData(1)
	self.ActBtn:setVisible(winData and (#winData > 0));
end

function MainUIView:serverTime_crossDay(...) --跨天
	PushMapModel:upPushMapMofangRed()
	self:upOpenNodeBtns()
end

--添加重力感应监听
function MainUIView:addAcceleration()
	local picBg = self.load_bg
	local onMoveUpdate = function()
		--print(1, "onMoveUpdate",self._bgTargetX,self._bgTargetY )
		local speed = 3
		local pos = picBg:getPosition()
		local disX = self._bgTargetX - pos.x
		local disY = self._bgTargetY - pos.y
		local dirX = disX > 0 and 1 or -1
		local dirY = disY > 0 and 1 or -1
		local targetX = pos.x + (math.abs(disX) > speed and speed or 0)*dirX
		local targetY = pos.y + (math.abs(disY) > speed and speed or 0)*dirY
		picBg:setPosition(targetX,targetY)
	end

	local onAcceleration = function(x,y,z,t)
		--print(1, "onAcceleration",x,y,z,t)
		self._bgTargetX = x * 50;
		self._bgTargetY = y*50;
	end

	self._accelerationTimer = Scheduler.schedule(function()
			--onMoveUpdate()
		end,0.05)

	self._accelerationLayer = cc.Layer:create()
	self.view:displayObject():addChild(self._accelerationLayer)
	self._accelerationLayer:setAccelerometerEnabled(true)
	self._accelerationLayer:registerScriptAccelerateHandler(onAcceleration)
end

function MainUIView:module_open_hint()
	self:setFuncManual()
end

-- 功能手册
function MainUIView:setFuncManual()
	local funcData = {}
	local isShow = false
    for k,v in pairs(DynamicConfigData.t_module) do
        if v.noteIsShow >0 then
            funcData[v.noteIsShow] = v
        end
    end
    for i=1,#funcData do
        local data = funcData[i]
        local tips = ModuleUtil.getModuleOpenTips(data.id)
		if tips then
			isShow = true
			break
        end
    end
	self.btn_funcManual:setVisible(isShow)
	local tips = ModuleUtil.getModuleOpenTips(ModuleId.HelpFunctionManual.id)
	if tips then
		self.btn_funcManual:setVisible(false)
	end
	self.btn_funcManual:removeClickListener()
	self.btn_funcManual:addClickListener(function()  
		ModuleUtil.openModule(ModuleId.HelpFunctionManual.id,true)
	end)
end

function MainUIView:removeAcceleration()
	Scheduler.unschedule(self._updateTimeId)
	self._accelerationLayer:unregisterScriptAccelerateHandler()
end

function MainUIView:setVisible(value)
	Super.setVisible(self, value)
	if value then
		--SoundManager.initLastMusicArr()
		self:playBgm(not self.isFirstShow)
		self.isFirstShow  = false
	end

end

function MainUIView:chat_jingyan_updataInfo(_,id)--禁言后删除
	if self._mainMsgBoard then
		for i = # self._mainMsgBoard._ChatmsgList,1, -1 do
			local chatItem =  self._mainMsgBoard._ChatmsgList[i]
			if chatItem and chatItem.fromPlayer and chatItem.fromPlayer.playerId == id then
				table.remove(self._mainMsgBoard._ChatmsgList, i)
				table.remove(self._mainMsgBoard._msgList, i)	
			end
		end
		self._mainMsgBoard.list_msg:setNumItems(#self._mainMsgBoard._msgList)
	end
end


return MainUIView
