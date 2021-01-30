--连抽获得成功界面2
--added by xhd
local GetSuccess2View,Super = class("GetSuccess2View",Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function GetSuccess2View:ctor( args )
    self._packName = "GetCards"
	self._compName = "GetSuccess2View"
	self._rootDepth = LayerDepth.Window

	self.list = false
	self.againBtn = false
	self.confirmBtn = false
	self.resultList = false
	self.itemCode = false
	self.id = false
	self.spineNode = false
	self.kapai_zhanshiCb = false

	self.cost = false
    self.costItemObj =false

	self.listCellArr = {}
    self.curCardArr = {}
	self.shichoukapai_chuxianweizhi = false
	self.fx_shichouchuxian_loop = false
    self.skeletonNodeArr = {}
    self.skeletonNodeArr2 = {}
    self.winDowTime = 30
    self.hadDoneSpineArr = {}
    self.canClickFlag = false
    self.changjingScheduleID = false
    self.soundId = false
	self.soundId2 = false
	self.curActionColor = 3
	-- --测试数据
	-- self._args.resultList = {
    --    [1] = {
    --       amount=1,
    --       resultType=0,
    --       code=35009,
    --       type = 4,
    --       status = 0,
    --       isNew = true,
    --    },
    --    [2] = {
    --       amount=1,
    --       resultType=0,
    --       code=44003,
    --       type = 4,
    --       status = 0,
    --    },
    --    [3] = {
    --       amount=1,
    --       resultType=0,
    --       code=44003,
    --       type = 4,
    --       status = 0,
    --    },
    --    [4] = {
    --       amount=1,
    --       resultType=0,
    --       code=33001,
    --       type = 4,
    --       status = 0,
    --    },
    --    [5] = {
    --       amount=1,
    --       resultType=0,
    --       code=44003,
    --       type = 4,
    --       status = 0,
    --    },
    --    [6] = {
    --       amount=1,
    --       resultType=0,
    --       code=44003,
    --       type = 4,
    --       status = 0,
    --    },
    --    [7] = {
    --       amount=1,
    --       resultType=0,
    --       code=44003,
    --       type = 4,
    --       status = 0,
    --    },
    --    [8] = {
    --       amount=1,
    --       resultType=0,
    --       code=33001,
    --       type = 4,
    --       status = 0,
    --    },
    --    [9] = {
    --       amount=1,
    --       resultType=0,
    --       code=44003,
    --       type = 4,
    --       status = 0,
    --    },
    --    [10] = {
    --       amount=1,
    --       resultType=0,
    --       code=33001,
    --       type = 4,
    --       status = 0,
    --    },
    -- }
    -- self._args.itemCode = 10000005
    -- self._args.id = 9
    -- self._args.cost = {{type=3,code= 10000004,amount= 1,},}
end

function GetSuccess2View:_initUI( ... )
    self.list = self.view:getChildAutoType("list")
    self.againBtn = self.view:getChildAutoType("againBtn")
    self.confirmBtn = self.view:getChildAutoType("confirmBtn")

    self.costItem = self.view:getChildAutoType("costItem")
    self.costItemObj = BindManager.bindCostItem(self.costItem)

    self.fanzhuanBtn = self.view:getChildAutoType("fanzhuanBtn")
    self.fanzhuanBtn:setVisible(false)
	self.btn_pauseSpine = self.view:getChildAutoType("btn_pauseSpine")
	self.spineParent = self.view:getChildAutoType("spineParent")
	
	self.gxhdNode = self.view:getChildAutoType("txt_title")
	local efx_zitilizi =  SpineUtil.createSpineObj(self.gxhdNode, vertex2(180,50), "animation", "Spine/ui/chouka", "efx_zitilizi", "efx_zitilizi",true)
	self:setBg("bg_heroInfo3.jpg")
	if ModelManager.PlayerModel.TipsNotifyId then
		return
	end
    self:updateWindow()
    
end

function GetSuccess2View:getcard_update_success(_,data )
	self._args = data
	if  tolua.isnull(self.view) then
		return
	end
	if ModelManager.PlayerModel.TipsNotifyId then
		return
	end
	printTable(1,"数据刷新",self._args)
	self:updateWindow()
end

function GetSuccess2View:tips_notify_close( ... )
	-- body
	print(1,"tips_notify_close")
	self:updateWindow()
end

function GetSuccess2View:updateWindow()
	self.view:getController("showCtrl"):setSelectedIndex(0)
    --卡牌位置随机下
    self.resultList = {}
    self.resultList = TableUtil.randomSortArray(self._args.resultList)
    self.itemCode = self._args.itemCode
    self.id = self._args.id
    self.cost = self._args.cost
    self.list:setVisible(false)
	self.costItemObj:setDarkBg(true)
	self.costItemObj:setUseMoneyItem(false)
    self.costItemObj:setData(self.cost[1].type, self.cost[1].code, self.cost[1].amount, true,false,false)
    self:showCards()
end

function GetSuccess2View:showCards( ... )
	self.list:setItemRenderer(function(index,obj)
		local cardInfo = obj:getChildAutoType("cardInfo")
		local cardCell = BindManager.bindCardCell(cardInfo)
		local config =  DynamicConfigData.t_hero[self.resultList[index+1].code]
		if not config then
			return 
		end
		cardCell:setFiveStarSkeFlag(true)
		cardCell:setData(config, false)
		cardCell:setLevel(1)
		cardCell:setFrameSkeVisible(true)
		cardCell:setIsNew(self.resultList[index+1].isNew)
	end
	)
	self.list:setData(self.resultList)
	for i=1,#self.resultList do
		if not self.listCellArr[i] then
			local obj = UIPackageManager.createGComponent("UIPublic", "CardItem")
			obj:setPivot(0.5,0.5,true)
			obj:retain()
			self.listCellArr[i] = obj
		end
        self.listCellArr[i]:setVisible(true)
		local cardCell = BindManager.bindCardCell(self.listCellArr[i])
		self.listCellArr[i].scrigtObj = cardCell
		cardCell:setFiveStarSkeFlag(true)
		local config =  DynamicConfigData.t_hero[self.resultList[i].code]
		cardCell:setData(config, false)
		cardCell:setLevel(1)
		cardCell:setFrameSkeVisible(false)
		cardCell:setIsNew(self.resultList[i].isNew)
	end
    self:play_spine()
end

function GetSuccess2View:play_spine( ... )

	local flag = GetCardsModel:checkHadSSR(self.resultList)
	local  guangxian = "animation_zi"
	local  guangxian2 = "chuxian_sr" --紫光
	if flag then
		guangxian = "animation"
		guangxian2 = "chuxian_ssr" 
	end

	
	local chouka_changjing1 =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), "animation2", "Spine/ui/chouka2", "cj_chouka", "cj_chouka",false)
    local chouka_changjing2 =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), "animation", "Spine/ui/chouka2", "cj_chouka", "cj_chouka",false)
    self.soundId = SoundManager.playSound(1014,false)
    local sprite = display.newSprite("Spine/ui/chouka/image/chouka_changjing.png", 0, 0)
    chouka_changjing2 = SpineUtil.addChildToSlot(chouka_changjing1,sprite,"chouka_changjing")
	local chouka_changjing =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), guangxian, "Spine/ui/chouka2", "fx_choukachangjing", "fx_choukachangjing",false)

	local doNextChuxian = function( ... )
		self.curActionColor = 3
		local chouka_changjing =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), guangxian2, "Spine/ui/chouka2", "fx_choukachangjing", "fx_choukachangjing",false)
		local fx_shichouchuxian_down =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), "fx_shichouchuxian_down", "Spine/ui/chouka2", "fx_chuxianweizhi", "fx_chuxianweizhi",false)
		local fx_shichouchuxian_up =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), "fx_shichouchuxian_up", "Spine/ui/chouka2", "fx_chuxianweizhi", "fx_chuxianweizhi",false)
		local fx_shichouchuxian_loop =  SpineUtil.createSpineObj(self.spineParent, vertex2(0,0), "fx_shichouchuxian_loop", "Spine/ui/chouka2", "fx_chuxianweizhi", "fx_chuxianweizhi",false)
		self.shichoukapai_chuxianweizhi = fx_shichouchuxian_down
		self.fx_shichouchuxian_loop = fx_shichouchuxian_loop
        self.skeletonNodeArr = {}
        --插入10张牌
		for i=1,#self.resultList do
			self.hadDoneSpineArr[i] = false

			local color = GetCardsModel:getColorByCode( self.resultList[i].code )
			local ronjieAni = "fx_rongjie_sr_up"
			if color == 5 then
				ronjieAni = "fx_rongjie_ssr_up"
			else
				ronjieAni = "fx_rongjie_sr_up"
			end

			local fx_kapaiAni ="fx_r_b"
			if color == 3 then
				fx_kapaiAni ="fx_r_b"
			elseif color == 4 then
				fx_kapaiAni ="fx_sr_b"
			elseif color ==5 then
				fx_kapaiAni ="fx_ssr_b"
			end

			SpineUtil.addChildToSlot(fx_shichouchuxian_down,self.listCellArr[i]:displayObject(),"kapai"..i)
		    self.listCellArr[i]:getController("texiaoCtrl"):setSelectedIndex(1)
			self.listCellArr[i]:getController("colorCtrl"):setSelectedIndex(color-2)			
			
			local skeletonNode = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_kapairongjie")
			skeletonNode:setAnimation(0, "kapai_loop", true)
			SpineUtil.addChildToSlot(fx_shichouchuxian_down,skeletonNode,"kapai"..i)
			
			self.listCellArr[i].scheOneId =  Scheduler.scheduleOnce(1, function( ... )
				if skeletonNode and not tolua.isnull(skeletonNode) then
					skeletonNode:removeFromParentAndCleanup()
				end
				local skeletonNode = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_kapairongjie")
				skeletonNode:setAnimation(0, ronjieAni, false)
				SpineUtil.addChildToSlot(fx_shichouchuxian_down,skeletonNode,"kapai"..i)

				skeletonNode:setEventListener(function(name,event)
					local eventName=event:getData():getName()
					if eventName == "appear" then
						local fx_kapai = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_kapai")
						fx_kapai:setAnimation(0, fx_kapaiAni, true)
						SpineUtil.addChildToSlot(fx_shichouchuxian_down,fx_kapai,"kapai"..i)
						self.listCellArr[i].fx_kapai = fx_kapai
						if color == 3 then
							fx_kapai:setVisible(false)
						else
							fx_kapai:setVisible(true)
						end
						if not self.fanzhuanBtn:isVisible() then
							self.canClickFlag = true --允许点击
        	                self.fanzhuanBtn:setVisible(true)
						end
					end
				end)

				-- skeletonNode:setCompleteListener(function( name )
				-- 	if name ==ronjieAni then
				-- 		local fx_kapai = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_kapai")
				-- 		fx_kapai:setAnimation(0, fx_kapaiAni, true)
				-- 		SpineUtil.addChildToSlot(fx_shichouchuxian_down,fx_kapai,"kapai"..i)
				-- 		self.listCellArr[i].fx_kapai = fx_kapai
				-- 		if color == 3 then
				-- 			fx_kapai:setVisible(false)
				-- 		else
				-- 			fx_kapai:setVisible(true)
				-- 		end
				-- 		if not self.fanzhuanBtn:isVisible() then
				-- 			self.canClickFlag = true --允许点击
        	    --             self.fanzhuanBtn:setVisible(true)
				-- 		end
				-- 	end
				-- end)

			end)
            
		end
		
        -- fx_shichouchuxian_down:setCompleteListener(function( name )
        -- 	self.canClickFlag = true --允许点击
        -- 	self.fanzhuanBtn:setVisible(true)
		-- end)
		
        local fanzhuanFunc = function( ... )
            --一开始 就要隐藏一键翻牌
            self.fanzhuanBtn:setVisible(false)
            self.canClickFlag = false
            -- print(1,"一键状态位修改",self.canClickFlag)
            --如果没有卡牌能翻 直接结束
            local flag = self:checkEndFunc()
            if not flag then
            	print(1,"一键翻牌后进去")
            	self:show_GetCardView()
            end
            
	    end

        self.fanzhuanBtn:removeClickListener(22)
        self.fanzhuanBtn:addClickListener(function( ... )
        	if self.canClickFlag then
        		fanzhuanFunc()
        	end
        end,22)
    end
   
    local beginFunc = function ( ... )
        if self.changjingScheduleID then
        	Scheduler.unschedule(self.changjingScheduleID)
        	self.changjingScheduleID = false
		end
		if tolua.isnull(self.view) then
			return
		end

        self:checkHeroData() --数据准备
    	self.view:getController("showCtrl"):setSelectedIndex(2)
        self.spineParent:displayObject():removeAllChildren()
        doNextChuxian()
    end

     --10秒清除
    if self.changjingScheduleID then
    	Scheduler.unschedule(self.changjingScheduleID)
    	self.changjingScheduleID = false
    end
    self.changjingScheduleID =  Scheduler.scheduleOnce(6.3, function( ... )
    	beginFunc()
    end)

    self.btn_pauseSpine:removeClickListener(11)
    self.btn_pauseSpine:addClickListener(function ( ... )
    	SoundManager.stopSound(self.soundId)
        beginFunc()
        self.btn_pauseSpine:removeClickListener(11)
    end,11)
