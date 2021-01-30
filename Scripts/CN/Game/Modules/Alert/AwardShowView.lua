--added by xiehande
--功能 公用奖励弹窗
local PlayerController = require("Game.Modules.Player.PlayerController");
local AwardShowView,Super = class("AwardShowView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function AwardShowView:ctor(args)
	LuaLogE("AwardShowView ctor")
	self._packName = "UIPublic_Window"
	self._compName = "AwardShowView"
	self._isFullScreen = true
	self._rootDepth = LayerDepth.AlertWindow
	self.awardList = false
	self.timer = false
	self.spineParent = false
	self.textLoader = false
	self.curCardArr = {}
	self.rewardItemMap={}
	self.schedulerArr = {}
	self.scheduler = false
	self.closeTimer = false
	self.txtTimer =false
	-- self.spineNode = false
	-- printTable(1,self._args)
end

function AwardShowView:showEffect( ... )
	-- self.spineNode = self.view:getChildAutoType("spineNode")
	-- self.setSpine:setSpine("Spine/ui/efx_jiesuan")
	if tolua.isnull(self.view) then return end
	if self._args.type == GameDef.GamePlayType.ChaptersFastBattle or self._args.type == GameDef.GamePlayType.ChaptersHangUp then
		self.textLoader:setURL("UI/AwardShow/xingdongshouyi.png")
	elseif self._args.type == GameDef.GamePlayType.HeroChange then
		self.textLoader:setURL("UI/AwardShow/cailiaofanhui.png")
	else
		self.textLoader:setURL("UI/AwardShow/gongxihuode.png")
	end
		
	self.view:getTransition("t0"):play(function( ... )
						  end);
    local spine1 =  SpineUtil.createSpineObj(self.spineParent, vertex2(self.spineParent:getWidth()/2,self.spineParent:getHeight()/2), "gongxihuode", "Spine/ui/jiesuan", "efx_jiesuan", "efx_jiesuan",false)
    spine1:setCompleteListener(function( name )
		
    	spine1:setAnimation(0,"gongxihuode_loop",true)
    end)
    if self.rewardItemMap and next(self.rewardItemMap) then
		self.awardList:setData(self.rewardItemMap)
		self.awardList:setOpaque(false)
	end
end

function AwardShowView:showSpine(  )
    if self.timer then
    	Scheduler.unschedule(self.timer)
    end
    local countTime  = 0 
	self.timer=Scheduler.schedule(function(time)
		countTime=countTime + time
		if countTime>=0.1 then
           self:showEffect()
            if self.timer then
		    	Scheduler.unschedule(self.timer)
		    	self.timer = nil
		    end
		end
    end,0)
end

function AwardShowView:_initUI()
	printTable(1, self._args)
	if self._args.type == GameDef.GamePlayType.FairyLand and FairyLandModel.autoNext then
		self._args.autoCloseTime = 2
	end
	if self._args.autoCloseTime and self._args.autoCloseTime > 0 then
		if self.closeTimer then
			Scheduler.unschedule(self.closeTimer)
		end
		self.closeTimer=Scheduler.scheduleOnce(self._args.autoCloseTime,function(time)
			self:closeView()
		end)
	end
	
	self.spineParent = self.view:getChildAutoType("spineParent")
	self.textLoader = self.view:getChildAutoType("textLoader")
    self.showCtrl = self.view:getController("showCtrl")    
	self.awardList = self.view:getChildAutoType("awardList")
	local progress = self.view:getChildAutoType("progress")
	progress:setValue(0)
	self.awardList:setY(177)
	if self._args.type == GameDef.GamePlayType.ChaptersFastBattle or self._args.type == GameDef.GamePlayType.ChaptersHangUp then
		self.view:getController("typeCtrl"):setSelectedIndex(1)
		self.awardList:setY(316)
		local playerCell = BindManager.bindPlayerCell(self.view:getChildAutoType("heroCell")); 
		playerCell:setHead(PlayerModel.head, PlayerModel.level, nil,nil,PlayerModel.headBorder);
		local progress = self.view:getChildAutoType("progress")
		local ptitle = progress:getChildAutoType("title")
		local nextInfo = DynamicConfigData.t_roleAttr[PlayerModel.level+1]
		local lastInfo = DynamicConfigData.t_roleAttr[PlayerModel.level]
		local nextExp = nextInfo and nextInfo.exp
		local lastConfigExp = lastInfo and lastInfo.exp
		local exp = PlayerModel.exp
		if not nextExp then
			progress:setMax(1)
			progress:setValue(1)
			ptitle:setText(Desc.player_expStr3)
		else
			local lastExp = PlayerModel:getTempExp(  )
			-- local curExp = PlayerModel.exp
			-- if curExp<10000 then
			-- 	print(1,lastExp)
			-- 	print(1,curExp)
			-- 	print(1,nextExp)
			-- 	progress:setMax(nextExp)
			-- 	progress:setMin(0)
			-- 	if curExp>20 then
			-- 		progress:tweenValue(curExp,1)
			-- 	else
			-- 		progress:setValue(curExp)
			-- 	end
			-- else
				-- print(1,lastExp)
				-- print(1,exp)
				-- print(1,lastConfigExp)
				-- print(1,nextExp)
				if lastExp>lastConfigExp or nextExp<lastConfigExp  then --已经走了下一段
					progress:setValue(0)
					progress:setMax(100)
					progress:setMin(0)
				else
					print(1,"progress:getValue",progress:getValue())
					progress:setValue((lastExp/nextExp)*100)
					progress:setMax(100)
					progress:setMin(0)
				end

				-- local curStr = exp
				-- if exp >= 100000000 then
				-- 	curStr = Desc.player_expStr2:format(exp/100000000)
				-- elseif exp >= 10000 then
				-- 	curStr = Desc.player_expStr1:format(exp/10000)
				-- end
				-- local nextStr = nextExp
				-- if nextExp >= 100000000 then
				-- 	nextStr = Desc.player_expStr2:format(nextExp/100000000)
				-- elseif nextExp >= 10000 then
				-- 	nextStr = Desc.player_expStr1:format(nextExp/10000)
				-- end
				-- ptitle:setText(curStr.."/"..nextStr)
				ptitle:setText(lastExp.."/"..nextExp)
				local countTime = 0
				local onUpdate = function(value)
					ptitle:setText(math.ceil(value).."/"..nextExp)
				end
				TweenUtil.toDouble(ptitle, {onUpdate = onUpdate,from = lastExp, to = exp, time = 1, ease = EaseType.SineOut})
				if __ENGINE_VERSION__ > 2 then
					local startTime = (lastExp/nextExp)
					local endTime = (exp/nextExp)
					if lastExp>lastConfigExp or nextExp<lastConfigExp  then --已经走了下一段
						startTime = 0
					end
					print(1,"startTime",startTime)
					print(1,"endTime",endTime)
					progress:getTransition("t0"):play(1,0.5,startTime,endTime,function( ... )
				    end);
				-- else
					-- progress:getTransition("t0"):play(function( ... )
					-- end);
				end
			-- end
		end
		local time = PushMapModel:getPushmapRewardGuajiCache()
		local timeLab = self.view:getChildAutoType("timeLab")
		timeLab:setText(TimeLib.formatTime(time, true, false))
	elseif self._args.type == GameDef.GamePlayType.HeroChange then
		self.awardList:setY(230)
		self.view:getController("typeCtrl"):setSelectedIndex(2)
	else
		self.view:getController("typeCtrl"):setSelectedIndex(0)
	end
	
	
	--祈福特殊处理
	self.view:getController("gpCtrl"):setSelectedIndex(0)
	if self._args.type == GameDef.GamePlayType.ActivityShrinePray  then
		local data = ActShrineBlessModel:getShirneTempCode()
		-- printTable(1,"数据1",data)
		-- printTable(1,"数据2",self._args.reward)
		if data then
			if self._args.reward[1] and self._args.reward[1].code == data.code and self._args.reward[1].amount == data.amount then
				self.view:getController("gpCtrl"):setSelectedIndex(1)
			end
		end
	end
	
	--一番巡礼大奖特殊处理
	if self._args.type == GameDef.GamePlayType.ActivityElfHis  then
		local shireCost = ActATourGiftModel:getTourTempCode()
		if shireCost then
			for i=1,#self._args.reward do
				if self._args.reward[i].code == shireCost.code and self._args.reward[i].amount == shireCost.amount then
					self.view:getController("gpCtrl"):setSelectedIndex(1)
					break;
				end
			end
		end
	end


	--測試數據
	 -- self._args.reward = {[1]={type=2,code=1,amount=20},[2]={type=2,code=2,amount=20},[3]={type=1,code=1,amount=20},[4]={type=3,code=10000005,amount=1},[5]={type=3,code=10000006,amount=1},[6]={type=3,code=10000006,amount=1},[7]={type=3,code=10000006,amount=1},[8]={type=3,code=10000006,amount=1}}
	if self._args.reward and next(self._args.reward) then
		-- 纹章的生成规则与普通道具不同，道具表的code相当于礼包，但要显示具体生成的纹章，这里特殊处理一下
		self._args.reward = EmblemModel:awardListResetEmblemData(self._args.reward)

		local emblemConf = DynamicConfigData.t_Emblem
		for key, value in pairs(self._args.reward) do
			local configInfo=ItemConfiger.getInfoByCode(value.code,value.type)
			value["color"]=1
			if configInfo then
				value["color"]=configInfo.color
			end
			-- 纹章特殊处理
			if configInfo and configInfo.type == 28 then
				local spData = value.specialData and value.specialData.heraldry or false
				local id = spData and spData.heraldryId or false
				if id and emblemConf[id] then
					value["color"] = emblemConf[id].rank
					value["isEmblem"] = true
				end
			end
			table.insert( self.rewardItemMap, value)
		end
	end
    TableUtil.sortByMap(self.rewardItemMap, {{key="color",asc=true}})
    
	self.awardList:setItemProvider(
		function(index)
			if self.rewardItemMap[index+1].type == GameDef.GameResType.Hero then
				return "ui://hgm3oko8dp3dxcwwwm"
			elseif self.rewardItemMap[index+1].isEmblem then
				return "ui://hgm3oko8h32o2"
			else
				return "ui://hgm3oko8o10na"
			end
		end
	)
	self.awardList:setItemRenderer(function(index,obj)
        if self.schedulerArr[index] then
        	Scheduler.unschedule(self.schedulerArr[index])
        	self.schedulerArr[index] = false
        end
        local interTime = 1/#self.rewardItemMap
        if interTime >= 0.1 then
        	interTime = 0.1
		end
		if (not obj.playedAnim) then
			obj:setVisible(false)
			self.schedulerArr[index] = Scheduler.scheduleOnce(index*interTime, function( ... )
        	    if obj and  (not tolua.isnull(obj)) then
        	    	obj:setVisible(true)
        	    	if obj:getTransition("t0") then
        	    		obj:getTransition("t0"):play(function( ... )
		        			    local spine =  SpineUtil.createSpineObj(obj, vertex2(obj:getWidth()/2,obj:getHeight()/2), "wuti_chuxian", "Spine/ui/jiesuan", "efx_jiesuan", "efx_jiesuan",false)
					    end);
        	    	end
        	    end
			end)
			obj.playedAnim = true;
		end
	   
		local data = self.rewardItemMap[index+1]
		--特殊处理 祈福活动
		if self._args.type == GameDef.GamePlayType.ActivityShrinePray  then
			local shireCost = ActShrineBlessModel:getShirneTempCode()
			if shireCost then
				if self._args.reward[1] and self._args.reward[1].code == shireCost.code and self._args.reward[1].amount == shireCost.amount then
					local speCtrl = obj:getController("speCtrl")
					if speCtrl then
						speCtrl:setSelectedIndex(1)
					end
				end
			end
		end

		if self._args.type == GameDef.GamePlayType.ActivityElfHis  then
			local tourCost = ActATourGiftModel:getTourTempCode()
			if tourCost and data.code == tourCost.code and data.amount == tourCost.amount then
				local speCtrl = obj:getController("speCtrl")
				if speCtrl then
					speCtrl:setSelectedIndex(1)
				end
			end
		end


		if data.type == GameDef.GameResType.Hero then --卡牌英雄
			local heroCell = BindManager.bindHeroCellShow(obj)
			local tempdata = {}
			tempdata.code = data.code
			tempdata.category = DynamicConfigData.t_hero[data.code].category
			if data.extraData then
				if data.extraData.hero then
					if data.extraData.hero.star then
						tempdata.star = data.extraData.hero.star
					else
						tempdata.star = DynamicConfigData.t_hero[data.code].heroStar
					end
					if data.extraData.hero.level then
						tempdata.level = data.extraData.hero.level
					else
						tempdata.level = 1
					end
					
					tempdata.stage = data.extraData.hero.stage
					tempdata.isNew = data.extraData.hero.isNew
				end
			else
				tempdata.star = DynamicConfigData.t_hero[data.code].heroStar
				tempdata.level = 1
			end
			tempdata.amount = data.amount
			heroCell:setData(tempdata)
		elseif data.isEmblem then -- 纹章
			local spData = data.specialData and data.specialData.heraldry or false
			if (spData) then
				local c = DynamicConfigData.t_Emblem[spData.heraldryId]
				local d = {
					code = spData.heraldryId,
					category = spData.category,
					exp = spData.exp,
					star = spData.star,
					color = data.color,
					pos = c.pos
				}
				local itemCell = BindManager.bindEmblemCell(obj)
				itemCell:setData(d)
				obj:addClickListener(function()
					itemCell:showItemTips()
				end)
			end
	    else
	    	local itemcell = BindManager.bindItemCell(obj)
			local itemData = ItemsUtil.createItemData({data = data})
			itemcell:setIsBig(false)
			itemcell:setItemData(itemData)
	    end
	end
	)
	self.awardList:setVirtual();    
	--只有合成才需要往下走
	if not (self._args.type == GameDef.GamePlayType.HeroCombine) then
		--这里只是奖励获取的时候 将动画reverse下 合成不需要 注意
		print(1,"不是合成 将动画reverse播放一下")
		self.view:getTransition("t0"):playReverse()
	    self.view:getTransition("t0"):stop()
		self.showCtrl:setSelectedIndex(1)
		self:showSpine()
		return
	end

	self.showCtrl:setSelectedIndex(1)
	--检测是否是4,5星 或者新英雄
	local data1 = {}
	local maxStar = 0
	local cardCode=0
	for i,v in ipairs(self.rewardItemMap) do
		printTable(150,"i v",i,v)
		if v.type == GameDef.GameResType.Hero then
			local flag,heroStar = self:checkCard(v)
			if flag then
				table.insert(data1,v)
			end

			if heroStar and maxStar < heroStar then
				maxStar = heroStar
				cardCode=v.code
			end
		end
	end

	self.curCardArr = data1
	self:show_GetCardView()
	Dispatcher.dispatchEvent("event_getHighStarHero",maxStar,cardCode)
	
	
end

--通过监听弹出
function AwardShowView:show_GetCardView( ... )
	if  tolua.isnull(self.view) then
		return
	end
	if self.scheduler then
		Scheduler.unschedule(self.scheduler)
	end
	local func =  function( ... )
		if #self.curCardArr>0 then
			local tempdata = TableUtil.DeepCopy(self.curCardArr[#self.curCardArr]) 
			ViewManager.open("GetHeroCardShowView",{data = tempdata})
			table.remove(self.curCardArr)
		else
			if not tolua.isnull(self.view) then
				self.showCtrl:setSelectedIndex(1)
			    self:showSpine()
			end
			-- self.view:getTransition("t0"):play(function( ... )
			-- 			  end);
		end
	end
	self.scheduler = Scheduler.scheduleOnce(0, func)

end

function AwardShowView:checkCard( card)
	local code = card.code
	local Category = DynamicConfigData.t_hero[code].category
	if card.isNew then --新的
        return true,0
	end
	if card.isFirstCombine then
		return true,0
	end
	local heroStar = DynamicConfigData.t_hero[code].heroStar
	if heroStar>4 then
		return true,heroStar
	end
	return false,nil
end

function AwardShowView:_initEvent( ... )
end

function AwardShowView:_exit( ... )
	if ModelManager.PlayerModel then
		ModelManager.PlayerModel:set_awardData(false)
	end
	Dispatcher.dispatchEvent(EventType.pata_showNext)
	

	if self.awardList then
	--  local rewardItem,rewardItemAmount=RollTips.getflyRewardAndPos(self.rewardItemMap,self.awardList)
	-- 	RollTips.startflyRewardList(rewardItem,rewardItemAmount)
	end

	--如果有关闭回调的，调用回调
	if self._args.closeCallBack then
		self._args.closeCallBack(self._args.closeCaller)
	end
	
	if self._args.closefuc then
		self._args.closefuc()
	end
    if self.scheduler then
		Scheduler.unschedule(self.scheduler)
		self.scheduler = false
	end

	for i,v in ipairs(self.schedulerArr) do
		if self.schedulerArr[i] then
        	Scheduler.unschedule(self.schedulerArr[i])
        	self.schedulerArr[i] = false
        end
	end
	if self.timer then
    	Scheduler.unschedule(self.timer)
    	self.timer = nil
    end
	
	if self.closeTimer then
		Scheduler.unschedule(self.closeTimer)
	end
	
	Scheduler.scheduleNextFrame(function()
		Dispatcher.dispatchEvent(EventType.module_open_hint)
	end)

	-- 秘境寻宝次数达到后自动弹出奖励
	if self._args.type == GameDef.GamePlayType.FairyLand then
		FairyLandModel:tipsReward()
		if not self._args.closefuc then
			Dispatcher.dispatchEvent(EventType.fairyLand_onRwardClose)
		end
	end
end

return AwardShowView