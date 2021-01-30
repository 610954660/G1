--Date :2020-12-27
--Author : add by xhd
--Desc : 巅峰竞技场入口类

local StrideSeverView,Super = class("StrideSeverView", Window)

function StrideSeverView:ctor()
	--LuaLog("StrideSeverView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideSeverView"
	--self._rootDepth = LayerDepth.Window
	
end

function StrideSeverView:_initEvent( )
	
end

function StrideSeverView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideSeverView
	self.list_function = viewNode:getChildAutoType('$list_function')--GList
	--{autoFieldsEnd}:StrideServer.StrideSeverView
	--Do not modify above code-------------
end

function StrideSeverView:_initListener( )
	
	self.list_function:setItemRenderer(function(index, obj)
        local openCtrl = obj:getChildAutoType("openCtrl")
		local statusCtrl = obj:getChildAutoType("statusCtrl")
		local icon_bg =  obj:getChildAutoType("icon_bg")
		local txt_countdown =  obj:getChildAutoType("txt_countdown")
		local icon_nameImg =  obj:getChildAutoType("icon_nameImg")
		local txt_open =  obj:getChildAutoType("txt_open")
		local openTxt =  obj:getChildAutoType("openTxt")
		local typeTxt =  obj:getChildAutoType("typeTxt")
		local timeLab =  obj:getChildAutoType("timeLab")
		local startLab =  obj:getChildAutoType("startLab")
		if ModuleUtil.hasModuleOpen(ModuleId.StrideSeverView.id) then
			local stateInfo = StrideServerModel:getStateInfo()
			if stateInfo.isPartIn then
				if  stateInfo.isOpen == 0 then
					openCtrl:setSelectedIndex(1)
					local openDay = 0
					local condition =  DynamicConfigData.t_module[ModuleId.StrideSeverView.id].condition
					for k,v in pairs(condition) do
						if v.type == 4 then
							openDay = v.val
						end
					end
					openCtrl:setSelectedIndex(1)
					openTxt:setText(DescAuto[301]..openDay..DescAuto[302]) -- [301]="开服" -- [302]="天后开启"
					txt_countdown:setText(DescAuto[303]..stateInfo.seasonStarTime) -- [303]="开启倒计时:"
				elseif stateInfo.isOpen == 1 then
					openCtrl:setSelectedIndex(2)
					txt_countdown:setText(DescAuto[304]..stateInfo.seasonEndTime) -- [304]="结束倒计时:"
					if stateInfo.smallStage == 1 then --竞猜
						statusCtrl:setSelectedIndex(1)
						timeLab:setText(DescAuto[305]) -- [305]="配置文本时间"
					elseif stateInfo.smallStage == 2 then --对战
						statusCtrl:setSelectedIndex(3)
						timeLab:setText(DescAuto[305]) -- [305]="配置文本时间"
					elseif stateInfo.smallStage == 3 then --休整
						statusCtrl:setSelectedIndex(2)
						timeLab:setText(DescAuto[305]) -- [305]="配置文本时间"
					end
					obj:removeClickListener(100)
					obj:addClickListener(function()
					   ViewManager.open("StrideMainView")
					end,100)
				elseif stateInfo.isOpen == 2 then
					openCtrl:setSelectedIndex(1)
					openTxt:setText(DescAuto[306]) -- [306]="未开赛"
					txt_countdown:setText(DescAuto[303]..stateInfo.nextSeasonTime) --下赛季开赛时间 -- [303]="开启倒计时:"
				end
			else
				openCtrl:setSelectedIndex(1)
				openTxt:setText(DescAuto[307]) -- [307]="本服未参赛"
			end
		else
		   --如果等级不足
		   local condition =  DynamicConfigData.t_module[ModuleId.StrideSeverView.id].condition
		   local flag1,flag2 = false
		   for k,v in pairs(condition) do
				if  v.type == 1 then -->等级
					if PlayerModel.level < tonumber(v.val) then
						flag1 = true
					end
			    elseif v.type ==4 then  --开服天数
					local openDay = ServerTimeModel:getOpenDay() + 1
					if openDay < v.val then
						flag2 = true
					end
			    end
		   end
		   if flag1 then
			  openCtrl:setSelectedIndex(0)
		   end

		   if (not flag1) and flag2 then
			  openCtrl:setSelectedIndex(0)
		   end
		end
	end)
	
	self.list_function:setNumItems(1)
end

function StrideSeverView:_initUI( )
	self:_initVM()
	self:_initListener()

end




return StrideSeverView
