--added by wyang
--道具框封裝
local LihuiDisplay,Super = class("LihuiDisplay",BindView)
function LihuiDisplay:ctor(view)
	self.playerIcon = false
	self.skeletonNode = false
	self.heroId = 0
	self.fashionId = 0
	self.testTouchNum = 0
	self.isPause  = false
end

function LihuiDisplay:init( ... )
	self.playerIcon = self.view:getChildAutoType("playerIcon")
	self.view:addEventListener(FUIEventType.TouchMove,function() 
		local pos = self.view:getPosition()
		local data = {}
		data.pos = pos
		data.scanf = self.view:getScale()
		Dispatcher.dispatchEvent("set_lihuiPos_Event",data)
	end,5330)
	
	--release版本一定不能显示对位框
	if __IS_RELEASE__ then
		self.view:getController("c1"):setSelectedIndex(0)
	end
end

function LihuiDisplay:setData(heroId,offset, staticFlag, fashionId)
	if self.heroId ~= heroId or self.fashionId ~= fashionId then
		self.heroId = heroId
		self.fashionId = fashionId or 0
		if self.skeletonNode then 
			self.skeletonNode:removeFromParent()
			self.skeletonNode = false
		end
		local pos = {x = 200, y =-270}
		if offset then
			pos = {x = 200+offset.x, y =-270+offset.y}
		end
		self.skeletonNode = SpineUtil.createHeroDraw(self.playerIcon,pos,heroId,self.isPause,fashionId)
		if self.isPause then
			self:setStatic(true)
		end
		if ModelManager.PlayerModel.lihuiDebugMode then
		    local control = self.view:getController("c1")
		    if control then
		    	control:setSelectedIndex(1)
		    end
		end
		--[[local pic = self.view:getChildAutoType("pic1")
		pic:retain()
		pic:setPosition(0,0)
		pic:removeFromParent()
		SpineUtil.addChildToSlot(self.skeletonNode,pic:displayObject(),"pair_box")--]]
		
		--[[local bone = self.skeletonNode:findBone("pair_box")
		if bone ~=nil  then
			print(1)
			local posX = bone:getWorldX()
			local posY = bone:getWorldY()
			self.playerIcon:setPosition(200 - posX, 125 - posY)
		else
			self.playerIcon:setPosition(200, 125)
		end--]]
		--if MainUIModel:isLihuiStatic() then
			--self:setStatic()
			--self:pause()
		--end
	end
end

function LihuiDisplay:setMonsterData(resource,action)
	if self.heroId ~= resource then
		self.heroId = resource
		if self.skeletonNode then 
			self.skeletonNode:removeFromParent()
			self.skeletonNode = false
		end
		local pos = {x = 200, y =-270}
		self.skeletonNode =  SpineUtil.createModel(self.playerIcon, pos, action, false,false,resource)
	end
end

--GetTyChangeView需要给策划编辑位置（仅限pc）
function LihuiDisplay:setCanEditPos()
	self.view:setTouchable(true)
	if LoginModel:isTestAgent() then
		self.view:addClickListener(function()
			self.testTouchNum = self.testTouchNum + 1
			if self.testTouchNum then
				if self.testTouchNum>= 5 then
		            self.view:setDraggable(true)
					Dispatcher.dispatchEvent("set_lihuiPos_Event")
				end
			end
		end)
	end
end

function LihuiDisplay:setStatic(isPause)
	self.isPause = isPause
	if self.skeletonNode then
		if self.isPause then
			self.skeletonNode:setAnimation(0, "animation", false)
			local function fucCall()
				self:pause()
			end
			Scheduler.scheduleOnce(0.01, fucCall)
		else
			self:resume()
		end
	end
end

function LihuiDisplay:pause()
	if self.skeletonNode then
		self.skeletonNode:pause()
	end
end


function LihuiDisplay:resume()
	if self.skeletonNode then
		self.skeletonNode:resume()
		self.skeletonNode:setAnimation(0, "animation", true)
	end
end


function LihuiDisplay:setVisible(v)
	self.view:setVisible(v)
end
function LihuiDisplay:setPosition(x,y)
	self.view:setPosition(x,y)
end
function LihuiDisplay:getWidth(x,y)
	return self.view:getWidth()
end
function LihuiDisplay:getHeight()
	return self.view:getHeight()
end
function LihuiDisplay:setAlpha(a)
	return self.view:setAlpha(a)
end
function LihuiDisplay:setColor(a)
	return self.skeletonNode:setColor(a)
end

function LihuiDisplay:setScale(scalex,scaley)
	return self.view:setScale(scalex,scaley)
end

--退出操作 在close执行之前 
--function LihuiDisplay:__onExit()
    ---- print(1,"LihuiDisplay __onExit")
----   self:_exit() --执行子类重写
   ----[[self:clearEventListeners()
   --for k,v in pairs(self.baseCtlView) do
   		--v:__onExit()
   --end--]]
	----Dispatcher.removeEventListener(FUIEventType.set_lihuiPos_state,self:set_lihuiPos_state);
--end

return LihuiDisplay