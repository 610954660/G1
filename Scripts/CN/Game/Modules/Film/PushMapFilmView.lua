--Name : PushMapFilmView.lua
--Author : generated by FairyGUI
--Date : 2020-4-18
--Desc : 

local PushMapFilmView,Super = class("PushMapFilmView", View)
local film_Config = false
local film_curConfig = false

function PushMapFilmView:ctor()
	--LuaLog("PushMapFilmView ctor")
	self._packName = "Film"
	self._compName = "PushMapFilmView"
	self._rootDepth = self._args._rootDepth or LayerDepth.Window  
	self._isFullScreen = true
	self.isShowGuochangyun=false
	self.step = "simple"
	self.index = 0
	self.schedulerID = 0
	self.clickFuc = false
	self.isAuto = false
	self.bgF = ""
	self.userF = ""
	self.endfunc = false
	self.curData = {}
	self.exitfunc =false
	self.bgAction = false
	self.lockClick = false
	
	self.isAutoOpen = 0
	self.schedulerIDAuto = false
end

function PushMapFilmView:_initEvent( )
	
end

function PushMapFilmView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Film.PushMapFilmView
		vmRoot.closebt = viewNode:getChildAutoType("$closebt")--Button
		vmRoot.name = viewNode:getChildAutoType("layer/$name")--Label
		vmRoot.user1 = viewNode:getChildAutoType("layer/$user1")--Button
		local layer = viewNode:getChildAutoType("layer/$layer")--
		vmRoot.layer = layer
			layer.layer = viewNode:getChildAutoType("layer/$layer/$layer")--loader
		vmRoot.exit = viewNode:getChildAutoType("$exit")--Button
		vmRoot.huigu = viewNode:getChildAutoType("$huigu")--Button
		vmRoot.text = viewNode:getChildAutoType("layer/$text")--Label
		vmRoot.user2 = viewNode:getChildAutoType("layer/$user2")--Button
		vmRoot.auto = viewNode:getChildAutoType("$auto")--Button
		local call = viewNode:getChildAutoType("layer/$call")--Label
		vmRoot.call = call
			call.mask = viewNode:getChildAutoType("layer/$call/$mask")--graph
	--{vmFieldsEnd}:Film.PushMapFilmView
	--Do not modify above code-------------
end

function PushMapFilmView:_initUI( )
	self:_initVM()
	
	
	if self._args.step then
		self.step = self._args.step
	end
	if self._args.isShowGuochangyun then
		self.isShowGuochangyun = self._args.isShowGuochangyun
	end
	if self._args.step == "CJ1" or self._args.step == "S2" then
		self.view:getController("viewCtrl"):setSelectedIndex(1)
		self.isAutoOpen = 3
	end
	
	if self._args.endfunc then
		self.endfunc = self._args.endfunc
	end
	
	if self._args.exitfunc then
		self.exitfunc = self._args.exitfunc
	end

	self.bg = self.view:getChildAutoType("bg")
	local function setMask(obj,value)
		if value then
			obj:getChildAutoType("icon"):setColor(cc.c3b(155,155,155))
		else
			obj:getChildAutoType("icon"):setColor(cc.c3b(255,255,255))
		end
	end
	
	local function setData(obj,data)
		if data and data ~= "" then
			obj:setVisible(true)

			local d_info = string.split(data,",")
			if d_info[5] == "fade" then
				local url = obj:getIcon()
				local icon = obj:getChildAutoType("icon")
				local iconhelp = obj:getChildAutoType("iconhelp")
				iconhelp:setVisible(true)
				iconhelp:setURL(url)
				iconhelp:displayObject():setOpacity(255)
				iconhelp:displayObject():stopAllActions()
				iconhelp:displayObject():runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function() iconhelp:setURL("") end)))
				if string.find(d_info[1],"ui://") then
					icon:setURL(d_info[1])
				else
					icon:setURL(self.userF..d_info[1])
				end
				icon:displayObject():setOpacity(0)
				icon:displayObject():stopAllActions()
				icon:displayObject():runAction(cc.FadeIn:create(0.2))
			else
				obj:getChildAutoType("iconhelp"):setURL("")
				obj:getChildAutoType("iconhelp"):setVisible(false)
				if string.find(d_info[1],"ui://") then
					obj:setIcon(d_info[1])
				else
					obj:setIcon(self.userF..d_info[1])
				end
			end
			
			
			if not obj.edit then
				obj:setTouchable(false)
			end
			
			
			obj:setWidth(d_info[4])
			obj:setHeight(d_info[5])
			obj:setPosition(d_info[2],d_info[3])
			obj:setMask(d_info[6]=="mask" and true or false)
			if obj.ac then
				obj.ac:stop(true,false)
				obj.ac = false
			end
			if d_info[7] then
				obj.ac = obj:getTransition(d_info[7])
				if obj.ac then 
					obj.ac:play(function()
	
					end);
				else
					RollTips.show("not action "..d_info[7])
				end
			end
		else
			obj:setVisible(false)
		end
	end
	
	self.user1.setData = setData
	self.user2.setData = setData
	self.call.setData = setData
	
	self.user1.setMask = setMask
	self.user2.setMask = setMask
	self.call.setMask  = function(obj,value) obj.mask:setVisible(value) end
	
	self.auto:addClickListener(function(context)
			context:stopPropagation()
			self.isAuto = not self.isAuto
			if self.isAuto then
				self.auto:setSelected(true)
				if not self.clickFuc then
					self:runNext()
				end
			else
				self.auto:setSelected(false)
			end
		end,33)
	
	self.exit:addClickListener(function(context)
			context:stopPropagation()
			
			if self.exitfunc then
				self.exitfunc()
			end

			self:closeView()
		end,33)
	self.closebt:addClickListener(function(context)
			context:stopPropagation()

			if self.endfunc then
				self.endfunc()
			end

			self:closeView()
		end,33)
	
	self.huigu:addClickListener(function(context)
			context:stopPropagation()
			local datas = {_rootDepth = self._args._rootDepth,data = film_Config[self.step],index = self.index}
			printTable(33,datas)
			ViewManager.open("PushMapHuiguView",datas)
		end,33)
	
	self.view:addClickListener(function()
				if self.lockClick then return end
				
				print(33,"addClickListener 11")
				if self.clickFuc then
					self.clickFuc()
					self.clickFuc = false
				else
					self.lockClick = true
					self:runNext()
				end
			end,33)
	if self._args.filmConfig then
		film_Config = self._args.filmConfig
	else
		film_Config = DynamicConfigData.FilmConfig
	end
	
	film_curConfig = film_Config[self.step]
	print(33,"film_curConfig",GuideModel.step,GuideModel.index,GuideModel.guideName)
	if self.step=="CJ1" and film_curConfig and #film_curConfig ==13 and  GuideModel.curValue > 0 then
		
		table.remove(film_curConfig,1)
		table.remove(film_curConfig,1)
		table.remove(film_curConfig,1)
		table.remove(film_curConfig,1)
		table.remove(film_curConfig,1)
	end
	
	self.text:setTouchable(false)
	--开始引导
	self:beginFilm()
