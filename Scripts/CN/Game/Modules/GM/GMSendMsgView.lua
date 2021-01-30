--示测试页
local GMSendMsgView,Super = class("GMSendMsgView", Window)
function GMSendMsgView:ctor()
	LuaLogE("GMSendMsgView ctor")
	self._packName = "GM"
	self._compName = "GMSendMsgView"
	self.msgNameText = ""
	self.infoTable= {}
	self.skeletonNode = false
	self.lastIput1 = {"Test_Cmd#{}"}
	self.comb1 = false
	self.msg2Text = ""
end

function GMSendMsgView.loadComponent(_,comp)
	print(33,"GMSendMsgView.loadComponent",comp)
	local view = GMSendMsgView.new()
	view.view = comp
	view:_initUI()
	return view
end

function GMSendMsgView:_initUI()
	local msgName = self.view:getChildAutoType("name")
	self:readLastInput1()
	msgName:onChanged(function (str)
			--print(33,"msgNameText =",str)
			self.msgNameText = str
		end)
	
	local jsonInfo = self.view:getChildAutoType("info")
	local result = self.view:getChildAutoType("result")
	
	jsonInfo:onChanged(function (str)
			result:setText("parameter error!!")
			--print(33,"jsonInfo =",str)
			local function calljson()
				local f  = loadstring("return "..str)
				self.msg2Text = str
				self.infoTable = f()
				
				--printTable(33,"self.infoTable",self.infoTable)
			end
			if pcall(calljson) then

				result:setText("ok")
				
				printTable(33,self.infoTable)
			else

				result:setText(DescAuto[125]) -- [125]="参数错误"
			end

		end)
	
	self.comb1 = self.view:getChildAutoType("comb1")
	--local seartext = self.view:getChildAutoType("seartext")
	self.comb1:setItems(self.lastIput1)

	--self.comb1:setValues(self.lastIput1)
	--self.comb1:setItems(self.lastIput1)
	--self.comb2:setItems(self.lastIput2)
	
	if self.lastIput1[1] then
		local ft = string.split(self.lastIput1[1],"#")
		msgName:setText(ft[1])
		jsonInfo:setText(ft[2])
	end
	self.comb1:addEventListener(FUIEventType.Changed,function(data)
			local ft = string.split(self.comb1:getTitle(),"#")
			msgName:setText(ft[1])
			jsonInfo:setText(ft[2])
		end)
	
	local send = self.view:getChildAutoType("send")
	send:addClickListener(function()
			self.msgNameText = msgName:getText()
			self.msg2Text = jsonInfo:getText()
			print(33,"sendMsg =",self.msgNameText)
			printTable(33,self.infoTable)
			if self.msgNameText ~= "" then
				RPCReq[self.msgNameText](self.infoTable,function(callInfo)
					printTable(33,callInfo)
					result:setText(json.encode(callInfo))
				end)
				
				result:setText("aready send")
				
				if self.lastIput1[1] ~= self.msgNameText then
					table.insert(self.lastIput1,1,self.msgNameText.."#"..self.msg2Text)
					if #self.lastIput1 > 20 then
						self.lastIput1[21] = nil
					end
					self:saveLastInput1()
					self.comb1:setItems(self.lastIput1)
					self.comb1:refresh()
				end
			end
		end)
end

function GMSendMsgView:readLastInput1()
	if CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then

		local lastIput1 = FileCacheManager.getStringForKey(LoginModel:formatUserDefaultKeyWithAgent("GMSendMsgView"), "", nil, true)
		if lastIput1 ~= "" then
			local Info = json.decode(lastIput1)
			if type(Info) == "table" then
				self.lastIput1 = Info
			end
		end
	end
end

function GMSendMsgView:saveLastInput1()
	if CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		FileCacheManager.setStringForKey(LoginModel:formatUserDefaultKeyWithAgent("GMSendMsgView"), json.encode(self.lastIput1), nil, true)
	end
end


return GMSendMsgView
