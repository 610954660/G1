--红点管理类
--@class RedManager
--使用方法：
--1.在RedConst 中注册相关的模块红点数据
--2.在View中重写_addRed 处理，内部注册当前页面所需要的所有红点，界面会在显示的时候注册，关闭的时候，移除
--3.红点处理更新，调用RedManager.updateValue 方法即可， type 为在RedConst中定义的类型
--示例：背包模块，现在点击背包就会展示红点，点击背包第一个页签，红点就会取消。
--Tips:  模块看起相关的逻辑尚未进行验证，后期加上即可。
local RedManager = {}
local RedConst = require "Game.Consts.RedConst"

local _tipsValue = {} --对应红点状态值
local _tipsMap = {} --子内容为key,父内容为value
local _tipsMapList = {} --父内容为key,所有子内容为value
local _tipsDic={} --内容为key,value为红点对象
local _midDic ={} --内容为key,value为value
local _midMap ={} --模块控制
local _disInType={} --红点对象为key,内容为value

--启动红点
function RedManager.start()
    RedConst.init();
end

--初始化处理
function RedManager.init(tipsMap , tipsMapList , midMap)  
    _tipsMap = tipsMap
    _tipsMapList = tipsMapList
    _midMap = midMap
	for type,mid in pairs(_midMap) do
		_midDic[mid] = _midDic[mid] or {}
		_midDic[mid][type] = type
	end
end

--更新红点值
--needCheck 如果值是相同的，是否也触发设置红点显示（一般不用传）
function RedManager.updateValue(type , newVal , needCheck)
	if newVal then newVal = true end
    if needCheck==nil then needCheck= true end
    local curV = _tipsValue[type]
    if curV==newVal and needCheck then
        return 
    end
    _tipsValue[type] = newVal
   -- print(1 , "更改红点值 , " , type , newVal)
    RedManager.updateTips(type , newVal)
    RedManager.updateTipsValue(type)
end

--获取红点数据
function RedManager.getTips(type)
    --这里需要加上功能模块开启验证逻辑
    local hasOpen = ModuleUtil.hasModuleOpen( _midMap[ type ] )
    if hasOpen==nil or hasOpen == false then return false end
    return _tipsValue[type];
end

--更新红点处理
function RedManager.updateTips(type , isShow)
    local allDisplay = _tipsDic[type]
    if isShow==nil then
        isShow = false
    end    
    --模块开启验证
    local isOpen = ModuleUtil.hasModuleOpen( _midMap[ type ] );
    isShow = isShow and isOpen;
    if allDisplay then
        for display,viewDis in pairs(allDisplay) do            
            if not tolua.isnull(display) then 
				display:setVisible(isShow) 
			else
				allDisplay[display] = nil
			end
        end
    end
end


--添加红点依赖关系
function RedManager.addMap(key, items)
	RedManager.removeMap(key)
	local isShow = false;
	for i,v in ipairs(items) do
		if (not _tipsMap[items[i]]) then
			_tipsMap[items[i]] = {};
		end
		_tipsMap[items[i]][key] = true;
		if (RedManager.getTips(items[i])) then
			isShow = true;
		end
	end
	
	RedManager.updateValue(key, isShow)
	_tipsMapList[key] = items;
end

--移除红点注册关系统
function RedManager.removeMap(key) 
	RedManager.updateValue(key, false)
	local  items = _tipsMapList[key];
	if (items) then
		for i,v in ipairs(items) do
			if(v ~= "") then
				if _tipsMap[items[i]] then
					_tipsMap[items[i]][key] = nil
					_tipsMap[items[i]] = nil
				end
			end
		end
	end
	_tipsMapList[key] = nil
end

--更新Tips值处理
function RedManager.updateTipsValue(type) 
    local tipsMap = _tipsMap  
    while( tipsMap[type] ~= nil )
    do
        for k,v in pairs(tipsMap[type]) do
            local mapList = _tipsMapList[k];
            local isShow = false;          
            if mapList then
                for ki,vi in pairs(mapList) do
                    if _tipsValue[vi]==true then
                        --模块开启验证
                        local hasOpen = ModuleUtil.hasModuleOpen( _midMap[vi] )
                        if hasOpen then isShow= true break end 
                    end
                end
            end     
            RedManager.updateValue( k , isShow);
            _tipsValue[ k ] = isShow;
            type = k;
        end
    end
