--时装配置读取器
local isAllInit = false
local FashionConfiger = {}
local FashionConfigerByHeroId = {}
local FashionConfigerByFashionId = {}
local FashionComposeConfiger = {}
local FashionActivityConfiger = {}

function FashionConfiger.initAllConfigs()
	isAllInit = true
	--时装表
	local fashionConfig = DynamicConfigData.t_Fashion
	for _,data in pairs(fashionConfig) do
		for _,v in pairs(data) do
			FashionConfigerByHeroId[v.heroCode] = FashionConfigerByHeroId[v.heroCode] or {}
			table.insert(FashionConfigerByHeroId[v.heroCode],v)
			table.sort(FashionConfigerByHeroId[v.heroCode],function(a,b)
				return a.code < b.code
			end)
			FashionConfigerByFashionId[v.code] = v
		end
	end
	--时装合成表
	local fashionComposeConfig = DynamicConfigData.t_FashionCompose
	for _,v in pairs(fashionComposeConfig) do
		FashionComposeConfiger[v.itemOutput] = v
	end
	--登录时装表
	local fashionActivityConfig = DynamicConfigData.t_FashionActivity
	for _,v in pairs(fashionActivityConfig) do
		FashionActivityConfiger[v.fashionId] = v
	end
end

--获取英雄所有的时装
function FashionConfiger.getAllFashionInfoByHeroId(heroId)
	if not isAllInit then FashionConfiger.initAllConfigs() end
	return FashionConfigerByHeroId[heroId] or false
end

--获取皮肤数据
function FashionConfiger.getFashionInfoByFashionId(fashionId)
	if not isAllInit then FashionConfiger.initAllConfigs() end
	return FashionConfigerByFashionId[fashionId] or false
end

--根据时装id获取英雄id
function FashionConfiger.getHeroIdByFashionId(fashionId)
	if not isAllInit then FashionConfiger.initAllConfigs() end
	return FashionConfigerByFashionId[fashionId] and FashionConfigerByFashionId[fashionId].heroCode or false
end

--根据时装id获取合成配置
function FashionConfiger.getFashionComposeConfigerByFashionId(fashionId)
	if not isAllInit then FashionConfiger.initAllConfigs() end
	return FashionComposeConfiger[fashionId] or false
end

--获取登录弹的时装
function FashionConfiger.getFashionActivityConfiger()
	if not isAllInit then FashionConfiger.initAllConfigs() end
	for i,v in pairs(FashionActivityConfiger) do
		if v.popup == 1 then 
			return v
		end
	end
	return false
end

return FashionConfiger
