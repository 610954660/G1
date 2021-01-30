local HtmlUtil = {}
--------------------------------
-- 格式化字符串成html样式
-- @param		#string		str			原字符串
-- @param		#c3b|string	color		颜色
-- @param		#int		size		字号
-- @param		#int		outline		描边粗细，为0时不描边
-- @return	#string		格式化成带html格式的字符串
-- @params		#strNewLine  第二行显示啥
function HtmlUtil.formatString(str, color, size, outline, strNewLine) 
	local attr = " style={"
	local hasStyle = false

	local typeColor = type(color)
	if typeColor == "table" then
		attr = string.format("%scolor={r=%d, g=%d, b=%d}", attr, color.r, color.g, color.b)
		hasStyle = true
	elseif typeColor == "string" then
		color = UI.htmlColor2C3b(color)
		attr = string.format("%scolor={r=%d, g=%d, b=%d}", attr, color.r, color.g, color.b)
		hasStyle = true
	end

	if type(size) == "number" then
		attr = string.format("%s size=%d",attr, size)
		hasStyle = true
	end

	if type(outline) == "number" and outline > 0 then
		attr = string.format("%s outline=%d", attr, outline)
		hasStyle = true
	end

	attr = attr .. "}"

	if not strNewLine then
		if hasStyle then
			return string.format("<font%s>%s</font>", attr, str)
		else
			return str
		end
	else
		if hasStyle then
			return string.format("<font%s>%s</font>\n<font%s>%s</font>", attr, str, attr, strNewLine)
		else
			return str .. "\n" .. strNewLine
		end

	end
end

--多行拼接
--[[
params的item为{str, color, size, outline}
]]
function HtmlUtil.formatMultiLineString(params)
	params = params or {}

	local res = ""
	for i,v in ipairs(params) do
		if type(v) == "string" then
			res = res..v
		else
			res = res..formatString(v.str, v.color, v.size, v.outline)
		end
		if i ~= #params then
			res = res.."\n"
		end
	end

	return res
end

function HtmlUtil.formatImage(params)
	return string.format("<img src='%s'/>", params.src)

end
function HtmlUtil.formatNodeString(params)
	params = params or {}
	return string.format("<node creator='%s' creatorParams='%s'/>", tostring(params.creator),tostring(params.creatorParams))
end
