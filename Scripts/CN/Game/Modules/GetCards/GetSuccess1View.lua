--单抽获得成功界面1
--added by xhd
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local GetSuccess1View,Super = class("GetSuccess1View",Window)
-- local nolyUserItem = {1,}
function GetSuccess1View:ctor( ... )
    self._packName = "GetCards"
	self._compName = "GetSuccess1View"
	self._rootDepth = LayerDepth.Window

	self.cardInfo = false
	self.againBtn = false
	self.confirmBtn = false
	self.resultList = false
	self.itemCode = false
	self.id = false
	self.spineNode = false

	self.cost = false
    self.costItemObj =false

	self.curCardArr = {}
    self.changjingScheduleID = false
	self.shilianScheduleID = false
    self.listCell =false
    self.skeletonNode = false
    self.soundId = false
    self.soundId2 = false
    
    --测试数据
    -- self._args.resultList = {
    --    [1] = {
    --       amount=1,
    --       resultType=0,
	-- 	  code=35010,
	-- 	--   code = 24002,
    --       type = 4,
    --       status = 0,
    --    },
    -- }
    -- self._args.itemCode = 10000005
	-- self._args.id = 1
	-- self._args.cost = {{type=2,code= 4,amount= 100,},}
end

function GetSuccess1View:_initUI( ... )
    local cardInfo = self.view:getChildAutoType("cardInfo/cardInfo")
	self.cardInfo = BindManager.bindCardCell(cardInfo)
    self.againBtn = self.view:getChildAutoType("againBtn")
    self.confirmBtn = self.view:getChildAutoType("confirmBtn")
    self.costItem = self.view:getChildAutoType("costItem")
    self.btn_pauseSpine = self.view:getChildAutoType("btn_pauseSpine")
	self.costItemObj = BindManager.bindCostItem(self.costItem)
	self.spineParent = self.view:getChildAutoType("spineParent")
	self.gxhdNode = self.view:getChildAutoType("n62")
	self:setBg("bg_heroInfo3.jpg")
	local efx_zitilizi =  SpineUtil.createSpineObj(self.gxhdNode, vertex2(180,50), "animation", "Spine/ui/chouka", "efx_zitilizi", "efx_zitilizi",true)
	if ModelManager.PlayerModel.TipsNotifyId then
		return
	end
    self:updateWindow()
end

function GetSuccess1View:getcard_update_success(_,data )
	--printTable(1,"GetSuccess1View update_success",data) 
	self._args = data
	if tolua.isnull(self.view) then
		return
	end 
	if ModelManager.PlayerModel.TipsNotifyId then
		return
	end
	self:updateWindow()
end

function GetSuccess1View:updateWindow()
	if tolua.isnull(self.view) then
		return
	end 
	-- printTraceback()
	self.view:getController("showCtrl"):setSelectedIndex(0)
    self.resultList = self._args.resultList
    self.itemCode = self._args.itemCode
    self.cost = self._args.cost
    self.id = self._args.id
    -- printTable(1,self._args)
    if self._args.specialType==1 then
    	self.againBtn:setGrayed(true)
    	self.againBtn:setTouchable(false)
    	self.costItem:setVisible(false)
    	self:showCards()
    	return
    else
    	self.costItem:setVisible(true)
    	self.againBtn:setGrayed(false)
    	self.againBtn:setTouchable(true)
    end
	
	self.costItemObj:setDarkBg(true)
	self.costItemObj:setUseMoneyItem(false);
	self.costItemObj:setData(self.cost[1].type, self.cost[1].code, self.cost[1].amount, true,false,false)

    self:showCards()
end

function GetSuccess1View:tips_notify_close( ... )
	-- body
	print(1,"tips_notify_close")
	self:updateWindow()
end

