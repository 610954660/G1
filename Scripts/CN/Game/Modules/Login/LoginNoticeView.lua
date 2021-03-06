--Name : LoginNoticeView.lua
--Author : generated by FairyGUI
--Date : 2020-6-10
--Desc : 

local LoginNoticeView,Super = class("LoginNoticeView", Window)

function LoginNoticeView:ctor()
	--LuaLog("LoginNoticeView ctor")
	self._packName = "Login"
	self._compName = "LoginNoticeView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function LoginNoticeView:_initEvent( )
	
end

function LoginNoticeView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Login.LoginNoticeView
		vmRoot.titleComp = viewNode:getChildAutoType("$titleComp")--
		vmRoot.noticeList = viewNode:getChildAutoType("$noticeList")--list
	--{vmFieldsEnd}:Login.LoginNoticeView
	--Do not modify above code-------------
end

function LoginNoticeView:_initUI( )
	self:_initVM()
	self:updatePanel()
end

function LoginNoticeView:updatePanel( ... )
	local noticeData =  LoginModel:getNotice(6);
	if noticeData and #noticeData>0 then
		self.titleComp:getChildAutoType("uiTitleText"):setText(noticeData[1].title)
		self.noticeList:setItemRenderer(function ( index,obj )
			obj:getChildAutoType("uiContentText"):setText(noticeData[index+1].content)
		end)
		self.noticeList:setNumItems(1)
	end
end


return LoginNoticeView