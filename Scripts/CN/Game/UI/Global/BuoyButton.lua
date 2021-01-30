--added by wyang
--带消耗的按钮
--local BuoyButton = class("BuoyButton")
local BuoyButton,Super = class("BuoyButton",BindView)

function BuoyButton:ctor(view)
   self.view=view
   self.gsPos=self.view:getPosition()
   self.moduleId=false
	self.beginPosX = false
end

function BuoyButton:_initUI( ... )
	local stateTime=0
	self.view:addClickListener(function ( ... ) 
			if self.moduleId and stateTime==0 then
				ModuleUtil.openModule(self.moduleId, true )
			end
	end)
	self.view:setDraggable(true)
	local DragEnd=false
	self.view:displayObject():onUpdate(function (dt)
			if DragEnd then
				stateTime=stateTime+dt
				if stateTime>=0.8 then
					local xPos = (self.view:getPosition().x > 0 and self.view:getPosition().x < display.width ) and self.view:getPosition().x or self.beginPosX
					self.view:setPosition(xPos,self.gsPos.y)
					stateTime=0
					DragEnd=false
					self.view:setSelected(false)
				end

			end
	end,0)


	self.view:addEventListener(FUIEventType.DragStart,function ( ... ) --战斗付费加速插件
			DragEnd=false
			stateTime=0
			self.view:setSelected(true)
			self.beginPosX = self.view:getPosition().x
	end)
	self.view:addEventListener(FUIEventType.DragEnd,function ( ... ) --战斗付费加速插件
			DragEnd=true
	end)
end


--浮标需要打开的窗口
function BuoyButton:bindOpenModule(moduleId)
     self.moduleId=moduleId
	 RedManager.register("V_UNLOCKSPEED",self.view:getChildAutoType("img_red"))
	 BattleModel:redCheck()
	 self:module_open()
end



function BuoyButton:buoyWindow_Close()
	self.view:setSelected(false)
end

function BuoyButton:buoyWindow_Remove()
	self.view:removeFromParent()
end

function BuoyButton:module_open()
	--RedManager.updateValue("M_SPEEDPLUGNIN",true)
	--print(5656,)
	self.view:setVisible(ModuleUtil.moduleOpen(self.moduleId,false))
end


--退出操作 在close执行之前
function BuoyButton:_onExit()
	print(1,"BuoyButton __onExit")
end

return BuoyButton