end

function PushMapFilmView:beginFilm()

	if film_Config then
		self:run()
	end

end

function PushMapFilmView:run()
	if not self or tolua.isnull(self.view) then return end
	
	self.lockClick = false
	local sindex = self.index + 1
	if not film_curConfig or film_curConfig[sindex] == nil then
		self:finishStep()
		return
	end
	self.index = sindex
	print(33,"step,index",self.step,self.index)

	self.curData = film_curConfig[self.index]
	self["doFilmType"..self.curData.type](self,self.curData)

end

function PushMapFilmView:runNext()
	if not self or tolua.isnull(self.view) then return end

	--延迟一帧执行
	Scheduler.scheduleNextFrame(function() self:run() end)

end

function PushMapFilmView:finishStep()
	print(33,"finishStep ",self.step,self.index)
	--printTable(33,film_curConfig)
	if self.endfunc then
		self.endfunc()
	end
	
	self:closeView()
end

function PushMapFilmView:createItem(info,names)
	local spr = fgui.UIPackage:createObject("Film","user");
	spr:setPosition(info.x,info.y)
	spr:setWidth(info.w)
	spr:setHeight(info.h)
	if names then
		spr:setName(names)
	end
	if info.icon then
		spr:setIcon(self.userF..info.icon)
	end
	
	if info.mask==1 then
		spr:getChildAutoType("icon"):setColor(cc.c3b(155,155,155))
	else
		spr:getChildAutoType("icon"):setColor(cc.c3b(255,255,255))
	end
	
	if info.title then
		local title = spr:getChildAutoType("title")
		title:setVisible(true)
		title:setText(info.title.txt)
		title:setPosition(info.title.x,info.title.y)
		title:setFontSize(info.title.s)
		local c_info = string.split(info.title.c,",")
		title:setColor({r=c_info[1],g=c_info[2],b=c_info[3]})
	end
	if info.e then
		local d_info = string.split(info.e,",")
		if d_info[2] == "stop" or d_info[2] == "0" then
			self.lockClick = true
		end
		spr:addClickListener(function(context)
				context:stopPropagation()
				self:_doClick(d_info)
			end)
	else
		spr:setTouchable(false)
	end
	
	spr.sdata = info
	--spr:setName()
	self.layer:addChild(spr)
	
	if info.a then
		local ac = spr:getTransition(info.a)
		if ac then
			ac:play(function()
	
				end);
		else
			RollTips.show("not action "..info.a)
		end
	end
	
	return spr
end