end

--英雄页面点击后事件推送
function GetSuccess2View:show_GetCardView( ... )
	if tolua.isnull(self.view) then
         return
	end
	SoundManager.stopSound(self.soundId2)
	-- print(1,"show_GetCardView",self.canClickFlag)
	if self.canClickFlag then
		return
	end
	print(1,"准备开始递归")
	if self.kapai_zhanshiCb then
		Scheduler.unschedule(self.kapai_zhanshiCb)
        self.kapai_zhanshiCb = false
	end
	self:checkEndFunc()
	--寻找下一阶段
	local flag = false
	local last3ColorIndex = 0
	for i=1,#self.resultList do
		if (not self.hadDoneSpineArr[i])  and self.curActionColor ==3 and self.curActionColor == GetCardsModel:getColorByCode( self.resultList[i].code) then
			flag = true
			last3ColorIndex = i
		end
	end
	if not flag then
		self.curActionColor = 4
	end
	
	if self.curActionColor == 4 then
		local flag2 = false
		for i=1,#self.resultList do
			if (not self.hadDoneSpineArr[i])  and self.curActionColor ==4 and self.curActionColor == GetCardsModel:getColorByCode( self.resultList[i].code) then
				flag2 = true
				break
			end
		end
		if not flag2 then
			self.curActionColor = 5
		end
	end

	print(1,"self.curActionColor",self.curActionColor)
	
	for i=1,#self.resultList do
		if not self.hadDoneSpineArr[i] and self.curActionColor == GetCardsModel:getColorByCode( self.resultList[i].code)  then
			print(1,"找到开始位置")
	    	local beginAction = function ( ... )
				if tolua.isnull(self.view) then return end
	    	    self:checkNowShowIsNew(self.curCardArr[i])
				self.hadDoneSpineArr[i] = true
				
				if self.listCellArr[i].fx_kapai then
					self.listCellArr[i].fx_kapai:removeFromParent()
					self.listCellArr[i].fx_kapai = nil
				end

				local color = GetCardsModel:getColorByCode( self.resultList[i].code )

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

				local fx_fanzhuan1 = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_fanzhuan")
				fx_fanzhuan1:setAnimation(0, fanzhuanAniDown, false)
				SpineUtil.addChildToSlot(self.shichoukapai_chuxianweizhi,fx_fanzhuan1,"kapai"..i)

				local fx_fanzhuan = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_fanzhuan")
				fx_fanzhuan:setAnimation(0, fanzhuanAniUp, false)
				SpineUtil.addChildToSlot(self.fx_shichouchuxian_loop,fx_fanzhuan,"kapai"..i)


				self.listCellArr[i]:retain() 
				self.listCellArr[i]:displayObject():removeFromParent()
				SpineUtil.addChildToSlot(fx_fanzhuan1,self.listCellArr[i]:displayObject(),"kapai_a1")
				self.listCellArr[i]:getController("texiaoCtrl"):setSelectedIndex(1)
				self.listCellArr[i]:getController("colorCtrl"):setSelectedIndex(color-2)
				self.listCellArr[i]:release()
 
				fx_fanzhuan1:setEventListener(function(name,event)
					local eventName=event:getData():getName()
					print(1,"事件名称","stackName",name,eventName)
					if  eventName=="flip" then
						self.listCellArr[i]:getController("texiaoCtrl"):setSelectedIndex(0)
						self.listCellArr[i]:getController("colorCtrl"):setSelectedIndex(color-2)
					end
				end)

				fx_fanzhuan1:setCompleteListener(function(name)
					if name ==fanzhuanAniDown then
						self.listCellArr[i]:retain()
						self.listCellArr[i]:displayObject():removeFromParent()
						SpineUtil.addChildToSlot(self.shichoukapai_chuxianweizhi,self.listCellArr[i]:displayObject(),"kapai"..i)
						self.listCellArr[i]:release()
						self.listCellArr[i]:getController("texiaoCtrl"):setSelectedIndex(0)
						self.listCellArr[i]:getController("colorCtrl"):setSelectedIndex(color-2)
						if self.listCellArr[i] and self.listCellArr[i].scrigtObj  then
							local config =  DynamicConfigData.t_hero[self.resultList[i].code]
							self.listCellArr[i].scrigtObj:setData(config, false)
							self.listCellArr[i].scrigtObj:setFrameSkeVisible(true)
						end
						
						if self.curCardArr[i] then
							local heroStar = DynamicConfigData.t_hero[self.curCardArr[i].code].heroStar
							if heroStar ==4 then
								self.soundId2 = SoundManager.playSound(1016)
							elseif heroStar ==5 then
								self.soundId2 = SoundManager.playSound(1015)
							end
							ViewManager.open("GetHeroCardShowView",{data = self.curCardArr[i],speFlag= false})
						end

						if self.kapai_zhanshiCb then
							Scheduler.unschedule(self.kapai_zhanshiCb)
							self.kapai_zhanshiCb = false
						end
						if self.curCardArr[i] then
							self.kapai_zhanshiCb = Scheduler.scheduleOnce(self.winDowTime, function( ... )
								SoundManager.stopSound(self.soundId2)
								ViewManager.close("GetHeroCardShowView")
								--检测是否最后一个
								local flag = self:checkEndFunc()
								if not flag then
									--第二版 修改递归
									if self.curActionColor==3  then
										if last3ColorIndex ==i then
											self:show_GetCardView()
										end
									else
										self:show_GetCardView()
									end
								end
							end)
						else
							local flag = self:checkEndFunc()
							if not flag then
								print(1,"不是最后一个继续递归")
								--第二版 修改递归
								if self.curActionColor==3  then
									if last3ColorIndex ==i then
										self:show_GetCardView()
									end
								else
									self:show_GetCardView()
								end
							end
						end
					end
				end)
			end
			beginAction()
			if  self.curActionColor> 3 then
			    break;
			end
		end
	end
    
