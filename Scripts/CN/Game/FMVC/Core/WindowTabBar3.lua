--added by xhd 
--多窗口页面样式1 继承于多窗口基类
local WindowTabBar3,Super = class("WindowTabBar3", WindowTabBar)

function WindowTabBar3:ctor(args)
    -- print(1,"WindowTabBar1:ctor")
	self._packName = "WindowTabBar3"
	self._compName = "WindowTabBar3"
	-- self._maskType = 1
	-- self._moneyType = 0
end

-- 如果要 关闭动画
function WindowTabBar3:doCtrlUp()
	-- local winCtrl = self._root:getController("winCtrl")
	-- if winCtrl then
	-- 	winCtrl:setSelectedName("up")
	-- end
end

function WindowTabBar3:doCtrlNormal()
	-- local winCtrl = self._root:getController("winCtrl")
	-- if winCtrl then
	-- 	winCtrl:setSelectedName("normal")
	-- end
end

return WindowTabBar3