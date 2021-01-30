--Date :2020-12-27
--Author : add by xhd
--Desc : 巅峰总界面

local StrideMainView,Super = class("StrideMainView", MutiWindow)

function StrideMainView:ctor()
	--LuaLog("StrideMainView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideMainView"
	--self._rootDepth = LayerDepth.Window
	
end

function StrideMainView:_initEvent( )
	
end

function StrideMainView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideMainView
	self._tabBar = viewNode:getChildAutoType('_tabBar')--GList
	self.btn_record = viewNode:getChildAutoType('btn_record')--GButton
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.guessBtn = viewNode:getChildAutoType('guessBtn')--Button6
		self.guessBtn.img_red = viewNode:getChildAutoType('guessBtn/img_red')--GImage
	self.lastText = viewNode:getChildAutoType('lastText')--GTextField
	self.lastTime = viewNode:getChildAutoType('lastTime')--GTextField
	self.viewCtrl = viewNode:getController('viewCtrl')--Controller
	--{autoFieldsEnd}:StrideServer.StrideMainView
	--Do not modify above code-------------
end

function StrideMainView:_initListener( )
	
	-- self.leftList:setItemRenderer(function(index, obj)

	-- end)

end

function StrideMainView:_initUI( )
	self:_initVM()
	self:_initListener()
	self:setBg("bg_stride.jpg")
	self.btn_record:addClickListener(function()
        ViewManager.open("StrideGuessRecordView")
	end)

	self.view:addEventListener(FUIEventType.Click,function(context)
		Dispatcher.dispatchEvent(EventType.update_event_combox,context)
	end)

	local redImg = self.guessBtn:getChildAutoType("img_red")
	RedManager.register("V_Stride", redImg);

	self.guessBtn:addClickListener(function()
		if  StrideServerModel:isActiveIng() then
			local smallState = StrideServerModel:getSmallStage(  )
			print(1,"smallState",smallState)
			if smallState == 1 then
				ViewManager.open("StrideRecordInView") --竞猜
			elseif smallState == 2 then
				--直接三连播 播放记录
				RPCReq.TopArena_GetGuessRecordIdList({},function(data)
					if next(data) then
						if #data.recordIdList==3 then
							local btypeArr = {GameDef.BattleArrayType.TopArenaAckOne,GameDef.BattleArrayType.TopArenaAckTwo,GameDef.BattleArrayType.TopArenaAckThree}
							StrideServerModel:battleBegin(data.recordIdList,btypeArr,GameDef.GamePlayType.TopArena)
						else
							ViewManager.open("StrideRecordInView") --竞猜
						end
					end
				end)
			elseif smallState == 3 then
				--打开竞猜成功->统一记录回放->观看记录
				ViewManager.open("StrideRecordInView") --竞猜
			end
		else
			RollTips.show("活动已结束")
		end
	end)


   --页面默认打开
   self._args.viewData = {}
   local info = {
		--    red= "V_TASK_DAILY",
		--    mid= ModuleId.Task.id,
		   title =DescAuto[288], -- [288]="巅峰赛"
		   page="StrideMainView",
	   }
   table.insert(self._args.viewData, info);

   local info = {
	--    red= "V_TASK_MAIN",
	--    mid= ModuleId.Task.id,
	   title = DescAuto[290], -- [290]="晋级赛"
	   page="StrideRankJJGameView",
   }
   table.insert(self._args.viewData, info);
   local info = {
	--    red= "V_TASK_Achievement",
	--    mid= ModuleId.TaskAchievement.id,
	   title = DescAuto[291], -- [291]="冠军赛"
	   page="StrideRankGJGameView",
   }
   table.insert(self._args.viewData, info);
   
   self._tabBar:setItemRenderer(function(index, obj)
	    local d = self._args.viewData[index + 1];
	    if not  StrideServerModel:getMainSelectPage() then
		   StrideServerModel:setMainSelectPage(1)
		   obj:setSelected(true)
	--    elseif StrideServerModel:getMainSelectPage() == index+1 then
	-- 	   obj:setSelected(true)
		elseif 1 == index+1 then
			obj:setSelected(true)
		end
	   if d.red and d.red ~= "" then
		   RedManager.register(d.red, obj:getChildAutoType("img_red"), d.mid);
	   end
	   obj:setTitle(d.title);
   end)
   self._tabBar:setNumItems(#self._args.viewData)
   self:updatePanel()
end

function StrideMainView:_viewChangeCallBack(index)
	StrideServerModel:setMainSelectPage(index+1)
end


--更新页面
function StrideMainView:updatePanel(  )
   self:updateTimeShow()
end

function StrideMainView:updateTimeShow( ... )
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
		self.__timerId = false
	end
	local status,timems = StrideServerModel:getLastTime( )
	-- if status <1 then
	-- 	self.lastTime:setText("赛季已结束")
	-- 	return
	-- end
	-- local smallStage =  StrideServerModel:getSmallStage()
	-- if smallStage == 1 then
	if status == 2 or status == 0 then
		self.lastText:setText("开启倒计时：")
	else
		self.lastText:setText("赛季倒计时：")
	end
	timems = timems	
	local function updateCountdownView(time)
		local dayTime = 24*60*60
		local timeStr = ""
		if time > 0 then
			if time<dayTime then
				timeStr = TimeLib.GetTimeFormatDay(time,2)
			else
				timeStr = TimeLib.GetTimeFormatDay1(time,2)
			end
			self.lastTime:setText(timeStr)
		else
			self.lastTime:setText("赛季已结束")
		end
	end
	updateCountdownView(timems)
	self.__timerId = TimeLib.newCountDown(timems, function(time)
		updateCountdownView(time)
	end, function()
		self.lastTime:setText("赛季已结束") -- TODO
	end, false, false, false)
end

function StrideMainView:_exit( ... )
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
		self.__timerId = false
	end
end


return StrideMainView
