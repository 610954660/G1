
local TestUIView,Super = class("TestUIView", Window)
function TestUIView:ctor()
	LuaLogE("TestUIView ctor")
	self._packName = "Test"
	self._compName = "TestUIView"
	self.btn1 = false
	self.btn2 = false
	self.btn3 = false
	self.btn4 = false
	self.btn5 = false
	self.btn6 = false
	self.btn7 = false
	self.btn8 = false
	self.btn9 = false
	self.btn10 = false

	self.btn11 = false
	self.btn12 = false
	self.btn13 = false
	self.btn14 = false
	self.btn15 = false

	self.g1 = false
	self.g2 = false
	self.g3 = false

	self.playerTitle1 = false
	self.playerTitle2 = false
	self.playerTitle3 = false

	self.item1 = false
	self.item2 = false
	self.item3 = false
	LuaLogE("self._compName",self._compName)
end


function TestUIView:_initUI()
 --    self.btn1 = FGUIUtil.getChild(self.view,"btn1","GButton")
 --    self.btn2 = FGUIUtil.getChild(self.view,"btn2","GButton")
 --    self.btn3 = FGUIUtil.getChild(self.view,"btn3","GButton")
 --    self.btn4 = FGUIUtil.getChild(self.view,"btn4","GButton")
	-- self.btn1:setTitle("addPackage")
	-- self.btn1:addClickListener(function()
	-- 	MsgManager.showRollTipsMsg("123456")
	-- 	-- UIPackageManager.addPackage("Gif_Fate")
	-- end)

	-- self.btn2:setText("removePackage")
	-- self.btn2:addClickListener(function()
	-- 	UIPackageManager.removePackage("BagTest")
	-- end)

	-- self.btn3:setText("reloadPackageAsync")
	-- self.btn3:addClickListener(function()
	-- 	-- UIPackageManager.reloadPackageAsync("Gif_Fate")
	-- end)

	-- self.btn4:setText("UnloadAssets")
	-- self.btn4:addClickListener(function()
	-- 	local info = UIPackageManager.getPackageInfo("BagTest")
	-- 	info.package:UnloadAssets()
	-- end)
end


-- function TestUIView:_initUI()

-- 	self.playerTitle1 = self._root:getChild("playerTitle1", "PlayerTitle")
-- 	self.playerTitle2 = self._root:getChild("playerTitle2", "PlayerTitle")
-- 	self.playerTitle3 = self._root:getChild("playerTitle3", "PlayerTitle")

-- 	self.btn6 = self._root:getChild("btn6", "Button")
-- 	self.btn7 = self._root:getChild("btn7", "Button")
-- 	self.btn8 = self._root:getChild("btn8", "Button")
-- 	self.btn9 = self._root:getChild("btn9", "Button")
-- 	self.btn10 = self._root:getChild("btn10", "Button")

-- 	self.btn6:setText("1=称号20001")
-- 	self.btn6:onClick(function()
-- 		self.playerTitle1:setTitle(20001)
-- 	end)

-- 	self.btn7:setText("1=称号20002")
-- 	self.btn7:onClick(function()
-- 		self.playerTitle1:setTitle(20002)
-- 	end)

-- 	self.btn8:setText("1=称号清空")
-- 	self.btn8:onClick(function()
-- 		self.playerTitle1:setTitle()
-- 	end)

-- 	-- self.btn9:setText("1=称号清空")
-- 	-- self.btn9:onClick(function()
-- 	-- end)

-- 	-- self.btn9:setText("1=称号清空")
-- 	-- self.btn9:onClick(function()
-- 	-- end)

-- 	-- self.btn10:setText("1=称号清空")
-- 	-- self.btn10:onClick(function()
-- 	-- end)
-- end

-- function TestUIView:_initUI()
--     LuaLogE("_initUI")
	-- self.item1 =  FGUIUtil.addChild(self.view,"item1","GComponent")
	-- self.item2 = self.view:getChild("item2", "ItemIcon")
	-- self.item3 = self.view:getChild("item3", "ItemIcon")

	-- self.btn11 = self.view:getChild("btn11", "Button")
	-- self.btn12 = self.view:getChild("btn12", "Button")
	-- self.btn13 = self.view:getChild("btn13", "Button")
	-- self.btn14 = self.view:getChild("btn14", "Button")
	-- self.btn15 = self.view:getChild("btn15", "Button")

	-- self.btn11:setText("10001")
	-- self.btn11:onClick(function()
	-- 	self.item1:setItemCode(100011101)
	-- end)

	-- self.btn12:setText("10002")
	-- self.btn12:onClick(function()
	-- 	self.item1:setItemCode(100102201)
	-- end)

	-- self.btn13:setText("1=清空")
	-- self.btn13:onClick(function()
	-- 	self.item1:setItemCode()
	-- end)

	-- self.btn9:setText("1=称号清空")
	-- self.btn9:onClick(function()
	-- end)

	-- self.btn9:setText("1=称号清空")
	-- self.btn9:onClick(function()
	-- end)

	-- self.btn10:setText("1=称号清空")
	-- self.btn10:onClick(function()
	-- end)
-- end

function TestUIView:_enter()

end



return TestUIView
