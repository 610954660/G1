local ColorUtil = {}

--物品品质颜色
ColorUtil.itemColor = {
	[1]=ccc3(0xFF,0xFF,0xFF),--"白色"
	[2]=ccc3(0x11,0x97,0x17),--"绿色"
	[3]=ccc3(0x19,0x88,0xc8),--"蓝色"
	[4]=ccc3(0xCB,0x21,0xD1),--"紫色"
	[5]=ccc3(0xCA,0x56,0x00),--"橙色"
	[6]=ccc3(0xD1,0x21,0x21),--"红色"		
}

ColorUtil.itemTipsColor = {
	[1]=ccc3(0xFF,0xFF,0xFF),--"白色"
	[2]=ccc3(0x97,0xE6,0xAD),--"绿色"
	[3]=ccc3(0x8A,0xD4,0xFF),--"蓝色"
	[4]=ccc3(0xED,0x93,0xF0),--"紫色"
	[5]=ccc3(0xFF,0xBD,0x7A),--"橙色"
	[6]=ccc3(0xFE,0x94,0x94),--"红色"		
}

ColorUtil.itemTipsHeadColor = {
	[1] = cc.c3b(0xFF ,0xFF, 0xFF),--"白色"
	[2] = cc.c3b(0x97, 0xe6, 0xad),--"绿色"
	[3] = cc.c3b(0x8a, 0xd4, 0xff),--"蓝色"
	[4] = cc.c3b(0xed, 0x93, 0xf0),--"紫色"
	[5] = cc.c3b(0xff, 0xbd, 0x7a),--"橙色"
	[6] = cc.c3b(0xfe, 0x94, 0x94),--"红色"	
}

ColorUtil.itemColorStr = {
	[1]="#FFFFFF",--"白色"
	[2]="#119717",--"绿色"
	[3]="#1988c8",--"蓝色"
	[4]="#CB21D1",--"紫色"
	[5]="#CA5600",--"橙色"
	[6]="#D12121",--"红色"
}

ColorUtil.chatIemColorStr = {
	[1]="#FFFFFF",--"白色"
	[2]="#3bfe44",--"绿色"
	[3]="#3ab7ff",--"蓝色"
	[4]="#f946ff",--"紫色"
	[5]="#ffa443",--"橙色"
	[6]="#ff3b3b",--"红色"
}

ColorUtil.tipItemColorStr = {
	[1]="#FFFFFF",--"白色"
	[2]="#97e6ad",--"绿色"
	[3]="#8ad4ff",--"蓝色"
	[4]="#ed93f0",--"紫色"
	[5]="#ffbd7a",--"橙色"
	[6]="#fe9494",--"红色"
}

--文本颜色
ColorUtil.textColor = {
	white = ccc3(0xFF,0xFF,0xFF),--"白色"
	gray = ccc3(0xD1,0xD1,0xD1),--"灰色"
	black = ccc3(0x45,0x45,0x45),--"黑色"
	yellow= ccc3(0xCA,0x56,0x00),--"橙色"
	green = ccc3(0x11,0x91,0x17),--"绿色"
	red = ccc3(0xD1,0x21,0x21),--"红色"	
}

--文本颜色
ColorUtil.textColor_Light = {
	white = ccc3(0xFF,0xFF,0xFF),--"白色"
	gray = ccc3(0xD1,0xD1,0xD1),--"灰色"
	black = ccc3(0x28,0x2D,0x36),--"黑色"
	yellow= ccc3(0xFF,0xC3,0x5B),--"橙色"
	green = ccc3(0x6A,0xFF,0x60),--"绿色"
	red = ccc3(0xFF,0x64,0x64),--"红色"	
}

--文本颜色
ColorUtil.textColorStr = {
	white = "#FFFFFF",--"白色"
	gray = "#D1D1D1",--"灰色"
	black = "#282D36",--"黑色"
	yellow= "#FFC35B",--"橙色"
	green = "#119117",--"绿色"
	red = "#D12121",--"红色"	
}

--文本颜色(浅色)
ColorUtil.textColorStr_Light = {
	white = "#FFFFFF",--"白色"
	gray = "#D1D1D1",--"灰色"
	black = "#282D36",--"黑色"
	yellow= "#FFC35B",--"橙色"
	green = "#6aff60",--"绿色"
	red = "#FF6464",--"红色"	
}

--获取物品颜色
function ColorUtil.getItemColor(color)
	if not color then color = 0 end
	color = tonumber(color)
	if color >= 1 and color <= 6 then
		return ColorUtil.itemColor[color]
	else
		return ColorUtil.itemColor[1];
	end
end

--获取物品颜色
function ColorUtil.getItemTipsColor(color)
	if not color then color = 0 end
	color = tonumber(color)
	if color >= 1 and color <= 6 then
		return ColorUtil.itemTipsColor[color]
	else
		return ColorUtil.itemTipsColor[1];
	end
end

function ColorUtil.getItemTipsColorStr(color)
	if not color then color = 0 end
	color = tonumber(color)
	if color >= 1 and color <= 6 then
		return ColorUtil.tipItemColorStr[color]
	else
		return ColorUtil.tipItemColorStr[1];
	end
end

--获取物品颜色(字符串)
function ColorUtil.getItemColorStr(color)
	if not color then color = 0 end
	if color >= 1 and color < 6 then
		return ColorUtil.itemColorStr[color]
	else
		return 0;
	end
end

--获取物品颜色(字符串)
function ColorUtil.getChatItemColorStr(color)
	if color >= 1 and color < 6 then
		return ColorUtil.chatIemColorStr[color]
	else
		return 0;
	end
end


--获取物品颜色(字符串)
function ColorUtil.getChatColorStr(color,viewType)
	if viewType==1 then--主界面聊天显示
			if color >= 1 and color < 6 then
				return DynamicConfigData.t_ChatColor[color].color2
			else
				return DynamicConfigData.t_ChatColor[color].color2;
			end
		else
			if color >= 1 and color < 6 then
				return DynamicConfigData.t_ChatColor[color].color
			else
				return DynamicConfigData.t_ChatColor[color].color;
			end
	end
end


--把0xXXXXXX格式转成ccc3格式
function ColorUtil.getColorByStr(color)
	print(69, string.sub(color, 3,4))
	print(69, string.sub(color, 5,6))
	print(69, string.sub(color, 7,8))
	return ccc3(tonumber("0x"..string.sub(color, 3,4)),tonumber("0x"..string.sub(color, 5,6)),tonumber("0x"..string.sub(color, 7,8)))
end

--添加富文本cocos需要使用富文本框，普通文本框不行
function ColorUtil.formatColorString(content, sColor)
	--if sColor then
	--	return "[color=" .. sColor .."]" .. content .."[/color]";
	--else
	--	return content ..'';
	--end
	return string.format("<font color='%s'>%s</font>", sColor,content);
	--[color=#FFFF00]游戏UI编辑器[/color]
end

function ColorUtil.formatColorString1(content, sColor)
	if sColor then
		return "[color=" .. sColor .."]" .. content .."[/color]";
	else
		return content ..'';
	end
	--[color=#FFFF00]游戏UI编辑器[/color]
end

return ColorUtil