local AgentResConfiger = {}
function AgentResConfiger.getLoadingBackground()
	local bgConfig = {src = "Agent/loading_background_default.jpg",offsetX = 0,offsetY =0}

	--如果渠道有放资源则用渠道的
	local exist = cc.FileUtils:getInstance():isFileExist("Agent/loading_background_custom.jpg")
	if exist then
		bgConfig.src = "Agent/loading_background_custom.jpg"
	else
		-- 3张随机用一张
		-- local paths = {}
		-- for i = 1, 3 do
		-- 	local path = string.format("Agent/loading_background_%d.jpg", i)
		-- 	if cc.FileUtils:getInstance():isFileExist(path) then
		-- 		table.insert(paths, path)
		-- 	end
		-- end
		-- if #paths > 0 then
		-- 	local index = math.random(1, #paths)
		-- 	bgConfig.src = paths[index]
		-- end
	end
	return bgConfig
end

function AgentResConfiger.getLoadingLogo()
	local logoConfig = {src = "Agent/logo_default.png",offsetX = 0,offsetY =0,scale = 0.9}

	--如果渠道有放资源则用渠道的
	local exist = cc.FileUtils:getInstance():isFileExist("Agent/logo_custom.png")
	if exist then
		logoConfig.src = "Agent/logo_custom.png"
	end
	
	local offset = GYPlatform:getMetaDataByKey("LOGO_CONFIG")
	if offset and string.find(offset,",") then
		offset = string.split(offset,",")
		logoConfig.offsetX = offset[1] or 0
		logoConfig.offsetY = offset[2] or 0
		logoConfig.scale = offset[3] or logoConfig.scale
	end
	return logoConfig
end

function AgentResConfiger.getLoginBackground()
	local bgConfig = {src = "Agent/login_background_default.jpg"}

	--如果渠道有放资源则用渠道的
	local exist = cc.FileUtils:getInstance():isFileExist("Agent/login_background_custom.jpg")
	if exist then
		bgConfig.src = "Agent/login_background_custom.jpg"
	end
	
	return bgConfig
end


function AgentResConfiger.getLoginLogo()
	local logoConfig = {src = "Agent/logo_default.png",offsetX = 0,offsetY =0}

	--如果渠道有放资源则用渠道的
	local exist = cc.FileUtils:getInstance():isFileExist("Agent/logo_custom.png")
	if exist then
		logoConfig.src = "Agent/logo_custom.png"
	end	
	return logoConfig
end

function AgentResConfiger.getSystemImage()
	local chatHeadOnlineConfig = {src = "Agent/system_icon_default.png"}

	--如果渠道有放资源则用渠道的
	local exist = cc.FileUtils:getInstance():isFileExist("Agent/system_icon_custom.png")
	if exist then
		chatHeadOnlineConfig.src = "Agent/system_icon_custom.png"
	end	
	return chatHeadOnlineConfig
end

function AgentResConfiger.getLogo()
	return getLoginLogo()
end

return AgentResConfiger