--aded by xhd  View
--页面管理器
--@class ViewManager
local ViewManager = {}

-- 已注册视图
local ViewGroups = require "Game.UI.ViewGroups"
local ViewArrayType = require "Game.Consts.ViewArrayType"

-- 打开着的常驻视图
local _residentViews = {}

-- 打开着的普通视图
local _openingViews = {}

-- 隐藏缓存中的视图
local _hideViews = {}

-- 窗口数量
local _windowCount = 0

-- 各种层级的界面
local _parentLayer = {}

--每一个层级最高层的界面
local viewLayersNum = {}

--战斗界面之后打开的view
local viewAfterBattleView = {}


local _globalWaitObj = false
local _reconnectWaitObj = false

--包体数据保存
local _packView = {}
local _packRemoveTime = {}
local _pcDict = {}

local recordLastView = {"","","","","",""}
local recordLastNum = 0

local modelCheck = {}

local _mainUIView = false

local hadShowCloseTips = false --是否已经显示网络断开提示


local _upSprite = false
local _downSprite = false

ViewManager._packView = _packView
ViewManager._parentLayer = _parentLayer
--设置groot visible
function ViewManager.showOrHideGRoot(bool)
    if bool == nil then
        fgui.GRoot.inst.visible = not fgui.GRoot.inst.visible
    else
        fgui.GRoot.inst.visible = bool
    end
end

function ViewManager.init(groot)
    for k, v in pairs(LayerDepth) do
        local obj = fgui.GComponent:create()
        obj:setSortingOrder(v)
        groot:addChild(obj)
        _parentLayer[v] = obj
        viewLayersNum[v] = 0
    end
    --鼠标点击特效开始
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	local obj=ViewManager.getParentLayer(LayerDepth.UIEffect)
	local hadTouch=true
	local endTime=0
	obj:setPivot(0,0)
	listener:registerScriptHandler(function (touch,event)
			hadTouch=true
			endTime=0
			local point = obj:displayObject():convertToNodeSpace(cc.p(touch:getLocation().x, touch:getLocation().y))
			point.y=-point.y
			point.x= point.x
			SpineUtil.residentSpine("Effect","jiemian_dianji","jiemian_dianji",obj,point,"animation",0.5)
			return true
		end, cc.Handler.EVENT_TOUCH_BEGAN)

	listener:registerScriptHandler(function (touch,event)
			hadTouch=false
			return true
		end, cc.Handler.EVENT_TOUCH_ENDED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,obj:displayObject());
	obj:displayObject():onUpdate(function (dt)
			if hadTouch==false then
				endTime=endTime+dt
				if endTime>=0.5 then
					--SpineUtil.hideParticleObj("particle_click")
					hadTouch=true
					endTime=0
				end

			end
		end,0)
    --鼠标点击特效结束

end

function ViewManager.showMainUI(bool)
    ViewManager.setVisible("MainUIView", bool)
    -- ViewManager.setVisible("HurtView", bool)
    ViewManager.setVisible("TaskTraceView", bool)
    -- ViewManager.setVisible("HintView", bool)
end


function ViewManager.getAllViews()
    return _residentViews, _openingViews, _hideViews
end

function ViewManager.fitAllViews()
	--return _residentViews, _openingViews, _hideViews
	for k,v in pairs(_residentViews) do
		v.window:__fitToScreen(true)
	end
	for k,v in pairs(_openingViews) do
		v.window:__fitToScreen(true)
	end
	for k,v in pairs(_hideViews) do
		v.window:__fitToScreen(true)
	end
end

--打开模块
--@param viewName       #string     要打开的视图名
--[[
    窗口名字，默认窗口名字对应viewGroups的类
]]

--@param args           #table      参数
--[[
args = {
    key = "1层跳转",
    key2 = "2层跳转",
}]]
--callback 回调方法 

function ViewManager.open(viewName, args,callback)

	local info = ViewGroups[viewName]
	if info and info.mid then
		if not ModuleUtil.moduleOpen(info.mid,true) then
			return
		end
	end

	
	return ViewManager.doOpen(viewName, args,callback)
end

