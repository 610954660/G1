local HttpUtil = {}
--正在请求中的url
local _requestingURLs = {}  

local private = {}

function private.showTipMsg(msg, isShow)
	if isShow == nil then isShow = true end
	if msg then
		--if isShow and MsgManager then
			-- MsgManager.showRBMsg(msg)
		--end
		LuaLogE("Http error!!! HttpUtil showTipMsg: " .. msg)
	end
end


-- 跟php屡次核对得出来的最终处理结果
-- 原始参数去掉一些特殊符号后用来计算sign, 用urlencode后的参数传给php, 因为php那边也不知道它的底层为什么会做decode导致参数对不上
function private.getFormatedURLData(params, key)
	local paramsT = {}
	local md5ParamsT = {}

	for k, v in pairs(params) do
		local key = tostring(k)
		local value = tostring(v)
		if key and key ~= "" and value and value ~= "" then
			if key ~= "0" and value ~= "0" then
				table.insert(md5ParamsT, key.."="..string.htmlspecialchars(string.trim(value)))
			end
			table.insert(paramsT, key.."="..string.urlencode(value))
		end
	end

	table.sort(paramsT)
	table.sort(md5ParamsT)	

	local paramsStr = table.concat(paramsT, "&")
	local md5ParamsStr = table.concat(md5ParamsT, "&") .. key	

	-- print(10, "key", key)
	-- print(10, "原始参数", paramsStr)
	-- print(10, "计算md5的参数", md5ParamsStr)

	local paramsMd5Str = string.lower(gy.GYStringUtil:getStringMD5(md5ParamsStr))
	local sign = "&sign="..paramsMd5Str
	params.sign = paramsMd5Str
	return paramsStr..sign, params
end

function private.onHttpResponse(dict, onSuccess, onFailed, url, showTips)
	_requestingURLs[url] = nil

	if dict.code ~= 200 then
		private.showTipMsg(string.format("Http request failed. code:%s msg:%s", dict.code, dict.dlMsg), showTips)
		if onFailed then
			onFailed({code = dict.code, reason = dict.dlMsg, status=dict.dlStatus})
		end
		return
	end
	
	print(69, dict.data)
	local subData = string.match(dict.data, "{.*}")  --有时候c++返回的json后面多加了几个字符，导到解析失败，这里把多余的去掉
	if not subData or subData == "" then
		private.showTipMsg("HTTP response error! data = -1", showTips)
		if onFailed then
			onFailed({code = -1, reason = "data = -1" })
		end
		return
	end
	if subData then
		dict.data = subData 
	end
	local jsContent = cjson.decode(dict.data)

	if type(jsContent) == "table" then
		local code = tonumber(jsContent.code)
		if code == 1000 then
			if onSuccess then
				onSuccess(jsContent.data)
			end
		else
			local reason = ""
			if jsContent.content and jsContent.content ~= ""  then
				reason = jsContent.content
			elseif jsContent.data then
				reason = jsContent.data 
			end
			
			private.showTipMsg(string.format("HTTP response error! %s(code=%d)", reason, code or 0), showTips)
			if onFailed then
				onFailed({code = code, reason = reason})
			end
		end
	else
		private.showTipMsg("HTTP response error! data = -1", showTips)
		if onFailed then
			onFailed({code = -1, reason = "data = -1" })
		end
	end
end

function private.send(params)
	local url
	local isNew = false
	if params.isNew then 
		url = params.ip
		params.params.event = params.action
		isNew = true
	else
		url = string.format("%s%s", params.ip, params.action)
	end

	if params.filterRepeat and _requestingURLs[url] then
		local errorStr = string.format("The url is requesting:%s", url)
		private.showTipMsg("errorStr", false)
		if params.onFailed then
			params.onFailed({code = -2, reason = errorStr})
		end
		return
	end
	
	local data,newParam = private.getFormatedURLData(params.params, params.key)
	
	local failedTimes = 0
	local scriptHandler = nil

	local function doSendPost()
		_requestingURLs[url] = true
		-- LuaLogE(string.format("~~~~~send~~~~~\n%s?%s", url, tostring(data)))
		
		if isNew then
			gy.GYHttpClient:send(url, data, scriptHandler, params.isGet, false, params.immediately, params.timeoutForConnect, params.timeoutForRead)
		else
			gy.GYHttpClient:send(url, data, scriptHandler, params.isGet, params.isCompress, params.immediately, params.timeoutForConnect, params.timeoutForRead)
		end
	end

	scriptHandler = function(dict)
		-- printTable(10, "返回结果", dict)
		local function onFailed(data)
			failedTimes = failedTimes + 1
			if failedTimes >= params.retryTimes then
				if params.onFailed then
					params.onFailed(data)
				end
			else
				if params.retryDelay <= 0 then
					doSendPost()
				else
					Scheduler.scheduleOnce(params.retryDelay, doSendPost)
				end
			end
		end
		private.onHttpResponse(dict, params.onSuccess, onFailed, url, params.showTips)
	end

	doSendPost()
