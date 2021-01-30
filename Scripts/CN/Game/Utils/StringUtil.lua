--[[
	命名空间: xstr
	作者: apache(email: hqwemail@gmail.com; website: http://hi.baidu.com/hqwfreefly)
	版本号: 0.1
	创建日期: 2010-10-17
	函数列表: trim, capitalize, count, startswith, endswith, expendtabs, isalnum, isalpha, isdigit, islower, isupper,
			  join, lower, upper, partition, zfill, ljust, rjust, center, dir, help
	声明: 该软件为自由软件，遵循GPL协议。如果你需要为xstr增加函数，请在func_list中添加函数名，并在help函数中为其撰写帮助文档
	帮助: xstr:dir() 列出命名空间下的函数列表。xstr:help("func")查看func的帮助文档
--]]
local StringUtil = {}
func_list = "trim, capitalize, count, startswith, endswith, expendtabs, isalnum, isalpha, isdigit, islower, isupper, join, lower, upper, partition, zfill, ljust, rjust, center, dir, help"
--[[去除str中的所有空格。成功返回去除空格后的字符串，失败返回nil和失败信息]]
function StringUtil.trim(str)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	str = string.gsub(str, " ", "")
	return str
end

--[[将str的第一个字符转化为大写字符。成功返回转换后的字符串，失败返回nil和失败信息]]
function StringUtil.capitalize(str)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	local ch = string.sub(str, 1, 1)
	local len = string.len(str)
	if ch < 'a' or ch > 'z' then
		return str
	end
	ch = string.char(string.byte(ch) - 32)
	if len == 1 then
		return ch
	else
		return ch .. string.sub(str, 2, len)
	end
end
--[[统计str中substr出现的次数。from, to用于指定起始位置，缺省状态下from为1，to为字符串长度。成功返回统计个数，失败返回nil和失败信息]]
function StringUtil.count(str, substr, from, to)
	if str == nil or substr == nil then
		return nil, "the string or the sub-string parameter is nil"
	end
	from = from or 1
	if to == nil or to > string.len(str) then
		to = string.len(str)
	end
	local str_tmp = string.sub(str, from ,to)
	local n = 0
	for _, _ in string.gfind(str_tmp, substr) do
		n = n + 1
	end
	return n
end
--[[判断str是否以substr开头。是返回true，否返回false，失败返回失败信息]]
function StringUtil.startswith(str, substr)
	if str == nil or substr == nil then
		return nil, "the string or the sub-stirng parameter is nil"
	end
	if string.find(str, substr) ~= 1 then
		return false
	else
		return true
	end
end
--[[判断str是否以substr结尾。是返回true，否返回false，失败返回失败信息]]
function StringUtil.endswith(str, substr)
	if str == nil or substr == nil then
		return nil, "the string or the sub-string parameter is nil"
	end
	str_tmp = string.reverse(str)
	substr_tmp = string.reverse(substr)
	if string.find(str_tmp, substr_tmp) ~= 1 then
		return false
	else
		return true
	end
end
--[[使用空格替换str中的制表符，默认空格个数为8。返回替换后的字符串]]
function StringUtil.expendtabs(str, n)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	n = n or 8
	str = string.gsub(str, "\t", string.rep(" ", n))
	return str
end
--[[去掉字符串中的回车]]
function StringUtil.expendEnter(str)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	str = string.gsub(str, "\n", "")
	return str
end





--[[如果str仅由字母或数字组成，则返回true，否则返回false。失败返回nil和失败信息]]
function StringUtil.isalnum(str)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if not ((ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or (ch >= '0' and ch <= '9')) then
			return false
		end
	end
	return true
end
--[[如果str全部由字母组成，则返回true，否则返回false。失败返回nil和失败信息]]
function StringUtil.isalpha(str)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if not ((ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z')) then
			return false
		end
	end
	return true
end
--[[如果str全部由数字组成，则返回true，否则返回false。失败返回nil和失败信息]]
function StringUtil.isdigit(str)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if ch < '0' or ch > '9' then
			return false
		end
	end
	return true
end
--[[如果str全部由小写字母组成，则返回true，否则返回false。失败返回nil和失败信息]]
function StringUtil.islower(str)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if ch < 'a' or ch > 'z' then
			return false
		end
	end
	return true
end
--[[如果str全部由大写字母组成，则返回true，否则返回false。失败返回nil和失败信息]]
function StringUtil.isupper(str)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if ch < 'A' or ch > 'Z' then
			return false
		end
	end
	return true
end
--[[使用substr连接str中的每个字符，返回连接后的新串。失败返回nil和失败信息]]
function StringUtil.join(str, substr)
	if str == nil or substr == nil then
		return nil, "the string or the sub-string parameter is nil"
	end
	local xlen = string.len(str) - 1
	if xlen == 0 then
		return str
	end
	local str_tmp = ""
	for i = 1, xlen do
		str_tmp = str_tmp .. string.sub(str, i, i) .. substr
	end
	str_tmp = str_tmp .. string.sub(str, xlen + 1, xlen + 1)
	return str_tmp
end

--[[将str以substr（从左向右查找）为界限拆分为3部分，返回拆分后的字符串。如果str中无substr则返回str, '', ''。失败返回nil和失败信息]]
function StringUtil.partition(str, substr)
	if str == nil or substr == nil then
		return nil, "the string or the sub-string parameter is nil"
	end
	local len = string.len(str)
	local start_idx, end_idx = string.find(str, substr)
	if start_idx == nil or end_idx == len then
		return str, '', ''
	end
	return string.sub(str, 1, start_idx - 1), string.sub(str, start_idx, end_idx), string.sub(str, end_idx + 1, len)
end
--[[在str前面补0，使其总长度达到n。返回补充后的新串，如果str长度已经超过n，则直接返回str。失败返回nil和失败信息]]
function StringUtil.zfill(str, n)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	if n == nil then
		return str
	end
	local format_str = "%0" .. n .. "s"
	return string.format(format_str, str)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--[[设置str的位宽，默认的填充字符为空格。对齐方式为左对齐（rjust为右对齐，center为中间对齐）。返回设置后的字符串。失败返回nil和失败信息]]
function StringUtil.ljust(str, n, ch)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	ch = ch or DescAuto[360] -- [360]="　"
	n = tonumber(n) or 0
	local len = string.len(str)
	return string.rep(ch, n - len) .. str
end

function StringUtil.rjust(str, n, ch)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	ch = ch or DescAuto[360] -- [360]="　"
	n = tonumber(n) or 0
	local len = string.len(str)
	return str .. string.rep(ch, n - len)
end

function StringUtil.center(str, n, ch)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	ch = ch or " "
	n = tonumber(n) or 0
	local len = string.len(str)
	rn_tmp = math.floor((n - len) / 2)
	ln_tmp = n - rn_tmp - len
	return string.rep(ch, rn_tmp) .. str .. string.rep(ch, ln_tmp)
end

-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function StringUtil.lua_string_split(str, split_char)
    local sub_str_tab = {}
    while (true) do
        local pos = string.find(str, split_char)
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str
            break
        end
        local sub_str = string.sub(str, 1, pos - 1)
        sub_str_tab[#sub_str_tab + 1] = sub_str
        str = string.sub(str, pos + 1, #str)
    end

    return sub_str_tab
end

--add by lqh
function StringUtil.getLength(str)
	if not str then
		return 0
	end
	return utf8.len(str)
end

--截取utf8 长度
-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
local function chsize(char)
    if not char then
        print("not char")
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end
-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- 例如utf8len("1你好") => 3
function StringUtil.utf8len(str)
    local len = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        len = len +1
    end
    return len
end

-- 截取utf8 字符串
-- str:            要截取的字符串
-- startChar:    开始字符下标,从1开始
-- numChars:    要截取的字符长度
function StringUtil.utf8sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

-- 过滤特殊符号
-- https://blog.csdn.net/allenjay11/article/details/53207888
function StringUtil.filter_spec_chars(s)
    local ss = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c<192 then
            if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
                table.insert(ss, string.char(c))
            end
            k = k + 1
        elseif c<224 then
            k = k + 2
        elseif c<240 then
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        table.insert(ss, string.char(c,c1,c2))
                    end
                end
            end
            k = k + 3
        elseif c<248 then
            k = k + 4
        elseif c<252 then
            k = k + 5
        elseif c<254 then
            k = k + 6
        end
    end
    return table.concat(ss)
end

function StringUtil.check_spec_char(s)
    -- local ss = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
		if c<192 then
			-- ascii
			if c < 48 or (c > 57 and c < 65) or (c > 90 and c < 97) or (c > 122) then
				return false
			end
			k = k + 1
        elseif c<224 then
			-- k = k + 2
			return false
        elseif c<240 then
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
					if c == 228 then 
						a1 = 184
					elseif c == 233 then 
						a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
						-- table.insert(ss, string.char(c,c1,c2))
					else
						return false
                    end
				end
			else
				return false
            end
            k = k + 3
        elseif c<248 then
			k = k + 4
			return false
        elseif c<252 then
			k = k + 5
			return false
        elseif c<254 then
			k = k + 6
			return false
        end
    end
    return true
end


function StringUtil.getTextNewlineInfoByPixel(xOffset,contentWidth,content,fontSize)
	return Fanren:getTextNewlineInfoByPixel(xOffset,contentWidth,content, UI.FONT_FACE, fontSize)
end

--[[
@params seconds 总秒数
@params type  h:转换成小时  m:转换成分钟


eg: formatTime(61,"m")  ==> 01:01
eg: formatTime(3610,"h")  ==> 01:00:10
]]
function StringUtil.formatTime(seconds,type, formatText)
	if seconds < 0 then
		seconds = 0
	end
	local restSecond = math.mod(seconds,60)
	local restMin = math.floor(seconds/60)
	local finalStr = ""

	if not type or type == "m" then
		if restMin < 10 then
			restMin = 0 .. restMin
		end
		if restSecond < 10 then
			restSecond = 0 .. restSecond
		end
		formatText = formatText or "%s:%s"
		finalStr = string.format(formatText,restMin,restSecond)
	elseif type == "h" then
		local hour = math.floor(restMin/60)
		local restMin = math.mod(restMin,60)

		if hour < 10 then
			hour = 0 .. hour
		end
		if restMin < 10 then
			restMin = 0 .. restMin
		end
		if restSecond < 10 then
			restSecond = 0 .. restSecond
		end
		formatText = formatText or "%s:%s:%s"
		finalStr = string.format(formatText,hour,restMin,restSecond)
	elseif type == "d" then
		local day = math.floor(seconds / (24 * 3600))
		local sec = seconds - day * 24 * 3600
		local hour = math.floor(sec / 3600)
		sec = sec - hour * 3600
		local min = math.floor(sec / 60)
		sec = sec - min * 60
		formatText = formatText or "%s:%s:%s:%s"
		finalStr = string.format(formatText,day,hour,min,sec)
	elseif type == "y" then
		formatText = formatText or "%Y-%m-%d %H:%M:%S"
		finalStr = os.date(formatText,seconds)
	end

	return finalStr
end

-- 判断名字是否合法
-- 弃用（12个英文字符名字太长）
-- function is_name_available(str, maxLength)
-- 	local cn_chars = {}
-- 	local en_chars = {}
-- 	for i = 1, string.len(str) do
-- 	    local c = string.byte(str, i)
-- 	    if c < 128 then -- 
-- 	        table.insert(en_chars, c)
-- 	    else
-- 	        table.insert(cn_chars, c)
-- 	    end
-- 	end

-- 	-- 
-- 	local cn_str = string.char(unpack(cn_chars))
-- 	local en_str = string.char(unpack(en_chars))
-- 	if type(maxLength) == "number" then 
-- 	    local cn_len = StringUtil.getLength(cn_str) 
-- 	    local en_len = string.len(en_str)
-- 	    if (maxLength * 2) < (cn_len * 2 + en_len) then
-- 	        -- 超出宽度（中文字符宽度为两个英文字符宽度）
-- 	        return false
-- 	    end
-- 	end

-- 	-- 含有非法英文字符
-- 	if string.find(en_str, "%W") then
-- 	    return false
-- 	end

-- 	-- 含有敏感字段
-- 	-- return false

--  	return true
-- end

-- 裁剪text，得到前面长度为length的字符串(支持非英文字符) -- by weicong
function StringUtil.clamp_text(str, length)
    if string.len(str) < length then
        return str
    end

    local len = 0
    local skip = 0
    local chars = {}

    for i = 1, string.len(str) do
        local c = string.byte(str, i)
        if i > skip then
        	len = len + 1
            if c >= 128 then 
                if c < 0xE0 then -- 2位utf8
                    skip = i + 1

                elseif 0xE0 <= c and c < 0xF0 then -- 3位utf8
                    skip = i + 2

                elseif 0xF0 <= c and c < 0xF8 then -- 4位utf8
                    skip = i + 3

                end
            end
        end
        
        if len > length then
            break
        end

        table.insert(chars, c)
    end

    return string.char(unpack(chars))
end

-- 拆字text，得到一组字符
function StringUtil.getWords(str)
    local skip = 0
    local chars = {}
    local ret = {}
    for i = 1, string.len(str) do
        local c = string.byte(str, i)
        if i > skip then
            if #chars > 0 then
                table.insert(ret, string.char(unpack(chars)))
            end
            chars = {}
            if c >= 128 then
                if c < 0xE0 then -- 2位utf8
                    skip = i + 1

                elseif 0xE0 <= c and c < 0xF0 then -- 3位utf8
                    skip = i + 2

                elseif 0xF0 <= c and c < 0xF8 then -- 4位utf8
                    skip = i + 3

                end
            end
        end
        table.insert(chars, c)
    end
	if #chars > 0 then
	    table.insert(ret, string.char(unpack(chars)))
	end
    return ret
end

------------------------------------------------------------------------------------------------------------------------------------------
--[[显示xstr命名空间的所有函数名]]
function StringUtil.dir(self)
	print(self.func_list)
end
--[[打印指定函数的帮助信息, 打印成功返回true，否则返回false]]
-- function StringUtil.help(fun_name)
-- 	man = {
-- 		["trim"] = "xstr:trim(str) --> string | nil, err_msg\n  去除str中的所有空格，返回新串\n  print(xstr:trim(\"  hello wor ld \") --> helloworld",
-- 		["capitalize"] = "xstr:capitalize(str) --> string | nil, err_msg\n  将str的首字母大写，返回新串\n  print(xstr:capitalize(\"hello\") --> Hello",
-- 		["count"] = "xstr:count(str, substr [, from] [, to]) --> number | nil, err_msg\n  返回str中substr的个数, from和to用于指定统计范围, 缺省状态下为整个字符串\n  print(xstr:count(\"hello world!\", \"l\")) --> 3",
-- 		["startswith"] = "xstr:startswith(str, substr) --> boolean | nil, err_msg\n  判断str是否以substr开头, 是返回true，否返回false\n  print(xstr:startswith(\"hello world\", \"he\") --> true",
-- 		["endswith"] = "xstr:endswith(str, substr) --> boolean | nil, err_msg\n  判断str是否以substr结尾, 是返回true, 否返回false\n  print(xstr:endswith(\"hello world\", \"d\")) --> true",
-- 		["expendtabs"] = "xstr:expendtabs(str, n) --> string | nil, err_msg\n  将str中的Tab制表符替换为n格空格，返回新串。n默认为8\n  print(xstr:expendtabs(\"hello	world\")) --> hello        world",
-- 		["isalnum"] = "xstr:isalnum(str) --> boolean | nil, err_msg\n  判断str是否仅由字母和数字组成，是返回true，否返回false\n  print(xstr:isalnum(\"hello world:) 123\")) --> false",
-- 		["isalpha"] = "xstr:isalpha(str) --> boolean | nil, err_msg\n  判断str是否仅由字母组成，是返回true，否返回false\n  print(xstr:isalpha(\"hello WORLD\")) --> false",
-- 		["isdigit"] = "xstr:isdigit(str) --> boolean | nil, err_msg\n  判断str是否仅由数字组成，是返回true，否返回false\n  print(xstr:isdigit(\"0123456789\")) --> true",
-- 		["islower"] = "xstr:islower(str) --> boolean | nil, err_msg\n  判断str是否全部由小写字母组成，是返回true，否返回false\n  print(xstr:islower(\"hello world\")) --> false",
-- 		["isupper"] = "xstr:isupper(str) --> boolean | nil, err_msg\n  判断str是否全部由大写字母组成，是返回true，否返回false\n  print(xstr:isupper(\"HELLO WORLD\")) --> false",
-- 		["join"] = "xstr:join(str, substr) --> string | nil, err_msg\n  使用substr连接str中的每个元素，返回新串\n  print(xstr:join(\"hello\", \"--\")) --> h--e--l--l--o",
-- 		["lower"] = "xstr:lower(str) --> string | nil, err_msg\n  将str中的大写字母小写化，返回新串\n  print(xstr:lower(\"HeLLo WORld 2010\")) --> hello wold 2010",
-- 		["upper"] = "xstr:upper(str) --> string | nil, err_msg\n  将str中的小写字母大写化，返回新串\n  print(xstr:upper(\"hello world 2010\")) --> HELLO WORLD 2010",
-- 		["partition"] = "xstr:partition(str, substr) --> string, string, string | nil, err_msg\n  将str按照substr为界限拆分为3部分，返回拆分后的字符串\n  print(xstr:partition(\"hello*world\", \"wo\")) --> hello*	wo	rld",
-- 		["zfill"] = "xstr:zfill(str, n) --> string | nil, err_msg\n  在str前补0，使其总长度为n。返回新串\n  print(xstr:zfill(\"100\", 5)) --> 00100",
-- 		["ljust"] = "xstr:ljust(str, n, ch) --> string | nil, err_msg\n  按左对齐方式，使用ch补充str，使其位宽为n。ch默认为空格，n默认为0\n  print(xstr:ljust(\"hello\", 10, \"*\")) --> *****hello",
-- 		["rjust"] = "xstr:ljust(str, n, ch) --> string | nil, err_msg\n  按右对齐方式，使用ch补充str，使其位宽为n。ch默认为空格，n默认为0\n  print(xstr:rjust(\"hello\", 10, \"*\")) --> hello*****",
-- 		["center"] = "xstr:center(str, n, ch) --> string | nil, err_msg\n  按中间对齐方式，使用ch补充str，使其位宽为n。ch默认为空格，n默认为0\n  print(xstr:center(\"hello\", 10, \"*\")) --> **hello***",
-- 		["dir"] = "xstr:dir()\n  列出xstr命名空间中的函数",
-- 		["help"] = "xstr:help(\"func\")\n  打印函数func的帮助文档\n  xstr:help(\"dir\") --> \nxstr:dir()\n  列出xstr命名空间中的函数",
-- 	}
-- 	print(man[fun_name])
-- end

--获取子字符串,一个中文字符按1长度计算
function StringUtil.getSubStringCN(str,b,l)
	b = b or 1
	
	local lenInByte = #str
	local width = 0
 	local charStore = {}

 	local tmpi = 1
	for i=1,lenInByte do
		if tmpi <= i then 
		    local curByte = string.byte(str, i)
		    local byteCount = 1;
		    if curByte>0 and curByte<=127 then
		        byteCount = 1
		    elseif curByte>=192 and curByte<223 then
		        byteCount = 2
		    elseif curByte>=224 and curByte<239 then
		        byteCount = 3
		    elseif curByte>=240 and curByte<=247 then
		        byteCount = 4
		    end
		     
		    local char = string.sub(str, i, i+byteCount-1)
		    tmpi = tmpi + byteCount 
		    
		    charStore[#charStore+1] = char
		end 
	end
	l = l or #charStore
	 
	local sub = ""
	for i=1,l do
		if i+b-1>#charStore then
			break
		end
		
		sub = sub..charStore[i+b-1]
	end
	return sub,#charStore

end

--把数字转成保留x位小数的，默认一位
function StringUtil.transValue(value, digNum)
	if not digNum then digNum = 1 end
	if value >= 1 then
		if value >= 100000000 then
			value = (math.floor(value/10000000)/10)..Desc.common_y
		elseif value >= 10000 then
			value = (math.floor(value/1000)/10)..Desc.common_w
		end
	else
		value = 0
	end
	return tostring(value)
end


-- add by wangchao -----------------------------------------------
function StringUtil.transTime(time)
	local day = math.floor(time/3600/24)
	local hour = math.floor(time/3600 % 24)
	local min = math.floor(time/60 % 60)
	local sec = math.floor(time % 60)

	return day, hour, min, sec
end

-- 转换成 h:m:s 或者 m:s
function StringUtil.transTimeStr(time, type)
	
	local b = math.floor(time/3600)
	local c = math.floor(time/60 % 60)
	local d = math.floor(time % 60)

	local bStr = ""
	local cStr = ""
	local dStr = ""


	local tmp = false
	if type == "h" then
		tmp = true
	end

	if tmp or b > 0 then
		bStr = tostring(b)
		if b < 10 then
			bStr = "0" .. bStr
		end
		bStr = bStr .. ":"
	end

	if true or c > 0 then 
		cStr = tostring(c)
		if c < 10 then
			cStr = "0" .. cStr
		end
		cStr = cStr .. ":"
	end

	if true or d > 0 then 
		dStr = tostring(d)
		if d < 10 then
			dStr = "0" .. dStr
		end
		dStr = dStr
	end

	local str = bStr .. cStr .. dStr
	
	return str
end


function StringUtil.transTimeText(time,dayStr,hourStr,minStr,secondStr)
	
	local a, b, c, d = transTime(time)
	local aText = ""
	local bText = ""
	local cText = ""
	local dText = ""
	if a > 0 then
		aText = a .. (dayStr or Desc.common_day)
	end
	if b > 0 then 
		bText = b .. (hourStr or Desc.common_hour)
	end
	if c > 0 then 
		cText = c .. (minStr or Desc.common_minute)
	end
	if d > 0 then
		dText = d .. (secondStr or Desc.common_second)
	end
	local text = aText .. bText .. cText .. dText
	
	return text
end


local chnNum =
{
	[0] = Desc.common_0,
	[1] = Desc.common_1,
	[2] = Desc.common_2,
	[3] = Desc.common_3,
	[4] = Desc.common_4,
	[5] = Desc.common_5,
	[6] = Desc.common_6,
	[7] = Desc.common_7,
	[8] = Desc.common_8,
	[9] = Desc.common_9,
	[10] = Desc.common_10,
}

-- 字符串 转 字符串
-- 阿拉伯0-10 转换 中文零-十
function StringUtil.transNumToChnNum(num)
	if num == nil then
		return ""
	end
	if type(num) == "string" then
		num = tonumber(num)
	end
	if num >= 0 and num <= 10 then
		return chnNum[num]
	elseif num > 10 and num <= 19 then
		local ge = num % 10
		return chnNum[10] .. chnNum[ge]
	elseif num >= 20 and num < 100 then
		local shi = math.floor(num / 10)
		local shiStr = chnNum[shi]

		local ge = num % 10
		local geStr = ""
		if ge > 0 then
			geStr = chnNum[ge]
		end
		return shiStr .. chnNum[10] .. geStr
	end
	return ""
end

function StringUtil.stringHashNumber( str, min, max )
	local region = max-min+1
	local mstr = string.lower(FRMD5(str, string.len(str)))
	print(mstr)
	local hashNum = 0
	local part = math.floor(region/#mstr)
	local i = 0
	string.gsub(mstr, ".", function (c)
		local num = string.byte(c)
		hashNum = (i * part) + num * (i * part + 1) + hashNum
		i = i + 1
	end)
	return hashNum % region + min
end

--横的中文变竖的
function StringUtil.transText(text)
	local str = ""
	local len = string.utf8len(text)
	if len > 0 then
		for k = 1, len do
			str = str .. utf8sub(text,k,1)
			if k ~= len then
				str = str .. "\n"
			end
		end

	end

	return str
end



--横的中文中间加空格
function StringUtil.transSpaceText(text)
	local str = ""
	local len = string.utf8len(text)
	if len > 0 then
		for k = 1, len do
			str = str .. utf8sub(text,k,1)
			if k ~= len then
				str = str .. "  "
			end
		end

	end

	return str
end

function StringUtil.transCopyTimeStr(time, type)
	local b = math.floor(time / 3600)
	local c = math.floor(time / 60 % 60)
	local d = math.floor(time % 60)

	local bStr = ""
	local cStr = ""
	local dStr = ""

	if b > 0 then
		bStr = tostring(b)
		if b < 10 then
			bStr = "0" .. bStr
		end
		bStr = bStr .. ":"
	end

	cStr = tostring(c)
	if c < 10 then
		cStr = "0" .. cStr
	end
	cStr = cStr .. ":"

	dStr = tostring(d)
	if d < 10 then
		dStr = "0" .. dStr
	end
	dStr = dStr

	local str = bStr .. cStr .. dStr

	return str
end

--获取字符串显示出来的像素长度
function StringUtil.getStringPixelLength(str, font, fontSize, outline)
	return gy.GYStringUtil:getStringPixelLength(str, font, fontSize or 18, outline or 0)
end

--字符串是否包含字库无法识别的字符
function StringUtil.containUnreconizedCharacter(str, font)
	return gy.GYStringUtil:hasUnreconizeLetter(str, font or UI.FONT_FACE)
end

--字符串是否包含屏蔽字
function StringUtil.containShieldCharacter(str)
	if type(str) ~= "string" or str == "" then
		return false
	end

	gy.GYStringUtil:loadFilterData("Filter/filter.data", false)
	local content = gy.GYStringUtil:filterString(str)
	return string.find(content, "*")
end

--把敏感词换成*号
function StringUtil.filterString(str)
	if type(str) ~= "string" or str == "" then
		return str
	end
	gy.GYStringUtil:loadFilterData("Filter/filter.data", false)
	return gy.GYStringUtil:filterString(str)
end

--不知为什么，头像上传服务器返回值偶尔一些奇怪字符，暂时过滤掉
function StringUtil.getVisibleAsciiCharacter(str)
	local finalStr = ""
	string.gsub(str, "[%g%s]", function (char)
		finalStr = finalStr.. char
	end)
	return finalStr
end

-- 在第2个中文字内插入空格
function StringUtil.inSertSpace(str,spaceNum)
	local len = string.len(str)
	local ch1 = string.sub(str, 1, len/2)
	local ch2 = string.sub(str, len/2 + 1, len)
	local space = ""
	for i = 1,spaceNum do
		space = space .. " "
	end
	return ch1 .. space .. ch2
end

-- 在2个字的中文插入空格，用于2个字的属性对齐4个字的属性
function StringUtil.formatTwoChinese(str,space)
	space = space or 5
	if StringUtil.utf8len(str) == 2 then
		return inSertSpace(str, space)
	end
	return str
end

-- 限制字符串长度，字母数字标点按1个字符，中文特殊符号按2个字符计算 -- added by zn
-- eg. limitLen = 12 能输入6个中文 或 12个字母
function StringUtil.limitStringLen(str, limitLen)
	local len = 0
    local skip = 0
    local chars = {}
    for i = 1, string.len(str) do
        local c = string.byte(str, i)
        if i > skip then
            if c >= 128 then 
				len = len + 2
                if c < 0xE0 then -- 2位utf8
                    skip = i + 1
                elseif 0xE0 <= c and c < 0xF0 then -- 3位utf8
                    skip = i + 2
                elseif 0xF0 <= c and c < 0xF8 then -- 4位utf8
                    skip = i + 3
				end
			else -- 英文数字标点 1 个长度
				len = len + 1
            end
        end
        
        if len > limitLen then
            break
        end
        table.insert(chars, c)
    end
    return string.char(unpack(chars))
end

-- 判断是否纯数字或者纯字母

function StringUtil.isOnlyNumberOrCharacter(str)
	
	if string.isOnlyNumber(str) then return true end
	if string.isOnlyCharacter(str) then return true end
	
	return false
end



function StringUtil.compareStr(str1,str2)
	
	 --获取最小的值
    local getMin = function(one, two, three)
		one = (one < two and one or two)
        return one < three and one or three
	end
	
	
	local compare = function(str, target)
        local d --int d[][];              --矩阵
        local  n = #str
        local m = #target
        local i                  
        local j                
        local ch1             
        local ch2;               
        local temp           
        if (n == 0) then
            return m
        end
        if (m == 0) then
            return n
        end
        d = {}
        -- 初始化第一列
        for i = 1,n + 1 do -- (i = 0; i <= n; i++) 
			d[i] = {}
            d[i][1] = i -1 ;
        end
        -- 初始化第一行
        for j = 1,m + 1 do --(j = 0; j <= m; j++) {
            d[1][j] = j - 1
        end
        for i = 2,n + 1 do --(i = 1; i <= n; i++) {
            -- 遍历str
            ch1 = string.sub(str, i - 1, i - 1) --str.charAt(i - 1);
            -- 去匹配target
            for j = 2,m do --(j = 1; j <= m; j++) {
                ch2 = string.sub(target, j - 1, j - 1) --target.charAt(j - 1);
                if (ch1 == ch2 or string.lower(ch1) == string.lower(ch2) ) then
                    temp = 0;
                else
                    temp = 1;
                end
                -- 左边+1,上边+1, 左上角+temp取最小
                d[i][j] = getMin(d[i][j - 1] + 1, d[i - 1][j] + 1, d[i -1][j -1] + temp);
            end
        end
        return d[n][m];
	end
 
 
    
   
 
   
    --获取两字符串的相似度：1-（编辑距离）/字符串最大长度
    local getSimilarityRatio = function(str, target)
        local max = math.max(#str, #target)
        return 1 - compare(str, target) / max;
	end


	return getSimilarityRatio(str1, str2)
end
return StringUtil