function GetSuccess1View:play_spine( ... )
	local flag = GetCardsModel:checkHadSSR(self.resultList)
	local  guangxian = "animation_zi" --紫光
	local  guangxian2 = "chuxian_sr" --紫光
	if flag then
		guangxian = "animation" --金光
		guangxian2 = "chuxian_ssr" --金光
	end
	local color = GetCardsModel:getColorByCode( self.resultList[1].code )
	local ronjieAni = "fx_rongjie_sr_up"
	if color == 5 then
		ronjieAni = "fx_rongjie_ssr_up"
	else
		ronjieAni = "fx_rongjie_sr_up"
	end
	local fanzhuanAniUp = "fanzhuan_r_up"
	local fanzhuanAniDown = "fanzhuan_r_down"
	if color == 3 then
		fanzhuanAniUp = "fanzhuan_r_up"
		fanzhuanAniDown = "fanzhuan_r_down"
	elseif color == 4 then
		fanzhuanAniUp = "fanzhuan_sr_up"
		fanzhuanAniDown = "fanzhuan_sr_down"
	elseif color ==5 then
		fanzhuanAniUp = "fanzhuan_ssr_up"
		fanzhuanAniDown = "fanzhuan_ssr_down"
	end
    
    --过场动画
    local chouka_changjing1 =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), "animation2", "Spine/ui/chouka2", "cj_chouka", "cj_chouka",false)
    local chouka_changjing2 =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), "animation", "Spine/ui/chouka2", "cj_chouka", "cj_chouka",false)
    self.soundId = SoundManager.playSound(1014,false)
    local sprite = display.newSprite("Spine/ui/chouka/image/chouka_changjing.png", 0, 0)
    chouka_changjing2 = SpineUtil.addChildToSlot(chouka_changjing1,sprite,"chouka_changjing")
    local chouka_changjing =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), guangxian, "Spine/ui/chouka2", "fx_choukachangjing", "fx_choukachangjing",false)

	local func1 = function( ... )
		if tolua.isnull(self.spineParent) then
			return 
		end
		self.btn_pauseSpine:removeClickListener(11)
        if self.changjingScheduleID then
        	Scheduler.unschedule(self.changjingScheduleID)
        	self.changjingScheduleID = false
        end
		self.spineParent:displayObject():removeAllChildren()
		local chouka_changjing =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), guangxian2, "Spine/ui/chouka2", "fx_choukachangjing", "fx_choukachangjing",false)
		local fx_danchouchuxian_down =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), "fx_danchouchuxian_down", "Spine/ui/chouka2", "fx_chuxianweizhi", "fx_chuxianweizhi",false)
        local fx_danchouchuxian_up =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), "fx_danchouchuxian_up", "Spine/ui/chouka2", "fx_chuxianweizhi", "fx_chuxianweizhi",false)
		local fx_danchouchuxian_loop =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), "fx_danchouchuxian_loop", "Spine/ui/chouka2", "fx_chuxianweizhi", "fx_chuxianweizhi",false)

		--显示卡牌背景真实框
		SpineUtil.addChildToSlot(fx_danchouchuxian_down,self.listCell:displayObject(),"kapai1")
		self.listCell:getController("texiaoCtrl"):setSelectedIndex(1)
		self.listCell:getController("colorCtrl"):setSelectedIndex(color-2)

		local skeletonNode = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_kapairongjie")
		skeletonNode:setAnimation(0, "kapai_loop", true)
		SpineUtil.addChildToSlot(fx_danchouchuxian_down,skeletonNode,"kapai1")
		
		self.changjingScheduleID =  Scheduler.scheduleOnce(1, function( ... )
			if skeletonNode and not tolua.isnull(skeletonNode) then
				skeletonNode:removeFromParentAndCleanup()
			end
			local skeletonNode = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_kapairongjie")
			skeletonNode:setAnimation(0, ronjieAni, false)
			SpineUtil.addChildToSlot(fx_danchouchuxian_down,skeletonNode,"kapai1")
			skeletonNode:setEventListener(function(name,event)
				local eventName=event:getData():getName()
				if eventName == "appear" then
					local fx_fanzhuan1 = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_fanzhuan")
					fx_fanzhuan1:setAnimation(0, fanzhuanAniDown, false)
					SpineUtil.addChildToSlot(fx_danchouchuxian_down,fx_fanzhuan1,"kapai1")

					self.listCell:retain()
					self.listCell:displayObject():removeFromParent()
					SpineUtil.addChildToSlot(fx_fanzhuan1,self.listCell:displayObject(),"kapai_a1")
					self.listCell:getController("texiaoCtrl"):setSelectedIndex(1)
					self.listCell:getController("colorCtrl"):setSelectedIndex(color-2)
					self.listCell:release()

					local fx_fanzhuan = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_fanzhuan")
					fx_fanzhuan:setAnimation(0, fanzhuanAniUp, false)
					SpineUtil.addChildToSlot(fx_danchouchuxian_loop,fx_fanzhuan,"kapai1")

					fx_fanzhuan1:setEventListener(function(name,event)
						local eventName=event:getData():getName()
						print(1,"事件名称","stackName",name,eventName)
						if  eventName=="flip" then
							self.listCell:getController("texiaoCtrl"):setSelectedIndex(0)
							self.listCell:getController("colorCtrl"):setSelectedIndex(color-2)
						end
					end)

					fx_fanzhuan1:setCompleteListener(function(name)
						if name ==fanzhuanAniDown then
							self.listCell:retain()
							self.listCell:displayObject():removeFromParent()
							SpineUtil.addChildToSlot(fx_danchouchuxian_down,self.listCell:displayObject(),"kapai1")
							self.listCell:release()
							self.listCell:getController("texiaoCtrl"):setSelectedIndex(0)
							self.listCell:getController("colorCtrl"):setSelectedIndex(color-2)
							if self.listCell and self.listCell.scrigtObj  then
								local config =  DynamicConfigData.t_hero[self.resultList[1].code]
								self.listCell.scrigtObj:setData(config, false)
								self.listCell.scrigtObj:setFrameSkeVisible(true)
							end
							self:show_GetCardView()
						end
					end)
				end
			end)

			-- skeletonNode:setCompleteListener(function( name )
			-- 	if name ==ronjieAni then
			-- 		local fx_fanzhuan1 = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_fanzhuan")
			-- 		SpineUtil.addChildToSlot(fx_danchouchuxian_down,fx_fanzhuan1,"kapai1")
			-- 		local fx_fanzhuan = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_fanzhuan")
			-- 		SpineUtil.addChildToSlot(fx_danchouchuxian_loop,fx_fanzhuan,"kapai1")

			-- 		fx_fanzhuan:setAnimation(0, fanzhuanAniUp, false)
			-- 		fx_fanzhuan1:setAnimation(0, fanzhuanAniDown, false)

			-- 		self.listCell:retain()
			-- 		self.listCell:displayObject():removeFromParent()
			-- 		SpineUtil.addChildToSlot(fx_fanzhuan1,self.listCell:displayObject(),"kapai_a1")
			-- 		self.listCell:getController("texiaoCtrl"):setSelectedIndex(1)
			-- 		self.listCell:getController("colorCtrl"):setSelectedIndex(color-2)
			-- 		self.listCell:release()

			-- 		fx_fanzhuan1:setEventListener(function(name,event)
			-- 			local eventName=event:getData():getName()
			-- 			print(1,"事件名称","stackName",name,eventName)
			-- 			if  eventName=="flip" then
			-- 				self.listCell:retain()
			-- 				self.listCell:displayObject():removeFromParent()
			-- 				SpineUtil.addChildToSlot(fx_danchouchuxian_down,self.listCell:displayObject(),"kapai1")
			-- 				self.listCell:release()
			-- 				self.listCell:getController("texiaoCtrl"):setSelectedIndex(0)
			-- 				self.listCell:getController("colorCtrl"):setSelectedIndex(color-2)
			-- 				if self.listCell and self.listCell.scrigtObj  then
			-- 					self.listCell.scrigtObj:setFrameSkeVisible(true)
			-- 				end
			-- 			end
			-- 		end)

			-- 		fx_fanzhuan1:setCompleteListener(function(name)
			-- 			if name ==fanzhuanAniDown then
			-- 				self:show_GetCardView()
			-- 			end
			-- 		end)
		    --     end
			-- end)
		end)
    end
    
    --10秒清除
	self.changjingScheduleID =  Scheduler.scheduleOnce(6.3, function( ... )
    	func1()
    end)
    
    self.btn_pauseSpine:removeClickListener(11)
    self.btn_pauseSpine:addClickListener(function ( ... )
       SoundManager.stopSound(self.soundId)
       func1()
       self.btn_pauseSpine:removeClickListener(11)
    end,11)