function ViewManager.doOpen( viewName, args,callback )
	local battleBegin = false
	--if ViewManager.isShow("BattleBeginView") then
		--battleBegin = true
		--local arrType = FightManager.getRunArrayType(viewName)
		--if  arrType and ViewArrayType[arrType] and viewName == ViewArrayType[arrType].view then
			----RollTips.show("请等待本次战斗结束")
			--ViewManager.backToBattleView(arrType)
			--return
		--end
	--end
	local arraType = FightManager.getRunArrayType(viewName,args)
	local ViewArrayInfo = ViewArrayType[arraType]
	if  arraType and ViewArrayInfo and viewName == ViewArrayType[arraType].view then
		--RollTips.show("请等待本次战斗结束")
		if  ViewArrayInfo.args and ViewArrayInfo.args.page  then 
			if args and args.page == ViewArrayInfo.args.page then
				battleBegin = true
				ViewManager.backToBattleView(arraType)
				return
			end
		else
			battleBegin = true
			ViewManager.backToBattleView(arraType)
			return
		end
		
		
	end
	if  ScriptType == ScriptTypeLua and not __IS_RELEASE__ and CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		GMModel:findChangeLua(true)
	end
	
    -- LuaLogE("open window=",viewName)
	printTable(33,args)
    if _residentViews[viewName] or _openingViews[viewName] then
        if _hideViews[viewName] then
            local viewInfo = _hideViews[viewName]
            if viewInfo.window then
                viewInfo.window:setVisible(true)
                _hideViews[viewName] = nil
                --如果需要回调
                if callback then callback() end
            end
            return
        end

        local v = _openingViews[viewName]
		print(33,"_openingViews",v,v.window,v.bringToFront)
        if v and v.window then
            
            v.window:bringToFront()
			local depth = v.window._rootDepth
			if depth == LayerDepth.PopWindow then depth = LayerDepth.Window end
            viewLayersNum[depth] = viewLayersNum[depth] + 1
            v.window._layerNum = viewLayersNum[depth]
			if v.window.openPage and args and args.page then
				v.window:openPage(args)
			end
            
            --子级跳转
            if args and args.key then
                -- if v.view.setSelectedKey then
                --     v.view:setSelectedKey(args.key, args.key2)
                -- end
            end
        end
        --如果需要回调
        if callback then callback() end
        return
    end

    args = args or {}
    local  viewInfo
    --如果有className则用className查找view页面
    --用处是可以同时存在多个相同的view页面
    if args.className then
        viewInfo = clone(ViewGroups[args.className])
    else
        viewInfo = clone(ViewGroups[viewName])
    end

    local mid = 0
    if viewInfo.mid ~=nil then mid = viewInfo.mid end
    local hasOpen = ModuleUtil.moduleOpen( mid , true )  
    if hasOpen == nil then return end
    
    assert(viewInfo ~= nil, string.format("%s 's viewInfo is nil", viewName))
    if viewInfo.closeOthers == nil then
        viewInfo.closeOthers = false
    end
    if viewInfo.playSound == nil then
        viewInfo.playSound = true
    end
    if not viewInfo.isResident then
        if viewInfo.closeOthers then
            ViewManager.closeAll()
        end
    end
    if viewInfo.class == nil then
        viewInfo.class = require(viewInfo.path)
    end
    viewInfo.window = viewInfo.class.new(args, viewName)
    viewInfo.window._viewName = viewName
	local depth = viewInfo.window._rootDepth
	if depth == LayerDepth.PopWindow then depth = LayerDepth.Window end
    viewLayersNum[depth] = viewLayersNum[depth] + 1
    viewInfo.window._layerNum = viewLayersNum[depth]
    viewInfo.name = viewName

    if viewInfo.isResident then
        _residentViews[viewName] = viewInfo
    else
        _openingViews[viewName] = viewInfo
    end

	
	GMModel:addView(viewInfo)
    viewInfo.window:toCreate(callback)
	
	if viewInfo.window._willOpenInBattle and cc.Director:getInstance():getScheduler():getTimeScale()>1 then
		cc.Director:getInstance():getScheduler():setTimeScale(1)
	end
	--记录战斗后打开的界面
	if viewInfo.window._batttleView then
		viewAfterBattleView = {}
	end
	if battleBegin and depth == LayerDepth.Window then
		table.insert(viewAfterBattleView,viewInfo.window)
	end
	
	--ViewManager.freshRenderOrder(viewInfo.window._rootDepth)
	ViewManager.freshShowView(viewInfo.window,false)
	--背景模糊放在其他页面隐藏之后  预防截图不准确
	viewInfo.window:_setBlur(true)
	
	
    return viewInfo.window
