
local PlayerCrownTitleView,Super = class("PlayerCrownTitleView", Window)

function PlayerCrownTitleView:ctor()
	LuaLogE("PlayerCrownTitleView ctor")
	self._packName = "Player"
	self._compName = "PlayerCrownTitleView"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = true
	self.sureBtn = false
	self.headInfo = false
	self.headList = false
	self.crownTitle = false
	self.txt_time = false
	self.txt_attr = false
	self.txt_name = false
	self.txt_condition = false
	self.activeCtrl = false
	self.curIndex = false
	self.timer = false
end


function PlayerCrownTitleView:_initUI()
	LuaLogE("PlayerCrownTitleView _initUI")


	--LoginModel:readSavedServerInfo()
	local crownTitle = self.view:getChildAutoType("crownTitle")
	self.crownTitle = BindManager.bindCrownTitleCell(crownTitle)
	self.txt_time = self.view:getChildAutoType("txt_time")
	self.txt_attr = self.view:getChildAutoType("txt_attr")
	self.txt_name = self.view:getChildAutoType("txt_name")
	self.txt_condition = self.view:getChildAutoType("txt_condition")
	self.activeCtrl = self.view:getController("activeCtrl")

	self.headInfo = {}
	local titleInfo = DynamicConfigData.t_CrownTitle
	for k,v in pairs(titleInfo) do
		local temp = {}
		temp.code = v.code
		temp.order = v.order
		temp.isHave = 0
		if ModelManager.PackModel:getCrownTitleBag():getAmountByCode(v.code) > 0 then
			temp.isHave = 1
		end
		table.insert(self.headInfo,temp)
	end
	
	TableUtil.sortByMap(self.headInfo, {{key="isHave", asc = true},{key="order", asc = false}})
	
	
	
	self.sureBtn = self.view:getChildAutoType("Btn")
	self.btn_notGet = self.view:getChildAutoType("btn_notGet")
	self.btn_notGet:removeClickListener()
	self.btn_notGet:addClickListener(function()
		local frame = self.headInfo[self.curIndex]
		local config = DynamicConfigData.t_CrownTitle[frame.code]
		ModuleUtil.openModule(config.jump,true)
		
	end)
	
	self.sureBtn:removeClickListener()
	self.sureBtn:addClickListener(function()
			--[[local frame = self.headInfo[self.curIndex]
			if frame.isHave == 0 then
				RollTips.show(Desc.player_crownTitleNotHave)
				return 
			end
			RPCReq.GamePlay_Modules_Rename_headBorder({id = frame.code},function(args)
					print(33,"head chang callback")
					printTable(33,args)
					if args.ret == 0 then
						RollTips.show(Desc.player_changesuccess)
						PlayerModel.headBorder = args.id
						self.headList:setNumItems(#self.headInfo);
						--Dispatcher.dispatchEvent(EventType.player_headreset,args.id)
					else
						--RollTips.show("error.code = "..args.ret)
					end
				end)
			--]]
			--self:closeView()
		end)

	self.headList = self.view:getChildAutoType("list")
	
	self.headList:setItemRenderer(function(index,obj)
			--obj:removeClickListener()--池子里面原来的事件注销掉
			local usingCtrl = obj:getController("using")
			local img_red = obj:getChildAutoType("img_red")
			local showBg = obj:getController("showBg")
			local crownTitle = obj:getChildAutoType("crownTitle")
			local titleObj = BindManager.bindCrownTitleCell(crownTitle)
			titleObj:setData(self.headInfo[index+1].code)
			
			--showBg:setSelectedIndex(0)
			RedManager.register("V_CROWN_TITLE_"..self.headInfo[index+1].code, img_red)
			
			if index == 0  and not self.curIndex then
				self.curIndex = index + 1
				self:updateSelectedFrameInfo()
			else
			end
			if self.headInfo[index+1].isHave == 1 then
				titleObj:setGrayed(false)
				titleObj:resumeEffect()
			else
				titleObj:setGrayed(true)
				titleObj:stopEffect()
			end
			obj:removeClickListener(33)
			obj:addClickListener(function(context)
					print(33,index)
					self.curIndex = index+1
					self:updateSelectedFrameInfo()
			end,33)
			--[[local gloader = obj:getChildAutoType("iconLoader")
			if self.headInfo[index+1].isHave == 0 then
				gloader:setGrayed(true)
			end--]]
			
			
		end
	)
	self.headList:setNumItems(#self.headInfo);
	self.headList:setSelectedIndex(self.curIndex - 1)
end


function PlayerCrownTitleView:updateSelectedFrameInfo( ... )
	if (self.timer) then
            TimeLib.clearCountDown(self.timer);
        end
	local frame = self.headInfo[self.curIndex]
	local frameId = frame.code

	local frameInfo = DynamicConfigData.t_CrownTitle[frameId]
	
	RedManager.updateValue("V_CROWN_TITLE_"..frameId, false)
	if frameInfo then
		self.txt_attr:setText(frameInfo.attrType)
		self.txt_name:setText(frameInfo.name)
		self.crownTitle:setData(frameId)
		self.activeCtrl:setSelectedIndex(frame.isHave)
		--if frame.isHave == 0 then
		--	self.txt_time:setText(Desc.player_headNotGet)
		--else
			if frameInfo.existTime == -1 then
				self.txt_time:setText(Desc.player_forever)
			else
				local item  = ModelManager.PackModel:getCrownTitleBag():getItemsByCode(frameId)
				if item and #item > 0 then
					local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
					local expireMS = math.floor((item[1]:getExpireMS() - serverTime)/1000)
					local function onCountDown( time )
						if not tolua.isnull(self.txt_time) then
							self.txt_time:setText(TimeLib.GetTimeFormatDay(time, 2))
						else
							TimeLib.clearCountDown(self.timer)
						end
					end
					local function onEnd( ... )

					end
					if self.timer then TimeLib.clearCountDown(self.timer) end
					self.timer = TimeLib.newCountDown(expireMS, onCountDown, onEnd, false, false,false)
					self.txt_time:setText("")
				else
					self.txt_time:setText(TimeLib.GetTimeFormatDay(frameInfo.existTime, 2))
				end
			end
		--end
		self.txt_condition:setText(frameInfo.unlockingConditions)
	else
		txt_frameName:setText("")
	end
	
end


function PlayerCrownTitleView:_initEvent( ... )
	--self:addEventListener(EventType.login_chooseServer,self)
end

function PlayerCrownTitleView:_exit( ... )
	if (self.timer) then
		TimeLib.clearCountDown(self.timer);
	end
end

return PlayerCrownTitleView