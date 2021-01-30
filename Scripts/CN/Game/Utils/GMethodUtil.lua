local GMethodUtil = {}

--1个参数只返回属性名,2个参数返回属性值
function GMethodUtil:getFightAttrName(type,value)
	if value==nil then
		local attrConfig= DynamicConfigData.t_combat[type]
		return attrConfig.name;
	else
		if type<=100 then
			return StringUtil.transValue(value)
		else
			return value/100 ..'%' 
		end
	end
end

function GMethodUtil:setFrameViewBg(view,url)
	local frame= view:getChildAutoType('frame')
	if  not frame then
		return
	end
	local fullScreen=frame:getChildAutoType('fullScreen')
	local bgIcon=fullScreen:getChildAutoType('icon')
	bgIcon:setURL(url) 
end

function GMethodUtil:formatBracketsStr(str)
	return	string.format( "[%s]",str)
end

function GMethodUtil:setFrameMoneyCompVis(view,vis)
	local frame= view:getChildAutoType('frame')
	if  not frame then
		return
	end
	local moneyComp=frame:getChildAutoType('moneyComp')
	moneyComp:setVisible(vis)
end

function GMethodUtil.getSizeString(content, size)
	if size then
		return "[size=" .. size .."]" .. content .."[/size]";
	else
		return content ..'';
	end
end

function GMethodUtil.getRichTextMoneyImgStr(type)
	if type<=100 then
		return "<img src='Icon/money/money"..type..".png' width = '30' height = '30'/>";
	else
		return '';
	end
end

function GMethodUtil.getRichTextItemImgStr(type, code, width, height)
	if not width then width = 30 end
	if not height then height = 30 end
	if not type then type = 3 end
	if type==1 then
		code =1  --经验
	elseif type ==2 and code<=100  then
		code = (2000 + code)
	elseif type ==5 and code<=100  then
		code = (5000 + code)
	end
		
	if type<=100 then
		return "<img src='Icon/item/"..code..".png' width = '30' height = '30'/>";
	else
		return '';
	end
end

