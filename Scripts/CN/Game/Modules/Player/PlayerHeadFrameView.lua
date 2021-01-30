
local PlayerHeadFrameView,Super = class("PlayerHeadFrameView", Window)

function PlayerHeadFrameView:ctor()
	LuaLogE("PlayerHeadFrameView ctor")
	self._packName = "Player"
	self._compName = "PlayerHeadFrameView"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = true
	self.sureBtn = false
	self.headInfo = false
	self.headList = false
	self.heroCell = false
	self.txt_time = false
	self.txt_attr = false
	self.txt_condition = false
	self.activeCtrl = false
	self.curIndex = 1
	self.timer = false
end


function PlayerHeadFrameView:_initUI()
	LuaLogE("PlayerHeadFrameView _initUI")


	--LoginModel:readSavedServerInfo()
	local heroCell = self.view:getChildAutoType("heroCell")
	self.heroCell = BindManager.bindPlayerCell(heroCell)
	self.txt_time = self.view:getChildAutoType("txt_time")
	self.txt_attr = self.view:getChildAutoType("txt_attr")
	self.txt_condition = self.view:getChildAutoType("txt_condition")
	self.activeCtrl = self.view:getController("activeCtrl")

	self.headInfo = {}
	local frameInfo = DynamicConfigData.t_HeadFrame
	for k,v in pairs(frameInfo) do
		local temp = {}
		temp.code = v.code
		temp.isHave = 0
		if ModelManager.PackModel:getHeadBorderBag():getAmountByCode(v.code) > 0 then
			temp.isHave = 1
		end
		table.insert(self.headInfo,temp)
	end
	
	table.sort(self.headInfo,function(a,b)
		return a.isHave > b.isHave
	end)
	
	
	self.sureBtn = self.view:getChildAutoType("Btn")

	self.sureBtn:addClickListener(function()
			local frame = self.headInfo[self.curIndex]
			if frame.isHave == 0 then
				RollTips.show(Desc.player_frameNotHaveFrame)
				return 
			end
			RPCReq.GamePlay_Modules_Rename_headBorder({id = frame.code},function(args)
					print(33,"head chang callback")
					printTable(33,args)
					if args.ret == 0 then
						RollTips.show(Desc.player_changesuccess)
						PlayerModel.headBorder = args.id
						--self.address:setText(PlayerModel.address)
						self.headList:setNumItems(#self.headInfo);
						Dispatcher.dispatchEvent(EventType.player_headreset,args.id)
					else
						--RollTips.show("error.code = "..args.ret)
					end
				end)
			
			--self:closeView()
		end)

	self.headList = self.view:getChildAutoType("list")
	
	self.headList:setItemRenderer(function(index,obj)
			--obj:removeClickListener()--池子里面原来的事件注销掉
			local usingCtrl = obj:getController("using")
			local img_red = obj:getChildAutoType("img_red")
			local showBg = obj:getController("showBg")
			showBg:setSelectedIndex(0)
			RedManager.register("V_HEAD_BORDER_"..self.headInfo[index+1].code, img_red)
			
			if self.headInfo[index+1].code == ModelManager.PlayerModel.headBorder or ModelManager.PlayerModel.headBorder == 0 then
				self.curIndex = index + 1
				self:updateSelectedFrameInfo()
				usingCtrl:setSelectedIndex(1)
			else
				usingCtrl:setSelectedIndex(0)
			end
			--if self.headInfo[index+1].isHave == 1 then
			obj:removeClickListener(33)
			obj:addClickListener(function(context)
					print(33,index)
					self.curIndex = index+1
					self:updateSelectedFrameInfo()
			end,33)
			--else
			--	obj:removeClickListener()
			--	obj:addClickListener(function(context)
			--			RollTips.show(Desc.player_renamecode8)
			--		end)
			--end
			local gloader = obj:getChildAutoType("frameLoader")
			local frameInfo = DynamicConfigData.t_HeadFrame[self.headInfo[index+1].code]
			if frameInfo then
				gloader:setURL(PathConfiger.getHeadFrame(frameInfo.icon))
			end
			if self.headInfo[index+1].isHave == 0 then
				gloader:setGrayed(true)
			end
			
			
		end
	)
	self.headList:setNumItems(#self.headInfo);
	self.headList:setSelectedIndex(self.curIndex - 1)
end


function PlayerHeadFrameView:updateSelectedFrameInfo( ... )
	if (self.timer) then
            TimeLib.clearCountDown(self.timer);
        end
	local frame = self.headInfo[self.curIndex]
	local frameId = frame.code
	self.heroCell:setShowBg(false)
	self.heroCell:setShowLv(false)
	--local txt_frameName = self.heroCell:getChildAutoType("playerName")
	local frameInfo = DynamicConfigData.t_HeadFrame[frameId]
	
	--self.sureBtn:setTouchable(frame.isHave ~= 0)
	--self.sureBtn:setGrayed(frame.isHave == 0)
	
	--[[local attrStr = ""
	for _,v in ipairs(frameInfo.addAttr) do
		attrStr = string.format("%s%s +%s\n", attrStr, Desc["card_attrName_"..v.type], v.value )
	end--]]
	self.txt_attr:setText(frameInfo.attrType)
	
	RedManager.updateValue("V_HEAD_BORDER_"..frameId, false)
	if frameInfo then
		self.heroCell:setHead(0,0,0,frameInfo.name,frameInfo.icon)
		
		--txt_frameName:setText(frameInfo.name)
		self.activeCtrl:setSelectedIndex(frame.isHave)
		--if frame.isHave == 0 then
		--	self.txt_time:setText(Desc.player_headNotGet)
		--else
			if frameInfo.existTime == -1 then
				self.txt_time:setText(Desc.player_forever)
			else
				local item  = ModelManager.PackModel:getHeadBorderBag():getItemsByCode(frameId)
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


function PlayerHeadFrameView:_initEvent( ... )
	--self:addEventListener(EventType.login_chooseServer,self)
end

function PlayerHeadFrameView:_exit( ... )
	if (self.timer) then
		TimeLib.clearCountDown(self.timer);
	end
end

return PlayerHeadFrameView