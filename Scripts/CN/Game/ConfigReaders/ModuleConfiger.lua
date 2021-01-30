--功能模块配置读取器
local ModuleConfiger = {}
local dict = {}

--获取功能开启配置
function ModuleConfiger.getAllConfig()
	dict = DynamicConfigData.t_module
    if not dict then
        dict = require "Configs.Generate.t_module"
    end
    return dict
end

return ModuleConfiger