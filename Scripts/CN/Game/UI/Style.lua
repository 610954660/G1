local UI = {}
--常用的AnchorPoint------------------------------------
--居中
UI.POINT_CENTER = cc.p(0.5, 0.5)
--左上
UI.POINT_LEFT_TOP = cc.p(0, 1)
--左中
UI.POINT_LEFT_CENTER = cc.p(0, 0.5)
--左下
UI.POINT_LEFT_BOTTOM = cc.p(0, 0)
--右上
UI.POINT_RIGHT_TOP = cc.p(1, 1)
--右中
UI.POINT_RIGHT_CENTER = cc.p(1, 0.5)
--右下
UI.POINT_RIGHT_BOTTOM = cc.p(1, 0)
--中上
UI.POINT_CENTER_TOP = cc.p(0.5, 1)
--中下
UI.POINT_CENTER_BOTTOM = cc.p(0.5, 0)


-----常用颜色-----------------------
UI.COLOR_WHITE = cc.c4b(0xFF, 0xFF, 0xFF, 0xFF)
UI.COLOR_WHITE_F3 = cc.c4b(0xF3, 0xF5, 0xFF, 0xFF)
UI.COLOR_BLACK = cc.c4b(0, 0, 0, 0xFF)
UI.COLOR_RED = cc.c4b(0xFF, 0, 0, 0xFF)
UI.COLOR_GREEN = cc.c4b(0, 0xFF, 0, 0xFF)
UI.COLOR_GREEN_A4 = cc.c4b(0xA4, 0xDA, 0x84, 0xFF)
UI.COLOR_GREEN_B2 = cc.c4b(0xB2, 0xFF, 0x43, 0xFF)
UI.COLOR_GREEN_A1E086 = cc.c4b(0xA1, 0xe0, 0x86, 0xFF)
UI.COLOR_BLUE = cc.c4b(0, 0, 0xFF, 0xFF)
UI.COLOR_YELLOW = cc.c4b(0xFF, 0xFF, 0, 0xFF)
UI.COLOR_YELLOW_FFF6BD = cc.c4b(0xFF, 0xF6, 0xBD, 0xFF)
UI.COLOR_GRAY_3 = cc.c4b(0x33, 0x33, 0x33, 0xFF)
UI.COLOR_GRAY_6 = cc.c4b(0x66, 0x66, 0x66, 0xFF)
UI.COLOR_GRAY_9 = cc.c4b(0x99, 0x99, 0x99, 0xFF)
UI.COLOR_GRAY_A = cc.c4b(0xAA, 0xAA, 0xAA, 0xFF)
UI.COLOR_GRAY_B = cc.c4b(0xBB, 0xBB, 0xBB, 0xFF)
UI.COLOR_GRAY_C = cc.c4b(0xCC, 0xCC, 0xCC, 0xFF)
UI.COLOR_GRAY_D = cc.c4b(0xDD, 0xDD, 0xDD, 0xFF)
UI.COLOR_GRAY_E = cc.c4b(0xEE, 0xEE, 0xEE, 0xFF)


UI.HTML_COLOR_WHITE = "#FFFFFF"
UI.HTML_COLOR_BLACK = "#000000"
UI.HTML_COLOR_RED = "#FF0000"
UI.HTML_COLOR_GREEN = "#00FF00"
UI.HTML_COLOR_BLUE = "#0000FF"
UI.HTML_COLOR_YELLOW = "#FFFF00"
UI.HTML_COLOR_GRAY_3 = "#333333"
UI.HTML_COLOR_GRAY_6 = "#666666"
UI.HTML_COLOR_GRAY_9 = "#999999"
UI.HTML_COLOR_GRAY_A = "#AAAAAA"
UI.HTML_COLOR_GRAY_B = "#BBBBBB"
UI.HTML_COLOR_GRAY_C = "#CCCCCC"
UI.HTML_COLOR_GRAY_D = "#DDDDDD"
UI.HTML_COLOR_GRAY_E = "#EEEEEE"

--缓存皮肤尺寸
local CACHED_SKIN_SIZE = {
	[""] = { width = 0, height = 0 } -- 默认
}

--获取皮肤尺寸
function UI.getSkinSize(src)
	local skinSize = CACHED_SKIN_SIZE[src]
	if not skinSize then
		-- 去预先记录列表找
		local size = cc.ResourceManager:getInstance():getImageSize(src)
		if size.width > 0 and size.height > 0 then
			CACHED_SKIN_SIZE[src] = size
			return size	
		end

		skinSize = {width = 2, height = 2}
		if cc.FileUtils:getInstance():isFileExist(src) then
			local tmpSkin = cc.TextureCache:getInstance():addImage(src)
			local size = tmpSkin:getContentSize()
			skinSize.width = size.width
			skinSize.height = size.height
			CACHED_SKIN_SIZE[src] = skinSize
		end
	end
	return skinSize
end

--获取资源的原始尺寸
function UI.skin2OrgSize(skin)
	return getSkinSize(skin.src)
end

