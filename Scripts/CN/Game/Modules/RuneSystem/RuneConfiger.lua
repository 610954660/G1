--added by xhd 符文系统配置读取器
local RuneConfiger = {}


function RuneConfiger.getRunePageOpenConfig()
   return DynamicConfigData.t_RunePageOpen
end

function RuneConfiger.getRuneLevel( itmeId )
	 if itmeId and  type(itmeId)=="number" then
	 	if itmeId ==0 then
	 		return 0
	 	else
	 		return DynamicConfigData.t_Rune[itmeId].level
	 	end
	 end
	return 0
end

function RuneConfiger.getRuneConfig( itmeId )
	 if itmeId and  type(itmeId)=="number" then
	 	return DynamicConfigData.t_Rune[itmeId]
	 end
	return nil
end

--是否高级属性
function RuneConfiger.isHightAttr(id)
	local color  = math.floor(id / 100)
	local colorConfig = DynamicConfigData.t_RuneAttr[color]
	return colorConfig and colorConfig[id] and colorConfig[id].highattrsign == 1
end

function RuneConfiger.getRuneArrConfig(color)
	local rtable = {}
	if color == 100 then
		for key, value in pairs(DynamicConfigData.t_RuneAttr) do
			for key1, value1 in pairs(value) do
				table.insert(rtable,value1)
			end
		end
		return rtable
	else
		if color and  type(color)=="number" then
			local ctable =  DynamicConfigData.t_RuneAttr[color]
			for key, value in pairs(ctable) do
				table.insert(rtable,value)
			end
			return rtable
		end
	end

   return nil
end

function RuneConfiger.getRuneColor( itmeId )
	 if itmeId and  type(itmeId)=="number" then
	 	return DynamicConfigData.t_Rune[itmeId].color
	 end
	return 0
end

function RuneConfiger.getRuneCost( itmeId )
	 if itmeId and  type(itmeId)=="number" then
	 	return DynamicConfigData.t_Rune[itmeId].cost
	 end
	return 0
end

function RuneConfiger.getRuneCost2( itmeId )
	 if itmeId and  type(itmeId)=="number" then
	 	return DynamicConfigData.t_Rune[itmeId].pay
	 end
	return 0
end

function RuneConfiger.getRuneGeziConfig(color,order )
	if color and order then
		return DynamicConfigData.t_RunePage[color][order]
	end
	return nil
end
function RuneConfiger.getRuneSkillConfig(  )
    local tempConfig = DynamicConfigData.t_RuneSkill
    local config = {}
    for k,v in pairs(tempConfig) do
    	table.insert(config,v)
    end
    table.sort(config,function( a,b )
    	return a.id < b.id
    end)
    return config
end

function RuneConfiger.getRuneSkillConfigById( id )
	
    return DynamicConfigData.t_RuneSkill[id]
end

function RuneConfiger.getRunCompositeConfig( level )
	return DynamicConfigData.t_RuneComposite[level]
end

function RuneConfiger.getcurColorItemIdbyNLevel( color,level )
	for k,v in pairs(DynamicConfigData.t_Rune) do
		if color == v.color and v.level== level+1 then
			return v.itemId
		end
	end
	return nil
end

function RuneConfiger.getRunePalace( ... )
	return DynamicConfigData.t_RunePalace
end

return RuneConfiger