end

function GetSuccess1View:showCards( ... )
	if self.resultList[1].type==GameDef.GameResType.Hero then
		local config =  DynamicConfigData.t_hero[self.resultList[1].code]
		if not config then
			return 
		end
		--测试数据
		-- self.resultList[1].isNew = true

		self.cardInfo:setFiveStarSkeFlag(true)
		self.cardInfo:setData(config)
		self.cardInfo:setLevel(1)
		self.cardInfo:setFrameSkeVisible(true)
		self.cardInfo:setIsNew(self.resultList[1].isNew)
		
		local obj = UIPackageManager.createGComponent("UIPublic", "CardItem")
		obj:setPivot(0.5,0.5,true)
		obj:retain()
		self.listCell = obj
		local cardCell = BindManager.bindCardCell(obj)
		self.listCell.scrigtObj = cardCell
		cardCell:setFiveStarSkeFlag(true)
		local config =  DynamicConfigData.t_hero[self.resultList[1].code]
		cardCell:setData(config, false)
		cardCell:setLevel(1)
		cardCell:setFrameSkeVisible(false)
		cardCell:setIsNew(self.resultList[1].isNew)
        self:showHeroCardFunc()
		self:play_spine()
	end
end



function GetSuccess1View:showHeroCardFunc( ... )
	--检测是否是4,5星 或者新英雄
	local data1 = {}
	local maxStar = 0
	local cardCode=0
	for i,v in ipairs(self._args.resultList) do
		if v.type == GameDef.GameResType.Hero then
			local flag,heroStar = self:checkCard(v)
			if flag then
				table.insert(data1,v)
			end
			
			--获取最高星级
			if maxStar < heroStar then
				maxStar = heroStar
				cardCode=v.code
			end
		end
	end

	self.curCardArr = data1
	--获得英雄的最高星数
	Dispatcher.dispatchEvent("event_getHighStarHero",maxStar,cardCode)
