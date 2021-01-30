--added by wyang
--自动排列的按钮列表，需要显示的按钮会自动加到列表里面，先显示的按钮会在左边
local ButtonList = class("ButtonList",BindView)
function ButtonList:ctor(view,noClick)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	self.poxXMap = {}
end

function ButtonList:init( ... )
	self.list_btn = self.view:getChildAutoType("list_btn")
	local allChildren = self.view:getChildren()
	for _,child in pairs(allChildren) do
		if child:getName() ~= "list_btn" then
			self.poxXMap[child:getName()] = child:getPosition().x
			local setVis = child.setVisible
			child.setVisible = function (selfObj, visible)
				setVis(selfObj, visible)
				if visible then
					self.list_btn:addChild(child)
					self.list_btn:setChildIndex(child, self.poxXMap[selfObj:getName()])
				else
					self.view:addChild(child)
				end
			end
		end
	end
end

--退出操作 在close执行之前 
function ButtonList:__onExit()
     print(086,"ButtonList __onExit")
end

return ButtonList