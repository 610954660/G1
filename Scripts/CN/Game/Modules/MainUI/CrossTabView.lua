--Date :2020-12-26
--Author : generated by FairyGUI
--Desc : 

local CrossTabView,Super = class("CrossTabView", View)

function CrossTabView:ctor()
	--LuaLog("CrossTabView ctor")
	self._packName = "MainSubBtn"
	self._compName = "CrossTabView"
	--self._rootDepth = LayerDepth.Window
	self.calltimer = {}
end

function CrossTabView:_initEvent( )
end

function CrossTabView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:MainSubBtn.CrossTabView
	self.list = viewNode:getChildAutoType('list')--GList
	--{autoFieldsEnd}:MainSubBtn.CrossTabView
	--Do not modify above code-------------
end

function CrossTabView:_initListener( )

	self.list:setItemRenderer(function(index, obj)
		local data = self.list._dataTemplate[index+1]
		if data.res == self.templateUI2 then
			local list = obj:getChildAutoType('list')
			list:setItemRenderer(function(index2, obj2)
				local tData = data[index2+1]
				self:initLocalRes(index2, obj2,tData)
				tData.fun(function(data2)
					if tolua.isnull(obj2) then return end
					self:initDataRes(index2, obj2,data2)
				end)
			end)
			list:setNumItems(2)
		else
			self:initLocalRes(index, obj,data)
			data.fun(function(data)
				if tolua.isnull(obj) then return end
				self:initDataRes(index, obj,data)
			end)
		end
	end)
	self.list:setItemProvider(function(index)
		return self.list._dataTemplate[index+1].res 
        end)
end

function CrossTabView:_initUI( )
	self:_initVM()
	self:_initListener()
	-- if not StrideServerModel:checkBaseInfoState( ) then
	StrideServerModel:reqInfoData()
	-- end
	local pos = self.list:localToGlobal(Vector2.zero)
	local width = self.list:getWidth()
	local dis = display.width - ( pos.x + width )
	if dis > 0 then
		self.list:setWidth(width + dis)
	end

	-- fun 回调 通用数据格式说明 可能延迟返回的数据
	--当初设置一个fun回调的初衷是各功能数据可以在列表初始化的时候再请求服务器去拿，然后回调更新界面
	
	--data.dayTimes 	= 当前剩余免费次数
	--data.seasonTime 	= 距离赛季结束时间
	--data.rank 		= 当前排名
	--data.red 			= 红点   "V_CrossArenaPVP"
	--data.moduleId 	= 模块ID

	--res = "ui://rg68duaml58txcwx19", 		UI控件 
	--bg  = "UI/MainSub/bg_1.png",     		背景
	--bg2  = "UI/MainSub/titlebg_1.png",	标题背景
	--titleBig  = "天",						第一个字
	--titleMid  = "域试炼",					后面的字
	--titleYw  = "TIAN YU SHI LIAN",	    英文标题

	--模板
	self.templateUI1 = "ui://rg68duam9j4nxcwwzy"   --单个
	self.templateUI2 = "ui://rg68duaml58txcwx19"	--两个上下一起
	
	self.TabData = {
		[1] = {
			fun = function(fun)CrossPVPModel:getMainSubInfo(fun)end,  --当初设置
			res = self.templateUI1,
			bg  = "UI/MainSub/bg_1.png",
			bg2  = "UI/MainSub/titlebg_1.png",
			titleBig  = "天",
			titleMid  = "域试炼",
			titleYw  = "TIAN YU SHI LIAN",
		},

		[2] = {
			fun = function(fun) CrossTeamPVPModel:getMainSubInfo(fun) end,
			res = self.templateUI1,
			bg  = "UI/MainSub/bg_2.png",
			bg2  = "UI/MainSub/titlebg_2.png",
			titleBig  = "先",
			titleMid  = "驱组队竞技",
			titleYw  = "XIAN QU ZU DUI JING JI",
		},

		[3] = {
			fun = function(fun) end,
			res = self.templateUI2,
			[1] = {
				fun = function(fun) CrossArenaPVPModel:getMainSubInfo(fun) end,
				bg  = "UI/MainSub/bg_3.png",
				bg2  = "UI/MainSub/titlebg_3.png",
				titleBig  = "跨",
				titleMid  = "服竞技",
				titleYw  = "KUA FU JING JI",
			},
			[2] = {
				fun = function(fun) StrideServerModel:getMainSubInfo(fun) end,
				bg  = "UI/MainSub/bg_4.png",
				bg2  = "UI/MainSub/titlebg_6.png",
				titleBig  = "巅",
				titleMid  = "峰竞技",
				titleYw  = "DIAN FENG JING JI",
			},
		},
		[4] = {
			fun = function(fun) end,
			res = self.templateUI2,
			[1] = {
				fun = function(fun) 	CrossLaddersModel:getMainSubInfo(fun) end,
				bg  = "UI/MainSub/bg_7.png",
				bg2  = "UI/MainSub/titlebg_5.png",
				titleBig  = "跨",
				titleMid  = "服天梯赛",
				titleYw  = "KUA FU TIAN TI SAI",
			},
			[2] = {
				fun = function(fun) 	CrossLaddersChampModel:getMainSubInfo(fun) end,
				bg  = "UI/MainSub/bg_8.png",
				bg2  = "UI/MainSub/titlebg_7.png",
				titleBig  = "天",
				titleMid  = "梯冠军赛",
				titleYw  = "TIAN TI GUAN JUN SAI",
			}
		},

		[5] = {
			fun = function(fun) ExtraordinarylevelPvPModel:getMainSubInfo(fun) end,
			res = self.templateUI1,
			bg  = "UI/MainSub/bg_5.png",
			bg2  = "UI/MainSub/titlebg_4.png",
			titleBig  = "超",
			titleMid  = "凡段位赛",
			titleYw  = "CHAO FAN DUAN WEI SAI",
		},
        -- --巅峰竞技
		-- [6] = {fun = function(fun)
		-- 	StrideServerModel:getMainSubInfo(fun)
		-- end,
		-- res = "ui://rg68duaml58txcwx19",
		-- bg  = "UI/MainSub/bg_1.png",
		-- bg2  = "UI/MainSub/titlebg_1.png",
		-- titleBig  = "天",
		-- titleMid  = "域试炼",
		-- titleYw  = "TIAN YU SHI LIAN",
		-- },

	}
	self:CrossTabView_refresh()
