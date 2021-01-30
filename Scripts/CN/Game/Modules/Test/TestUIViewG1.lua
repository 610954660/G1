--added by xhd 模型展示测试页
local TestUIViewG1,Super = class("TestUIViewG1", Window)
function TestUIViewG1:ctor()
	LuaLogE("TestUIViewG1 ctor")
	self._packName = "Test"
	self._compName = "TestUIViewG1"
	self.panelList = false
	self.panelControl= false
	self.skeletonNode = false
end


function TestUIViewG1:_initUI()
    self.panelList = FGUIUtil.getChild(self.view,"list","GList")
    self.panelControl = self.view:getController("c1")
    self.panelList:regUnscrollItemClick(function(index,target)
       self:changePage(index)
       self.panelControl:setSelectedIndex(index)
    end)
end

function TestUIViewG1:changePage( index )
    if index==1 then 
      self:initSpineView()
    end
end

--创建动作测试页面
function TestUIViewG1:initSpineView( ... )
    local view = FGUIUtil.getChild(self.view,"n63","GComponent")
    local acitonList = FGUIUtil.getChild(view,"n6","GList")
    local btn1 = FGUIUtil.getChild(view,"n7","GButton")
	local btn2 = FGUIUtil.getChild(view,"n8","GButton")
	local btn3 = FGUIUtil.getChild(view,"n9","GButton")
	local function callfunc1( ... )
		print(1,"callfunc1")
		if self.skeletonNode then
			self.skeletonNode:removeFromParent()
		end
	    self.skeletonNode = sp.SkeletonAnimation:createWithJsonFile("Spine/farmer.json","Spine/farmer.atlas",1)
	    self.skeletonNode:setPosition(500,120)
	    view:displayObject():addChild(self.skeletonNode)
	    self.skeletonNode:setAnimation(0, "dead", true);
    end
    btn1:addClickListener(callfunc1)
    callfunc1()

	local function callfunc2( ... )
		print(1,"callfunc2")
		if self.skeletonNode then
			self.skeletonNode:removeFromParent()
		end
	    self.skeletonNode = sp.SkeletonAnimation:createWithJsonFile("Spine/mima.json","Spine/mima.atlas",1)
	    self.skeletonNode:setPosition(500,120)
	    view:displayObject():addChild(self.skeletonNode)
	    self.skeletonNode:setAnimation(0, "dead", true);
    end
    btn2:addClickListener(callfunc2)

	local function callfunc3( ... )
		print(1,"callfunc3")
		if self.skeletonNode then
			self.skeletonNode:removeFromParent()
		end
	    self.skeletonNode = sp.SkeletonAnimation:createWithJsonFile("Spine/spirit.json","Spine/spirit.atlas",1)
	    self.skeletonNode:setPosition(500,120)
	    view:displayObject():addChild(self.skeletonNode)
	    self.skeletonNode:setAnimation(0, "dead", true);
    end
    btn3:addClickListener(callfunc3)

    acitonList:regUnscrollItemClick(function( index,target )
    	print(1,"lallala",index)
    	if index==0 then
    		self.skeletonNode:setAnimation(0, "dead", true);
    	elseif index==1 then
            self.skeletonNode:setAnimation(0, "stack", true);
        elseif index==2 then
            self.skeletonNode:setAnimation(0, "stand", true);
        elseif index==3 then
            self.skeletonNode:setAnimation(0, "walk", true);
        end
    end)
end

function TestUIViewG1:_enter()

end



return TestUIViewG1
