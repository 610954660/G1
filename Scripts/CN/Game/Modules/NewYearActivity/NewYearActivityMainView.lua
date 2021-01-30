--Date :2021-01-21
--Author : generated by FairyGUI
--Desc : 

local NewYearActivityMainView,Super = class("NewYearActivityMainView", MutiWindow)

function NewYearActivityMainView:ctor()
	--LuaLog("NewYearActivityMainView ctor")
	self._packName = "NewYearActivity"
	self._compName = "NewYearActivityMainView"
	self._rootDepth = LayerDepth.Window
	self.progressCellList = {}
	self.isEnd = false
	self.timer= false
	self.smallBossId = false
	self.smallBossTimerKey = false
end

function NewYearActivityMainView:_initEvent( )
	self.btn_fire:addClickListener(function()
		--贡献鞭炮
		local itemCode = DynamicConfigData.t_NewYearActivity[1].contributeCost
		local num = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode) 
		local params = {}
		params.activityId = GameDef.ActivityType.NewYear
		params.amount = num
		params.onSuccess = function (data)
			printTable(6,"贡献鞭炮data",data)
			ModelManager.NewYearActivityModel.contribute = data.contribute
			self:updateProgressBar()
		end
		printTable(6,"贡献鞭炮",params)
		RPCReq.Activity_NewYear_Contribute(params,params.onSuccess)
	end)
	self.btn_bigBoss:addClickListener(function()
		ViewManager.open("NewYearActivityBigBossView",{id = ModelManager.NewYearActivityModel:getBigId()})
	end)
	self.btn_smallBoss:addClickListener(function()
		ViewManager.open("NewYearActivitySmallBossView",{id = self.smallBossId})
	end)
	self.btn_redPack:addClickListener(function()
		ViewManager.open("NewYearActivityRedPackView")
	end)
end

function NewYearActivityMainView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:NewYearActivity.NewYearActivityMainView
	self.bossIcon = viewNode:getChildAutoType('bossIcon')--GLoader
	self.btn_bigBoss = viewNode:getChildAutoType('btn_bigBoss')--btn_bigBoss
		self.btn_bigBoss.icon = viewNode:getChildAutoType('btn_bigBoss/icon')--GLoader
		self.btn_bigBoss.img_red = viewNode:getChildAutoType('btn_bigBoss/img_red')--GImage
		self.btn_bigBoss.txt_name = viewNode:getChildAutoType('btn_bigBoss/txt_name')--GTextField
	self.btn_fire = viewNode:getChildAutoType('btn_fire')--btn_fire
		self.btn_fire.img_red = viewNode:getChildAutoType('btn_fire/img_red')--GImage
	self.btn_redPack = viewNode:getChildAutoType('btn_redPack')--btn_redPack
		self.btn_redPack.img_red = viewNode:getChildAutoType('btn_redPack/img_red')--GImage
	self.btn_smallBoss = viewNode:getChildAutoType('btn_smallBoss')--btn_smallBoss
		self.btn_smallBoss.icon = viewNode:getChildAutoType('btn_smallBoss/icon')--GLoader
		self.btn_smallBoss.img_red = viewNode:getChildAutoType('btn_smallBoss/img_red')--GImage
		self.btn_smallBoss.txt_name = viewNode:getChildAutoType('btn_smallBoss/txt_name')--GTextField
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.progressBar = viewNode:getChildAutoType('progressBar')--ProgressBar
		self.progressBar.barBg = viewNode:getChildAutoType('progressBar/barBg')--GImage
	self.txt_leftTime = viewNode:getChildAutoType('txt_leftTime')--GRichTextField
	self.txt_progress = viewNode:getChildAutoType('txt_progress')--GTextField
	--{autoFieldsEnd}:NewYearActivity.NewYearActivityMainView
	--Do not modify above code-------------
end

function NewYearActivityMainView:_initUI( )
	self:_initVM()
	 self._pageNode = self.frame:getChildAutoType("contentNode")
	self:__regCtrl()  
	self:setBg("")
	--创建地图页
	self:createComponentByPageName("NewYearActivityMapView")
	self:setProgressBar()
	self:updateProgressBar()
	self:updateCountTimer()
	self:setSmallBossBtn()
	self:setSmallBossIcon()
	self:setBossIcon()
	self:setBigBossIcon()
	--注册红点
	RedManager.register("V_NEW_YEAR_BIG_BOSS",self.btn_bigBoss.img_red)
	RedManager.register("V_NEW_YEAR_SMALL_BOSS",self.btn_smallBoss.img_red)
	RedManager.register("V_NEW_YEAR_CONTRIBUTE_ITEM",self.btn_fire.img_red)
	RedManager.register("V_NEW_YEAR_BIG_RED_PACK",self.btn_redPack.img_red)
end

