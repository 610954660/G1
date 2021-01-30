--added by zgs 多页窗口基类2  (基于编辑时多页设计方式)
local MutiWindow,Super = class("MutiWindow",Window)

local ViewGroups = require "Game.UI.ViewGroups"


--[[
1.支持重设Glist跟控制器的对应关系
2.支持子页为外部包体的view
]]

--使用MutiWindow需要遵守一个规则  编辑器里面的View名字要跟控制器分页的名字一样

function MutiWindow:ctor( args )

	self._preIndex = 0 --当前index 默认0
	self._prePage = "0" --当前页面名字 默认"0"

	self._tabBarName = "tabBar"
	self._tabBarBgName = "img_tabBarBg"
	self._tabBar = false   --关联控制器切换的Glist
	self._pageNode = false  --用来装页面的容器

	self.viewCtrlName = "viewCtrl"
	self.viewCtrl = {} --控制器
	self.ctlView  = {} --控制器不同页面对应的View

	self._tabBarData = {}--控制器和Glist关联数据
	
	self.firstLoad = true
	
	self._pagePackage = {}
end

--重写 __toInit()
function MutiWindow:__toInit()
	-- print(1,"MutiWindow __toInit")
	self:__initMutiWindow()
	Super.__toInit(self)
	
	self:_addPackageCount()
	
	--如果有设置数据
	if self._args.viewData then
		self:setTabBarData(self._args.viewData)
	end
	
	--如果打开时指定了页面
	if self._args.page then
		self:_setPage(self._args.page)
	end
	
	--如果指定的页面跟默认页面一样 需要手动调用一次
	if self.firstLoad then
		self:onViewControllerChanged()
	end
	
	CLASS_ALLOW_NEW_INDEX = true
	self:addMutiRedRigister()
	self:_initFinish()
	CLASS_ALLOW_NEW_INDEX = false
	
end

function MutiWindow:openPage(args)
	if args.page then
		self:_setPage(args.page)
	end
end

--初始化 控制器多页相关
function MutiWindow:__initMutiWindow()
    print(1,"__initMutiWindow")
	self._tabBar = self.view:getChildAutoType(self._tabBarName)
	if self._args.regCtrl then 
		self:__regCtrl() 
	else
		self.viewCtrl = self.view:getController(self.viewCtrlName)
		----添加控制器变化监听
		if self.viewCtrl then
			self.viewCtrl:addEventListener(FUIEventType.Changed,function()
					self:onViewControllerChanged()
				end)
			
			self._preIndex = self.viewCtrl:getSelectedIndex()
			self._prePage  = self.viewCtrl:getSelectedPage()
		end
	end
end

--监听多页切换，并构建
function MutiWindow:onViewControllerChanged()
	if tolua.isnull(self.view) then return end 
	if not self:__checkPageModule(false,self.viewCtrl:getSelectedPage(),self._prePage) then
		return
	end

	
	if self.ctlView[self._prePage] then
		self.ctlView[self._prePage]:setVisible(false)
	end
	self._preIndex = self.viewCtrl:getSelectedIndex()
	self._prePage = self.viewCtrl:getSelectedPage()
	
	if self.ctlView[self._prePage] then
		self.ctlView[self._prePage]:setVisible(true)
	end
	
	self.firstLoad = false
	

	print(0,"onViewControllerChanged ",self._preIndex,self._prePage)

	local pageName = self._prePage
	--判断是否已经初始化
	if self.ctlView[pageName] == nil then
		--符合规则的才才创建
		if string.find(pageName,"View") or string.find(pageName,"Window") then
			--创建对应的view实例
			self:createComponentByPageName(pageName)
			self:__initPageByData()
		end

	elseif self.ctlView[pageName] and self.ctlView[pageName]._refresh then
		--如果已存在 执行刷新
		self.ctlView[pageName]:_refresh()
	end
	self:onShowPage(pageName)
	
	--执行自定义切页监听
	if self._viewChangeCallBack then
		self:_viewChangeCallBack(self._preIndex)
	end