end

--关闭视图
function ViewManager.close( viewName, isImmediate )
	local viewInfo = ViewManager.getViewInfo(viewName)
	if not viewInfo then
		-- LuaLogE("不存在视图 ",tostring(viewName))
		return
	end
	if viewInfo==nil or viewInfo.window ==nil then
		-- LuaLogE("界面已关闭",tostring(viewName))
	end
	if viewInfo.hide then
		ViewManager.hide(viewName)
		return
	end
	--if viewInfo.window._willOpenInBattle then
		--PBattleModel:updateGameSpeed()
	--end
    _residentViews[viewName] = nil
    _openingViews[viewName] = nil
	-- for k, info in ipairs(_viewStack) do
 --        if info.name == viewName then
 --            table.remove(_viewStack, k)
 --            break
 --        end
 --    end

	ViewManager.freshShowView(viewInfo.window,true)
    viewInfo.window:close(isImmediate)
	GMModel:removeView( viewName )
end

--视图隐藏
function ViewManager.hide(viewName)
    local viewInfo = ViewManager.getViewInfo(viewName)
    if viewInfo and viewInfo.window then
        viewInfo.window:setVisible(false)
        _hideViews[viewName] = viewInfo
    end
end

--清除所有界面
function ViewManager.clear()
	ViewManager.showIpadBg(false)
    ViewManager.closeAll(true, true)
end

-- 关闭所有窗口
function ViewManager.closeAll(closeResident, isImmediate)
    for k, v in pairs(_openingViews) do
        ViewManager.close(v.name, isImmediate)
    end
    if closeResident then
        for k, v in pairs(_residentViews) do
            ViewManager.close(v.name, isImmediate)
        end
    end
    ViewManager.closeGlobalWait()
end

function ViewManager.getParentLayer(depth)
	if depth == LayerDepth.PopWindow then depth = LayerDepth.Window end
    return _parentLayer[depth]
end


-------------------------页面计数---------------------
function ViewManager.addWindowCount()
    _windowCount = _windowCount + 1
end

function ViewManager.subWindowCount()
    _windowCount = _windowCount - 1
end

function ViewManager.getWindowCount()
    return _windowCount
end
-------------------------页面计数---------------------

-------------------------包引用计数---------------------
--增加计数
function ViewManager.addCount(packageName, compName)
	print(33,"addCount",packageName, compName)
	if not _packView[packageName] then
        _packView[packageName] = 0
		_packRemoveTime[packageName] = cc.millisecondNow()
    end
    _pcDict[packageName] = _pcDict[packageName] or {}
    _pcDict[packageName][compName] = _pcDict[packageName][compName] or 0

    _packView[packageName] = _packView[packageName] + 1
    _pcDict[packageName][compName] = _pcDict[packageName][compName] + 1
    -- Dispatcher.dispatchEvent(EventType.TEST_PACKAGE_UPDATE)
end

--减少计数
function ViewManager.subCount(packageName, compName)
	print(33,"subCount",packageName, compName)
	if not _packView[packageName] then
        _packView[packageName] = 0
		_packRemoveTime[packageName] = cc.millisecondNow()
    end
    _pcDict[packageName] = _pcDict[packageName] or {}
    _pcDict[packageName][compName] = _pcDict[packageName][compName] or 0


    _packView[packageName] = _packView[packageName] - 1
    _pcDict[packageName][compName] = _pcDict[packageName][compName] - 1

    if _packView[packageName] < 0 then
        _packView[packageName] = 0
    end

    if _pcDict[packageName][compName] <= 0 then
        _pcDict[packageName][compName] = nil
    end
	
	if _packView[packageName] <= 0 then
		_packRemoveTime[packageName] = cc.millisecondNow()
	end

    -- Dispatcher.dispatchEvent(EventType.TEST_PACKAGE_UPDATE)
end

function ViewManager.getPackageCount(packageName)
    return _packView[packageName] or 0
end


