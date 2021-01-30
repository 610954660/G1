local URLUtil = {}
function URLUtil.escape(w)
    pattern="[^%w%d%._%- ]"  --"[^%w%d%._%-%* ]" 这里去掉%*, 跟http服务端匹配
    s=string.gsub(w,pattern,function(c)  
        local c=string.format("%%%02X",string.byte(c))  
        return c  
    end)  
    s=string.gsub(s," ","+")  
    return s  
end  

local function detail_escape(w)  
    local t={}  
    for i=1,#w do  
        c = string.sub(w,i,i)  
        b,e = string.find(c,"[%w%d%._%-'%* ]")  
        if not b then  
            t[#t+1]=string.format("%%%02X",string.byte(c))  
        else  
            t[#t+1]=c  
        end  
    end  
    s = table.concat(t)  
    s = string.gsub(s," ","+")  
    return s  
end  
  
local function unescape(w)
    s=string.gsub(w,"+"," ")
    s,n = string.gsub(s,"%%(%x%x)",function(c)
        return string.char(tonumber(c,16))  
    end)
    return s  
end  

url={parsed={}} --存储decode出来的key-value  

function url:new()  
    local u={}    --对象  
    u.old= nil    --上一次decode 字符串的值  
    u.de = nil    --decode字符串后的结果值  
    u.en = nil    --encode字符串后的结果值  
    u.enold = nil --上一次encode 字符串的值  
    u.len = 0     --记录parsed map的长度  
  
    setmetatable(u,{__index=self})
    return u  
end  
  
function url:decode(line)

    assert(line == nil or type(line) == "string")
	
    if self.old == line then 
	    return print("url:decode have cache"),self.de 
	end  
	
    if not line then 
	    return self.de 
	end  
  
    self.parsed=nil  
    self.len = 0  
    self.parsed={}
	
    for k,v in string.gmatch(line,"([^&=]+)=([^&=]+)") do  
        self.len = self.len + 1  
        self.parsed[k] = unescape(v)
    end
	
	if self.len == 0 then
		self.len = self.len + 1
		self.parsed[1] = unescape(line)
	end
  
    if  self.len == 0 then 
	    return nil  
	end  
  
    local r={} 
    for k,v in pairs(self.parsed) do  
        r[#r+1] = k.."="..v  
    end 
	
    self.de=table.concat(r,"&")  
    self.old=line
	
    return self.de  
end  

function url:encode(t)
    local typeT = type(t)
    if typeT == "string" then
        if t == self.enold then  
            print("url:encode have cache")  
            return self.en  
        end  
		
        local r={}  
        --正则 ([^&=]+)=([^&=]+) 改为 ([^&=]+)=([^&]+) 修复参数值中有“=”时被截取的bug  add by move                 

        for k,v in string.gmatch(t,"([^&=]+)=([^&]+)") do
            r[#r+1] = escape(k).."="..escape(v)  
        end
		
        self.en = table.concat(r,"&")  

        self.enold = t
		
        return self.en
		
    elseif typeT == "table" then
        local r = {}
        for k, v in pairs(t) do
            r[#r+1] = escape(k) .."=".. escape(v)  
        end
        self.en = table.concat(r, "&")
  
        return self.en  
    end  

    return nil
end  

function url:parse(line)  
    assert(line == nil or type(line) == "string")
    if not line then  
        if self.len == 0 then 
		    return nil  
        else 
		    return self.parsed 
		end  
    end
    if url:decode(line) == nil then 
	    return nil 
	end  
    return self.parsed  
end  
  
function url:get(k)  
    if self.len > 0 then  
        return self.parsed[k]  
    else  
        return nil  
    end  
end

function url:escape(w)
	return escape(w)
end

function url:unescape(w)
	return unescape(w)
end