end

--单独翻盘一只
function GetSuccess2View:doFanPaiFunc(i)
	if self.hadDoneSpineArr[i] then --已经翻盘过 不能再翻
		return
	end
	self:checkNowShowIsNew(self.curCardArr[i])
	self.hadDoneSpineArr[i] = true
	local color = GetCardsModel:getColorByCode( self.resultList[i].code )
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
	
	if self.listCellArr[i].fx_kapai then
		self.listCellArr[i].fx_kapai:removeFromParent()
		self.listCellArr[i].fx_kapai = nil
	end
	
	--1
	local fx_fanzhuan1 = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_fanzhuan")
	fx_fanzhuan1:setAnimation(0, fanzhuanAniDown, false)
	SpineUtil.addChildToSlot(self.shichoukapai_chuxianweizhi,fx_fanzhuan1,"kapai"..i,2)

	
	self.listCellArr[i]:retain()
	self.listCellArr[i]:displayObject():removeFromParent()
	SpineUtil.addChildToSlot(fx_fanzhuan1,self.listCellArr[i]:displayObject(),"kapai_a1")
	self.listCellArr[i]:getController("texiaoCtrl"):setSelectedIndex(1)
	self.listCellArr[i]:getController("colorCtrl"):setSelectedIndex(color-2)
	self.listCellArr[i]:release()

    -- -- 2
	local fx_fanzhuan = SpineMnange.createSpineByName("Spine/ui/chouka2/fx_fanzhuan")
	fx_fanzhuan:setAnimation(0, fanzhuanAniUp, false)
	SpineUtil.addChildToSlot(self.fx_shichouchuxian_loop,fx_fanzhuan,"kapai"..i,3)



	if self.curCardArr[i] then
		print(1,"单点状态位修改！！！")
		self.canClickFlag = false
	end

	fx_fanzhuan1:setEventListener(function(name,event)
		local eventName=event:getData():getName()
		print(1,"事件名称","stackName",name,eventName)
		if  eventName=="flip" then
			self.listCellArr[i]:retain()
			self.listCellArr[i]:displayObject():removeFromParent()
			SpineUtil.addChildToSlot(self.shichoukapai_chuxianweizhi,self.listCellArr[i]:displayObject(),"kapai"..i)
			self.listCellArr[i]:release()
			self.listCellArr[i]:getController("texiaoCtrl"):setSelectedIndex(0)
			self.listCellArr[i]:getController("colorCtrl"):setSelectedIndex(color-2)
			if self.listCellArr[i] and self.listCellArr[i].scrigtObj  then
				local config =  DynamicConfigData.t_hero[self.resultList[i].code]
				self.listCellArr[i].scrigtObj:setData(config, false)
				self.listCellArr[i].scrigtObj:setFrameSkeVisible(true)
			end
		end
	end)
	
	fx_fanzhuan1:setCompleteListener(function(name)
		if name ==fanzhuanAniDown then
			if self.curCardArr[i] then
				local heroStar = DynamicConfigData.t_hero[self.curCardArr[i].code].heroStar
				if heroStar ==4 then
					self.soundId2 = SoundManager.playSound(1016)
				elseif heroStar ==5 then
					self.soundId2 = SoundManager.playSound(1015)
				end
				ViewManager.open("GetHeroCardShowView",{data = self.curCardArr[i]},function( ... )
					print(1,"英雄展示状态位修改",self.canClickFlag)
					self.canClickFlag = true
					self:checkEndFunc()
				end)
			else
				self:checkEndFunc()
			end	
		end
	end)
