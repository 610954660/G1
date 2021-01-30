-- add by zn
-- 升级点记录

local HallowPointView = class("HallowPointView", Window)

function HallowPointView:ctor()
    self._packName = "HallowSys"
    self._compName = "HallowPointView"
    self._rootDepth = LayerDepth.PopWindow
    self.nextKey = false;
end

function HallowPointView:_initUI()
    local root = self
    local rootView = self.view
        root.list_item = rootView:getChildAutoType("list_item");
    
    self.list_item:setItemRenderer(function (idx, obj)
        self:upListItem(idx, obj);
    end)
    self.nextKey = next(HallowSysModel.sysInfo.heroShowRecord);
    self.list_item:setNumItems(TableUtil.GetTableLen(HallowSysModel.sysInfo.heroShowRecord));
end

function HallowPointView:upListItem(idx, obj)
    local map = HallowSysModel.sysInfo.heroShowRecord
    local key = idx == 0 and self.nextKey or next(map, self.nextKey);
    self.nextKey = key;
    local data = HallowSysModel.sysInfo.heroShowRecord[key];
    if (not obj.cell1) then
        obj.cell1 = BindManager.bindHeroCell(obj:getChildAutoType("playerCell1"));
    end
    if (not obj.cell2) then
        obj.cell2 = BindManager.bindHeroCell(obj:getChildAutoType("playerCell2"));
    end
    for i = 1, 2 do
        local cell = obj["cell"..i];
        local star = i == 1 and data.oldStar or data.curStar;
        local info = {
            code = data.code,
            star = star,
            level = 0;
        }
        cell:setBaseData(info);
        cell.level:setVisible(false);
        cell.level_frame:setVisible(false);
    end
    local url = ItemConfiger.getItemIconByCodeAndType(GameDef.GameResType.Item, 10006002);
    obj:getChildAutoType("icon"):setIcon(url)
    obj:getChildAutoType("txt_addNum"):setText(data.addPoint);
end

return HallowPointView