--Date :2021-01-20
--Author : added by xhd	
--Desc : 节日活动boss

local ActCommonBossView,Super = class("ActCommonBossView", Window)

function ActCommonBossView:ctor()
	--LuaLog("ActCommonBossView ctor")
	self._packName = "ActCommonBoss"
	self._compName = "ActCommonBossView"
	--self._rootDepth = LayerDepth.Window
	self.flag = false
	self.bossData = {}
	self.bossConfig = {}
	self.__timerId = {}
	-- self.btn_okluaObj = false
	self.skeletonNode = false
	-- self.timeCount = 0
	self.fightData = {}
	self.recordIds = {}
end

function ActCommonBossView:_initEvent( )
	self:updatePanel()
end

function ActCommonBossView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:ActCommonBoss.ActCommonBossView
	self.btn_ok = viewNode:getChildAutoType('$btn_ok')--GButton
	self.com_model = viewNode:getChildAutoType('$com_model')--GLoader
	self.list_skill = viewNode:getChildAutoType('$list_skill')--GList
	self.txt_count = viewNode:getChildAutoType('$txt_count')--GTextField
	self.btn_rule = viewNode:getChildAutoType('btn_rule')--GButton
	self.btn_tanyuan = viewNode:getChildAutoType('btn_tanyuan')--Button27
		self.btn_tanyuan.img_red = viewNode:getChildAutoType('btn_tanyuan/img_red')--GImage
	self.btn_tuijian = viewNode:getChildAutoType('btn_tuijian')--GButton
	self.numCtrl = viewNode:getController('numCtrl')--Controller
	self.recordList = viewNode:getChildAutoType('recordList')--GList
	self.showTxt = viewNode:getChildAutoType('showTxt')--GTextField
	self.tipComp = viewNode:getChildAutoType('tipComp')--Component1
		self.tipComp.blackbg = viewNode:getChildAutoType('tipComp/blackbg')--GLabel
		self.tipComp.tipList = viewNode:getChildAutoType('tipComp/tipList')--GList
		self.tipComp.title = viewNode:getChildAutoType('tipComp/title')--GRichTextField
	self.tipCtrl = viewNode:getController('tipCtrl')--Controller
	self.txt_countTimer = viewNode:getChildAutoType('txt_countTimer')--GTextField
	self.txt_countTitle = viewNode:getChildAutoType('txt_countTitle')--GTextField
	self.zhscBtn = viewNode:getChildAutoType('zhscBtn')--GButton
	--{autoFieldsEnd}:ActCommonBoss.ActCommonBossView
	--Do not modify above code-------------
end


function ActCommonBossView:tidyTextShow( data )
	local str = ""
	str  = data.name or Desc.activity_txt43
	local itemName = ""
	local config = ActCommonBossModel:getBossConfig(  )
	local itemInfo = ItemConfiger.getInfoByCode(config.item[1].code)
	if itemInfo then
		itemName = itemInfo.name
	end
	str = string.format( "[color=#F29F48]%s[/color][color=#ffffff]获得了%s*%d[/color]",str,itemName,data.num)
	return str
end

