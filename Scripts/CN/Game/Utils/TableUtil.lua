local TableUtil = {}
--[[
将a，b两者融合，如果有a则值为a，否则值为b
如：
a={a=1, b={c=1}, e="aaa"}
b={a=2, b={c=2, d="ddd"}, e="eee"}
local c = TableUtil.mergeA2B(a, b) --c = {a=1, b={c=1, d="ddd"}, e="aaa"}
]]
function TableUtil.mergeA2B(a, b)
	if a == nil then return b end
	if type(b) == "table" and type(a) == "table" then
		for k, v in pairs(b) do
			b[k] = mergeA2B(a[k], b[k])
		end
		return b
	else
		return a
	end
end
--[[
	取a、b的并集，某个字段同时存在，取a中该字段的值
]]
function TableUtil.unionA2B(a, b)
	if a == nil then return b end
	if type(b) == "table" and type(a) == "table" then
		for k, v in pairs(a) do
			b[k] = unionA2B(a[k], b[k])
		end
		return b
	else
		return a
	end
end

--[[
将一个table数组的内容随机排序(不改变原数组，返回一个新的数组)
@param	tbl		[table]		数组
@return [table]	返回一个已乱序的新数组
]]
function TableUtil.randomSortArray(tbl)
	local indexes = {}
	for i=1, #tbl do
		indexes[i] = i
	end
	
	local randomIndexes = {}
	while #indexes > 0 do
		table.insert(randomIndexes, table.remove(indexes, math.random(1, #indexes)))
	end
	
	local result = {}
	for k, v in ipairs(randomIndexes) do
		result[k] = tbl[v]
	end
	
	return result
end

--插入元素到数组固定位置
function TableUtil.insertTo(tbl, index, obj)
	for k = #tbl, index,-1 do
		tbl[k + 1] = tbl[k]
	end
	tbl[index] = obj
end

--把table格式化成string，与string2table结合使用
function TableUtil.table2string(tbl)
	if type(tbl) ~= "table" then return tostring(tbl) end
	
	local strTbl = {}
	for k, v in pairs(tbl) do
		local tmpStr = (type(k) == "number" and ("[" .. k .. "]") or tostring(k)) .. "="
		if type(v) == "table" then
			tmpStr = tmpStr .. table2string(v)
		elseif type(v) == "string" then
			tmpStr = tmpStr .. "'"..tostring(v).."'"
		else
			tmpStr = tmpStr .. tostring(v)
		end
		table.insert(strTbl, tmpStr)
	end
	
	if #strTbl > 0 then
		return string.format("{%s}", table.concat(strTbl, ","))
	end
	
	return ""
end

--把string格式化为table，与table2string结合使用
function TableUtil.string2table(str)
	if str ==nil or type(str)~="string" then
		return
	end
	return loadstring("return " .. str)()
end

--[[
对数组进行真实排序
@param	tbl			要排序的数组
@param	sortFunc	排序函数
@example
根据数组项中m的值从大到小进行排序，原本在前的依旧排前
local tbl = {
	{m=1, n=2},
	{m=7, n=2},
	{m=4, n=1},
	{m=2, n=2},
	{m=1, n=5},
}
local function sortFunc(a, b)
	if a.value.m > b.value.m then
		return true
	elseif a.value.m < b.value.m then
		return false
	else
		if a.index > b.index then
			return true
		else
			return false
		end
	end
end
TableUtil.realSort(tbl, sortFunc)
]]
function TableUtil.realSort(tbl, sortFunc)
	if type(tbl) ~= "table" or #tbl < 2 then return end
	
	local tmpTbl = {}
	for k, v in ipairs(tbl) do
		tmpTbl[k] = {index=k, value=v}
	end
	table.sort(tmpTbl, sortFunc)
	for k, v in ipairs(tmpTbl) do
		tbl[k] = v.value
	end
end

--逆序表对象
function TableUtil.reverseTable(tbl)
	local newTbl = {}

	for i=#tbl, 1, -1 do
		table.insert(newTbl, tbl[i])
	end	
	return newTbl
end


--[[
	从[x0,y0][x1,y1]...解析点坐标
--]]
function TableUtil.getPointFromTblParam(param)
	local x=string.gsub(param,"%[(%d+),%d+%][%[%d+,%d+%]]*","%1")
	local y=string.gsub(param,"%[%d+,(%d+)%][%[%d+,%d+%]]*","%1")
	x=tonumber(x)
	y=tonumber(y)
	if x and y then
		return {x=x,y=y}
	end
end

function TableUtil.getSPointArrayFromTbl(param)
	local seqPoint = Message.Public.SeqPoint.new()
	while(param and param ~= "") do
		local point = getPointFromTblParam(param)
		if point then
			local spoint = Message.Public.SPoint.new()
			spoint.x_SH	= point.x
			spoint.y_SH	= point.y
			seqPoint:pushBack(spoint)
		end
		param = string.gsub(param,"%[%d+,%d+%]([%[%d+,%d+%]]*)","%1")
	end
	return seqPoint:getArray()
end

function TableUtil.getPointsFromTbl(param)
	local points = {}

	while(param and param ~= "") do
		local point = getPointFromTblParam(param)
		if point then
			table.insert(points,point)
		end
		param = string.gsub(param,"%[%d+,%d+%]([%[%d+,%d+%]]*)","%1")
	end
	return points
end

--[[
params fun  [function(k, v)]
params key   
params value
Params ret  
params ary     数组
params table   表
]]
function TableUtil.tableFind(params)
	params = params or {}
	if type(params.ary) ~= "table" and type(params.table) ~= "table" then
		return nil
	end
	local function fun(k, v)
		if type(params.fun) == "function" then
			return params.fun(k, v, params)
		elseif params.key and params.value then
			return params.key == k and params.value == v
		elseif params.key then
			return params.key == k
		elseif params.value then
			return params.value == v
		end
	end
	if params.table then
		for k,v in pairs(params.table) do
			if fun(k, v) then
				if type(params.ret) == "function" then
					return params.ret(k, v)
				end
				return v, k
			end
		end
	else
		for k,v in ipairs(params.ary) do
			if fun(k, v) then
				if type(params.ret) == "function" then
					return params.ret(k, v)
				end
				return v, k
			end
		end
	end
	
end
--是空表{}
function TableUtil.isEmpty(tb)
	return next(tb) == nil
end

--得到table 的num 
function TableUtil.GetTableLen(tbl)
	local num = 0
	if tbl then
		for k,v in pairs(tbl) do
			num = num + 1
		end
	end
	return num
end
--查看一个表的是否存在value
function TableUtil.Exist(tbl,value)
	if tbl then
		for k,v in pairs(tbl) do
			if v == value then
				return true
			end
		end
	end
	return false
end

--- 查找最大
function TableUtil.MaxK(tbl)
	local max = 0
	for k,v in pairs(tbl) do
		if k >= max then
			max = k
		end
	end
	return max
end

-- 查找最大value
function TableUtil.MaxV(tbl)
	print(60,"in maxV")
	local max = 0
	for k,v in pairs(tbl) do
		if v >= max then
			max = v
		end
	end
	return max
end

function TableUtil.DeepCopy(object)      
    local SearchTable = {}  
    local function Func(object)  
        if type(object) ~= "table" then  
            return object         
        end  
        local NewTable = {}  
        SearchTable[object] = NewTable  
        for k, v in pairs(object) do  
            NewTable[Func(k)] = Func(v)  
        end     

        return setmetatable(NewTable, getmetatable(object))      
    end    

    return Func(object)  
end  

--数组的浅拷贝，深拷贝请使用deepcopy
function TableUtil.Clone(source)
	local tbl = {}
	for i,v in pairs(source) do	
		tbl[i] = v
	end
	return tbl
end

--数组的深拷贝
function TableUtil.deepcopyForkeyValue(source,target)
	if not source then
		return source
	end
	
	local tb1 = target or {}
	for k,v in pairs(source) do
		if type(v) == "table" then
			local tb2 = TableUtil.deepcopyForkeyValue(v)
			tb1[k] = tb2
		else
			tb1[k] = v
		end
	end
	local mt = getmetatable(source)
	if mt then
		setmetatable(tb1,mt)
	end
	return tb1
end
--根据value，判断是否存在
function table.hasValue(array,value)
    if not array then
        return false
    end
	for i,v in pairs(array) do
		if v == value then
			return true
		end
	end
	return false
end

--排序,arr1 需要排序的数组  p 需要排的属性 字符串来的 re false是倒序
function TableUtil.sortBy(_arr1, p, re)
	--wl_lua 15.1.4 修改lua调用的兼容问题
      if _arr1 == nil or #_arr1 == 0 then return {} end
      local function sortFun(a,b)
		local v1 = a[p]
		local v2 = b[p]
		if v1<v2 then return false end
		if v1>v2 then return true end
      end
      
      TableUtil.sort(_arr1,sortFun)
      if re then
	  	 _arr1 = TableUtil.reverseTable(_arr1) 
		end
      return _arr1
end
--排序Map,
--@params : _arr1 需要排序的数组
--@params :  keys: 排序的属性列表（  {{key="",asc=true}...}  )   key:属性名，asc：true为倒序，false为升序
--使用示例：
--local testData = {{b=3,a=2,c=4},{b=5,a=7,c=3},{b=4,a=2,c=3},{b=3,a=2,c=3}}
--TableUtil.sortByMap( testData , { {key="a",asc=true} ,{key="b",asc=false} ,{key="b",asc=true} } )
function TableUtil.sortByMap(_arr1, keys)	
    if _arr1 == nil or #_arr1 == 0 then return {} end
	
    local function sortFun(a,b)
		local index = 1
		local len = #keys
		while(index <= len) do
			local v = keys[index]			
			a[v.key] = a[v.key] or 0
			b[v.key] = b[v.key] or 0
			if a[v.key] == b[v.key] then
				index = index + 1
			else
				if v.asc then 
					return a[v.key] >= b[v.key]
				else 
					return a[v.key] < b[v.key] 
				end
			end
		end
		return false
    end      
    TableUtil.sort(_arr1,sortFun)
    return _arr1
end
--序处理
function TableUtil.sort(tbl, sortFunc)
	if type(tbl) ~= "table" or #tbl < 2 then return end
	if sortFunc == nil then
		-- TableUtil.sort(tbl)
		return
	end	for i=1,#tbl - 1 do		
		for k=i+1,#tbl do
			local element1 = tbl[i]
			local element2 = tbl[k]			
			if not sortFunc(element1,element2) then
				local temp = tbl[i]
				tbl[i] = tbl[k]
				tbl[k] = temp
			end								
		end
	end		
end

--把字符串列表用字符连接起来
function TableUtil.join(strList, joinStr)
	if strList == nil or joinStr == nil then
		return nil, "the string or the sub-string parameter is nil"
	end
	local xlen = #strList
	if xlen == 0 then
		return str
	end
	local str_tmp = ""
	local i
	for i = 1, xlen do
		if i == 1 then
			str_tmp = strList[i]
		else
			str_tmp = str_tmp .. joinStr..strList[i]
		end
	end
	return str_tmp
end

-- table,奖励物品,倍数
--累加的奖励
function TableUtil:getReward(outputMaterial,multiple)
	local rewardInfo={}
	if multiple==nil then	multiple=1	end
	for k1, v2 in pairs(outputMaterial) do
		for k, v in pairs(v2) do
			local amount = rewardInfo[v.type .. "_" .. v.code]
			if amount == nil then
				amount = 0
			end
			amount = amount + v.amount * multiple
			rewardInfo[v.type .. "_" .. v.code] = amount
		end
	end
		
	local rewardData = {}
	for k, v in pairs(rewardInfo) do
		local reward = {}
		local offset = string.split(k, "_")
		reward["type"] = tonumber(offset[1])
		reward["code"] = tonumber(offset[2])
		reward["amount"] = v
		table.insert(rewardData, reward)
	end
	return rewardData;
end


-- 查看某值是否为表tbl中的key值
function TableUtil:kIn(tbl, key)
	if tbl == nil then
		return false
	end
	for k, v in pairs(tbl) do
		if k == key then
			return true
		end
	end
	return false
end



return TableUtil