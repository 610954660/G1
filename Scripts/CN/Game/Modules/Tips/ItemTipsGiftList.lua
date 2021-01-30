--道具tips
--added by wyang
local ItemTipsGiftList = class("ItemTipsGiftList",View)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsGiftList:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsGiftList"
   self._isFullScreen = false

	self._data = args.data
end

function ItemTipsGiftList:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsGiftList:_initUI( ... )
	
	local list_gift = self.view:getChildAutoType("list_gift")
	local giftListData = self._data:getItemInfo().para
	
	list_gift:setItemRenderer(function(index,obj)
			local list_reward = obj:getChildAutoType("list_reward")
			local giftItems = DynamicConfigData.t_GiftGroupConfig[giftListData[index + 1]]
			if giftItems then
				list_reward:setItemRenderer(function(giftIndex,rewardObj)
					local data = giftItems.reward[giftIndex + 1]
					if data.type == 4 then
						rewardObj:getController("typeCtrl"):setSelectedIndex(0)
						local heroCellObj = BindManager.bindHeroCellShow(rewardObj:getChildAutoType("heroCell"))
						local tempdata = {}
						tempdata.code = data.code
						tempdata.category = DynamicConfigData.t_hero[data.code].category
						tempdata.star = DynamicConfigData.t_hero[data.code].heroStar
						tempdata.level = 1
						tempdata.name = DynamicConfigData.t_hero[data.code].heroName
						heroCellObj:setData(tempdata)
					else
						rewardObj:getController("typeCtrl"):setSelectedIndex(1)
						local itemcellObj = BindManager.bindItemCell(rewardObj:getChildAutoType("itemCell"))
						local itemData = ItemsUtil.createItemData({data = data})
						itemcellObj:setIsBig(false)
						--itemcellObj:setClickable(false)
						itemcellObj:setItemData(itemData,CodeType.ITEM)
					end
				end)
				list_reward:setData(giftItems.reward)
			end
		end)
	list_gift:setNumItems(#giftListData)
end

-- [子类重写] 准备事件
function ItemTipsGiftList:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsGiftList:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsGiftList:_exit()
end


return ItemTipsGiftList