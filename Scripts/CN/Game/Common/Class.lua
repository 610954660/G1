--深度拷贝对象，不能copy userdata对象
function deepcopy(orig)
    local copy

    if type(orig) == "table" then
        copy = {}
        for k, v in pairs(orig) do
            copy[deepcopy(k)] = deepcopy(v)
        end
        if getmetatable(orig) then
        	setmetatable(copy, deepcopy(getmetatable(orig)))
        end
    else -- number, string, boolean, etc
        copy = orig
    end

    return copy
end

--用于临时允许class对象创建新的值 代码片段过后必须重新设为false
CLASS_ALLOW_NEW_INDEX = false

--用于禁止类实例在构造函数执行完之后再创建类变量
local function errorNewIndex(t, k, v) 
	
	if CLASS_ALLOW_NEW_INDEX then
		rawset(t,k,v)
	else
		error(string.format("Error! class:'%s' no member variable:'%s'", t.__cname, tostring(k))) 
	end
	
end

--定义一个类对象
--@param	#string		className	类名
--@param	#table		super		父类
--@return	#table	类
function class(className, super)
	local cls = {
		name = className,
		ctor = false,		
		init = false,
		__cccreator = false,
		__cccreatorSelf = false,
		instanceIndexT = {},  	--存储需要继承的方法跟属性
	}

	local superType = type(super)
	if "table" == superType then
		cls.super = super

		cls.__cccreator = super.__cccreator
		cls.__cccreatorSelf = super.__cccreatorSelf
	end

	--该类所生成实例用于索引的元表
	local instanceIndexT = cls.instanceIndexT	
	if cls.super then
		for k, v in pairs(cls.super.instanceIndexT) do
			instanceIndexT[k] = v
		end
	end

	function cls.new(...)
		local instance = { __cname = cls.name }
		local mt = { 
			__index = instanceIndexT,
		}

		setmetatable(instance, mt)

		cls.runCtor(instance, ...)
		cls.runInit(instance, ...)
		--限制只能在构造函数执行完之前定义类变量
		mt.__newindex = errorNewIndex

		return instance
	end

	--执行构造函数
	function cls.runCtor(this, ...)
		local function ctor(c, ...)
			--递归调用父类的构造函数
			if c.super then
				ctor(c.super, ...)
			end

			if c.ctor then
				c.ctor(this, ...)
			end
		end
		ctor(cls, ...)
	end
	--执行构造后的初始化函数
	function cls.runInit(this, ...)
		local function init(c, ...)
			--递归调用父类的构造函数
			if c.super then
				init(c.super, ...)
			end

			if c.init then
				c.init(this, ...)
			end
		end
		init(cls, ...)
	end

	--将类方法copy到指定对象上，主要给ccclass用
	function cls.copyFuncs(this)
		for k, v in pairs(instanceIndexT) do
			this[k] = v
		end
	end

	--用在有时候想要调用某个类的方法，但又不需要创建类的实例
	--被调用方法里面的self不能是cls以及instanceIndexT, 因为这两个是会被继承的
	function cls.staticCall(funcName, ...)
		return instanceIndexT[funcName](nil, ...)
	end

	setmetatable(cls, {		
		__newindex = function(_, k, v)
			instanceIndexT[k] = v
		end
	})

	if super then
		return cls,super.instanceIndexT
	else
		return cls
	end
end

--定义一个继承自cc对象的类
function ccclass(className, super)
	local cls = nil
	local Super = nil

	local superType = type(super)
	if "table" == superType then
		cls,Super = class(className, super, true)
	else
		cls,Super = class(className, nil, true)
		if "function" == superType then
			cls.__cccreator = super
		end
	end

	if not cls.__cccreator then
		cls.__cccreator = cc.Node.create
		cls.__cccreatorSelf = cc.Node
	end

	--改写掉类的new方法
	function cls.new(...)
		local node
		if superType == "function" then
			node = cls.__cccreator(...)
		else
			node = cls.__cccreator(cls.__cccreatorSelf)
		end
		node.__cname = cls.name

		--将方法和属性copy到节点上去，并执行构造函数
		cls.copyFuncs(node)
		cls.runCtor(node, ...)
		cls.runInit(node,...)

		return node
	end

	return cls,Super
end

