--modify by xhd
--道具框封裝
local MainAdBoard = class("MainAdBoard")
local ActivityMap = require "Game.Modules.Activity.ActivityMap"
function MainAdBoard:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);

	self.list_point = false
	self.list_ad = false
	self._updateTimeId = false
	self._adData = false
	self._adShowData = false
	self._curIndex = 0
end

function MainAdBoard:init( ... )
	self.list_point = self.view:getChildAutoType("list_point")
	self.list_ad = self.view:getChildAutoType("list_ad")
	self.list_ad:setVirtualAndLoop()
	self.list_ad:setItemRenderer(function( index,obj )
		local img = obj:getChildAutoType("n0")
		img:setURL(PathConfiger.getActivityIcon(self._adData[index+1].showContent.bannerSrc,2))
		obj:removeClickListener(33)
		obj:addClickListener(function( ... )
			print(1,"点击打开的活动ID=",self._adData[index+1].id)
			if self._adData[index+1].speFlag then
				local mainActiveId = 1
		        local winData = ActivityModel:marketUIWinData(mainActiveId) 
		        if (winData and (#winData > 0)) then
		            ViewManager.open(ActivityMap.ActivityFrame[mainActiveId],{viewData =winData,page = winData[1].page})
		        else
		            RollTips.show(Desc.activity_txt1);
		        end
			else
				if self._adData[index+1].showContent.activitymark == 2 then
					local mainActiveId = self._adData[index+1].showContent.mainActiveId
					local winData = ActivityModel:marketUIWinData(mainActiveId)
					ViewManager.open(ActivityMap.ActivityFrame[mainActiveId],{viewData = winData,page = ActivityMap.actWinMap[self._adData[index+1].showContent.moduleOpen]})
				else
					local hasOpen = ModuleUtil.moduleOpen( self._adData[index+1].showContent.moduleOpen, true )
					if hasOpen then
						ViewManager.open(ActivityMap.actWinMap[self._adData[index+1].showContent.moduleOpen],{actData=self._adData[index+1]})
					end
				end
			end
			
		end,33)
	end)

    local function doSpecialEffect( context )
		local index = (self.list_ad:getFirstChildInView())%self.list_ad:getNumItems()
        self._curIndex = index
	    self.list_point:setNumItems(#self._adData)
	end
	self.list_ad:addEventListener(FUIEventType.Scroll,doSpecialEffect)
    
    self.list_point:setVirtual()
	self.list_point:setItemRenderer(
		function(index, obj) 
			local c1 = obj:getController("c1")
			c1:setSelectedIndex(index == self._curIndex and 1 or 0)
			obj:removeClickListener(100)
			obj:addClickListener(function ( ... )
				self:showPage(index)
			end,100)
		end
	)
end

function MainAdBoard:setData(data)
	self._adData = data
	--printTable(1, "===== 主界面banner ====", data);
	self._adShowData = data
	self.list_ad:setData(self._adShowData)
	self.list_point:setNumItems(#self._adData)
	self:showPage(0)
end

function MainAdBoard:showNext()
	local curIndex = self.list_ad:getFirstChildInView()
	local nextIndex = curIndex + 1
	self.list_ad:scrollToView(nextIndex, true)
end

function MainAdBoard:showPage(index)
	self.list_ad:scrollToView(index, true)
	self._curIndex = math.mod(index, #self._adData)
	self.list_point:setNumItems(#self._adData)
	if self._updateTimeId then
		Scheduler.unschedule(self._updateTimeId)
		self._updateTimeId = false
	end
	self._updateTimeId  = Scheduler.schedule(function()
		self:showNext()
	end,5)
end


--退出操作 在close执行之前 
function MainAdBoard:__onExit()
    print(1,"MainAdBoard __onExit")
	if(self._updateTimeId) then
		Scheduler.unschedule(self._updateTimeId)
		self._updateTimeId = false
	end
end

return MainAdBoard