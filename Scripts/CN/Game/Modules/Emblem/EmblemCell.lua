-- add by zn
-- 纹章item

local EmblemCell = class("EmblemCell", BindView)

function EmblemCell:ctor()
    self.itemCell = false;
    self.category = false;
    self.cardStar = false;
    self.categorySpine = false;
    self.data = false;
end

function EmblemCell:_initUI()
    local itemCell = self.view:getChildAutoType("itemCell");
    if (itemCell) then
        self.itemCell = BindManager.bindItemCell(itemCell);
    end
    self.category = self.view:getChildAutoType("category");
    local cardStar = self.view:getChildAutoType("cardStar");
    if (cardStar) then
        self.cardStar = BindManager.bindCardStar(cardStar);
    end
    -- self.categoryEffect = self.view:getChildAutoType("categoryEffect")
    self:setCategoryPos(1)
    self:setStarType(2)
end

function EmblemCell:setIsMid(bool)
    if (self.itemCell and type(bool) == "boolean") then
        self.itemCell:setIsMid(bool);
    end
end

function EmblemCell:setIsBig(bool)
    if (self.itemCell and type(bool) == "boolean") then
        self.itemCell:setIsBig(bool);
    end
end


function EmblemCell:setData(data)
    self.data = data
    local ctrl = self.view:getController("c2");
    if (ctrl) then
        ctrl:setSelectedIndex(data and 1 or 0);
    end
    if (self.itemCell and data) then
        self.itemCell:setEmblemData(data);
    end
    -- 种族
    if (self.category and data and data.category and data.category < 6 and data.category > 0) then
        self.category:setIcon(PathConfiger.getCardCategory(data.category))
    else
        self:setCategoryPos(0);
    end
    -- 星级
    if (data and data.star and data.star > 0) then
        self.cardStar:setData(data.star)
    else
        self:setStarType(0);
    end
    -- 隐藏默认背景
    self:setDefaultBg(0);
end

function EmblemCell:showFrame(bool)
    if (type(bool) == "boolean") then
        self.itemCell:setNoFrame(not bool);
    end
end

-- 设置种族显示的位置 0 隐藏 1 左上  2 正下
function EmblemCell:setCategoryPos(pos)
    local ctrl = self.view:getController("categoryPos");
    if (ctrl) then
        ctrl:setSelectedIndex(pos);
    end
end

-- 设置星级显示模式 0 隐藏 1 有星无底 2有星有底
function EmblemCell:setStarType(type)
    local ctrl = self.view:getController("starCtrl");
    if (ctrl) then
        ctrl:setSelectedIndex(type);
    end
end

-- 没有数据 但还需要显示占位的时候调用
function EmblemCell:setDefaultBg(pos)
    local posCtrl = self.view:getController("pos");
    posCtrl:setSelectedIndex(pos)
end

function EmblemCell:setStar(star)
	self.cardStar:setData(star)
	self:setStarType(2)
end

function EmblemCell:setGrayed(bool)
    self.view:setGrayed(bool)
end
-- 设置星星位置
function EmblemCell:setStarPos(type)
    local ctrl = self.view:getController("starPos")
    if (ctrl) then
        ctrl:setSelectedIndex(type)
    end
end

function EmblemCell:showCategoryEffect(boolean)
    local parent = self.view:getChildAutoType("categoryEffect")
    if parent then
        if (boolean) then
            local pos = cc.vertex2F(parent:getWidth()/2, parent:getHeight()/2)
            if not self.categorySpine then
                self.categorySpine = SpineUtil.createSpineObj(parent, pos, "ui_wenzhangjiacheng", "Spine/ui/Emblem", "efx_wenzhang", "efx_wenzhang", true)
            end
        elseif (not boolean and self.categorySpine) then
            self.categorySpine:removeFromParent()
            self.categorySpine = false
        end
    end
end

function EmblemCell:showItemTips(extraData)
    local info = {
        data = self.data, 
        winType = "tips"
    }
    if (extraData) then
        for k, v in pairs(extraData) do
            info[k] = v;
        end
    end
    ViewManager.open("EmblemCompareView", info)
end

return EmblemCell