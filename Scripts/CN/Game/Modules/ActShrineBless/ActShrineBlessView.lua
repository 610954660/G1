-- added by xhd
-- 神社祈福活动

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local ActShrineBlessView = class("ActShrineBlessView",Window)
local lastInterTime = 0.02
local maxInterTime = 0.5
function ActShrineBlessView:ctor()
	self._packName 	= "ActShrineBless"
	self._compName 	= "ActShrineBlessView"

	self.__timerId = false
	self.prayDropConfig = false
	self.serverData = false
	self.actType = GameDef.ActivityType.ShrinePray
	self.timeCount = 0
	self.scheduler = {}
	self.scheduler2 = {}
	self.cellArr = {}
	self.nextClickFlag =false
end

function ActShrineBlessView:updateItemCount(  )
	local config =ActShrineBlessModel:getPrayDrawConfig()
	local cost = config.costItem
	local url = ItemConfiger.getItemIconByCode(cost[1].code)
	local hadItemNum = PackModel:getItemsFromAllPackByCode(cost[1].code)
	self.itemicon:setURL(url)
	self.itemnum:setText(hadItemNum)

end

function ActShrineBlessView:_initUI()
    --已经存在大奖选择器
	self.hadSelCtrl = self.view:getController("hadSelCtrl")

	self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
	self.btn_rule  = self.view:getChildAutoType("btn_rule")	
	self.awardList = self.view:getChildAutoType("awardList")
	-- self.btn_dan = self.view:getChildAutoType("btn_dan")
	-- self.costItem_dan = self.btn_dan:getChildAutoType("costItem")
	-- self.costItemObj1 = BindManager.bindCostItem(self.costItem_dan)
	-- self.costItemObj1:setUseMoneyItem(true);

	self.itemCell = self.view:getChildAutoType("itemCell")
	self.itemcellObj = BindManager.bindItemCell(self.itemCell)
	self.jiaBtn = self.view:getChildAutoType("jiaBtn")
	self.changeBtn = self.view:getChildAutoType("changeBtn")
	self.itemicon = self.view:getChildAutoType("itemicon")
	self.itemnum = self.view:getChildAutoType("itemnum")
	self.btn_help2 = self.view:getChildAutoType("btn_help2")

	self.btn_add = self.view:getChildAutoType("btn_add")
	self.btn_add2 = self.view:getChildAutoType("btn_add2")
	self.btn_jlyl = self.view:getChildAutoType("btn_jlyl")
	self.layerLab = self.view:getChildAutoType("layerLab")
	self.btn_begin = self.view:getChildAutoType("btn_begin")
	
    --跳转来源
	self.btn_add:addClickListener(function( ... )
		local config =ActShrineBlessModel:getPrayDrawConfig(1)
		local cost = config.costItem
		local itemInfo = ItemConfiger.getInfoByCode(cost[1].code)
		local itemData = ItemsUtil.createItemData({data = {type = itemInfo.type, code = itemInfo.code, amount = 1}})
		ViewManager.open("ItemTips", {codeType = itemInfo.type, id = itemInfo.code, data = itemData})
	end)

	self.btn_add2:addClickListener(function( ... )
		local config =ActShrineBlessModel:getPrayDrawConfig(1)
		local cost = config.costItem
		local itemInfo = ItemConfiger.getInfoByCode(cost[1].code)
		local itemData = ItemsUtil.createItemData({data = {type = itemInfo.type, code = itemInfo.code, amount = 1}})
		ViewManager.open("ItemTips", {codeType = itemInfo.type, id = itemInfo.code, data = itemData})
	end)

	-- self.awardList:setVirtual()
	self.awardList:setItemRenderer(function(idx,obj)
		self.cellArr[idx+1] = obj
		local spineParent = obj:getChildAutoType("spineParent")
		local mulVal = obj:getChildAutoType("mulVal/mulVal")
		local tempBg = obj:getChildAutoType("tempBg")
		local btn_open = obj:getChildAutoType("btn_open")
		tempBg:setVisible(false)
		obj:getTransition("t2"):play(function( ... )
		end)
		local curConfig = self.prayDropConfig[idx+1]
		local typeCtrl = obj:getController("typeCtrl")
		spineParent:displayObject():removeAllChildren()
		btn_open:removeClickListener(88)
		if self.serverData.wish and self.serverData.isStartDraw then --选了许愿道具并且开始了寻宝
			local flag,data = ActShrineBlessModel:checkGeziReward(curConfig.gridId)			
			if flag then --该道具已经抽奖过 (大奖/小奖)
				--有格子 那么需要找格子存在的道具
				if tonumber(data.id)<100000 then
					curConfig = ActShrineBlessModel:findGeziReward(data.id)
					-- typeCtrl:setSelectedIndex(1)
				else
					curConfig = ActShrineBlessModel:getConfigChooseById(data.id)
					-- typeCtrl:setSelectedIndex(4)
				end	
				btn_open:setVisible(false)
				typeCtrl:setSelectedIndex(1)
				local reward 	= curConfig.reward[1]
				local itemCell  = obj:getChildAutoType("itemCell")
				local itemCellObj 	= BindManager.bindItemCell(itemCell)
				itemCellObj:setData(reward.code, reward.amount, reward.type)
				if curConfig.id >=100000 then --如果是许愿的大奖
					local spine = SpineUtil.createSpineObj(spineParent, vertex2(0,0), "pingzhikuang_hong", "Spine/ui/item", "daojupinzhikuang", "daojupinzhikuang",true)
					spine:setScale(0.6)
				end
				if data.multiple>1 then
					mulVal:setText(data.multiple)
				else
					mulVal:setText(0)
				end
			else
				--检测上下格子 换不同的背景图
				typeCtrl:setSelectedIndex(2)
				local downData = self.prayDropConfig[idx+1+5]
				if downData then
					local flag = ActShrineBlessModel:checkGeziReward(downData.gridId)
					if flag then
						typeCtrl:setSelectedIndex(3)
					end		
				end
				btn_open:setVisible(true)
				btn_open:addClickListener(function( ... )
					local config = ActShrineBlessModel:getPrayDrawConfig(  )
					local costItem = config.costItem[1]
					local itemInfo = ItemConfiger.getInfoByCode(costItem.code)
					if (not PlayerModel:checkCostEnough(costItem, false)) then
						RollTips.show(itemInfo.name..Desc.activity_txt33)
						return;
					else
                        --请求协议的回调
						local callfunc = function()
							for i=1,#self.cellArr do
								self.cellArr[i]:setTouchable(false)
							end	
							--播放动画
							obj:getTransition("t1"):play(function( ... )
								local spine = SpineUtil.createSpineObj(obj, vertex2(obj:getWidth()/2,obj:getHeight()/2), "fx_fanzhuan_up", "Spine/ui/activity", "shensheqifu_texiao", "shensheqifu_texiao",false)
								ActShrineBlessModel:setShirneTempCode()
								local params = {}
								params.activityId = ActShrineBlessModel:getActivityId( )
								params.gridId = curConfig.gridId
								params.onSuccess = function (res )
									obj:getTransition("t2"):play(function( ... )
										for i=1,#self.cellArr do
											self.cellArr[i]:setTouchable(true)
										end	
									end)
								end
								RPCReq.Activity_ShrinePray_Luckydraw(params, params.onSuccess)
							end)
						end

						local doFunc = function()
							if self.serverData.has and self.serverData.isStartDraw and self.serverData.wish==0 then --已经抽中大奖 还继续抽
								if not ActShrineBlessModel:getCheck2Flag() then
									local info = {}
									info.text = Desc.activity_txt38
									info.type = "ok"
									info.noClose = "no"
									info.check = true
									info.checkTxt = Desc.activity_txt30
									info.onOk = function(flag)
										ActShrineBlessModel:setCheck2Flag(flag)
										callfunc()
									end
									Alert.show(info);
								else
									callfunc()
								end

							else
								if not ActShrineShopModel:getCheckFlag() then
									local info = {}
									local costNameIcon2 = ItemConfiger.getItemIconStrByCode(costItem.code, costItem.type, true)
									info.text = Desc.activity_txt31..costNameIcon2.."[color=#119717]"..costItem.amount.."[/color]"..Desc.activity_txt32
									info.okText = Desc.activity_txt41
									info.type = "ok"
									info.noClose = "no"
									info.check = true
									info.checkTxt = Desc.activity_txt30
									info.onOk = function(flag)
										ActShrineShopModel:setCheckFlag(flag)
										callfunc()
									end
									Alert.show(info);
								else
									callfunc()
								end
							end
						end
                        doFunc()
					end
				end,88)
			end
		else --还没开始寻宝
			btn_open:setVisible(false)
			if curConfig.speFlag then -- 没选大奖 显示+
				typeCtrl:setSelectedIndex(0)
			else  --选了大奖 显示插入的大奖道具
				typeCtrl:setSelectedIndex(1)
				local reward 	= curConfig.reward[1]
				local itemCell  = obj:getChildAutoType("itemCell")
				local itemCellObj 	= BindManager.bindItemCell(itemCell)
				itemCellObj:setData(reward.code, reward.amount, reward.type)
				if curConfig.id == self.serverData.wish then --如果是许愿的大奖
					-- typeCtrl:setSelectedIndex(4)
					local spine = SpineUtil.createSpineObj(spineParent, vertex2(0,0), "pingzhikuang_hong", "Spine/ui/item", "daojupinzhikuang", "daojupinzhikuang",true)
					spine:setScale(0.6)
				end
				mulVal:setText(0)
			end
		end
	end)


	--问号
	self.btn_rule:addClickListener(function( ... )
		local info={}
		info['title']=Desc["help_StrTitle206"]
		info['desc']=Desc["help_StrDesc206"]
		ViewManager.open("GetPublicHelpView",info) 
	end)
	
	--叹号
	self.btn_help2:addClickListener(function( ... )
		local txt =  ActShrineBlessModel:getElfOneShowText()
		local info={}
		info['title']=Desc["help187RateTitle"]
		info['desc']= txt
		ViewManager.open("GetPublicHelpView",info) 
	end)
	
	--奖励预览
	self.btn_jlyl:addClickListener(function( ... )
		ViewManager.open("ActCurRewardView")
	end)
	
	--加号
	self.jiaBtn:addClickListener(function( ... )
		-- body
		ViewManager.open("ActBlessView")
	end)
	
	--更换
	self.changeBtn:addClickListener(function( ... )
		-- body
		ViewManager.open("ActBlessView")
	end)
	
