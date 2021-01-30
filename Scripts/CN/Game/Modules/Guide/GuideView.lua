--Name : GuideView.lua
--Author : zhouguoshan
--Date : 2020-3-10
--Desc : 新手引导

local GuideView,Super = class("GuideView", MutiWindow)


local guide_Config = false
local guide_curConfig = false



function GuideView:ctor()
	--LuaLog("GuideView ctor")
	self._packName = "Guide"
	self._compName = "GuideView"
	self._isFullScreen = false
	self._rootDepth = LayerDepth.Guide
	
	self.schedulerID = false
	self.firstq = true

end

function GuideView:_initEvent( )
	
end

function GuideView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Guide.GuideView
		local GuideType1View = viewNode:getChildAutoType("$GuideType1View")--
		vmRoot.GuideType1View = GuideType1View
			GuideType1View.text1 = viewNode:getChildAutoType("$GuideType1View/$text1")--richtext
			GuideType1View.imageBg = viewNode:getChildAutoType("$GuideType1View/$imageBg")--loader
		vmRoot.nextbt = viewNode:getChildAutoType("$nextbt")--Button
		local GuideType2View = viewNode:getChildAutoType("$GuideType2View")--
		vmRoot.GuideType2View = GuideType2View
			GuideType2View.window = viewNode:getChildAutoType("$GuideType2View/$window")--
			GuideType2View.guang = viewNode:getChildAutoType("$GuideType2View/$guang")--loader
			GuideType2View.hand = viewNode:getChildAutoType("$GuideType2View/$hand")--image
			local text = viewNode:getChildAutoType("$GuideType2View/$text")--Label
			GuideType2View.text = text
				text.texbg = viewNode:getChildAutoType("$GuideType2View/$text/$texbg")--image
	--{vmFieldsEnd}:Guide.GuideView
	--Do not modify above code-------------
end