end
--功能开启时，更新相关红点显示处理
function RedManager.openModuleTips(mid)
    local midInfo = _midDic[mid];
    if midInfo then
        for k , v in pairs(midInfo) do
            RedManager.updateValue(k , _tipsValue[k] , false)
        end
    end
end

--注册红点的模块Id
function RedManager.regMid(type , mid)
	if _midDic[mid]==nil then _midDic[mid] = {}; end
	_midDic[mid][type] = type;
    _midMap[type] = mid;
    --RedManager.updateTips(type , _tipsValue[type] );
	RedManager.updateTipsValue(type) 
end

--注册红点处理
--@params    type     RedConsts中定义的类型，type为null时清除注册
--@params    display  红点显示对象，里面必须包含（img_tips)对象，进行红点控制
function RedManager.register(type , display , mid)
    if type ==nil or type =='' then
        --移除逻辑        
        if display then
			display:setVisible(false)
            local inType = _disInType[ display ];
            if inType then
                _tipsDic[inType][display] = nil;
                _disInType[display] = nil;                
            end            
        end
        return
    end
	
		
    if _tipsDic[type]==nil then
        _tipsDic[type] = {};
    end
    if display then
        --一个红点不能注册2种类型
        local inType = _disInType[display]
        if inType then 
            _tipsDic[inType][display] = nil;
            _disInType[display] = nil; 
        end
        _disInType[display] = type
        _tipsDic[type][display] = 1;   
        if mid ~= nil then   
			if _midDic[mid]==nil then _midDic[mid] = {}; end
			_midDic[mid][type] = type;
			_midMap[type] = mid;
		end
        --if viewDis and viewDis.tipsEvent==nil then viewDis.tipsEvent = {} end
        --viewDis.tipsEvent[display] = type;
		--[[display:addEventListener(FUIEventType.Exit,function(context) 
			_tipsDic[type][display] = nil;
            _disInType[display] = nil; 
		end);
		
		display:addEventListener(FUIEventType.Enter,function(context) 
			_tipsDic[type][display] = 1;
            _disInType[display] = type; 
		end);--]]

        RedManager.updateTips(type , _tipsValue[type])
    end
end

--移除红点
function RedManager.removeTips(type , viewDis)
    local tipsDic = _tipsDic[type];
    if not tipsDic then return end;
    for display , vDis in pairs(tipsDic) do
        if vDis == viewDis then
            _tipsDic[type][display] = nil;
            _disInType[display] = nil
        end
    end  
end

function RedManager.printDebug()
	--printTable(1,_tipsMapList)
	--printTable(1,_tipsMap)
	print(69, "")
	printTable(69, _tipsMapList["V_CardCategory0"])
	print(69, "V_CardCategory0", RedManager.getTips("V_CardCategory0"))
	for _,v in pairs(_tipsMapList["V_CardCategory0"]) do
		print(69, v, RedManager.getTips(v))
	end
end

--查看快点状态
function RedManager.getRedInfo(redKey)
    local redInfo={}
    local mapList = _tipsMapList[redKey];	
    if redInfo[redKey]==nil then
        redInfo[redKey]={}
    end
    if (not mapList) then
        return nil
    end
    for ki,vi in pairs(mapList) do
        if redInfo[redKey][vi]==nil then
            redInfo[redKey][vi]={}
        end
        local mid= _midMap[vi]
        local red=_tipsValue[vi]
        local hasOpen = ModuleUtil.hasModuleOpen( mid )
        redInfo[redKey][vi]={red,mid,hasOpen}
    end
    local mid= _midMap[redKey]
    local red=_tipsValue[redKey]
    local hasOpen = ModuleUtil.hasModuleOpen( mid )
    redInfo[redKey]["curRed"]={red,mid,hasOpen}
	printTable(157,">>>>>>>>>>>>>>>",redInfo)
	return redInfo
end


--移除所有红点
function RedManager.removeAll(viewDis)
    if viewDis and viewDis.tipsEvent then
        for k , v in pairs(viewDis.tipsEvent) do
            RedManager.removeTips(viewDis.tipsEvent[k] , viewDis)
        end
        viewDis.tipsEvent =  nil
    end
end

function RedManager:clear()
	_tipsValue = {} --对应红点状态值
	_tipsMap = {} --子内容为key,父内容为value
	_tipsMapList = {} --父内容为key,所有子内容为value
	_tipsDic={} --内容为key,value为红点对象
	_midDic ={} --内容为key,value为value
	_midMap ={} --模块控制
	_disInType={} --红点对象为key,内容为value
	
	RedConst.clear()
end

return RedManager