function ViewManager.getAllPackageCount()
    local tempArr = {}
    for k,v in pairs(_packView) do
        local temp = {}
        temp.pname = k
        temp.count = v
        table.insert(tempArr,temp)
    end
    return tempArr
end

function ViewManager.getPackageRemoveTime(packageName)
	local time = _packRemoveTime[packageName]
    return _packRemoveTime[packageName] and _packRemoveTime[packageName] or cc.millisecondNow()
end

function ViewManager.getPCDict(packageName)
    return _pcDict[packageName]
end

-------------------------包引用计数---------------------
-- 全局菊花等待模态
local _waitId
function ViewManager.showGolbalWait()
	if ViewManager.hadShowCloseTips then return end
    if not _globalWaitObj then
        ViewManager.clearWaitId()

        _globalWaitObj = UIPackageManager.createGComponent("UIPublic", "ModalWaitView")
		if _globalWaitObj then
			_globalWaitObj:retain()
        --父节点
        
			_globalWaitObj:setSize(display.width, display.height)
		end
        --_globalWaitObj:addRelation(parentObj, fgui.RelationType.Size)

        --[[ViewManager.clearWaitId()
        _waitId = Scheduler.scheduleOnce(3, function()
            ViewManager.closeGlobalWait()
            _waitId = false
        end)--]]
    end
	
	if _globalWaitObj and not _globalWaitObj:getParent() then
		local parentObj = ViewManager.getParentLayer(LayerDepth.Alert)
		parentObj:addChild(_globalWaitObj)
	end
end

--关闭菊花等待模态
function ViewManager.closeGlobalWait()
	
    if _globalWaitObj and _globalWaitObj:getParent() then
        _globalWaitObj:removeFromParent()
        --_globalWaitObj = false
        ViewManager.clearWaitId()
    end
end

--清除
function ViewManager.clearWaitId()
    if _waitId then
        Scheduler:unschedule(_waitId)
        _waitId = false
    end
end

--isSlow 是否网络延时提示
function ViewManager.showReconnectWait(isSlow)
	if ViewManager.hadShowCloseTips then return end
	 ViewManager.clearWaitId()
    if _reconnectWaitObj == false then
        _reconnectWaitObj = UIPackageManager.createGComponent("UIPublic", "ReconnectingView")
		if _reconnectWaitObj then
			_reconnectWaitObj:retain()
			--父节点
			_reconnectWaitObj:setSize(display.width, display.height)
		end
    end
	if isSlow then
		_reconnectWaitObj:getChildAutoType("txt_text"):setText("等待数据中...")
	else
		_reconnectWaitObj:getChildAutoType("txt_text"):setText("网络不佳，正在玩命重连中...")
	end
	if _reconnectWaitObj and not _reconnectWaitObj:getParent() then
		local parentObj = ViewManager.getParentLayer(LayerDepth.Alert)
		parentObj:addChild(_reconnectWaitObj)
	end
end

--关闭菊花等待模态
function ViewManager.closeReconnectWait()
	if _reconnectWaitObj and _reconnectWaitObj:getParent() then
        _reconnectWaitObj:removeFromParent()
    end
end

--获取界面的view
function ViewManager.getView(viewName)
    local viewInfo = false
    if _residentViews[viewName] then
        viewInfo = _residentViews[viewName]
    else
        viewInfo = _openingViews[viewName]
    end
    if viewInfo and viewInfo.window then
        return viewInfo.window
    end
    return false
end

--获取某个页面包含配置信息
function ViewManager.getViewInfo(viewName)
    local viewInfo = false
    if _residentViews[viewName] then
        viewInfo = _residentViews[viewName]
    else
    	viewInfo = _openingViews[viewName]
    end
    if viewInfo and viewInfo.window then
        return viewInfo
    end
    return false
end


-- 调用view中的接口
-- @viewName    #string     view名
-- @funcName    #string     接口函数名
-- @...         #*          接口函数对应的参数
function ViewManager.call(viewName, funcName, ...)
    local view = ViewManager.getView(viewName)
    if view then
        return view[funcName](view, ...)
    end
    return false
end

--某个页面是否在显示
function ViewManager.isShow(viewName)
    if _hideViews[viewName] then
        return false
    end
    if _residentViews[viewName] then
        return not (not _residentViews[viewName])
    end
    return not (not _openingViews[viewName])