end
--按需要调用此接口，大部分界面可能不需要自定义切页
function MutiWindow:createComponentByPageName(pageName)
	print(33,"createComponentByPageName =",pageName)
	local viewInfo = ViewGroups[pageName]
	local cpmView = require(viewInfo.path).new(self._args)

	--判断资源包体是否被加载
	cpmView:__readyPackage(function(isLoad)
			
			if isLoad and rawget(self,pageName) == nil then
				local obj = self.view:getChildAutoType(pageName)
				if not obj then
					obj = self.view:getChildAutoType("$"..pageName)
				end
				if obj then
					rawset(self,pageName,obj)
				end
			end
			
			--如果在同一个包
			if isLoad  and self[pageName] and self[pageName]:getResourceURL()~="" then
				cpmView._parent = self.view
				cpmView:__onEnter()
				ViewManager.addCount(cpmView._packName, cpmView._compName)
			else
				
				local func = function(vobj,cmpogj)
					if cpmView._isClosing or tolua.isnull(self.view) then
						--计数-1
						ViewManager.subCount(cpmView._package, cpmView._compName)
						return
					end
					--使用pageName 作为名字 保证编辑器节点和代码一致性
					local childName = pageName
					local obj_t = self.view:getChildAutoType(pageName)
					if self[pageName] then
						childName = self[pageName]:getName()
						self[pageName]:removeFromParent()
					elseif obj_t then
						Scheduler.scheduleNextFrame(function()
								if not tolua.isnull(obj_t) then
									obj_t:removeFromParent()
								end
						end)
						--obj_t:setName("")
					end 
					if self._pageNode then 
						self._pageNode:addChildByName(cmpogj,childName)
					else
						self.view:addChildByName(cmpogj,childName)
					end
					
					rawset(self,pageName,cmpogj)
					cpmView:__onEnter()
				end
				--重写CreateObjSuccess 方法
				rawset(cpmView,"__onCreateObjSuccess",func)

				--创建实例
				cpmView:__doCreateObj()
				--cpmView:getGear(0):setController()
			end
			
			--cpmView.closeView = function()
				--self:closeView()
			--end
			cpmView._args = self._args
			cpmView.view = self[pageName]
			
			if cpmView.view:getHeight() > 719 and cpmView.view:getWidth() > 1279 then
				cpmView._isFullScreen = true
			end
			cpmView._parentWin = self
			cpmView:__toInit()
			self.ctlView[pageName] = cpmView
		end)
end

--编辑器编辑好的布局 添加红点  动态页签通过配置viewData实现
function MutiWindow:addMutiRedRigister(  )
	if self.redArr and #self.redArr>0 and not self._args.viewData then
		local num =  self._tabBar:getNumItems()
		for i=1,num do
			if self.redArr[i] and self.redArr[i]~="" then
				local index = self._tabBar:itemIndexToChildIndex(i-1)
				local obj = self._tabBar:getChildAt(index)
				local img_red = obj:getChildAutoType("img_red")
				RedManager.register(self.redArr[i], img_red)
			end
		end
	end
end

--按需要调用此接口，大部分界面可能不需要自定义切页
function MutiWindow:setTabBarData(data)
	self._tabBarData = data

	--如果需要设置数据，那么就要移除编辑器设定的关联 （所以编辑器可以设定关联）
	self._tabBar:removeSelectionController()

	self._tabBar:setItemRenderer(function(index,obj)
			--如果存在红点 则注册红点
			local indexData = self._tabBarData[index+1]
			if indexData then
				local img_red = obj:getChildAutoType("img_red")
				if img_red and indexData.red then
					RedManager.register(indexData.red, img_red,indexData.mid)
				end
				self:__initBtnByData(obj,indexData)
			end

			--添加事件监听前先移除
			obj:removeClickListener(88)
			obj:addClickListener(function( ... )
					if indexData and not self:__checkPageModule(indexData.mid,indexData.page) then
						self._tabBar:setSelectedIndex(self._preIndex)
						return
					end
					self._preIndex = index
					if indexData and indexData.page  then
						--如果设置了数据，使用设置的名字跳转控制器
						if type(indexData.page) == "string" then
							self.viewCtrl:setSelectedPage(indexData.page)
						else
							self.viewCtrl:setSelectedIndex(indexData.page)
						end
					else
						--默认
						self.viewCtrl:setSelectedIndex(index)
					end

				end,88)
		end)

	self._tabBar:setData(self._tabBarData)
end


function MutiWindow:__checkPageModule(mid,page,backPage)

	local moduleId = mid
	if not moduleId and page then
		local info = ViewGroups[page]
		if  info and info.mid then
			moduleId = info.mid
		end
	end

	if moduleId then
		if not ModuleUtil.moduleOpen(moduleId,true) then
			if backPage then
				self:_setPage(backPage,false)
			end
			return false
		end
	end

	return true
end