end


function private.sendPlatform(url, params, onSuccess,onFailed)
	local data,newParam = private.getFormatedURLData(params, "")
	
	local failedTimes = 0
	local scriptHandler = nil

	local function doSendPost()
		LuaLogE(string.format("~~~~~send~~~~~\n%s?%s", url, tostring(data)))
		gy.GYHttpClient:send(url, data, scriptHandler, false, false, false, 30, 30)
	end

	scriptHandler = function(dict)
		-- printTable(10, "返回结果", dict)
		local function onFailedResult(data)
			failedTimes = failedTimes + 1
			if failedTimes >= 3 then
				if onFailed then
					onFailed(data)
				end
			else
				if 1 <= 0 then
					doSendPost()
				else
					Scheduler.scheduleOnce(1, doSendPost)
				end
			end
		end
		if dict.code == 200 then
			local subData = string.match(dict.data, "{.*}")
			--onSuccess(json.decode(subData))
		else
			--onFailedResult(json.decode(dict.data))
		end
		--private.onHttpResponse(dict, onSuccess, onFailedResult, url, params.showTips)
	end

	doSendPost()
end

------以下为公共接口-------------------------

--发给不是光娱的后台
function HttpUtil.sendToPlatform(url, params, onSuccess, onFailed) 
	private.sendPlatform(url, params, onSuccess)
end
-- 常规http请求，该接口不适合用于下载文件
-- ip					#string		地址，参考AgentConfiger.centerURL
-- action				#string		要执行的操作，一般使用HttpActionType枚举中的值
-- key					#string		加密用key，一般使用AgentConfiger.logKey
-- filterRepeat         #string		过滤重复请求
-- params				#table		执行该条http请求的参数
-- isGet				#boolean	是否使用get，默认使用post
-- timeoutForConnect	#number		连接超时时间(s)，默认值60s
-- timeoutForRead		#number		下载超时时间(s)，默认值60s
-- showTips				#boolean	是否显示异常飘字，默认值为false
-- retryTimes			#boolean	请求失败时尝试的次数，默认为1次
-- retryDelay			#number		请求失败再次尝试的延时(s)，为0或者nil时立马再次请求
-- immediately			#boolean    是否独立线程执行请求，默认为false
-- onSuccess			#function	请求成功的回调，如：local function onSuccess(data) end
-- onFailed				#function	请求失败的回调，如：local function onFailed(data) end
function HttpUtil.send(params)
	
	params = params or {}
	RPUtil.fillCommonInfos(params.params)
	assert(type(params.ip) == "string", type(params.ip).." ip must be a string")
	assert(type(params.action) == "string", type(params.action).." action must be a string")
	assert(type(params.key) == "string", type(params.key).." key must be a string")
	assert(type(params.params) == "table", type(params.params).." params must be a table")

	if not params.timeoutForConnect then
		params.timeoutForConnect = 30
	end

	if not params.timeoutForRead then
		params.timeoutForRead = 60
	end

	if not params.retryTimes then
		params.retryTimes = 1
	end

	if not params.retryDelay then
		params.retryDelay = 0
	end

	if not params.immediately then
		params.immediately = false
	end

	if params.isCompress == nil then
		params.isCompress = true
	end

	if params.filterRepeat == nil then
		params.filterRepeat = true
	end

	if params.isGet ~= true then
		params.isGet = false
	end
	
	if params.isNew then
		params.params.is_test = (not __IS_RELEASE__) and "regular" or "test"
		params.params.server_time = ModelManager.ServerTimeModel and ModelManager.ServerTimeModel:getServerTimeMS() or -1
	else
		params.params.isDebug =  (not __IS_RELEASE__) and "is_test" or nil
	end
	
	private.send(params)