end

function ActShrineBlessView:_initEvent( ... )
	self:ActShrineView_refreshPanal()
end

function ActShrineBlessView:_refresh( ... )
	self:ActShrineView_refreshPanal()
end


function ActShrineBlessView:ActShrineView_refreshPanal( ... )
	self:updatePanel()
	self:updateActTimeShow()
end

function ActShrineBlessView:packItem_change(_,params)
	local config =ActShrineBlessModel:getPrayDrawConfig()
	local code = config.costItem[1].code
	if params == code then
		self:updateItemCount()
	end
end

--随机调换动作
function ActShrineBlessView:allCellTranration(cbfunc)
	--记录原本的位置
	-- local allCellPosArr = {}
	-- for i=1,#self.cellArr do
	-- 	if self.cellArr[i] then
	-- 		table.insert(allCellPosArr,self.cellArr[i]:getPosition())
	-- 	end
	-- end
	-- printTable(1,allCellPosArr)
	local cellArrAll ={}
	local cellArr1 ={}
	local cellArr2= {}
	local num = 0
	for i=1,36 do
		table.insert(cellArrAll,i)
	end
	cellArrAll = TableUtil.randomSortArray(cellArrAll)
	for i=1,18 do
		table.insert(cellArr1,cellArrAll[i])
	end
	for i=19,36 do
		table.insert(cellArr2,cellArrAll[i])
	end
	
	local num1 = cellArr1[1]
	local num2 = cellArr2[1]
	local pos1 = {}
	local pos2 = {}
	if self.cellArr[num1] then
		pos1 = self.cellArr[num1]:getPosition()
	end

	if self.cellArr[num2] then
		pos2 = self.cellArr[num2]:getPosition()
	end

	local arg = {}
	arg.from = pos1
	arg.to = pos2
	arg.time = 0.6
	arg.ease = EaseType.Linear
	arg.tweenType = string.format("%s_%d","shrine",num1)
	arg.onComplete = function( ... )
		--还原位置
		-- for j=1,#self.cellArr do
		-- 	printTable(1,allCellPosArr[j])
		-- 	local pos = allCellPosArr[j]
		-- 	self.cellArr[j]:setPosition(pos.x,pos.y)
		-- end
		cbfunc()
			-- self.awardList:setNumItems(0)
	end
	TweenUtil.moveTo(self.cellArr[num1],arg)

	local arg = {}
	arg.from = pos2
	arg.to = pos1
	arg.time = 0.6
	arg.ease = EaseType.Linear
	arg.tweenType = string.format("%s_%d","shrine",num2)
	arg.onComplete = function( ... )
	end
	TweenUtil.moveTo(self.cellArr[num2],arg)


	for i=2,18 do
		local num1 = cellArr1[i]
		local num2 = cellArr2[i]
		local pos1 = {}
		local pos2 = {}
		if self.cellArr[num1] then
			pos1 = self.cellArr[num1]:getPosition()
		end

		if self.cellArr[num2] then
			pos2 = self.cellArr[num2]:getPosition()
		end

		local arg = {}
		arg.from = pos1
		arg.to = pos2
		arg.time = 0.5
		arg.ease = EaseType.Linear
		arg.tweenType = "shrine"
		arg.onComplete = function( ... )
			-- self.cellArr[num1]:setPosition(pos1.x,pos1.y)
		end
		TweenUtil.moveTo(self.cellArr[num1],arg)
		
		local arg = {}
		arg.from = pos2
		arg.to = pos1
		arg.time = 0.6
		arg.ease = EaseType.Linear
		arg.tweenType = "shrine"
		arg.onComplete = function( ... )
			-- self.cellArr[num2]:setPosition(pos2.x,pos2.y)
		end
		TweenUtil.moveTo(self.cellArr[num2],arg)
	end
	-- self.awardList:setNumItems(0)
	-- self.awardList:setNumItems(36)
