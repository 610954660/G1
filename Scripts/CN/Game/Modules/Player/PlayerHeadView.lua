
local PlayerHeadView,Super = class("PlayerHeadView", Window)

function PlayerHeadView:ctor()
	LuaLogE("PlayerHeadView ctor")
	self._packName = "Player"
	self._compName = "PlayerHeadView"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = true
	self.sureBtn = false
	self.headInfo = false
	self.headList = false
	self.curIndex = 1
	self.heroCell = false
	self.txt_time = false
	self.txt_condition = false
	self.timerKey = false
end



function PlayerHeadView:_initUI()
	LuaLogE("PlayerHeadView _initUI")

	self.heroCell = self.view:getChildAutoType("heroCell")
	--self.heroCell = BindManager.bindPlayerCell(heroCell)
	self.txt_time = self.view:getChildAutoType("txt_time")
	self.txt_condition = self.view:getChildAutoType("txt_condition")
	--LoginModel:readSavedServerInfo()

	self.headInfo = {}
	local cardInfo = ModelManager.CardLibModel:getCardHaveHeroId()
	for k,v in pairs(PlayerModel:getHeadInfo()) do
		local temp = {}
		temp.id = v.id
		temp.image = v.image
		temp.isHave = 0
		if cardInfo[v.id] then
			temp.isHave = 1
		end
		table.insert(self.headInfo,temp)
	end
	
	local exHead = DynamicConfigData.t_HeadEx
	for k,v in pairs(exHead) do
		local temp = {}
		temp.id = v.id
		temp.image = v.icon
		temp.isHave = 0
		temp.isExHead = 1
		if  ModelManager.PackModel:getFashionBag():getIsHaveFashion(v.id) then
			temp.isHave = 1
		end
		table.insert(self.headInfo,temp)
	end
	
	table.sort(self.headInfo,function(a,b)
		return a.isHave > b.isHave
	end)
	
	-- self.closeBtn = self.view:getChildAutoType("close")

	-- self.closeBtn:addClickListener(function() self:closeView() end)
			
	
	self.sureBtn = self.view:getChildAutoType("Btn")

	self.sureBtn:addClickListener(function()
		local frame = self.headInfo[self.curIndex]
		if frame.isHave == 0 then
			RollTips.show(Desc.player_renamecode8)
			return 
		end
		RPCReq.GamePlay_Modules_Rename_head({id = self.headInfo[self.curIndex].id},function(args)
				print(33,"head chang callback")
				printTable(33,args)
				if args.ret == 0 then
					RollTips.show(Desc.player_changesuccess)
					PlayerModel.head = args.id
					--self.address:setText(PlayerModel.address)
					self.headList:setNumItems(#self.headInfo);
					Dispatcher.dispatchEvent(EventType.player_headreset,args.id)
				else
					RollTips.show("error.code = "..args.ret)
				end
			end)
		
		--self:closeView()
	end)

	self.headList = self.view:getChildAutoType("list")
	
	self.headList:setItemRenderer(function(index,obj)
			--obj:removeClickListener()--池子里面原来的事件注销掉
			local usingCtrl = obj:getController("using")
			local showBg = obj:getController("showBg")
			local img_red = obj:getChildAutoType("img_red")
			RedManager.register("V_HEAD_"..self.headInfo[index+1].id, img_red)
			showBg:setSelectedIndex(1)
			if self.headInfo[index+1].id == ModelManager.PlayerModel.head  then
				self.curIndex = index +1
				self:updateSelectedHead()
				usingCtrl:setSelectedIndex(1)
			else
				usingCtrl:setSelectedIndex(0)
			end
			--if self.headInfo[index+1].isHave == 1 then
				obj:removeClickListener(33)
				obj:addClickListener(function(context)
						print(33,index)
						self.curIndex = index+1
						self:updateSelectedHead()
		end,33)
			--else
			--	obj:removeClickListener()
			--	obj:addClickListener(function(context)
			--			RollTips.show(Desc.player_renamecode8)
				--	end)
			--end
			local gloader = obj:getChildAutoType("iconLoader") 
			gloader:setURL(PathConfiger.getPlayerHead(self.headInfo[index+1].id))
			if self.headInfo[index+1].isHave == 0 then
				gloader:setGrayed(true)
			end
		end
	)
	self.headList:setNumItems(#self.headInfo);
	self.headList:setSelectedIndex(self.curIndex - 1)
end

function PlayerHeadView:updateSelectedHead( ... )
	local headInfo = self.headInfo[self.curIndex]
	if self.timerKey then
	    TimeLib.clearCountDown(self.timerKey)
	end
	self.sureBtn:setTouchable(headInfo.isHave ~= 0)
	self.sureBtn:setGrayed(headInfo.isHave == 0)
	
	RedManager.updateValue("V_HEAD_"..headInfo.id, false)
	local gloader = self.view:getChildAutoType("iconLoader")
	if headInfo then
		gloader:setURL(PathConfiger.getPlayerHead(headInfo.id))
	--self.heroCell:setHead(headInfo.id, 0, nil,nil,90000001)
		--self.heroCell:setShowLv(false)
		if headInfo.isHave == 0 then
			self.txt_time:setText(Desc.player_headNotGet)
		else
			if headInfo.isExHead then
				local itemInfo = ItemConfiger.getInfoByCode(headInfo.id) 
				if itemInfo.existTime and itemInfo.existTime > 0 then
					local fashionData = ModelManager.PackModel:getFashionBag():getFashionItemById(headInfo.id)
					local expireMS = fashionData and fashionData:getExpireMS() or 0
					local timems = math.floor((expireMS - ServerTimeModel:getServerTimeMS()) / 1000)
					local function onCountDown(time)
						if not tolua.isnull(self.txt_time) then
							local str = TimeLib.formatTime(time,true,false)
							self.txt_time:setText(string.format(Desc.FashionView_LeftTime,str))
						end
					end
					local function onEnd(...)
						headInfo.isHave = 0
						if not tolua.isnull(self.txt_time) then
							self.txt_time:setText(DescAuto[107]) -- [107]="已过期"
						end
					end
					self.timerKey = TimeLib.newCountDown(timems, onCountDown, onEnd, false, false, false)
				else
					self.txt_time:setText(Desc.player_forever)
				end
			else
				self.txt_time:setText(Desc.player_forever)
			end
		end
		
		if headInfo.isExHead then
			local heroInfo = DynamicConfigData.t_HeadEx[headInfo.id]
			if heroInfo then
				self.txt_condition:setText(heroInfo.unlockingConditions)
			end
		else
			local heroInfo = DynamicConfigData.t_hero[headInfo.id]
			if heroInfo then
				self.txt_condition:setText(string.format(Desc.player_headGet,heroInfo.heroName))
			end
		end
		
	end
	
end

function PlayerHeadView:_initEvent( ... )
	--self:addEventListener(EventType.login_chooseServer,self)
end

function PlayerHeadView:_exit( ... )
	if self.timerKey then
	    TimeLib.clearCountDown(self.timerKey)
	end
end

return PlayerHeadView