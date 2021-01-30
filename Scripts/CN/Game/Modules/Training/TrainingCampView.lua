--Date :2020-12-07
--Author : generated by FairyGUI
--Desc : 

local TrainingCampView,Super = class("TrainingCampView", Window)
local OpenParam=require "Game.Consts.OpenParam"
function TrainingCampView:ctor()
	--LuaLog("TrainingCampView ctor")
	self._packName = "Training"
	self._compName = "TrainingCampView"
	self._rootDepth = LayerDepth.Window
	
end

function TrainingCampView:_initEvent( )
	
end

function TrainingCampView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:Training.TrainingCampView
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list_reward = viewNode:getChildAutoType('list_reward')--GList
	self.playerIcon = viewNode:getChildAutoType('playerIcon')--GButton
	--{autoFieldsEnd}:Training.TrainingCampView
	--Do not modify above code-------------
end

function TrainingCampView:_initUI( )
	self:_initVM()
	self:setBg("ty_changebg.jpg")
	self.heroLihuiSet = BindManager.bindLihuiDisplay(self.playerIcon)
	self.heroLihuiSet:setData(15003)
	
	self:setData()
	--ViewManager.open("TrainingTipView",{windowType=1})

end



function TrainingCampView:setData( )
	local taskDatas=TrainingModel:getTraningTask()
	--奖励显示
	self.list_reward:setItemRenderer(function(index,obj)
			
			local taskData=taskDatas[index+1]
			if not taskData.state then
				taskData.state=0
			end
			obj:getController("takeCtrl"):setSelectedIndex(taskData.state)
			local rewardList = obj:getChildAutoType("list_reward")
			local btn_travel = obj:getChildAutoType("btn_travel")
			local btn_openWindow = obj:getChildAutoType("btn_openWindow")
			local txt_title=obj:getChildAutoType("txt_title")
			local txt_content=obj:getChildAutoType("txt_content")
			txt_title:setText(taskData.title)
			
			if taskData.state==0 then
				local beforTaskName=DescAuto[325] -- [325]="上一个教程"
				if taskDatas[index] then
					beforTaskName=taskDatas[index].title
				end
				txt_content:setText(taskData.task..string.format(Desc.Training_Unlock,beforTaskName))
			else
				txt_content:setText(taskData.task)
			end
			
			if taskData.ModuleId then
				if taskData.state==1 and not ModuleUtil.hasModuleOpen(taskData.ModuleId) then
					taskData.state=4--跳转
					obj:getController("takeCtrl"):setSelectedIndex(taskData.state)
					txt_content:setText(taskData.task..string.format(Desc.Training_Unlock,ModuleUtil.getModuleOpenTips(taskData.ModuleId)))
					btn_openWindow:addClickListener(function ()
							local mId=taskData.WindowId[1].id
							local mArgs=taskData.WindowId[1].args
							ModuleUtil.openModule(mId,true,{args= OpenParam.PataParam[mArgs]})
					end,111)
				end
			end
			
			
			
			rewardList:setItemRenderer(function(index,obj)
					local itemcell = BindManager.bindItemCell(obj)
					local itemData = ItemsUtil.createItemData({data = taskData.reward[1]})
					itemcell:setItemData(itemData)
					obj:addClickListener(function( ... )
							itemcell:onClickCell(index)
					end)
			end)
			rewardList:setNumItems(1)
			if taskData.state==0 then
				btn_travel:setGrayed(true)
				btn_travel:setTouchable(false)
			else
				btn_travel:setGrayed(false)
				btn_travel:setTouchable(true)
			end
			btn_travel:addClickListener(function ()
					self:travelClick(taskData.id,taskData.state)
			end,110)
				
	end)
	self.list_reward:setNumItems(#taskDatas)
end


function TrainingCampView:travelClick(id,state)
	if state==0 then  --未解锁
		--RollTips.show("未解锁")			
	elseif state==1 then --已解锁
		ViewManager.open("TrainingPrepareView",{taskId=id})
	elseif state==2 then --可领奖
		TrainingModel:getTaskRewawrd(id)
	elseif state==3 then --已通关
		ViewManager.open("TrainingPrepareView",{taskId=id})
	end	
end

function TrainingCampView:training_UpdateData()
	self:setData()
end


return TrainingCampView