function MutiWindow:__setObjData(obj,v)
	if string.find(v,".png") or string.find(v,".jpg") or string.find(v,"ui://") then
		if obj.setIcon then obj:setIcon(v) 
		elseif obj.setURL  then obj:setURL(v)  end
	else
		if obj.setTitle then obj:setTitle(v) 
		elseif obj.setText  then obj:setText(v)  end
	end
end

function MutiWindow:__initPageByData()
	local indexData = self._tabBarData[self._preIndex+1]

	if indexData and indexData.pageData then
		for k,v in pairs(indexData.pageData) do
			local cpm = rawget(self,k)
			if not cpm then
				rawset(self,k,self.view:getChildAutoType(k))
			end
			self:__setObjData(self[k],v)
		end
	end
end

function MutiWindow:__initBtnByData(obj,indexData)

	if indexData.btData then
		for k,v in pairs(indexData.btData) do
			local cpm = obj:getChildAutoType(k)
			self:__setObjData(cpm,v)
		end
	end
end

function MutiWindow:_addPackageCount()
	if not self.viewCtrl or not self.viewCtrl.hasPage then return end
	--如果有引用其他包体的，引用计数加1
	for k,v in pairs(self.view:getChildren()) do
		local name = v:getName()
		local hasPage = self.viewCtrl:hasPage(name)
		--暂时用v.addChildByName判断是否GComponent
		if hasPage and v.addChildByName and (string.find(name,"View") or string.find(name,"Window")) then
			local resUrl = v:getResourceURL()
			if resUrl and resUrl~="" then
				--截取获得所在包名字
				local pid = string.sub(resUrl, 6, 13)
				local package = fgui.UIPackage:getById(pid)
				if package then
					local packageName = package:getName()
					ViewManager.addCount(packageName, name)
					--保存起来增加的引用计算，退出的时候减回去
					table.insert(self._pagePackage,{packageName = packageName,resUrl = name})
				end
			end
		end 
	end
end

function MutiWindow:_subPackageCount()
	for i = 1, #self._pagePackage do
		ViewManager.subCount(self._pagePackage[i].packageName, self._pagePackage[i].resUrl)
	end
end

function MutiWindow:_exitFinish()
	for k,v in pairs(self.ctlView) do
		ViewManager.subCount(v._packName, v._compName)
	end
	self:_subPackageCount();
end
--重写 __onExit
function MutiWindow:__onExit()
	Super.__onExit(self)
	for k,v in pairs(self.ctlView) do
		v:__onExit()
	end
end

--虚构一个控制器  （针对没有控制器也需要多页操作的模块 ）
function MutiWindow:__regCtrl()
	
	self.viewCtrl = {
		pid = 0,
		page = "0"
		}
	print(33,"viewCtrl = ",self.viewCtrl)
	self.viewCtrl.setSelectedPage = function(t_self,page)
		print(33,"gg setSelectedPage",page,t_self.page)
		if t_self.page == page then return end
		for k,v in pairs(self.ctlView) do
			if k == page then
				v:setVisible(true)
			else
				v:setVisible(false)
			end
		end
		t_self.page = page
		for k,v in pairs(self._tabBarData) do
			if v.page == page then
				t_self.pid = k - 1
				break
			end
		end
		
		self:onViewControllerChanged()
	end
	self.viewCtrl.setSelectedIndex = function(t_self,index)
		if t_self.pid  == index then return end
		local page = self._tabBarData[index+1].page
		for k,v in pairs(self.ctlView) do
			if k == page then
				v:setVisible(true)
			else
				v:setVisible(false)
			end
		end
		t_self.pid = index
		t_self.page = page
		self:onViewControllerChanged()
	end
	self.viewCtrl.getSelectedPage = function(t_self)
		return t_self.page
	end
	self.viewCtrl.getSelectedIndex = function(t_self)
		return t_self.pid
	end
end

function MutiWindow:_setPage(page,triggerEvent)
	if tolua.isnull(self.view) then return end
	if type(page) == "string" then
		self.viewCtrl:setSelectedPage(page,triggerEvent or true)
	else
		self.viewCtrl:setSelectedIndex(page,triggerEvent or true)
	end
	if self._args.viewData then
		for k,v in pairs(self._args.viewData) do
			if page == v.page then
				self._tabBar:setSelectedIndex(k-1)
				break
			end
		end
	else
		if self._tabBar then
			self._tabBar:setSelectedIndex(self.viewCtrl:getSelectedIndex())
		end
	end

end

function MutiWindow:onShowPage(page)
	--切换页签时触发，方便继承作特殊处理
end

--子类重写 若需要  (基类和子类都初始化完成后调用)
function MutiWindow:_initFinish()
	
end

return MutiWindow
