--Name : TaskView.lua
--Author : generated by FairyGUI
--Date : 2020-6-23
--Desc : 

local TaskView,Super = class("TaskView", MutiWindow)

function TaskView:ctor()
	--LuaLog("TaskView ctor")
	self._packName = "Task"
	self._compName = "TaskView"
	--self._rootDepth = LayerDepth.Window
    --編輯器註冊的方式
	-- self.redArr ={"V_TASK_DAILY","V_TASK_WEEK","V_TASK_MAIN","V_RETRIEVERED"}
end

function TaskView:_initEvent( )
	
end

function TaskView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Task.TaskView
		vmRoot.EveryDailyView = viewNode:getChildAutoType("$EveryDailyView")--
		vmRoot.DailyTaskView = viewNode:getChildAutoType("$DailyTaskView")--
	    vmRoot.AchievementView = viewNode:getChildAutoType("$AchievementView")--
		vmRoot._tabBar = viewNode:getChildAutoType("$_tabBar")--list
		vmRoot.WeekDailyView = viewNode:getChildAutoType("$WeekDailyView")--
	--{vmFieldsEnd}:Task.TaskView
	--Do not modify above code-------------
end

function TaskView:onViewControllerChanged( )
	Super.onViewControllerChanged(self)
	TaskModel:setAniFlagIndex( self._preIndex+1,false)
end

function TaskView:_initUI( )
	print(1,"TaskView:_initUI( )")
	self:_initVM()
    --页面默认打开
	self._args.viewData = {}
	local info = {
			red= "V_TASK_DAILY",
			mid= ModuleId.Task.id,
			title = Desc.task_richang,
			page="EveryDailyView",
		}
	table.insert(self._args.viewData, info);
	local info = {
		red= "V_TASK_WEEK",
		mid= ModuleId.Task.id,
		title = Desc.task_zhouchang,
		page="WeekDailyView",
	}
	table.insert(self._args.viewData, info);
	local info = {
		red= "V_TASK_MAIN",
		mid= ModuleId.Task.id,
		title = Desc.task_xhuxian,
		page="DailyTaskView",
	}
	table.insert(self._args.viewData, info);
	local info = {
		red= "V_TASK_Achievement",
		mid= ModuleId.TaskAchievement.id,
		title = Desc.task_chengjiu,
		page="AchievementView",
	}
	table.insert(self._args.viewData, info);
	
	if (not ModuleUtil.getModuleOpenTips(ModuleId.Retrieve.id)) then
        local info = {
            red = "V_RETRIEVERED",
            mid = ModuleId.Retrieve.id,
            title = Desc.task_zhaohui,
            page = "RetrieveView",
        }
        table.insert(self._args.viewData, info)
	end
	self._tabBar:setItemRenderer(function(index, obj)
		local d = self._args.viewData[index + 1];
		if d.red and d.red ~= "" then
			RedManager.register(d.red, obj:getChildAutoType("img_red"), d.mid);
		end
		obj:setTitle(d.title);
		-- local icon = obj:getChildAutoType("icon")
		--obj:setIcon("Icon/mainSub/"..d.mid..".png")
		--local icon = obj:getChildAutoType("icon")
		--icon:setScale(0.8,0.8)
	end)
	self._tabBar:setNumItems(#self._args.viewData)
    if RedManager.getTips("V_TASK_DAILY") then
		self._args.page =self._args.viewData[1].page
	  else
		   if RedManager.getTips("V_TASK_WEEK") then
			   self._args.page =self._args.viewData[2].page
		   elseif RedManager.getTips("V_TASK_MAIN") then
			   self._args.page = self._args.viewData[3].page
		   end
	  end
end




return TaskView