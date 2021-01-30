local CommonMsgController = class("CommonMsgController",Controller)


function CommonMsgController:init()

	self:_initListeners()
end
-- 手动注册方法
function CommonMsgController:_initListeners()
	Dispatcher.addEventListener(RecvType.Error, self)
end


function CommonMsgController:Error(_,info)
	-- print(1,"Error")
	-- printTable(1,info)
	LuaLogE("Error")
	--printTable(1,info)
	--RollTips.show(errorDict[info.code].desc.." ["..info.code.."]")
	if GameDef.ErrorCodeDict[info.code] then
		RollTips.show(GameDef.ErrorCodeDict[info.code].desc)
	else
		RollTips.show("erroe code = "..info.code)
	end
	
end

return CommonMsgController