function ActCommonBossView:_initListener( )
	
	self.btn_ok:addClickListener(function()
		if self.bossData  and self.bossData.restTimes and self.bossData.restTimes>0 then --有次数
			local function battleHandler(eventName)
				if eventName == "begin" then
					ActCommonBossModel:reqBossBattle()
				elseif eventName == "end" then
					local data = ActCommonBossModel:getBossResult()
					ViewManager.open("ActCommonBossResultView",{data = data})
				end
			end
			local configType = GameDef.BattleArrayType.GuildDailyBoss
			Dispatcher.dispatchEvent(
				EventType.battle_requestFunc,
				battleHandler,
				{fightID = self.bossConfig.fightID, configType = GameDef.BattleArrayType.HolidayBoss}
			)
		else
			RollTips.show("今日挑战次数已经用完")
		end
	end)

	self.list_skill:setItemRenderer(function(index, obj)
		obj:removeClickListener(100)
		local skillId = self.list_skill._dataTemplate[index + 1]
		local conf = DynamicConfigData.t_skill[skillId];
		local iconLoader = obj:getChildAutoType("iconLoader")
		iconLoader:setIcon(CardLibModel:getItemIconByskillId(conf.icon));
		obj:removeClickListener();
		obj:addClickListener(function ()
			if conf then
				ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillId})
			end
		end)
	end)

	self.btn_rule:addClickListener(function()
		local info={}
		info['title']=Desc["help_StrTitle292"]
		info['desc']=Desc["help_StrDesc292"]
		ViewManager.open("GetPublicHelpView",info) 
	end)

	self.btn_tuijian:addClickListener(function()
		ActCommonBossModel:reqBossReCord( )
		self.flag = not self.flag
		if self.flag then
			self.tipCtrl:setSelectedIndex(1)
		else
			self.tipCtrl:setSelectedIndex(0)
		end
		self:showHeroTips()
	end)

	self.tipComp.blackbg:addClickListener(function()
		self.flag = not self.flag
		if self.flag then
			self.tipCtrl:setSelectedIndex(1)
		else
			self.tipCtrl:setSelectedIndex(0)
		end
	end)

	self.btn_tanyuan:addClickListener(function()
		ActCommonBossModel:reqBossReCord( )
		ModuleUtil.openModule(ModuleId.Hero.id, true)
	end)
	
	self.recordList:setVirtual()
	self.recordList:setItemRenderer(function(index, obj)
		local str =self:tidyTextShow(self.recordList._dataTemplate[index+1])
		local detail = obj:getChildAutoType("detail")
		detail:setText(str)
		local checkBtn = obj:getChildAutoType("checkBtn")
		checkBtn:removeClickListener(100)
		checkBtn:addClickListener(function ()
			print(1,"查看阵容点击")
			table.insert( self.recordIds, self.recordList._dataTemplate[index+1].recordId)
			for key,fightId in pairs(self.recordIds) do
				BattleModel:requestBattleRecord(fightId)
			end
		end,100)
	end)

	-- --召唤商城按钮
	-- self.zhscBtn:addClickListener(function()
    --     ModuleUtil.openModule()
	-- end)

end

--显示tips
function ActCommonBossView:showHeroTips()
	ActCommonBossModel:reqBossReCord( )
	local monsterInfo = DynamicConfigData.t_monster[self.bossConfig.BOSSID]
    if not monsterInfo then
        return
	end
	local str = "[color=#ffc35b]"..monsterInfo.name..":[/color]"..monsterInfo.dec
	local config = ActCommonBossModel:getHeroRecommendConfig()
	printTable(1,config)
	self.tipComp.title:setText(str)
	self.tipComp.tipList:setItemRenderer(function(index, obj)

		local playerCell = obj:getChildAutoType("heroCell")
		local detail = obj:getChildAutoType("detail")
		local heroCellObj = BindManager.bindHeroCell(playerCell)
		local data = {}
		data.star = DynamicConfigData.t_hero[config[index+1].heroCard].heroStar
		data.category = DynamicConfigData.t_hero[config[index+1].heroCard].category
		data.code = config[index+1].heroCard
		data.level = 1
		data.amount = 1
		heroCellObj:setData(data)
		detail:setText(config[index+1].dec)
	end)
	self.tipComp.tipList:setData(config)
end

--更新记录
function ActCommonBossView:update_bossView_reCord(  )
	local recordData = ActCommonBossModel:getBossRecordData(  )
	self.recordList:setData(recordData)
end

function ActCommonBossView:reflash_CommonBossView( ... )
	self:updatePanel()
end

function ActCommonBossView:updatePanel()
	-- self.view:getChildAutoType("frame/fullScreen"):setIcon("UI/Guild/"..bossInfo.bossBg);
	self.bossData = ActCommonBossModel:getData( )
	self.bossConfig = ActCommonBossModel:getBossConfig()
	self:updateActTimeShow()
	self:showBossView()
	self:showskill()
	self:showCount()