function GuideView:_initUI( )
	self:_initVM()
	
	GuideModel.guideMode = self._args.guideMode
	
	self.nextbt:addClickListener(function()
			if GuideModel.guideMode == 1 and GuideModel.step == 1 then
				return;
			end
			
			local info = {}
			--info.text = "确定跳过此引导？"

			info.type = "yes_no"
			info._rootDepth = self._rootDepth
			info.onYes = function()
				if GuideModel.guideMode == 1 then
					PHPUtil.reportStep(19999)
					--self:updateGuideToServer(#guide_Config,GuideModel.checkCount)
				end
				
				self:closeView()
				
				--self.firstq = false
				--self.nextbt:setVisible(false)
				--self:finishStep()
				
			end
			
			if self.firstq then
				Alert.show(info)
			else
				info.onYes()
			end
			
			
		end)
	
	self.view:setWidth(display.width)
	self.view:setHeight(display.height)
	self.nextbt:setVisible(false)
	
end


function GuideView:_initFinish()
	--开始引导
	self:beginCheckGuide()
end



function GuideView:checkCurLevel()
	
	local serverData = DynamicConfigData.t_NoviceProcess[GuideModel.curValue]
	if serverData and serverData.node == GuideModel.guideName then
		if (serverData.module == GuideModel.step and serverData.steps > GuideModel.index) or serverData.module > GuideModel.step  then
			GuideModel.step =  serverData.module
			GuideModel.index =  serverData.steps
		end
	end
	
	if guide_curConfig[GuideModel.index] then
		GuideModel.level =  1
		for i = 1, GuideModel.index do
			if guide_curConfig[i].ed == 1 then
				GuideModel.level = GuideModel.level+1
			end
		end
	else
		GuideModel.level = 1
	end
	print(33,"checkCurLevel",GuideModel.level)
end


function GuideView:beginCheckGuide()
	
	if self._args.guideName then
		GuideModel.guideName = self._args.guideName
		GuideModel.level = 1
		GuideModel.step =  self._args.guideStep or 1
		GuideModel.index =   0
		GuideModel.indexTop = -1
		GuideModel.guideGroup = {GuideModel.guideName}
		--local repeatG = false
		--for i = 1, #GuideModel.guideGroup do
			--if GuideModel.guideGroup[i] == "firstGuide" then
				--table.remove(GuideModel.guideGroup,i)
				--break
			--end
		--end
		
		--for i = 1, #GuideModel.guideGroup do
			--if GuideModel.guideGroup[i] == self._args.guideName then
				--repeatG = true
				--break
			--end
		--end
		--if not repeatG then
			--table.insert(GuideModel.guideGroup,GuideModel.guideName)
		--end
	end

	if GuideModel.guideName == "firstGuide" then
		GuideModel.guideMode = 1 
	end
	
	
	guide_Config = GuideModel.guide_AllConfig[GuideModel.guideName]
	if guide_Config then
		guide_curConfig = guide_Config[GuideModel.step]
	end
	
	
	if guide_curConfig then
		self:checkCurLevel()
		GuideModel.index =  self._args.guideIndex or 0
		GuideModel:updateGuideToServer()
		self:run()
	else
		Scheduler.scheduleNextFrame(function()
				self:closeView()
			end)
	end
	
end




function GuideView:finishStep()
	GuideModel.step = GuideModel.step + 1
	guide_curConfig = guide_Config[GuideModel.step]
	print(33,"GuideView:finishStep()")
	if guide_curConfig then
		GuideModel.state = 1
		GuideModel.index = 0
		GuideModel.indexTop = -1
		GuideModel.level = 1
		GuideModel:updateGuideToServer()

		self:runNext()
	--elseif GuideModel.step > #guide_Config and self.guideMode == 1 then
		--self.GuideTpye1:setVisible(false)
		--self.GuideTpye2:setVisible(false)
		--self:updateGuideToServer(GuideModel.step,GuideModel.checkCount)
		--self:closeView()
	else
		print(33,"not guide_curConfig")
		if #GuideModel.guideGroup > 1 then
			print(33,"guideGroup > 1")
			local oldName = GuideModel.guideName
			GuideModel.guideName = ""
			for i = 1, #GuideModel.guideGroup do
				if GuideModel.guideGroup[i] ~= oldName then
					GuideModel.guideName = GuideModel.guideGroup[i]
				end
			end
			
			for i = 1, #GuideModel.guideGroup do
				if GuideModel.guideGroup[i] == oldName then
					table.remove(GuideModel.guideGroup,i)
					break
				end
			end
			
			GuideModel.level = 1
			GuideModel.step = 1
			GuideModel.state = 1
			GuideModel.index = 0
			GuideModel.indexTop = -1
			guide_Config = GuideModel.guide_AllConfig[GuideModel.guideName]
			if guide_Config then
				guide_curConfig = guide_Config[GuideModel.step]
			end
			GuideModel:updateGuideToServer()
			if guide_curConfig then
				self:runNext()
			else
				self:closeView()
			end
			
			
		else
			GuideModel.guideGroup = {}
			GuideModel.level = 1
			GuideModel.indexTop = -1
			GuideModel:updateGuideToServer()
			self:closeView()
		end
	end
end




function GuideView:run()
	if tolua.isnull(self.view) then return end
	
	GuideModel.index = GuideModel.index + 1
	
	local g_data = guide_curConfig[GuideModel.index]
	--小于当前等级的步骤跳过
	while g_data do
		local level = g_data.level or 1
		if level >= GuideModel.level then
			break
		end
		GuideModel.index = GuideModel.index + 1
		g_data = guide_curConfig[GuideModel.index]
	end
	
	
	if guide_curConfig == nil or guide_curConfig[GuideModel.index] == nil then
		self:finishStep()
		return
	end
	print(33,"step,index",GuideModel.step,GuideModel.index)
	--self.searchView = false
	GuideModel.curData = guide_curConfig[GuideModel.index] or false
	local page = "GuideType"..GuideModel.curData.type.."View"
	self:_setPage(page)
	
	--self.view:setVisible(false)
	if GuideModel.guideMode == 1 then
		local stepRecord = 10000+GuideModel.step*100+GuideModel.index*1
		PHPUtil.reportStep(stepRecord)
		
		if GuideModel.step == 1 and GuideModel.index == 2 then
			PHPUtil.reportStep(ReportStepType.CHOOSE_EVENT)
		end
	end
	--因为要改变table数据，所以复制一份
	GuideModel.curData = clone(GuideModel.curData)
	
	if GuideModel.curData.func and GuideModel.curData.funcType then
		
		local funcData = string.split(GuideModel.curData.func,",")
		local typeData = string.split(GuideModel.curData.funcType,",")
		if funcData and typeData and #typeData > 0 then
			for i = 1, #typeData do
				GuideModel.curData["func"..typeData[i]] = funcData[i]
			end
		end
		if GuideModel.curData.func1 then
			GuideModel:_doGuideFunc(GuideModel.curData.func1)
		end
		GuideModel.curData.func = nil
		GuideModel.curData.funcType = nil
	end
	
	if GuideModel.curData.openView then
		local openView = string.split(GuideModel.curData.openView,",")
		local openArgs = nil
		if openView[5] then openArgs = loadstring("return "..openView[3]..","..openView[4]..","..openView[5])() 
		elseif openView[4] then openArgs = loadstring("return "..openView[3]..","..openView[4])() 
		elseif openView[3] then openArgs = loadstring("return "..openView[3])() end
		if openView[1] == "1" then
			ViewManager.open(openView[2],openArgs)
		elseif openView[1] == "2" then
			ModuleUtil.openModule(tonumber(openView[2]),openArgs)
		end

	elseif GuideModel.curData.type == 9 then
		self.view:setVisible(false)
	end
	
	GuideModel:updateRecordId(GuideModel.curData)
	
	self.ctlView[page]:doGuide(GuideModel.curData)
	
end

function GuideView:runNext(step,index)
	
	if not self or tolua.isnull(self.view) then return end
	
	if index then
		GuideModel.index =  index
	end
	
	if GuideModel.curData and GuideModel.curData.func3  then
		GuideModel:_doGuideFunc(GuideModel.curData.func3)
		GuideModel.curData.func3 = nil
	end
	--if GuideModel.curData and GuideModel.curData.doRunNext then return end
	--GuideModel.curData.doRunNext = true
	
	--保证上一个定时器被释放
	Scheduler.unschedule(self.schedulerID)
	--延迟一帧执行
	self.schedulerID = Scheduler.scheduleNextFrame(function() self:run() end)
	
end





function GuideView:_initEvent( ... )
	
	--self:addEventListener(EventType.view_open,self)
end

function GuideView:guide_runNext(_,step,index)
	GuideModel:updateGuideToServer()
	print(33,"guide_runNext",step,index,GuideModel.waitEvent)
	if step and step == "playerSeatLatout" then
		if GuideModel.waitEvent == false then
			return
		end
		step = nil
		GuideModel.waitEvent = false
	
	elseif step and step ~= GuideModel.step then 
		return 
	end
	
	self:runNext(step,index)
end



function GuideView:view_open(_,view)
	--print(33,"view open :",view._viewName)
	--if self.searchView  then 
		--self:GuideTpye2Logic(self.curData)	
		--self.searchView = false
	--end

end

function GuideView:_exit()
	--RollTips.show("引导结束了")
end


function GuideView:_event1()
	--ViewManager.open("GuideRoleChoseView")
end

function GuideView:_event2()
	
	--ViewManager.open("GuideSetNameView")
end

function GuideView:socket_disconnect()

	self:closeView()
end


return GuideView