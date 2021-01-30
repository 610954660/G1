--added by xhd FGUI package管理类
---@class UIPackageManager
local UIPackageManager = {}
-- 公共包
local _publicPackage = {
    MainUI = true,
    UIPublic = true,
    UIPublic_Window = true,
    UISound = true,
}

--常驻包，进入主界面再加载
local _residentPackage = {
    MainUI = true,
    Broadcast = true,
}

-- 基础包直接同步加载
local _basePackage = {
    "UIPublic",
    "UIPublic_Window",
    "UISound",
    "Window2",
    "Window4",
    "commonBg",
    "common",
    "Font",
    "Chat",
	"WindowMuti1",
}

-- 要保存不释放的包
local _keepPackage = {
	"ToolTip",
	"UIPublic_ReWard"
}

local _basePackageMap = {}

local _packageList = {}
UIPackageManager._packageList = _packageList

--正在加载的包，异步操作，避免同一时间重复加载
local _loadingPackageList = {}
UIPackageManager._loadingPackageList = _loadingPackageList

--package 管理器初始化
--暂定5秒一次检查 包资源使用情况
function UIPackageManager.init( ... )
	UIPackageManager.removeAllPackages()
	cc.TextureCache:getInstance():removeUnusedTextures()

    UIPackageManager.__timerId = false
    UIPackageManager.__checkTime = 5
    UIPackageManager.__referTime = 10
    UIPackageManager.translateLanguage() --切换语言配置文件
    UIPackageManager.startCheckAssets()
    UIPackageManager.initBasePackage()
end

--定时检测包使用
function UIPackageManager.startCheckAssets(  )
    if UIPackageManager.__timerId then
        Scheduler.unschedule(UIPackageManager.__timerId)
    end
    UIPackageManager.__timerId = Scheduler.schedule(function()
        --print(1,"清除无用包体")
        UIPackageManager.clearUnusedAssets()
    end, UIPackageManager.__checkTime)
end

--清除无用包体
function UIPackageManager.clearUnusedAssets(force)
	for packageName,v in pairs(_packageList) do
		if _basePackageMap[packageName] or _keepPackage[packageName] then
		
		elseif ViewManager.getPackageCount(packageName) == 0 then
			local nowTime = cc.millisecondNow()
			local removeTime = ViewManager.getPackageRemoveTime(packageName)
			local freeTime = nowTime - removeTime

			if force or  freeTime > UIPackageManager.__referTime * 1000 then
				UIPackageManager.removePackage(packageName)
			end
		end
	end
	
end


function UIPackageManager.getResidentList()
    return _residentPackage
end

function UIPackageManager.getPublicList()
    return _publicPackage
end

function UIPackageManager.getPackageList()
    return _packageList
end

function UIPackageManager.getPackageInfo(packageName)
    return _packageList[packageName]
end


function UIPackageManager.initBasePackage()
    for k, v in pairs(_basePackage) do
        print(1,"base package = ",v)
        UIPackageManager.addPackage(v)
		_basePackageMap[v] = 1
    end

end

function UIPackageManager.getPackagePathInPc(packageName)
    local filePath = string.format("Fgui/%s", packageName)
    return filePath
end

--添加包
function UIPackageManager.addPackage(packageName,callback)
    -- 直接读文件
    local filePath = UIPackageManager.getPackagePathInPc(packageName)
    local package = fgui.UIPackage:addPackage(filePath)
    _packageList[packageName] = package
    -- if callback then callback() end
    return package
end

--异步添加包体
function UIPackageManager.addPackageAsync(packageName, callback)
end

function UIPackageManager.getItemURL(package, component)
    return fgui.UIPackage.getItemURL(package, component)
end

function UIPackageManager.getUIURL(package, component)
    return string.format("ui://%s/%s", package, component)
end

-- 创建FGUI显示对象
-- @param   package     #string             资源所在包名
-- @param   component   #string             资源所在包的组件名
-- @return  #GameObject     返回创建的对象
function UIPackageManager.createObject(package, compName)
    local obj = fgui.UIPackage:createObject(package, compName)
    return obj
end

function UIPackageManager.createGComponent(package, compName)
    local obj = fgui.UIPackage:createGComponent(package, compName)
    return obj
end

function UIPackageManager.removePackage(packageName)
	print(1,"清除无用包体",  packageName)
    fgui.UIPackage:removePackage(packageName)
	_packageList[packageName] = nil
end


function UIPackageManager.removeAllPackages()
	_packageList = {}
    fgui.UIPackage:removeAllPackages()
end

--切换语言文件配置
function UIPackageManager.translateLanguage()
end

return UIPackageManager