end

function ActShrineBlessView:updatePanel()
	self.serverData = ActShrineBlessModel:getData( )
	-- printTable(1,self.serverData)
	self:updateItemCount()
	self.layerLab:setVar("layer",tostring(self.serverData.ring))
	self.layerLab:flushVars()
	--存在许愿道具
	if self.serverData.wish and self.serverData.wish>0 then
		self.hadSelCtrl:setSelectedIndex(1)
	    --选中的大奖
		self.itemcellObj:setAmountVisible(false)
		local itemData = ActShrineBlessModel:getitemDataById(self.serverData.wish)
		if itemData then
			self.itemcellObj:setData(itemData.code, itemData.amount, itemData.type)
		end
	else
		self.hadSelCtrl:setSelectedIndex(0)
		self.jiaBtn:getChildAutoType("img_red"):setVisible(false)
		local config = ActShrineBlessModel:getPrayChooseConfig(  )
		for i=1,#config do
			local hadNum = ActShrineBlessModel:getLimitbyCodeId( config[i].id )
			local limit = config[i].limit
			if hadNum<limit and (self.serverData.wish and self.serverData.wish==0) and not self.serverData.has then
				self.jiaBtn:getChildAutoType("img_red"):setVisible(true)
				break
			end
		end
	end
    self.btn_begin:getChildAutoType("img_red"):setVisible(false)
	if self.serverData.has then
		self.nextClickFlag = false
		self.btn_begin:setTitle(Desc.activity_txt34)
		self.btn_begin:setGrayed(false)
		self.btn_begin:setTouchable(true)
		self.btn_begin:removeClickListener(88)
		self.btn_begin:getChildAutoType("img_red"):setVisible(true)
		self.btn_begin:addClickListener(function( ... )
			print(1,"前往下层",self.nextClickFlag)
			if self.nextClickFlag then
				return
			end
			print(1,"前往下层成功")
			self.nextClickFlag = true
			--前往下一层
			for i=1,#self.cellArr do
				local tempBg = self.cellArr[i]:getChildAutoType("tempBg")
				self.cellArr[i]:setTouchable(false)
				if tempBg then
					tempBg:setVisible(true)
				end
			end		
			self.cellArr[1]:getTransition("t0"):play(function( ... )
				local callfunc = function()
					self.cellArr[1]:setTouchable(true)
					local params = {}
					params.activityId = ActShrineBlessModel:getActivityId( )
					params.onSuccess = function (res )
					    if tolua.isnull(self.view) then return end
						-- self.nextClickFlag = false
						print(1,"前往下层数据返回",self.nextClickFlag)
					end
					RPCReq.Activity_ShrinePray_NextRing(params, params.onSuccess)
				end
				callfunc()
				-- self:allCellTranration(callfunc)
			end);
			
			for i=2,#self.cellArr do
				self.cellArr[i]:setTouchable(false)
				self.cellArr[i]:getTransition("t0"):play(function( ... )
					self.cellArr[i]:setTouchable(true)
				end);
			end
			

		end,88)
	else
		if self.serverData.isStartDraw then --已经开始了寻宝
			self.btn_begin:setTitle(Desc.activity_txt34)
			self.btn_begin:setGrayed(true)
			self.btn_begin:setTouchable(false)
		else
			self.btn_begin:setTitle(Desc.activity_txt35)
			self.btn_begin:setGrayed(false)
			self.btn_begin:setTouchable(true)
			self.nextClickFlag = false
			self.btn_begin:removeClickListener(88)
			if   (self.serverData.wish >0) then
				self.btn_begin:getChildAutoType("img_red"):setVisible(true)
			end
			--开始寻宝
			self.btn_begin:addClickListener(function( ... )
				if not  (self.serverData.wish >0) then
					RollTips.show(Desc.activity_txt36)
					return
				end
				print(1,"开始寻宝",self.nextClickFlag)
				if self.nextClickFlag  then
					return
				end
				self.nextClickFlag = true
				print(1,"开始寻宝成功",self.nextClickFlag)
				--将右边的奖励翻转过去

				for i=1,#self.cellArr do
					self.cellArr[i]:setTouchable(false)
					local tempBg = self.cellArr[i]:getChildAutoType("tempBg")
					if tempBg then
						tempBg:setVisible(true)
					end
				end		
				self.cellArr[1]:getTransition("t0"):play(function( ... )
					self.cellArr[1]:setTouchable(true)
					local cbfunc = function()
						local params = {}
						params.activityId = ActShrineBlessModel:getActivityId( )
						params.onSuccess = function (res )
							-- self.nextClickFlag = false
							print(1,"开始寻宝数据返回",self.nextClickFlag)
							self.awardList:setData({})
							self.awardList:setData(self.prayDropConfig)
						end
						RPCReq.Activity_ShrinePray_StartDraw(params, params.onSuccess)
					end
					self:allCellTranration(cbfunc)
				end);
				
				for i=2,#self.cellArr do
					self.cellArr[i]:setTouchable(false)
					self.cellArr[i]:getTransition("t0"):play(function( ... )
						self.cellArr[i]:setTouchable(true)
					end);
				end

			end,88)
		end
	end

	local config =  ActShrineBlessModel:getPrayShowConfig( self.serverData.codeId )
	local obj = {}
	obj.speFlag = false
	if not (self.serverData.wish >0)  then --未选大奖
		obj.speFlag = true
		table.insert( config,1,obj )
	else --选了大奖（盖牌前/盖牌后-）
		local tempConfig = ActShrineBlessModel:getConfigChooseById(self.serverData.wish)
		local reward =TableUtil.DeepCopy(tempConfig) 
		reward.bigFlag = true
		reward.gridId = 1 --强行设置配置格子id为1    
		table.insert(config,1,reward)
	end
    for i=1,#config do
        config[i].gridId = i
    end	
	self.prayDropConfig = config
	self.awardList:setData(self.prayDropConfig)
end


--更新活动时间
function ActShrineBlessView:updateActTimeShow( ... )
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
    local actid = ActShrineBlessModel:getActivityId( )
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
		self.txt_countTimer:setText(Desc.activity_txt4) -- TODO
	end, false, false, false)
end

function ActShrineBlessView:_exit()
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end

	for i,v in ipairs(self.scheduler) do
		if self.scheduler[i] then
			Scheduler.unschedule(self.scheduler[i])
	        self.scheduler[i] = false
		end
	end
	for i,v in ipairs(self.scheduler2) do
		if self.scheduler2[i] then
			Scheduler.unschedule(self.scheduler2[i])
	        self.scheduler2[i] = false
		end
	end
end

return ActShrineBlessView