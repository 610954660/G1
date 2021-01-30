
-- 打开中的弹窗
local _alertDict = {}

local _dict = {
	default = {name = "AlertView"},
	AlertRewardView = {name = "AlertRewardView"},
	cost = {name = "AlertViewCost"},
	input = {name = "AlertInputComfirmView"},
	resetHero = {name = "ResetHeroSureTipView"},
}

---@class Alert
local Alert = {}


----@param args {
-- text:string,  本文描述 必填
-- title:string, 标题 默认"提示"
-- yesText:string, yesBtn的标题 默认"确定"
-- noText:string, noBtn的标题	默认"取消"
-- okText:string, okBtn的标题	默认"确定"
-- id:string, alert窗口的唯一标识 默认自动生成
-- cost:table, 需要显示的消耗，通用消耗格式
-- noHasNum:boolean, 显示消耗时不显示当前有的数量
-- onlyHasNum:boolean, 显示消耗时只显示当前有的数量

-- type:string,  "ok" |"yes_no"| "none"  默认 "ok"
-- mask:string,  是否有遮罩 "no" |"yes"   默认 "no"
-- swallow:string   是否吞噬UI下层点击事件 "no" |"yes"  默认"yes"
-- noClose, 是否隐藏关闭按钮 "no" |"yes" 默认"no"
-- onClose:function 关闭回调
-- onYes:function yesBtn回调
-- onNo:function noBtn关闭回调
-- onOk:function okBtn关闭回调
-- autoClose:string 自动关闭"no" |"yes" 默认"no"
-- align:string "left" "center" 只支持左对齐或者居中对齐，默认是居中对齐
-- }


--如果参数1是string,直接显示该内容，其他为默认参数
--如果参数1是table,则解析对应参数
function Alert.show(args,...)

	if type(args) == "string" then
		local text = args
		args = {}
		args.text = text
	end


	if args.alertType then
		if not Alert.shouldTodayAlert(args.alertType) then
			log(args.alertType, "no tips today")
			return
		end
	end
	if args.id == nil then
		args.id = UIDUtil:getUID()
	else
		-- args.id 在 AlertId.lua填写
	end
	args.key = args.key or "default"
	args.type = args.type or "ok"
	args.noClose = args.noClose or "yes"
	args.swallow = args.swallow or "yes"
	
	if args.cost or args.costType then
		args.key = "cost"
	elseif args.input then
		args.key = "input"
	end

	local info = _dict[args.key]
	local viewName = info.name .. args.id

	local view = _alertDict[viewName]
	if view then
		return view
	end

	if not args.title then
		args.title = Desc.common_tips
	end

	args.className = info.name
	args.viewName = viewName
	view = ViewManager.open(viewName, args)
	_alertDict[viewName] = view

	return view,viewName
end

function Alert.close(viewName)
	local view = _alertDict[viewName]
	if view then
		ViewManager.close(viewName)
		_alertDict[viewName] = nil
		if ModelManager.PlayerModel.TipsNotifyId and view == ModelManager.PlayerModel.TipsNotifyId then
			ModelManager.PlayerModel.TipsNotifyId = false
			Dispatcher.dispatchEvent(EventType.tips_notify_close)
		end
	end
end

function Alert.isShowView()
	if next(_alertDict) then
		return true
	end

	return false
end

function Alert.closeAll()
	for viewName, view in pairs(_alertDict) do
		if view then
			Alert.close(viewName)
		end
	end
end

function Alert.clearDict(viewName)
	_alertDict[viewName] = nil
end

function Alert.setTodayNoAlert(alertType)
	-- local time = Cache.serverTimeCache.getServerTime()
	local time = os.time()
	FileDataUtil.setInt(alertType, time, FileDataUtil.KeyId)
end

function Alert.shouldTodayAlert(alertType)
	local lastTime = FileDataUtil.getInt(alertType, -1, FileDataUtil.KeyId)
	if lastTime == -1 then
		return true
	end
	local a = os.date("*t", lastTime)
	local b = os.date("*t", os.time())
	if a.year ~= b.year or a.month ~= b.month or a.day ~= b.day then
		return true
	end
end

return Alert