function NewYearActivityMainView:setProgressBar()
	local h = 370
	local s = 370/1400
	local progressBarPos = self.progressBar:getPosition()
	local contribute = DynamicConfigData.t_NewYearActivity[1].contribute
	for _, v in ipairs(contribute) do
		local y = progressBarPos.y - (v * s)
		local obj = UIPackageManager.createObject("NewYearActivity", "progressCell")
		obj:addClickListener(function ()
			ViewManager.open("NewYearActivityRedPackView")
		end)
		obj:getChildAutoType("txt_num"):setText(v)
		self.view:addChild(obj)
		obj:setPosition(39,y)
		self.progressCellList[v] = obj
	end
end

function NewYearActivityMainView:updateProgressBar()
	local num = ModelManager.NewYearActivityModel.contribute
	local maxNum = DynamicConfigData.t_NewYearActivity[1].contributeClient
	for i, obj in pairs(self.progressCellList) do
		local ctr = obj:getController("ctr")
		if num >= i then 
			ctr:setSelectedIndex(1)
		else
			ctr:setSelectedIndex(0)
		end
	end
	self.txt_progress:setText(string.format(Desc.NewYearActivity_str5,num,maxNum))
	self.progressBar:setValue(num)
	self.progressBar:setMax(maxNum)
end

function NewYearActivityMainView:updateCountTimer()
    if self.isEnd then return end
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.NewYear)
    if not actData then return end
    local actId   = actData.id
    local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
    if not addtime then return end

    if status == 2 and addtime == -1 then
        self.isEnd = false
        self.txt_leftTime:setText(Desc.activity_txt5)
    else
    	local encoreTime = ModelManager.PopularVoteModel:getPopularVoteEncoreTime()
        local lastTime = (addtime / 1000) - (encoreTime*24*60*60)
        if lastTime == -1 then
            self.txt_leftTime:setText(Desc.activity_txt5)
        else
            if not tolua.isnull(self.txt_leftTime) then
                self.txt_leftTime:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
            end
            local function onCountDown(time)
                if not tolua.isnull(self.txt_leftTime) then
                    self.isEnd = false
                    self.txt_leftTime:setText(string.format(Desc.NewYearActivity_str6,TimeLib.GetTimeFormatDay(time, 2)))
                end
            end
            local function onEnd(...)
                self.isEnd = true
                if not tolua.isnull(self.txt_leftTime) then
                self.txt_leftTime:setText(Desc.activity_txt18)
                end
            end
            if self.timer then
                TimeLib.clearCountDown(self.timer)
            end
            self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
        end
    end
end

function NewYearActivityMainView:setSmallBossBtn()
	local bossInfo = {}
	local expireMs = false
	for id, data in pairs(ModelManager.NewYearActivityModel.bossInfo) do
		bossInfo = ModelManager.NewYearActivityModel:getNewYearBossConfig(id)
		if bossInfo and bossInfo.type == 3 then 
			if data.status == 2 then 
				if not expireMs or expireMs > data.expireMs then
					self.smallBossId = id
					expireMs = data.expireMs
				end
			end
		end
	end
	if self.smallBossId then 
		self.btn_smallBoss:setVisible(true) 
		if self.smallBossTimerKey then
			TimeLib.clearCountDown(self.smallBossTimerKey)
		end
		if expireMs then 
			local timems = math.floor((expireMs - ServerTimeModel:getServerTimeMS()) / 1000)
			local function onCountDown(t)
				if not tolua.isnull(self.btn_smallBoss.txt_name) then
					local str = TimeLib.formatTime(t,true,false)
					self.btn_smallBoss.txt_name:setText(str)
				end
			end
			local function onEnd(...)
			
			end
			self.smallBossTimerKey = TimeLib.newCountDown(timems, onCountDown, onEnd, false, false, false)
		else
			self.btn_smallBoss.txt_name:setText("")
		end
	else
		self.btn_smallBoss:setVisible(false) 
	end
end

function NewYearActivityMainView:setBigBossIcon()
	local bigBossId = ModelManager.NewYearActivityModel:getBigBossId()
	print(6,"bigBossId",bigBossId)
	self.btn_bigBoss.icon:setURL(PathConfiger.getHeroCard(bigBossId))
end

function NewYearActivityMainView:setSmallBossIcon()
	if self.smallBossId then
		local info = ModelManager.NewYearActivityModel:getNewYearBossConfig(self.smallBossId) 
		self.btn_smallBoss.icon:setURL(PathConfiger.getHeroCard(info.bossId))
	end
end

function NewYearActivityMainView:setBossIcon()
	local nextBossId = ModelManager.NewYearActivityModel.nextId
	local info = ModelManager.NewYearActivityModel:getNewYearBossConfig(nextBossId) 
	self.bossIcon:setURL(PathConfiger.getHeroCard(info.bossId))
end

function NewYearActivityMainView:NewYearActivity_BossInfoUpdate()
	self:setSmallBossBtn()
end
return NewYearActivityMainView