end


function ActCommonBossView:showBossView()
	local bossid = self.bossConfig.BOSSID
    if self.skeletonNode then
        self.skeletonNode:removeFromParent()
    end
	local skeletonNode = SpineMnange.createSprineById(bossid)
	if skeletonNode then
		local config = ActCommonBossModel:getBossConfig(  )
		skeletonNode:setScaleX(-1*config.size)
		skeletonNode:setScaleY(1*config.size)
		-- skeletonNode:setPosition(bossInfo.pos[1], bossInfo.pos[2])
		self.com_model:displayObject():addChild(skeletonNode)
		skeletonNode:setAnimation(0, "stand", true)
	end
	self.skeletonNode = skeletonNode
	
	self.showTxt:setText(string.format( "挑战建议:%s",self.bossConfig.fightTips))
	if self.bossData  and self.bossData.restTimes and self.bossData.restTimes>0 then --有次数
		self.btn_ok:getChildAutoType("img_red"):setVisible(true)
	else
		self.btn_ok:getChildAutoType("img_red"):setVisible(false)
	end
end


function ActCommonBossView:showCount()
	-- self.btn_okluaObj:setCostCtrl(0)
    if self.bossData.restTimes<=0 then
        self.numCtrl:setSelectedIndex(1)
    else
        self.numCtrl:setSelectedIndex(0)
    end
    self.txt_count:setText(string.format(Desc.Guild_Text1,self.bossData.restTimes))
end


--显示技能
function ActCommonBossView:showskill()
	local monsterInfo = DynamicConfigData.t_monster[self.bossConfig.BOSSID]
    if not monsterInfo then
        return
    end
    self.list_skill:setData(monsterInfo.skill)
end

--更新活动时间
function ActCommonBossView:updateActTimeShow( ... )
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
    local actid = ActCommonBossModel:getActivityId( )
	local status,timems = ActivityModel:getActStatusAndLastTime( actid)
	if status == 2 and timems == -1 then
		self.txt_countTimer:setText(Desc.activity_txt5)
		return
	end
	if status ==0 then
		self.txt_countTimer:setText(Desc.activity_txt13)
		return
	end

	if timems==0 then
		self.txt_countTimer:setText(Desc.activity_txt13)
		return
	end
	timems = timems/1000
	
	local function updateCountdownView(time)
		-- self.timeCount = self.timeCount + time
		-- print(1,self.timeCount)
		-- if self.timeCount>=10000000 then
		-- 	ActCommonBossModel:reqBossReCord( )
		-- 	self.timeCount = 0
		-- end
		if tolua.isnull(self.txt_countTimer) then
			return
		end
		if time > 0 then
			local timeStr = TimeLib.GetTimeFormatDay(time,2)
			self.txt_countTimer:setText(timeStr)
		else
			self.txt_countTimer:setText(Desc.activity_txt18)
		end
	end
	updateCountdownView(timems)
	self.__timerId = TimeLib.newCountDown(timems, function(time)
		updateCountdownView(time)
	end, function()
		if tolua.isnull(self.txt_countTimer) then
			return
		end
		self.txt_countTimer:setText(Desc.activity_txt4) -- TODO
	end, false, false, false)
end

function ActCommonBossView:_initUI( )
	self:_initVM()
	-- self.btn_okluaObj  = BindManager.bindCostButton(self.btn_ok)
	self:_initListener()
    ActCommonBossModel:reqBossReCord( )
end


function ActCommonBossView:_exit()
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
end

function ActCommonBossView:Battle_BattleRecordData(_, param)
    if (#self.fightData < #self.recordIds) then
		table.insert(self.fightData,param.battleData)
    end
	if (#self.fightData == #self.recordIds) then
		printTable(1,self.fightData)
		ViewManager.open("BattledataView",{isWin = self.fightData[1].result,isRecord = true,battleData = self.fightData[1]})
    end
end


return ActCommonBossView