end

--检测页面是否是隐藏
function ViewManager.isHide(viewName)
    if _hideViews[viewName] then
        return not (not _hideViews[viewName])
    end
end

--显示隐藏某页面
function ViewManager.setVisible(viewName, bol)
    local view = ViewManager.getView(viewName)
    if view then
        view:setVisible(bol)
    end
end

--获取某页面的显示状态
function ViewManager.isVisible(viewName)
    local view = ViewManager.getView(viewName)
    if view then
        view:getVisible()
    end
end

--获取所有显示状态的页面
function ViewManager.getOpeningViews()
    return _openingViews
end

--获取所有层级最顶层的界面
function ViewManager.getAllLayerTopWindow(banViewMap )
    local topViews = {}
    local preLayer = 0
    local temp = nil
    for k1,v1 in pairs(viewLayersNum) do
        temp = nil
        for k,v in pairs(_openingViews) do
			local depth = v.window._rootDepth
			if depth == LayerDepth.PopWindow then depth = LayerDepth.Window end
            if depth == k1 and (not banViewMap or not banViewMap[v.window._compName]) then
                 if not temp  then
                    temp = v
                 end
                 if v.window._layerNum> temp.window._layerNum then
                    temp = v
                 end
            end
        end
        topViews[k1] = temp
        --print(1,k1,topViews[k1])
    end
    return topViews
end

--layerRoot 如果不传 则是所有层级最顶层 
function  ViewManager.getLayerTopWindow( layerRoot,banRootMap,banViewMap)
    local topViews = ViewManager.getAllLayerTopWindow(banViewMap)
    if layerRoot and  topViews[layerRoot] then
        return topViews[layerRoot]
    else
        local topView = nil
        for k,v in pairs(topViews) do
            if (not banRootMap or not banRootMap[k]) and topViews[k] then
                if not topView then
                    topView = topViews[k]
                end
                if topView then
                    if topViews[k].window._rootDepth >topView.window._rootDepth then
                        topView = topViews[k]
                    end
                end
            end
        end
        return topView
    end
    return nil
end


function ViewManager.freshRenderOrder(depth)
	for k,v in pairs(_parentLayer[depth]:getChildren()) do
		v:displayObject():setLocalZOrder(k)
	end
end

local function _recordViewList(view,exit,msg)
	recordLastNum = recordLastNum + 1
	if recordLastNum > 6 then
		recordLastNum = 1
	end
	recordLastView[recordLastNum] = msg
	
	local logStr = recordLastNum.."|"
	for i = 1, 6 do
		logStr = logStr..recordLastView[i]
	end
	--if not exit and view._viewName then
		SDKUtil.setBuglyUserStep(logStr)
	--end
end

function ViewManager.freshShowView(view,exit)
	local str_t = view._viewName .. (exit and " exit>" or " open>")
	-- LuaLogE("freshShowView ",str_t)
	local depth = view._rootDepth
	if depth == LayerDepth.Message or depth == LayerDepth.RollTips then return end
	if depth == LayerDepth.WindowUI then return end
	if depth == LayerDepth.PopWindow then depth = LayerDepth.Window end
	
	if depth ~= LayerDepth.Window then
		local childs = _parentLayer[depth]:getChildren()
		local childNum = #childs
		if childNum > 0 then 
			local topIndex = 1
			for i=1 , childNum do
				childs[i]:setVisible(false)
				if exit and childs[i] ==  view.view then
					
				elseif i > topIndex then
					topIndex = i
				end
			end
			childs[topIndex]:setVisible(true)
		end
	end
	
	local win_childs = _parentLayer[LayerDepth.Window]:getChildren()
	local windowViewNum = #win_childs
	local findW = false
	local findPW = false
	local findWNum = 0
	print(33,"begin find Window = ",windowViewNum)
	for i = windowViewNum, 1,-1 do
		print(33,"for all view",win_childs[i]._rootDepth,win_childs[i]._viewName)
		if exit and win_childs[i]== view.view then
			
		elseif win_childs[i].hidebattle then
			
		elseif not findW and win_childs[i]._rootDepth == LayerDepth.Window  and win_childs[i]:getParent() then
			win_childs[i]:setVisible(true)
			findW = true
			print(33,"findW")
		elseif not findPW and win_childs[i]._rootDepth == LayerDepth.PopWindow and win_childs[i]:getParent() then
			findPW = true
			win_childs[i]:setVisible(true)
			print(33,"findPopW")
		else
			if view._args and view._args.noHideLast then
				
			else
				win_childs[i]:setVisible(false)
			end
			
		end
		if win_childs[i]._rootDepth == LayerDepth.Window and not win_childs[i].hidebattle then
			findWNum = findWNum + 1
		end
	end
	
	
	local showMainUIView = false
	if  findWNum == 1 then
		if   view._rootDepth == LayerDepth.Window and exit then
			showMainUIView = true
		else
			showMainUIView = false
		end
	elseif  findWNum > 1 then
		showMainUIView = false
	else
		showMainUIView = true
	end
	_parentLayer[LayerDepth.MainUI]:setVisible(showMainUIView)
	
	if _mainUIView then
		_mainUIView:setVisible(showMainUIView)
	end
	if depth == LayerDepth.MainUI then
		if exit then
			_mainUIView = false
		else
			_mainUIView = view
			_mainUIView:setVisible(true)
		end
	elseif depth == LayerDepth.Window then
		ViewManager.freshRenderOrder(depth)
	end
	
	
	_recordViewList(view,exit,str_t)
	Dispatcher.dispatchEvent(EventType.view_change)
	