end

function CrossTabView:CrossTabView_refresh()
	self.list:setData(self.TabData)
end

function CrossTabView:TopArena_NotifyActChange( ... )
	self.list:setData(self.TabData)
end


function  CrossTabView:update_stride_enterPanel()
	self.list:setData(self.TabData)
end

--设置本地数据
function CrossTabView:initLocalRes(index, obj,data)
	if data.bg then
		obj:getChildAutoType("bg"):setURL(data.bg)
	end
	if data.bg2 then
		obj:getChildAutoType("bg2"):setURL(data.bg2)
	end
	if data.titleBig then
		obj:getChildAutoType("titleBig"):setText(data.titleBig)
	end
	if data.titleMid then
		obj:getChildAutoType("titleMid"):setText(data.titleMid)
	end
	if data.titleYw then
		obj:getChildAutoType("titleYw"):setText(data.titleYw)
	end
end

--设置各功能获取的数据
function CrossTabView:initDataRes(index, obj,data)
	--检查玩法是否开启
	if not self:checkOpen(index, obj,data) then return end

	--这部分如果显示不相同自己实现吧
	if data.moduleId == ModuleId.StridePVP.id then
		self:strideCellShow(index, obj,data)
	else
		self:commonShow(index, obj,data)
	end


	--点击操作
	obj:addClickListener(function(context)
			self:touchItem(data.moduleId)
		end,100)

	--红点
	if data.red then
		RedManager.register(data.red, obj:getChildAutoType("img_red"),data.moduleId);
	end
end

function CrossTabView:checkOpen(index, obj,data)
	local tips = ModuleUtil.getModuleOpenTips(data.moduleId)
	--未开启 根据开服时间显示开启倒计时
	if tips then
		obj:getChildAutoType("openTips"):setText(tips..Desc.moduleOpen_tips0)
		obj:getChildAutoType("bg"):setColor({r = 150,g = 150,b = 150})
		obj:getController("status"):setSelectedIndex(1)
		local seasonTime = obj:getChildAutoType("seasonTime")
		local mInfo = DynamicConfigData.t_module[data.moduleId]
		if mInfo.beginTime and mInfo.beginTime > 0 then
			seasonTime:setVisible(true)
			self:timeUpdata(index,obj,mInfo.beginTime,Desc.MainSubBtn_crossView4)
		elseif data.seasonTime and data.seasonTime > 0 then
			self:timeUpdata(index,obj,data.seasonTime,data.entranceTitle or Desc.MainSubBtn_crossView3)
		else
			seasonTime:setVisible(false)
		end
		 return false
	end
	return true
end

function CrossTabView:commonShow(index, obj,data)
	
	local danIcon 		= obj:getChildAutoType("danIcon")
	local txt_danName 	= obj:getChildAutoType("txt_danName")
	local danCtrl = obj:getController("danCtrl")
	local showCtrl 	= obj:getController("showCtrl")
	local freeTimesGroup 	= obj:getChildAutoType("freeTimesGroup")	
	local isCrossChampCtrl 	= obj:getController("isCrossChampCtrl")

	if data.moduleId == ModuleId.CrossTeamPVP.id then
		txt_danName:setText(data.danName or "")
		danIcon:setIcon(data.danIcon or "")
		danCtrl:setSelectedIndex(1)
	elseif data.moduleId == ModuleId.CrossLaddersChamp.id then
		showCtrl:setSelectedIndex(0)
		freeTimesGroup:setVisible(false)
		isCrossChampCtrl:setSelectedIndex((not CrossLaddersChampModel:checkIsJoinEnough() and (CrossLaddersChampModel:isSecond() or  CrossLaddersChampModel:isPreMatch()) and 1 or 0))
	else
		danCtrl:setSelectedIndex(0)
	end
	
	obj:getController("status"):setSelectedIndex(0)
	obj:getChildAutoType("leftTime"):setText(Desc.MainSubBtn_crossView1:format(data.dayTimes or 0))
	obj:getChildAutoType("rank"):setText(Desc.MainSubBtn_crossView2:format(tostring(data.rank or 0)))
	
	self:timeUpdata(index,obj,data.seasonTime or 0,data.entranceTitle or Desc.MainSubBtn_crossView3,data.moduleId)