end

--格式化URL数据
function HttpUtil.getFormatedURLData(params, key)
	return private.getFormatedURLData(params, key)
end

--传入参数并下载文件
function HttpUtil.sendGetFile(params)
	params = params or {}
	assert(type(params.onFinish) == "function", type(params.onFinish).." onFinish must be a function")
	assert(type(params.url) == "string", type(params.url).." url must be a string")
	assert(type(params.fileName) == "string", type(params.fileName).." fileName must be a string")
	assert(type(params.filePath) == "string", type(params.filePath).." filePath must be a string")

	if not params.onProgress then
		params.onProgress = 0
	end

	if not params.timeoutForConnect then
		params.timeoutForConnect = 30
	end

	if not params.timeoutForRead then
		params.timeoutForRead = 60
	end

	gy.GYHttpClient:toGetFile(params.onFinish, params.onProgress, params.url, params.fileName, params.filePath, params.timeoutForConnect, params.timeoutForRead)
end

--下载文件用这个
function HttpUtil.downLoadFile(params)
	params = params or {}
	assert(type(params.onFinish) == "function", type(params.onFinish).." onFinish must be a function")
	assert(type(params.url) == "string", type(params.url).." url must be a string")
	assert(type(params.fileName) == "string", type(params.fileName).." fileName must be a string")
	assert(type(params.filePath) == "string", type(params.filePath).." filePath must be a string")

	if not params.onProgress then
		params.onProgress = 0
	end

	if not params.timeoutForConnect then
		params.timeoutForConnect = 30
	end

	if not params.timeoutForRead then
		params.timeoutForRead = 60
	end

	gy.GYHttpClient:download(params.url,  params.filePath,params.fileName,params.onFinish, params.onProgress, false,params.timeoutForConnect, params.timeoutForRead)
end


--下载图片，返回下载路径
function HttpUtil.downLoadImage(url,func,errorFunc)

	local filePath = cc.FileUtils:getInstance():getWritablePath().."dimage/"
	
	local fileName = gy.GYStringUtil:getStringMD5(url)
	local fullPath = filePath..fileName
	if cc.FileUtils:getInstance():isFileExist(fullPath) then
		func(url,fullPath)
		return
	end
	HttpUtil.downLoadFile({
			url = url,
			onFinish = function (data)
				if data.code == 200 then
					LuaLogE("downLoadImage success "..fullPath)
					if cc.FileUtils:getInstance():isFileExist(fullPath) then
						if func then
							func(url,fullPath)
						end
					end
				else
					if errorFunc then errorFunc(url) end
				end
			end,
			onProgress = function ()
				end,
			fileName = fileName,
			filePath =  filePath,
		})
end

--传入参数并上传文件
function HttpUtil.sendPostFile(params)
	params = params or {}
	assert(type(params.onFinish) == "function", type(params.onFinish).." onFinish must be a function")
	assert(type(params.url) == "string", type(params.url).." url must be a string")
	assert(type(params.fileFullPath) == "string", type(params.fileFullPath).." fileFullPath must be a string")

	if not params.onProgress then
		params.onProgress = 0
	end

	if not params.timeoutForConnect then
		params.timeoutForConnect = 30
	end

	if not params.timeoutForRead then
		params.timeoutForRead = 60
	end

	if params.isCompress == nil then
		params.isCompress = true
	end

	if __ENGINE_VERSION__ > 1 then
		if not params.header then
			params.header = DT
		end
		gy.GYHttpClient:toPostFile(params.onFinish, params.onProgress, params.url, params.fileFullPath, params.header, params.isCompress, params.timeoutForConnect, params.timeoutForRead)
	else
		gy.GYHttpClient:toPostFile(params.onFinish, params.onProgress, params.url, params.fileFullPath, params.isCompress, params.timeoutForConnect, params.timeoutForRead)
	end
end

return HttpUtil