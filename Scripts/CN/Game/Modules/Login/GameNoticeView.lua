--Name : GameNoticeView.lua
--Author : generated by FairyGUI
--Date : 2020-6-10
--Desc : added by xhd 游戏公告系统

local GameNoticeView,Super = class("GameNoticeView", Window)

function GameNoticeView:ctor()
	--LuaLog("GameNoticeView ctor")
	self._packName = "Login"
	self._compName = "GameNoticeView"
	self._rootDepth = LayerDepth.PopWindow
	self.showData = {}
end

function GameNoticeView:_initEvent( )
	
end

function GameNoticeView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Login.GameNoticeView
		vmRoot.titleComp = viewNode:getChildAutoType("$titleComp")--
		vmRoot.contextList = viewNode:getChildAutoType("$contextList")--list
		vmRoot.noticeList = viewNode:getChildAutoType("$noticeList")--list
		vmRoot.pageList = viewNode:getChildAutoType("$pageList")--list
		vmRoot.bannerLoader = viewNode:getChildAutoType("$bannerLoader")--loader
		vmRoot.btn_close = viewNode:getChildAutoType("$btn_close")--loader
	--{vmFieldsEnd}:Login.GameNoticeView
	--Do not modify above code-------------
end

function GameNoticeView:_initUI( )
	self:_initVM()
	self.titleComp:setVisible(false)
    self.noticeList:setItemRenderer(function (index,obj)
	    obj:setTitle(self.showData[index+1].title)
	    obj:removeClickListener(100)
	    obj:addClickListener(function( ... )
	    	self:updateRightPanel(index+1)
	    end)
	end)

	self.pageList:addClickListener(function()
		self:updateLeftPanel()
	end)

	self.btn_close:addClickListener(function()
		self:closeView()
	end)

	self.pageList:setSelectedIndex(0)
	
	local args = {
		onSuccess = function(data)
			LoginModel:setNotice(data)
			if  tolua.isnull(self.view) then
				return
			end
			self:updateLeftPanel()
		end,
		
		onFailed = function(data)
		end
	}
	PHPUtil.getNotice(args);

end

function GameNoticeView:updateLeftPanel( )
	local index = self.pageList:getSelectedIndex()
	self.showData = {}
	if index == 0 then
		self.showData = LoginModel:getNotice(11)
	else
        self.showData = LoginModel:getNotice(10)
	end
	self.noticeList:setNumItems(#self.showData)
	if #self.showData>0 then
		self.noticeList:setSelectedIndex(0)
	    self:updateRightPanel(1)
	else
		self.titleComp:setVisible(false)
		self.bannerLoader:setURL("")
		--self.titleComp:getChildAutoType("uiTitleText"):setText("")
		local child = self.contextList:getChildAt(0)
		if child then
			child:getChildAutoType("uiContentText"):setText("")
			child:getChildAutoType("uiContentText"):addEventListener(FUIEventType.ClickLink, function(data)
				RollTips.showWebPage("", data:getDataValue())
			end, 11);
		end
	end

end

function GameNoticeView:updateRightPanel( index )
	local  imgName = self.showData[index].image_name
	
	--如果配的是http网址，用网络加载的方式
	if string.match(imgName, "http") == "http" then
		self.bannerLoader:setNetWorkUrl(imgName)
	else
		local img = "UI/notice/"..imgName..".png"
		print(1,img)
		if not cc.FileUtils:getInstance():isFileExist(img) then
			img = "UI/notice111.png"
		end
		self.bannerLoader:setURL(img)
	end
	self.titleComp:setVisible(true)
	--printTable(1,self.showData[index])
	self.titleComp:setText(self.showData[index].subtitle or self.showData[index].title)
	local child = self.contextList:getChildAt(0)
	if child then
		child:getChildAutoType("uiContentText"):setText(self.showData[index].content)
	end
end


return GameNoticeView