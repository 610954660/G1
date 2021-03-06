--Name : LoginAwardView.lua
--Author : generated by FairyGUI
--Date : 2020-4-24
--Desc : 登录奖励 added by xiehande
local LoginAwardView,Super = class("LoginAwardView", MutiWindow)

function LoginAwardView:ctor()
	--LuaLog("LoginAwardView ctor")
	self._packName = "LoginAward"
	self._compName = "LoginAwardView"
	self._rootDepth = LayerDepth.PopWindow
	self._args.regCtrl = 1
end

function LoginAwardView:_initEvent( )

end

function LoginAwardView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:LoginAward.LoginAwardView
		vmRoot._tabBar = viewNode:getChildAutoType("$_tabBar")--list
	--{vmFieldsEnd}:LoginAward.LoginAwardView
	--Do not modify above code-------------
end

function LoginAwardView:_initUI( )
	self:_initVM()
	self._args.viewData = LoginAwardModel:makeWindowTab(  )
	if not self._args.page then
		self._args.page = self._args.viewData[1].page
	end
end

--点击后设置不同点显示
function LoginAwardView:_viewChangeCallBack(index)
	local indexData = self._tabBarData[index+1]
	self._frame:setIcon(PathConfiger.getBg(indexData.bg))
end

-- 每日首次登陆展示时 有活动需要拿到推图数据才能正常开启
function LoginAwardView:pushMap_getCurPassPoint()
	self._args.viewData = LoginAwardModel:makeWindowTab(  )
	if not self._args.page then
		self._args.page = self._args.viewData[1].page
	end
	self:setTabBarData(self._args.viewData)
end

return LoginAwardView