function PushMapFilmView:doFilmType1(data)
	
	self.layer:removeChildren()
	if data.item and #data.item>0 then
		for i = 1, #data.item do
			local info = data.item[i]
			self:createItem(info,i)
		end
	end
	if self._capSceneSprite then
		self._capSceneSprite:setVisible(false)
	end
	local bg_info = string.split(data.bg,",")
	if bg_info and #bg_info > 1 then
		self.bg:setURL(bg_info[1])
		if bg_info[2] == "blur" then
			self:_setBlur(false,bg_info[3])
			if self._capSceneSprite then
				self._capSceneSprite:setVisible(true)
			end
		end
	else
		self.bg:setURL(self.bgF..data.bg)
	end
	
	self.user1:setData(data.user1)
	self.user2:setData(data.user2)
	self.call:setData(data.call)
	
	if self.bgAction then
		self.bgAction:stop(true,false)
		self.bgAction = false
	end
	if data.bga then
		local acc = self.view:getTransition(data.bga)
		if acc then
			self.bgAction = acc
			self.bgAction:play(function()

				end);
		else
			self.bgAction = false
			RollTips.show("not action "..data.bga)
		end
	else
		self.bgAction = false
	end
	
	local d_info = string.split(data.name,",")
	self.name:setTitle(d_info[1])
	
	self.name:setWidth(d_info[4])
	self.name:setHeight(d_info[5])
	self.name:setPosition(d_info[2],d_info[3])
	local t_info = string.split(data.text,",")
	
	self.text:setWidth(t_info[4])
	self.text:setHeight(t_info[5])
	self.text:setPosition(t_info[2],t_info[3])
	if t_info[6] then
		local pl = self.text:getTransition(t_info[6])
		if pl then
			pl:play(function()end);
		end
	end
	
	local textStr = string.gsub(t_info[1], "<br>","\n")
	local textLen = StringUtil.utf8len(textStr)
	
	local n = 1
	
	local function updateText()
		local str = StringUtil.utf8sub(textStr,0, n)
		self.text:setTitle(str);
		n = n + 1
		if n > textLen then
			self.text:displayObject():stopAllActions()
			self.clickFuc = false
			if self.isAuto then
				self.text:displayObject():runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() self:runNext() end)))
			end
		end
	end
	
	self.text:displayObject():stopAllActions()
	self.text:displayObject():runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.02),cc.CallFunc:create(function() updateText() end))))
	
	self.clickFuc = function()
		self.text:displayObject():stopAllActions()
		self.text:setTitle(textStr)
	end
	
	Scheduler.unschedule(self.schedulerIDAuto)
	if self.isAutoOpen == 0 then
		self.schedulerIDAuto = Scheduler.scheduleOnce(10,function()
				--判断view是否还存在
				if not tolua.isnull(self.view) then
					self.isAutoOpen = 1
					self.isAuto = true
					self.auto:setSelected(true)
					self:runNext()
				end
			end)
	end
	
end


function PushMapFilmView:doFilmType2(data)
	
	
end

function PushMapFilmView:guide_setNameSuccess()

	--self:closeView()
	self:runNext()
end

function PushMapFilmView:eventHaddle(type,params)
	if type == "guide1" then
		Dispatcher.dispatchEvent(EventType.guideType2_checkNext,1,6)
		ViewManager.open(params)
	elseif type == "guide2" then
		ViewManager.open(params)
		Dispatcher.dispatchEvent(EventType.guideType2_checkNext,1,11)
	end
end

function PushMapFilmView:_event2()

	--ViewManager.open("GuideSetNameView")
end

function PushMapFilmView:_doClick(d_info)
	
	if d_info[1] == "1" then
		
	elseif d_info[1] == "2" then
		ViewManager.open(d_info[4])
		if d_info[4] == "GuideRoleChoseView" then
--			Dispatcher.dispatchEvent(EventType.guideType2_checkNext,1,2)
		elseif d_info[4] == "GuideSetNameView" then
--			Dispatcher.dispatchEvent(EventType.guideType2_checkNext,1,4)
		end
	elseif d_info[1] == "3" then
		ModuleUtil.openModule(d_info[4])
	end
	if d_info[2] == "stop" or d_info[2] == "0" then
		return
	end
	
	if tonumber(d_info[3]) >0 then
		self.index = tonumber(d_info[3])-1
		self.step  = d_info[2]
		print(33,"我被点击了 ",data.e,self.step,self.index)
		film_curConfig = film_Config[self.step]
		self:run()
	end
	
	--print(33,"我被点击了")
end

function PushMapFilmView:_exit()
	if  self.isShowGuochangyun==true then
		Dispatcher.dispatchEvent(EventType.pushMap_figthendInfo)
	end
	Scheduler.unschedule(self.schedulerIDAuto)
	Scheduler.scheduleNextFrame(function()
		ViewManager.close("PushMapHuiguView")
	end)
	
end


return PushMapFilmView