end

--重复卡牌 服务器只能标记一张是新的
function GetSuccess2View:checkNowShowIsNew(data)
	if not data then
		return
	end
	local count = 0
	local codeid = data.code
	local dataIndexArr = {}
	local isNewCode = false
	for i,v in ipairs(self.resultList) do
		if v.code == codeid and  self.curCardArr[i] then --是需要暂时英雄
			if v.isNew then
				isNewCode = true
			end
			count = count + 1
			table.insert(dataIndexArr,i)
		end
	end
	if isNewCode and count>1 then --是新的才走

		local flag = false
		for i,v in ipairs(dataIndexArr) do
			if self.hadDoneSpineArr[v] then
				flag = true
			end
		end
		--还没有翻过该英雄
		if not flag then
			for i,v in ipairs(dataIndexArr) do
				self.curCardArr[v].isNew = false
			end
			data.isNew = true
		end
	end
end

--检测是否应该结束
function GetSuccess2View:checkEndFunc( ... )
	if tolua.isnull(self.view) then return  end
	local flag = true --true标记最后一张
	for i=1,#self.hadDoneSpineArr do
		if not self.hadDoneSpineArr[i] then --存在没翻的
			flag = false
			break
		end
	end

	--点击的是最后一个了
	if  flag then
		print(1,"最后一个")
		self.view:getController("showCtrl"):setSelectedIndex(1)
		self.list:setVisible(true)
		for k,v in pairs(self.listCellArr) do
			v:setVisible(false)
		end
	end
	return flag
