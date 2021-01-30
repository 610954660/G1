--added by wyang
--获取奖励记录
local RewardRecordBoard,Super = class("RewardRecordBoard",BindView)
function RewardRecordBoard:ctor(view)
	self.list_record = false
	self._recordData = false
end

function RewardRecordBoard:init( ... )
	self.list_record = self.view:getChildAutoType("list_record")
	self.list_record:setItemRenderer(function(index,obj)
		local itemCell = obj:getChildAutoType("itemCell")
		local txt_num = obj:getChildAutoType("txt_num")
		local img_line = obj:getChildAutoType("img_line")
		local cell = BindManager.bindItemCell(itemCell)
		local data = self._recordData[index + 1]
		cell:setData(data.code, 1, data.type)
		--img_line:setVisible(index ~= #self._recordData - 1)
		
		txt_num:setText(MathUtil.toSectionStr(data.amount))
	end)
end

function RewardRecordBoard:setData(data)
	if not data then return end
	self._recordData = data
	self.list_record:setNumItems(#self._recordData)
	
end

return RewardRecordBoard