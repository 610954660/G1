--added by wyang
--道具框封裝
local HeroQuality,Super = class("HeroQuality",BindView)
function HeroQuality:ctor(view)
	self.list_quality = false
	self._qualityData = false
end

function HeroQuality:init( ... )
	self.list_quality = self.view:getChildAutoType("list_quality")
	self.list_quality:setItemRenderer(
        function(index, obj)
			local data = self._qualityData[index + 1] 
			obj:getChildAutoType("imgBg"):setColor(ColorUtil.getColorByStr(data.color))
			obj:getChildAutoType("title"):setText(data.attr)
		end)
end

function HeroQuality:setData(qualityData)
	self._qualityData = qualityData
	self.list_quality:setData(self._qualityData)
end


function HeroQuality:setVisible(v)
	self.view:setVisible(v)
end
function HeroQuality:setPosition(x,y)
	self.view:setPosition(x,y)
end
function HeroQuality:getWidth(x,y)
	return self.view:getWidth()
end
function HeroQuality:getHeight()
	return self.view:getHeight()
end
function HeroQuality:setAlpha(a)
	return self.view:setAlpha(a)
end
function HeroQuality:setColor(a)
	return self.skeletonNode:setColor(a)
end

function HeroQuality:setScale(scalex,scaley)
	return self.view:setScale(scalex,scaley)
end

return HeroQuality