end

function GetSuccess2View:checkHeroData( ... )
	--检测是否是4,5星 或者新英雄
	local data1 = {}
	local maxStar = 0
	local cardCode=0
	for i,v in ipairs(self.resultList) do
		data1[i] = false
		if v.type == GameDef.GameResType.Hero then
			local flag,heroStar = self:checkCard(v)
			if flag then
				data1[i] = v
			end
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

function GetSuccess2View:checkCard( card)
	local code = card.code
	local heroStar = DynamicConfigData.t_hero[code].heroStar
	if heroStar>4 or (heroStar==4 and card.isNew) then --5星或者4星新
		return true,heroStar
	end
	
	return false,heroStar
end


function GetSuccess2View:_initEvent( ... )
   
   self.againBtn:addClickListener(function( ... )
		if CardLibModel:isBagFull(10) then 
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
			    else  --使用后道具不足  ID无关联 只能特殊化处理  新手和UP已经屏蔽 这里就不添加判断了
		            if self.id == 2 then --如果是普通召唤 普通召唤不能使用钻石
		            	data.id = 2
		                data.xhType = 1
		                data.itemCode = self.itemCode
		 		        data.cost = self.cost
		            elseif self.id == 4 then --如果是高级召唤 高级召唤可以使用钻石
		            	local cost2 = DynamicConfigData.t_heroLottery[9].cost --钻石消耗
		            	data.id = 9
		            	data.xhType = 2
		            	data.itemCode = cost2[1].code
						 data.cost = cost2
					elseif self.id == 46 then --如果是异界十连 可以使用钻石
							local cost2 = DynamicConfigData.t_heroLottery[48].cost --钻石消耗
							data.id = 48
							data.xhType = 2
							data.itemCode = cost2[1].code
							 data.cost = cost2
					elseif self.id >1000 then --精英召唤
						printTable(1,"精英的数据",self._args)
						local id = 1002
						if self._args.activityId then
							id = self._args.lotteryIdList[4]
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
				printTable(1,"data=",data)
				Dispatcher.dispatchEvent(EventType.getcard_update_success,data)
			end
			if CardLibModel:isBagFull(10) then 
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
				text=string.format(Desc.getCard_6,self.cost[1].amount,1000,10),
				type="yes_no",
			}
			info.onYes = function()
				local params = {}
				params.id = self.id
				params.onSuccess = function (res )
					--printTable(1,res)
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
				if CardLibModel:isBagFull(10) then 
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
	 		    -- printTable(1,"友情抽卡",data)
	 			Dispatcher.dispatchEvent(EventType.getcard_update_success,data)
	 		end
			if CardLibModel:isBagFull(10) then 
				RollTips.show(Desc.getCard_bagFull)
				return 
			end
			RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
   	    end
   end)

   self.confirmBtn:addClickListener(function( ... )
   	  	-- ViewManager.close("GetSuccess2View")
   	  	self:closeView()
   end)

   for i=1,10 do
   	  self.view:getChildAutoType("btn_pai"..i):addClickListener(function( ... )
   	  	  if self.canClickFlag then
   	  	  	 self:doFanPaiFunc(i)
   	  	  end
   	  end)
   end
end

--initUI执行之前
function GetSuccess2View:_enter( ... )

end

--页面退出时执行
function GetSuccess2View:_exit( ... )
	print(1,"GetSuccess2View _exit")
	if self.kapai_zhanshiCb then
		Scheduler.unschedule(self.kapai_zhanshiCb)
        self.kapai_zhanshiCb = false
	end
	
	--场景过度
	if self.changjingScheduleID then
    	Scheduler.unschedule(self.changjingScheduleID)
    	self.changjingScheduleID = false
	end
end

function GetSuccess2View:closeView( ... )
	Super.closeView(self)
	for k,v in pairs(self.listCellArr) do
		if v.scheOneId then
			Scheduler.unschedule(v.scheOneId)
        	v.scheOneId = false
		end
		v:release()
	end
end

return GetSuccess2View