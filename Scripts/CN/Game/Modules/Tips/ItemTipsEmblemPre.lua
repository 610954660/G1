--纹章预览
--added by wyang

local ItemTipsEmblemPre = class("ItemTipsEmblemPre",View)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsEmblemPre:ctor(args)
	self._packName = "ToolTip"
	self._compName = "ItemTipsEmblemPre"
    self._isFullScreen = false

	self._data = args.data
end

function ItemTipsEmblemPre:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsEmblemPre:_initUI( ... )
    local list_item = self.view:getChildAutoType("list_item");
    local itemInfo = self._data.__itemInfo;
    local param = itemInfo.para;
    local suitId = {};
    if param[1] == -1 then
        local conf = DynamicConfigData.t_EmblemSuit;
        for _, data in pairs(conf) do
            table.insert(suitId, data.suitId);
        end
    else
        table.insert(suitId, param[1]);
    end
    local pos = {}
    if param[2] == -1 then
        pos = {1, 2, 3, 4};
    else
        table.insert(pos, param[2]);
    end
    local color = {}
    if param[3] == -1 then
        color = {1, 2, 3, 4, 5, 6}
    else
        table.insert(color, param[3]);
    end
    local arr = {};
    for _, a in ipairs(suitId) do
        for _, b in ipairs(pos) do
            for _, c in ipairs(color) do
                local code = a * 100 + b * 10 + c;
                local data = {
                    code = code,
                    category = 0,
                    exp = 0,
                    star = 0,
                    pos = b,
                    color = c,
                    suitId = a
                }
                table.insert(arr, data);
            end
        end
    end
    list_item:setVirtual();
    list_item:setItemRenderer(function (idx, obj)
        local d = arr[idx + 1];
        if (not obj.cell) then
            obj.cell = BindManager.bindEmblemCell(obj);
        end
        obj.cell:setData(d);
        obj:removeClickListener();
        obj:addClickListener(function()
            obj.cell:showItemTips()
        end)
    end)
    list_item:setNumItems(#arr);
end

-- [子类重写] 准备事件
function ItemTipsEmblemPre:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsEmblemPre:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsEmblemPre:_exit()
end


return ItemTipsEmblemPre