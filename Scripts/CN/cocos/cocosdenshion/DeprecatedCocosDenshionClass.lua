
----zhengyanwei  2015-08-12
--暂时不处理SimpleAudioEngine相关--现切后台会播放异常--改用新音效引擎--具体接口可以查看SoundManager.lua
----------------------------_修改开始_--------------------------*/
-- if nil == cc.SimpleAudioEngine then
--     return
-- end
-- -- This is the DeprecatedCocosDenshionClass

-- DeprecatedCocosDenshionClass = {} or DeprecatedCocosDenshionClass

-- --tip
-- local function deprecatedTip(old_name,new_name)
--     if CC_SHOW_DEPRECATED_TIP then print("\n********** \n"..old_name.." was deprecated please use ".. new_name .. " instead.\n**********") end
-- end

-- --SimpleAudioEngine class will be Deprecated,begin
-- function DeprecatedCocosDenshionClass.SimpleAudioEngine()
--     deprecatedTip("SimpleAudioEngine","cc.SimpleAudioEngine")
--     return cc.SimpleAudioEngine
-- end
-- _G["SimpleAudioEngine"] = DeprecatedCocosDenshionClass.SimpleAudioEngine()
-- --SimpleAudioEngine class will be Deprecated,end

----------------------------_修改结束_--------------------------*/
