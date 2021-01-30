--added by xhd 
--背包控制器
local BagController = class("BagController",Controller)
local PackUpdater = require  "Game.Modules.Pack.PackUpdater"
--背包使用道具
function BagController:Bag_UseItem( e,params )
	RPCReq.Bag_UseItem(params, params.onSuccess)
end

--丢弃物品 只有默认的背包才能丢弃
function BagController:Bag_DropItem(e,params  )
	RPCReq.Bag_DropItem(params, params.onSuccess)	
end

--回收物品，只有默认的人物背包才能回收
function BagController:Bag_Reclaim(e,params)
	RPCReq.Bag_DropItem(params, params.onSuccess)
end

--整理
function BagController:Bag_Arrange(e,params)
	RPCReq.Bag_Arrange(params, params.onSuccess)
end

--增加道具
function BagController:Add_Item(e,params)
	RPCReq.AddItem(params, params.onSuccess)
end


--背包数据更新 监听服务器数据更新
function BagController:Bag_ItemOpers( _,params )
    print(1,"BagController Bag_ItemOpers")
	local itemOpers = params.itemOpers
	local updateCode = params.reasonType
	local packEvents = {}
    local itemEvents = {}
    local getList = {}
    --printTable(1,itemOpers)
    for k, v in pairs(itemOpers) do
        local eventName, eventArg = ModelManager.PackModel:updatePackItems(v, updateCode)
        if eventName then
            -- local redTypes = {
            --     {redType="V_BAG_NOR", bagType = GameDef.BagType.Normal},
            --     {redType="V_BAG_EQUIP", bagType = GameDef.BagType.Equip},
            --     {redType="V_BAG_SPECIAL", bagType = GameDef.BagType.Special},
            --     {redType="V_BAG_HEROCOMP", bagType = GameDef.BagType.HeroComponent}
            -- }
            -- for k,v in pairs(redTypes) do
            --     if v.bagType == v.bagType then
            --         RedManager.updateValue(v.redType, true)
            --     end
            -- end
            -- 背包事件
            if not packEvents[eventName] then --针对某个背包栏目更新
                packEvents[eventName] = {}
            end
            packEvents[eventName][#packEvents[eventName] + 1] = eventArg

            -- 道具事件
            -- local itemEvent = PackUpdater.handleItemUpdateEvent(eventArg) --某个道具更新事件
            -- if itemEvent then
            --     if not itemEvents[itemEvent] then
            --         itemEvents[itemEvent] = { eventArg }
            --     else
            --         table.insert(itemEvents[itemEvent], eventArg)
            --     end
            -- end

            -- table.insert(getList,{
            --     item = eventArg.itemData,
            --     amount = eventArg.amountChange,
            -- })
        end
    end
    --发送背包数据更新消息
    for k, v in pairs(packEvents) do
        print(1,k,v)
        Dispatcher.dispatchEvent(k, v)
    end
    
    --道具事件
    -- for k, v in pairs(itemEvents) do
    --     print(1,k,v)
    --     Dispatcher.dispatchEvent(k, v)
    -- end
end

--请求 Bag_GetTypeItemData 服务器返回数据
-- function BagController:Bag_Infos( _,params )
--     print(1,"Bag_Infos aaa")
--     print(1,_)
--     printTable(1,params)
--     for k, v in pairs(baseData.bag) do
--         ModelManager.PackModel:setPack(v)
--     end

--     if(params.bags and params.bags[1]) then
--         local pack = ModelManager.PackModel:getPackByType(params.bags[1].type)
--         pack:clear()
--         ModelManager.PackModel:setPack(params.bags[1])
--         Dispatcher.dispatchEvent(EventType.update_Bag_Items,params.bags[1].type)
--     end
-- end


return BagController