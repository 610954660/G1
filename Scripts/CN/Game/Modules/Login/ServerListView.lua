

local ServerListView,Super = class("ServerListView", Window)

local LoginModel = require "Game.Modules.Login.LoginModel"

function ServerListView:ctor()
	LuaLogE("ServerListView ctor")
	self._packName = "Login"
	self._compName = "LoginServerListView"
	self._rootDepth = LayerDepth.PopWindow;
	self.groupList = false
	self.serverList = false
	self._isFullScreen = true

end

function ServerListView:_initUI()
	LuaLogE("ServerListView _initUI")

	
	self.groupList = self.view:getChildAutoType("regionList")

	self.serverList = self.view:getChildAutoType("serverList")
	PHPUtil.reportStep(ReportStepType.ENTER_SERVER_LIST)
	-- local closeBt = self.view:getChildAutoType("closebt")

	-- closeBt:addClickListener(function()
	-- 		self:closeView()
	-- 	end)
	
	--self.groupName = FGUIUtil.getChild(self.groupList,"nameLabel","GTextField")
	self:updateServerGroups()
	self:getServerList()
end


function ServerListView:getServerList()
	local args = {
		onSuccess = function(data)
			if not tolua.isnull(self.view) then
				self:updateServerGroups()
			end
		end,
		onFailed = function(data)
			RollTips.show(Desc.login_getServerFail)
			self:updateServerGroups() --获取失几也更新一下界面，如果之前已经获取过的，还可以显示
		end
	}
	--获取服务器列表
	PHPUtil.getServerList(args)
end


--更新左侧服务器大区
function ServerListView:updateServerGroups()
	local serverGroups =  LoginModel:getServerGroups();
	local serverGroupsName =  LoginModel:getServerGroupsName();
	local groupNum = LoginModel:getGroupNum();

	--printTable(33,serverGroups)
	printTable(33,serverGroupsName)

	self.groupList:setItemRenderer(function(index,obj)
			obj:removeClickListener()--池子里面原来的事件注销掉
			obj:addClickListener(function(context)
				SoundManager.playSound(1,false)
					local tIndex = index;
					self.groupList:setSelectedIndex(tIndex)
					self:updateServerList(groupNum - index,context)
				end)
			local nameLabel= obj:getChildAutoType("nameLabel")
			nameLabel:setText(serverGroupsName[groupNum - index])
		end
	)



	self.groupList:setNumItems(groupNum);
	if groupNum > 0 then
		self:updateServerList(groupNum);
		self.groupList:setSelectedIndex(0)
	end
	


end

--更新右侧服务器列表
function ServerListView:updateServerList(id,context)
	local serverGroups =  LoginModel:getServerGroups();

	--assert(serverGroups[id], "serverGroups id error "..id)
	print(33,id)
	printTable(33,context)


	print(33,"click me")
	printTable(33,serverGroups[id])

	local serverListInfo = serverGroups[id]
	local serverListNum = #serverGroups[id]
	--printTable(33,serverGroups)
	-- printTable(1, serverListInfo);


	self.serverList:setItemRenderer(function(index,obj)
			self:updateServerItem(serverListInfo[index+1],obj)
		end
	)
	--self.serverList:setNumItems(serverListNum);
	self.serverList:setNumItems(serverListNum);
end

--更新选择的服务器
function ServerListView:updateServerItem(serverInfo,obj)

	obj:removeClickListener()--池子里面原来的事件注销掉
	obj:addClickListener(function(context)
			self:updateSelectServer(serverInfo,context)
		end)
	local ctrl = obj:getController("c1");
	local lastLoginServer = LoginModel.__lastLoginServerInfo;
	if (lastLoginServer and lastLoginServer.unit_server == serverInfo.unit_server) then
		ctrl:setSelectedPage("Logged");
	elseif (serverInfo.roleInfo) then
		ctrl:setSelectedPage("haveRole");
	else
		ctrl:setSelectedPage("normal");
	end

	local nameLabel= obj:getChildAutoType("title") 
	nameLabel:setText(""..serverInfo.name)
	
	
	local statusIcon= obj:getChildAutoType("icon")
	local health =  serverInfo.health>2 and (serverInfo.health - 1) or serverInfo.health;
	if serverInfo.health > 7 then
		health = serverInfo.health - 6
	elseif serverInfo.health > 5 then
			health = serverInfo.health - 5
	end
	statusIcon:setURL("UI/Login/dl_zt_0"..health..".png")--放了一张图片
	local newCtrl = obj:getController("newCtrl");
	newCtrl:setSelectedIndex((serverInfo.health == 3) and 1 or 0)

	local role = obj:getChildAutoType("role");
	role:getChildAutoType('n14'):setVisible(false)
	role:getChildAutoType("icon"):setVisible(false)
	local name = "";
	local lv = "";
	printTable(2233, serverInfo);
	if (serverInfo.roleInfo) then
		local info = serverInfo.roleInfo;
		name = info.name;
		lv = "Lv."..info.level;
		role:getChildAutoType("icon"):setURL(PlayerModel:getUserHeadURL(info.photo));
		if (info.photo and info.photo ~= 0 and info.photo ~= "") then
			role:getChildAutoType('n14'):setVisible(true)
			role:getChildAutoType("icon"):setVisible(true)
		end
	end
	role:getChildAutoType("txt_name"):setText(name);
	role:getChildAutoType("txt_level"):setText(lv);
end

--更新选择的服务器
function ServerListView:updateSelectServer(server,context)
	if VersionChange:doChangeVersion(server) then
		return
	end
	VersionChange:clearChangeServerId()
	LoginModel:updateSelectedServer(server)
	Dispatcher.dispatchEvent(EventType.login_chooseServer)
	ViewManager.close("ServerListView")
end

return ServerListView