end

function GetSuccess1View:checkCard( card)
	local code = card.code
	local heroStar = DynamicConfigData.t_hero[code].heroStar
	-- local resInfo= DynamicConfigData.t_heroResource[heroStar]
	-- local color = resInfo.qualityRes
		if heroStar>4 or (heroStar==4 and card.isNew) then --5星或者4星新
			return true,heroStar
		end
	return false,heroStar
end

--通过监听弹出
function GetSuccess1View:show_GetCardView( ... )
    if tolua.isnull(self.view) then return end 
	SoundManager.stopSound(self.soundId2)
	if self.shilianScheduleID then
		Scheduler.unschedule(self.shilianScheduleID)
		self.shilianScheduleID = false
	end
    local onEnd = function( ... )
		if tolua.isnull(self.view) then return end 
		if self.shilianScheduleID then
			Scheduler.unschedule(self.shilianScheduleID)
			self.shilianScheduleID = false
		end
    	if #self.curCardArr>0 then
    		local heroStar = DynamicConfigData.t_hero[self.curCardArr[1].code].heroStar
    		if heroStar ==4 then
    			self.soundId2 = SoundManager.playSound(1016)
			elseif heroStar ==5 then
				self.soundId2 = SoundManager.playSound(1015)
			end
			local tempdata = TableUtil.DeepCopy(self.curCardArr[#self.curCardArr]) 
			ViewManager.open("GetHeroCardShowView",{data = tempdata},function( ... )
				self.view:getController("showCtrl"):setSelectedIndex(1)
				self.spineParent:displayObject():removeAllChildren()
			end)
			table.remove(self.curCardArr)
		else
			self.view:getController("showCtrl"):setSelectedIndex(1)
		end
    end
	
	self.shilianScheduleID = Scheduler.scheduleOnce(0.2, onEnd)
end

function GetSuccess1View:_initEvent( ... )
   self.againBtn:addClickListener(function( ... )
		if CardLibModel:isBagFull(1) then 
			local arg = {
				text = Desc.GetCard_Text19,
				type = "yes_no",
				onYes = function()  
					ModuleUtil.openModule(ModuleId.Hero.id, true)
				end,
				yesText = Desc.GetCard_Text20
			}
			Alert.show(arg)
			return 
		end
        if  self._args.xhType == 1 then --使用道具
        	local flag = ModelManager.PlayerModel:isCostEnough(self.cost, true)
	     	if not  flag then
	     		return
	     	end
			
	     	local num = PackModel:getItemsFromAllPackByCode(self.itemCode)
			local params = {}
	        params.id = self.id
			params.onSuccess = function (res )
			    local data = {}
			    data.resultList = res.resultList
			    if num-self.cost[1].amount>=self.cost[1].amount then --还是道具
			    	data.id = self.id
			    	data.xhType = 1
			    	data.itemCode = self.itemCode
		 		    data.cost = self.cost
				    if self._args.activityId then
				    	data.activityId = self._args.activityId
					end
					if self._args.lotteryIdList then
						data.lotteryIdList = self._args.lotteryIdList
					end
			    else --使用后道具不足  ID无关联 只能特殊化处理  新手和UP已经屏蔽 这里就不添加判断了
		            if self.id == 1 then --如果是普通召唤 普通召唤不能使用钻石
		            	data.id = 1
		                data.xhType = 1
		                data.itemCode = self.itemCode
		 		        data.cost = self.cost
		            elseif self.id == 3 then --如果是高级召唤 高级召唤可以使用钻石
		            	local cost2 = DynamicConfigData.t_heroLottery[8].cost --钻石消耗
		            	data.id = 8
		            	data.xhType = 2
		            	data.itemCode = cost2[1].code
						 data.cost = cost2
					elseif self.id == 45 then --仙魔
							local cost2 = DynamicConfigData.t_heroLottery[47].cost --钻石消耗
							data.id = 47
							data.xhType = 2
							data.itemCode = cost2[1].code
							 data.cost = cost2
					 elseif self.id > 1000 then --精英召唤
						printTable(1,"精英的数据",self._args)
						local id = 1001
						if self._args.activityId then
							id = self._args.lotteryIdList[3]
						end
		            	local cost2 = DynamicConfigData.t_heroLottery[id].cost 
		            	data.id = id
		            	data.xhType = 2
		            	data.itemCode = cost2[1].code
		 		        data.cost = cost2
		 		        if self._args.activityId then
		 		        	data.activityId = self._args.activityId
						 end
						if self._args.lotteryIdList then
							data.lotteryIdList = self._args.lotteryIdList
						end
		            end
			    end
				Dispatcher.dispatchEvent(EventType.getcard_update_success,data)
			end
			if CardLibModel:isBagFull(1) then 
				RollTips.show(Desc.getCard_bagFull)
				return 
			end
			if self._args.activityId then
				params.activityId = self._args.activityId
				RPCReq.HeroLottery_ActivityDraw(params, params.onSuccess)
			else
				RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
			end 
			
		elseif self._args.xhType == 2 then --只能消耗钻石
			if not ModelManager.PlayerModel:isCostEnough(self.cost, true) then
   	    		return
			end
			
			local info = {
				text=string.format(Desc.getCard_6,self.cost[1].amount,1000,1),
				type="yes_no",
			}
			info.onYes = function()
				local params = {}
				params.id = self.id
				params.onSuccess = function (res )
					local data = {}
					data.resultList = res.resultList
					data.itemCode = self.itemCode
					data.id = self.id
					data.xhType = 2
					data.cost = self.cost
					if self._args.activityId then
						data.activityId = self._args.activityId
					end
					if self._args.lotteryIdList then
						data.lotteryIdList = self._args.lotteryIdList
					end
					Dispatcher.dispatchEvent(EventType.getcard_update_success,data)
				end
				if CardLibModel:isBagFull(1) then 
					RollTips.show(Desc.getCard_bagFull)
					return 
				end
				if self._args.activityId then
					params.activityId = self._args.activityId
					RPCReq.HeroLottery_ActivityDraw(params, params.onSuccess)
				else
					RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
				end 
			end
			Alert.show(info);
		elseif self._args.xhType == 3 then --消耗友情币
			if not ModelManager.PlayerModel:isCostEnough(self.cost, true) then
   	    		return
   	    	end
 			local params = {}
	        params.id = self.id
	 		params.onSuccess = function (res )
	 		    local data = {}
	 		    data.resultList = res.resultList
	 		    data.itemCode = self.cost[1].code
	 		    data.id = self.id
	 		    data.xhType = 3
	 		    data.cost = self.cost
	 			Dispatcher.dispatchEvent(EventType.getcard_update_success,data)
	 		end
			if CardLibModel:isBagFull(1) then 
				RollTips.show(Desc.getCard_bagFull)
				return 
			end
			RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		end
   end)

   self.confirmBtn:addClickListener(function( ... )
   	  if self._args.specialType==1 then
   	  	ViewManager.close("GetAixinCardsView")
   	  	-- ViewManager.close("GetSuccess1View")
   	  	self:closeView()
   	  else
   	  	-- ViewManager.close("GetSuccess1View")
   	  	self:closeView()
   	  end
   end)
end

--initUI执行之前
function GetSuccess1View:_enter( ... )

end

--页面退出时执行
function GetSuccess1View:_exit( ... )
	print(1,"GetSuccess1View _exit")
	if self.shilianScheduleID then
		Scheduler.unschedule(self.shilianScheduleID)
		self.shilianScheduleID = false
	end

end

function GetSuccess1View:closeView( ... )
	Super.closeView(self)
	if self.listCell then
		self.listCell:release()
	end
end

return GetSuccess1View