-- skin = {src="Assets/UI/Button/**.png", scale9Rect={left=25, right=25, top=10, bottom=10},
--返回两个值，第一个为CapInsets，第二个为资源的原始尺寸
function UI.skin2CapInsets(skin)
	local capInsets, skinSize = nil, nil

	if not skin then return nil end

	local gridRect = skin.scale9Rect
	if not gridRect or (gridRect.left <= 0 and gridRect.right <= 0 and gridRect.top <= 0 and gridRect.bottom > 0) then
		return nil
	end

	local skinSize = getSkinSize(skin.src)
	if not skinSize then return nil end
	local rect = cc.rect(gridRect.left, gridRect.top, skinSize.width - gridRect.left - gridRect.right, skinSize.height - gridRect.top - gridRect.bottom)
	return rect, skinSize
end

--将html格式的颜色字符串转换成c3b格式的颜色对象，如：UI.htmlColor2C3b("#FFFFFF") -> {r=255, g=255, b=255}
function UI.htmlColor2C3b(htmlColor)
	local len = #htmlColor
	assert((len == 7 or len == 9) and string.sub(htmlColor, 1, 1) == "#", "UI.htmlColor2C3b format error!"..tostring(htmlColor))

	local r = tonumber("0x"..string.sub(htmlColor, 2, 3))
	local g = tonumber("0x"..string.sub(htmlColor, 4, 5))
	local b = tonumber("0x"..string.sub(htmlColor, 6, 7))

	return cc.c3b(r, g, b)
end

--将html格式的颜色字符串转换成c3b格式的颜色对象，如：UI.htmlColor2C4b("#FFFFFFFF") -> {r=255, g=255, b=255, a=255}
function UI.htmlColor2C4b(htmlColor)
	local len = #htmlColor
	assert((len == 7 or len == 9) and string.sub(htmlColor, 1, 1) == "#", "UI.htmlColor2C4b format error!")

	local r = tonumber("0x"..string.sub(htmlColor, 2, 3))
	local g = tonumber("0x"..string.sub(htmlColor, 4, 5))
	local b = tonumber("0x"..string.sub(htmlColor, 6, 7))
	local a = 0xFF
	if len == 9 then
		a = tonumber("0x"..string.sub(htmlColor, 8, 9))
	end

	return cc.c4b(r, g, b, a)
end

getColorHtml = htmlColor2C3b

local t_color_style = nil
function UI.getColorType(key)
	if not t_color_style then
		t_color_style = require("Configs.Handwork.ColorStyle")
	end
	local color = t_color_style[key] or t_color_style.text_normal1
	if t_color_style[key] == nil then
	end
	return htmlColor2C3b(color)
end

function UI.getColorTypeEx(key)
	if not t_color_style then
		t_color_style = require("Configs.Handwork.ColorStyle")
	end
	return t_color_style[key] or t_color_style.text_normal1
end

local t_colors = {}
local function initTColors()
	if not t_colors["qua"] then
		t_colors["qua"] = {
			getColorTypeEx("qua_gray"),
			getColorTypeEx("qua_white"),
			getColorTypeEx("qua_green"),
			getColorTypeEx("qua_blue"),
			getColorTypeEx("qua_purple"),
			getColorTypeEx("qua_gold"),
			getColorTypeEx("qua_orange"),
			getColorTypeEx("qua_red"),
			getColorTypeEx("qua_pink"),
		}
	end
	if not t_colors["alert"] then
		t_colors["alert"] = {
			getColorTypeEx("alert_gray"),
			getColorTypeEx("alert_white"),
			getColorTypeEx("alert_green"),
			getColorTypeEx("alert_blue"),
			getColorTypeEx("alert_purple"),
			getColorTypeEx("alert_gold"),
			getColorTypeEx("alert_orange"),
			getColorTypeEx("alert_red"),
			getColorTypeEx("alert_pink"),
		}
	end	
end
function UI.replaceColor(str, from, to)
	if not string.find(str, "#") then
		return str
	end
	initTColors()
	for k, v in ipairs(t_colors[from]) do
		str = string.gsub(str, v, t_colors[to][k])
	end
	return str
end

function UI.getColorByHex(value)
	local x = tonumber(value)
	local r = bit.rshift(bit.band(x, 0xff0000), 16)
	local g = bit.rshift(bit.band(x, 0x00ff00), 8)
	local b = bit.rshift(bit.band(x, 0x0000ff), 0)
	return cc.c3b(r, g, b)
end


function UI.setHitFactor(btn, len)
	if not btn or btn.setHitFactor == nil then return end

	local HIT_MIN_LEN = 60
	if len then
		HIT_MIN_LEN = len
	end

	local scaleX = 1
	local scaleY = 1
	local size = btn:getContentSize()
	if size and size.width and size.width > 0 and size.width < HIT_MIN_LEN then
		scaleX = HIT_MIN_LEN / size.width
	end
	if size and size.height and size.height > 0 and size.height < HIT_MIN_LEN then
		scaleY = HIT_MIN_LEN / size.height
	end
	btn:setHitFactor(cc.p(scaleX, scaleY))

	-- local drawer = cc.DrawNode:create()
	-- btn:addChild(drawer)
	-- local color =  cc.c4f(1, 0, 0, 1)
	-- local posX, posY = btn:getPosition()
	-- drawer:drawRect(
	-- 	cc.p(0,0),
	-- 	cc.p(HIT_MIN_LEN, HIT_MIN_LEN),
	-- 	color)
	-- drawer:setPosition(size.width/2-HIT_MIN_LEN/2, size.height/2-HIT_MIN_LEN/2)
	-- drawer:setAnchorPoint(cc.p(0.5, 0.5))
end

function UI.getAddictionAttributeColor(num)
	if not t_color_style then
		t_color_style = require("Configs.Handwork.ColorStyle")
	end

	local color
	if num == 4 then
		color = t_color_style["alert_blue"]
	elseif num == 5 then
		color = t_color_style["alert_purple"]
	else
		color  = t_color_style["alert_green"]
	end
	return htmlColor2C3b(color)
end

--将html格式的颜色字符串转换成c4f格式的颜色对象，如：UI.htmlColor2C4b("#FFFFFFFF") -> {r=1, g=1, b=1, a=1}
function UI.htmlColor2C4f(htmlColor)
	local c4b = UI.htmlColor2C4b(htmlColor)
	return cc.c4f(c4b.r/255, c4b.g/255, c4b.b/255, c4b.a/255)
end