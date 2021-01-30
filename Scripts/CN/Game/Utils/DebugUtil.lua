module("DebugUtil", package.seeall)

--按F4执行这个函数
function happyDebug()
	LuaLogE("go go go!")

	--自动打开界面，设置为当前开发功能
	local testModules = {
		-- ModuleType.PLAYER,
	}

	restoreLoaded()
	for _, v in ipairs(testModules) do
		ModuleManager.close(v)
		local ctrl = GameController.getCtrl(v)
		if ctrl then
			ctrl:dispose()
		end
		ModuleManager.open(v)
	end

	-- container节点用于方面某些显示对象的调试
	LayerManager.windowLayer:removeChildByTag(12345)
	local container = UI.newNode()
	LayerManager.windowLayer:addChild(container, 0, 12345)
	local centerX = display.cx
	local centerY = display.cy
	
	
end