end

function CrossTabView:strideCellShow( index, obj,data )
	printTable(1,"data",data)
	if data.status then
		if data.state ==0 then
			obj:getController("status"):setSelectedIndex(0)
			obj:getController("showCtrl2"):setSelectedIndex(0)
			local config = DynamicConfigData.t_module[data.moduleId]
			local days = 0
			for i,v in ipairs(config.condition) do
				if v.type == 4 then
					days = v.val
					break
				end
			end
			if days>0 then
				obj:getChildAutoType("openTips"):setText("开服"..days.."天后开启")
			else
				obj:getChildAutoType("openTips"):setText("开服36天后开启")
			end
			self:timeUpdata(index,obj,data.seasonTime or 0,data.entranceTitle or "开启倒计时：%s",data.moduleId)
		elseif data.state == 1 then
			obj:getController("status"):setSelectedIndex(0)
			obj:getController("showCtrl"):setSelectedIndex(1)
			obj:getController("showCtrl2"):setSelectedIndex(1)
			obj:getChildAutoType("stateTxt"):setText(StrideServerModel:getSmallStateStr())
			self:timeUpdata(index,obj,data.seasonTime or 0,data.entranceTitle or Desc.MainSubBtn_crossView3,data.moduleId)
		else --下个赛季
			obj:getController("status"):setSelectedIndex(0)
			obj:getController("showCtrl"):setSelectedIndex(1)
			obj:getChildAutoType("leftTime"):setText(StrideServerModel:getSmallStateStr())
			self:timeUpdata(index,obj,data.seasonTime or 0,data.entranceTitle or "开启倒计时：%s",data.moduleId)
		end
	else
		obj:getController("status"):setSelectedIndex(1)
		obj:getController("showCtrl"):setSelectedIndex(1)
		obj:getChildAutoType("openTips"):setText("未开启")
		obj:getChildAutoType("leftTime"):setText(StrideServerModel:getSmallStateStr())
		self:timeUpdata(index,obj,data.seasonTime or 0,data.entranceTitle or "开启倒计时：%s",data.moduleId)
	end
end


--定时器
function CrossTabView:timeUpdata(index,obj,timeDt,fontDes,moduleId)

	local seasonTime = obj:getChildAutoType("seasonTime")
	seasonTime:setText(fontDes:format(timeDt))
	--启动定时器
	if timeDt > 0 then
		seasonTime:setText(TimeLib.GetTimeFormatDay(timeDt, 2))
		local dayTime = 24*60*60
		local function onCountDown(time)
			if time<dayTime then
				seasonTime:setText(fontDes:format(TimeLib.formatTime(time)))
			else
				seasonTime:setText(fontDes:format(TimeLib.GetTimeFormatDay1(time)))
			end
		end
		local function onEnd(...)
			self:CrossTabView_refresh()
			print(8848,"11111111111111111")
			if moduleId ~= ModuleId.CrossTeamPVP.id or 
				moduleId ~= ModuleId.CrossLadders.id then
				seasonTime:setText(Desc.common_txt1)
			end
		end
		if self.calltimer[obj] then
			TimeLib.clearCountDown(self.calltimer[obj])
		end
		self.calltimer[obj] = TimeLib.newCountDown(timeDt, onCountDown, onEnd, false, false, false)
	else
		seasonTime:setText(Desc.common_txt1)
	end
end

--点击响应
function CrossTabView:touchItem(moduleId)

	if moduleId == ModuleId.CrossPVP.id then
		local crossData = CrossPVPModel:getSeverData()
		if not crossData then
			RollTips.show(Desc.activity_txt1)
			return
        end
    elseif moduleId == ModuleId.CrossTeamPVP.id then
        CrossTeamPVPModel:getDefTemp()
        return
    end
    local tips = ModuleUtil.getModuleOpenTips(moduleId)
    if tips ~= nil then
        RollTips.show(Desc.WorldChallenge_str5)
        return
	end
	if moduleId == ModuleId.StridePVP.id then
		if not  StrideServerModel:isActiveIng() then
			RollTips.show("未达到开启条件")
			return
		end
	end
	if moduleId == ModuleId.CrossLaddersChamp.id then
		CrossLaddersChampModel:entrance()
		return
	end

    ModuleUtil.openModule(moduleId, true)
end


function CrossTabView:_exit()
	--移除定时器
	for k,v in pairs(self.calltimer) do 
		if v then TimeLib.clearCountDown(v) end
	end
end


return CrossTabView