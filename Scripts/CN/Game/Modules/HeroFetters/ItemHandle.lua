local ItemHandle,Super = class("ItemHandle", Window)

function ItemHandle:ctor(obj)
	self.view = obj
	self.severData = {}
end
function ItemHandle:setData(data)
	self.severData = HeroFettersModel:getSeverData()[data.id]
	self.view:getChild("name"):setText(data.name)
	self.view:getChild("starList"):setItemRenderer(function(index,obj)
		local condindex = data.conditions[index + 1]
		if self.severData and self.severData.condition then
			local curNum = self.severData.condition[condindex] and self.severData.condition[condindex].curNum or 0
			local maxNum = table.nums(data.fetterGroup)
			if curNum >= maxNum then
				obj:getController("state"):setSelectedIndex(1)
			end
		end
	end)
	self.view:getChild("starList"):setData(data.conditions)
	for key,value in pairs(data.pics) do
		local obj = self.view:getChild("img"..key)
		if obj then
			obj:setIcon(string.format("Icon/Fetter/%s",value.img))
			if value.heroId ~= 0 then
				local hero = self.severData and self.severData.hero[value.heroId]
				if hero then
					obj:setGrayed(false)
				end
			end
		end
	end
end

function ItemHandle:onExit()

end

return ItemHandle