--added by xhd 控制器基类
---@class Controller
local Controller = class("Controller")

function Controller:ctor()
    self.__eventListeners = {}
end

--子类不可继承重写
function Controller:init()
    local bindMap = self:excludebindMapFun()
    for funcName in pairs(getmetatable(self).__index) do
        if not bindMap[funcName] then
            local pos = string.find(funcName,"_") 
            if pos and pos > 1 then
                if not __IS_RELEASE__ then
                    --在不在两类事件枚举里面
                end
                Dispatcher.addEventListener(funcName,self)
            end
        end
    end

    self:_initListeners();
end

-- 清除
function Controller:__clearListeners()
    for _, v in ipairs(self.__eventListeners) do
        Dispatcher.removeEventListener(v[1], v[2])
    end
    self.__eventListeners = {}
end

function Controller:addEventListener(...)
    Dispatcher.addEventListener(...)
    local name, listener = ...
    self.__eventListeners[name] = { name, listener }
end

function Controller:removeEventListener(name)
    if self.__eventListeners[name] then
        Dispatcher.removeEventListener(self.__eventListeners[name][1], self.__eventListeners[name][2])
    end
end

function Controller:clear()
    self:__clearListeners()
end

-------------------------可重写的方法---------------------------------
-- 子类重写 手动注册方法
function Controller:_initListeners()

end

--子类重写  排除自动绑定的方法
function Controller:excludebindMapFun( ... )
   return {}
end
-------------------------可重写的方法---------------------------------


return Controller 