end

function ViewManager.backToBattleView(arraType)
	
	--for i = 1, #viewAfterBattleView do
		--ViewManager.close(viewAfterBattleView[i]._viewName)
	--end
	
	--local view = ViewManager.getView("BattleBeginView")
	--if view then
		--view.view.hidebattle = false
		--view:setVisible(true)
		--ViewManager.open("BattleBeginView")
	--end	
	--viewAfterBattleView = {}
	FightManager.openFight(arraType)
end

function ViewManager.showMainView()
	
	--local win_childs = _parentLayer[LayerDepth.Window]:getChildren()
	--local windowViewNum = #win_childs
	--for i = windowViewNum, 1,-1 do
		--win_childs[i]:setVisible(false)
	--end
	
	for k,v in pairs(_openingViews) do
		if v.window._compName == "BattleBeginView" then
			v.window:setVisible(false)
		elseif  v.window._rootDepth == LayerDepth.Window or  v.window._rootDepth == LayerDepth.PopWindow then
			v.window:closeView()
		end
	end
	local view = ViewManager.getView("BattleBeginView")
	if view then
		view:setVisible(false)
		view.view.hidebattle = true
	end
	ViewManager.setVisible("BattleBeginView",false)
	_parentLayer[LayerDepth.MainUI]:setVisible(true)
	if _mainUIView then
		_mainUIView:setVisible(true)
	end
end

function ViewManager.backToMainView(banViewMap)
	for k,v in pairs(_openingViews) do
		local depth = v.window._rootDepth
		if  depth == LayerDepth.MainUI  then
			--v.window.view:setVisible()
			if v.window._compName == "MainSubBtnView" then
				v.window:closeView()
			end
		elseif  depth == LayerDepth.PopMainUI or depth == LayerDepth.Message then
			
		elseif  banViewMap and banViewMap[v.window._viewName] then
			
		else
			v.window:closeView()
		end
	end
	Dispatcher.dispatchEvent(EventType.view_change)
end

function ViewManager.showIpadBg(value)
	if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then return end 
	if _upSprite then
		_upSprite:setVisible(value)
		_downSprite:setVisible(value)
		return
	end
	if value and display.height > 720 then
		local offY = (display.height - 720)/2
		_upSprite = cc.Sprite:create("UI/Loading/ipad_s.png")
		_downSprite = cc.Sprite:create("UI/Loading/ipad_s.png")
		_upSprite:setAnchorPoint(cc.p(0.5,1))
		_upSprite:setPosition(display.width/2,offY)
		_downSprite:setAnchorPoint(cc.p(0.5,0))
		_downSprite:setPosition(display.width/2,display.height - offY)
		fgui.GRoot:getInstance():displayObject():addChild(_upSprite)
		fgui.GRoot:getInstance():displayObject():addChild(_downSprite)
	end


    
end

return ViewManager