-- /**
-- * 是否电话号码
-- */
function GMethodUtil:checkPhone(str)
    return string.match(str,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d") == str;
end
    
function GMethodUtil:checkQQ(str)
    -- local reg = "%w+([-+.]%w+)*@%w+([-.]%w+)*%.%w+([-.]%w+)*"
    -- return reg.test(str);
   return string.find(str,"^[+-]?%d+$") 
end

function GMethodUtil:checkEmail(str)
    if not str then
        return false
    end
    if (string.match(str,"[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
        return true
    else
        return false
    end
end

function GMethodUtil:checkThreeStar(str)
	for i=1,50 do
		local hasNum=string.find(str,"[0-9]+[0-9]+[0-9]+[0-9]+") 
		if hasNum~=nil then
			local strstr1=string.match(str,"[0-9]+[0-9]+[0-9]+[0-9]+")
			local numLen=string.len(strstr1)
			local s= self:getZhengZeiStr(numLen)
			str=string.gsub(str,strstr1,s)
		else
			break
		end
	end
	for i=1,50 do
		local hasYingwen=string.find(str,"[a-zA-Z]+[a-zA-Z]+[a-zA-Z]+") 
		if hasYingwen~=nil then
			local strstr2=string.match(str,"[a-zA-Z]+[a-zA-Z]+[a-zA-Z]+")
			local strLen=string.len(strstr2)
			local s= self:getZhengZeiStr1(strLen)
			str=string.gsub(str,strstr2,s)
		else
			break
		end
	end
	return str
	--string.match(str,"/([a-zA-Z/d]){3}/g")
end

function GMethodUtil:getZhengZeiStr(numLen)
	local str=""
	for i = 1, numLen, 1 do
		str=str.."*"
	end
	return str
end

function GMethodUtil:getZhengZeiStr1(numLen)
	local str=""
	for i = 1, numLen, 1 do
		str=str.."*"
	end
	return str
end


function GMethodUtil:getLastTimeOnlineStr(offlineStamp)
		local time = ServerTimeModel:getServerTime()
		local onlimeTime=time-offlineStamp;
		local hour=3600*24
		local hour1=3600*24*30
		local hour2=3600*24*30*12
		if onlimeTime<3600 then
			if onlimeTime/60<=1 then 
				return  Desc.pushmap_str6
			end
			return  math.floor((onlimeTime/60) ) ..Desc.pushmap_str7
			elseif onlimeTime>=3600 and onlimeTime<(hour) then
				return math.floor((onlimeTime/3600))..Desc.pushmap_str8
			elseif onlimeTime>=(hour) and onlimeTime<(hour1) then
				return math.floor((onlimeTime/(hour))) ..Desc.pushmap_str9
			elseif onlimeTime>=(hour1) and onlimeTime<(hour2) then
				return math.floor((onlimeTime/(hour1))) ..Desc.pushmap_str10
			elseif onlimeTime>(hour2) then
				return math.floor((onlimeTime/(hour2))) ..Desc.pushmap_str11
		end
end


function GMethodUtil:getHowLongOverdueStr(curTime,endTime, strFormat)--%s后过期
	local onlimeTime=endTime-curTime;
	local hour=3600*24
	local hour1=3600*24*30
	local hour2=3600*24*30*12
	if onlimeTime<3600 then
		if onlimeTime/60<=1 then 
			return  string.format(strFormat ,"一分钟")  
		end
		return  string.format(strFormat ,math.floor((onlimeTime/60) ).."分钟")  
		elseif onlimeTime>=3600 and onlimeTime<(hour) then
			return string.format(strFormat ,math.floor((onlimeTime/3600)).."小时") 
		elseif onlimeTime>=(hour) and onlimeTime<(hour1) then
			return string.format(strFormat ,math.floor((onlimeTime/(hour))).."天") 
		elseif onlimeTime>=(hour1) and onlimeTime<(hour2) then
			return string.format(strFormat , math.floor((onlimeTime/(hour1))).."月") 
		elseif onlimeTime>(hour2) then
			return  string.format(strFormat ,math.floor((onlimeTime/(hour2))).."年")
	end
end

function GMethodUtil:clearHTML(html)
    html = string.gsub(html, '<script[%a%A]->[%a%A]-</script>', '')
    html = string.gsub(html, '<style[%a%A]->[%a%A]-</style>', '')
    html = string.gsub(html, '<[%a%A]->', '')
    --删除空行
    html = string.gsub(html, '\n\r', '\n')
    html = string.gsub(html, '%s+\n', '\n')
    html = string.gsub(html, '\n+', '\n')
    html = string.gsub(html, '\n%s+', '\n')
    --删除前后空格
    html = string.gsub(html, '^%s+', '')
    html = string.gsub(html, '%s+$', '')
    return html
end

function GMethodUtil:isfacesetURL(content)
	if not content then
		return
	end
	local isface=false
	local faceId=401
	local length = string.len(content)
	if length==6 then
		if string.sub(content,1,2)=="{/" and string.sub(content,6,6)=="}" then
			 faceId=string.sub(content,3,5)
			if math.floor(tonumber(faceId)/100)>2 then
				isface=true
			end
		end 
	end
	return isface,faceId
end


function GMethodUtil:getGoodsCount(type, itemCode)
	local hasNum = 0
	if type == CodeType.ITEM then
		hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)
	elseif type == CodeType.MONEY then
		hasNum = ModelManager.PlayerModel:getMoneyByType(itemCode)
	end	
	return hasNum
end

--传一种物品
function GMethodUtil:getGoodsEnough(cost)
	if not cost then
		return false
	end
	local hasNum = 0
	if cost.type == CodeType.ITEM then
		hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(cost.code)
	elseif cost.type == CodeType.MONEY then
		hasNum = ModelManager.PlayerModel:getMoneyByType(cost.code)
	end	
	if hasNum>=cost.amount then
		return true
	else
		return false
	end
end

return GMethodUtil