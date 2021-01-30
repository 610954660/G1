---lua内存泄漏检测
local mt = {__mode = "kv"}
leakDetectionTable = {}
setmetatable(leakDetectionTable,mt)

local mt2 = { __mode == "kv"}
local tag = {}
setmetatable(tag,mt)

function traverseTb(tb,prefix)
	prefix = prefix or ""
	for k,v in pairs(tb) do 
		local valType = type(v)
		if valType == "table" and v ~= _G and v ~= leakDetectionTable and v ~= tag then
			if tag[v] then
				local tmp = leakDetectionTable[v]
				tmp.referenceCount = tmp.referenceCount + 1
				table.insert(tmp,string.format("%s.%s",prefix,k))
			else
				tag[v] = true
				leakDetectionTable[v] = {
					string.format("%s.%s",prefix,k),
					referenceCount = 1
				}

				traverseTb(v,string.format("%s.%s",prefix,k))
				local tmpMt = getmetatable(v)
				if tmpMt then
					traverseTb(tmpMt,string.format("%s.%s(mt)",prefix,k))
				end
			end
		elseif valType == "function" then
			if tag[v] then return end

			tag[v] = true
			local index = 1
			while true  do 
				local name,value = debug.getupvalue(v,index)
				if name == nil then
					break
				end
				if type(value) == "table" then
					traverseTb(value,string.format("%s.%s(upval:%d)",prefix,k,index))
				end
				index = index + 1
			end
		end
	end
end

function snapShot()
	traverseTb(_G)
end

function printResult()
	local function compare(a,b)
		return a.referenceCount > b.referenceCount
	end
	table.sort(leakDetectionTable,compare)
	printTable(10,"检测结果",leakDetectionTable)
end

function printResult2()
	local tb = {}
	for k,v in pairs(leakDetectionTable) do 
		if v.referenceCount >= 2 then
			tb[k] = v
		end
	end

	local function compare(a,b)
		return a.referenceCount >= b.referenceCount
	end
	table.sort(tb,compare)

	printTable(10,"检测结果",tb)
end