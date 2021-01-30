--[[-------------------------------------------------------
 	QAct快速动作库：
   	* 提供cocos.Action创建对象的快捷写法
   	* 一定程度上提高action代码可读性
--]]-------------------------------------------------------

QAct = {}

-- local function __document_and_sample__(node1, node2, node3)
-- 	-- 代码：
-- 	-- 	local moveTo = cc.MoveTo:create(2, cc.p(1, 2))
-- 	-- 	node1:runAction(moveTo)
-- 	-- 	node2:runAction(moveTo)
-- 	-- 	node3:runAction(moveTo)
-- 	-- 与下面这样写法效果一样:
-- 	-- 且moveTo附带了run(node)方法
--  	local moveTo = QAct.MoveTo(2, cc.p(1, 2))
-- 				 	   .run(node1)

--  	local moveTo2 = QAct.MoveTo(2, cc.p(1, 2))
-- 	node2.runAction(moveTo2)

-- 	-- 更多写法: --------------------------------------

--  	local easeOut = QAct.EaseOut(QAct
--  							.MoveTo(2, cc.p(1, 2))
--  						)
--  						.run(node1)

-- 	local seq = QAct.Sequence()
-- 					.delayTime(2)
-- 					.callFunc(function() print("delayCall") end)
-- 					.action(easeOut) -- 多种组合通过“.action(cocos对象)”实现
-- 					.action(QAct.EaseOut
-- 						.EaseOut(QAct
-- 							.MoveTo(2, cc.p(1, 2))
-- 						)
-- 					)
-- 					.easeOut(QAct
-- 						.MoveTo(2, cc.p(1, 2))
-- 					)
-- 					.run(node1)


-- 	local spawn = QAct.Spawn()
-- 					  .moveTo(1, cc.p(1, 2))
-- 					  .scaleTo(1, 2)
-- 					  .action(cc.MoveTo:create(1, cc.p(2, 2)))

-- 	-- -- 特殊地 : Spawn() 和 Sequence() 返回的不是cocos对象
-- 	-- -- ，但可以getRaw()拿回本身的cocos对象
-- 	node3.runAction(spawn.getRaw())
-- 	QAct.EaseOut(seq:getRaw())
-- 		.run(node2)
-- end

---------------------------------------------
local s_funcList = 
{
	-- 这里需要慢慢补全
	moveTo = cc.MoveTo,
	moveBy = cc.MoveBy,
	scaleTo = cc.ScaleTo,
	scaleBy = cc.ScaleBy,
	fadeIn = cc.FadeIn,
	fadeOut = cc.FadeOut,
	fadeTo = cc.FadeTo,
	rotateTo = cc.RotateTo,
	rotateBy = cc.RotateBy,

	delayTime = cc.DelayTime,
	callFunc = cc.CallFunc,
	removeSelf = cc.RemoveSelf,

	easeRateAction = cc.EaseRateAction,
	easeIn = cc.EaseIn,
	easeOut = cc.EaseOut,
	easeInOut = cc.EaseInOut,
	easeExponentialIn = cc.EaseExponentialIn,
	easeExponentialOut = cc.EaseExponentialOut,
	easeExponentialInOut = cc.EaseExponentialInOut,
	easeSineIn = cc.EaseSineIn,
	easeSineOut = cc.EaseSineOut,
	easeSineInOut = cc.EaseSineInOut,
	easeElastic = cc.EaseElastic,
	easeElasticIn = cc.EaseElasticIn,
	easeElasticOut = cc.EaseElasticOut,
	easeElasticInOut = cc.EaseElasticInOut,


	easeBounceOut = cc.EaseBounceOut,
}

local s_meta_stream = {
	__index = function(t, name)
		if name == "action" then
			return 
			function(action)
				if t.__raw == false then
					t.__raw = action
				else
					t.__raw = t.__blend(t.__raw, action)
				end

				return t
			end

		elseif name == "run" then
			return 
			function(node)
				assert(t.__raw, "QAct : __raw is a nil value")
				node:runAction(t.__raw)
				return t
			end

		else
			return 
			function(...) 
				assert(s_funcList[name], "QAct :"..name.." not found" )
				local act = s_funcList[name]:create(...)

				if t.__raw == false then
					t.__raw = act
				else
					t.__raw = t.__blend(t.__raw, act)
				end

				return t 
			end

		end
	end	
}

local function s_new_t(blend)
	local t = { __raw = false, __blend = blend }

	function t:getRaw()
		assert(self.__raw, "QAct : __raw is a nil value")
		return self.__raw
	end

	setmetatable(t, s_meta_stream)

	return t
end

function QAct.Spawn()
	return s_new_t(function(...)
		return cc.Spawn:create(...)
	end)
end

function QAct.Sequence()
	return s_new_t(function(...)
		return cc.Sequence:create(...)
	end)
end

---------------------------------------------
local s_meta_self = {
	__index = function(t, name)
		assert(cc[name], "QAct :"..name.." not found")
		if cc[name] then
			return
			function(...) 
				local act = cc[name]:create(...)
				function act.run(node)
					node:runAction(act)
					return act
				end
				return act
			end
		end
	end
}

setmetatable(QAct, s_meta_self)

---------------------------------------------