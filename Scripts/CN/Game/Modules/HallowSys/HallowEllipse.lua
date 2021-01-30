-- add by zn
-- 基座椭圆旋转

local HallowEllipse = class("HallowEllipse", BindView)

function HallowEllipse:ctor()
    -- self._packName = "packName"
    -- self._compName = "HallowEllipse"
    -- self._rootDepth = LayerDepth.PopWindow
    self.center = cc.p(self.view:getWidth()/2, self.view:getHeight()/2+10)
    self.radiusX = 420
    self.radiusY = 70
    self.angle = 0

    self.hallows = {};
    self.timer = false;
    self.isTouching = false;
    self.listener = false; -- 触摸
end

function HallowEllipse:_initUI()
    local root = self
    local rootView = self.view
    -- local holder = fgui.GGraph:create();
	    -- holder:drawEllipse(self.radiusX * 2, self.radiusY * 2, 2, ccc4f(255, 0, 0, 255), ccc4f(0, 0, 0, 100));
        -- holder:setPivot(0.5, 0.5, true)
        -- holder:setPosition(self.center.x , self.center.y);
        -- self.view:addChild(holder);
        -- root.hallow = rootView:getChildAutoType("hallow1");
        for i = 1, 5 do
            local hallow = rootView:getChildAutoType("hallow"..i);
            local angle = i < 4 and (i - 1) * 0.4 * math.pi or (i - 3) * -0.4 * math.pi;
            self.hallows[i] = {
                hallow = hallow,
                angle = angle
            }
        end
        root.base = rootView:getChildAutoType("loader_base");
        root.base:setSortingOrder(1);
        -- self:updateFunc(0);
        self.timer = Scheduler.schedule(function (dt)
            self:updateFunc(dt);
        end, 0)
end

function HallowEllipse:_initEvent()
    local onTouchBegin = function (context)
        local touch = context:getLocation();
        for i = 1, 5 do
            local hallow = self.hallows[i].hallow:displayObject();
            local p = hallow:getParent():convertToNodeSpaceAR(touch);
            local box = hallow:getBoundingBox();
            if (cc.rectContainsPoint(box, p)) then
                self.isTouching = true;
                return true
            end
        end
        return false
    end
    local onTouchMove = function (context)
        local preTouch = context:getPreviousLocation();
        local touch = context:getLocation();
        local offset = (touch.x - preTouch.x) * 0.013;
        for i = 1, 5 do
            self:ellipsePos(offset, i);
        end
    end
    local onTouchEnd = function (context)
        self.isTouching = false;
    end
    local listen = cc.EventListenerTouchOneByOne:create();
    listen:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN);
    listen:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED);
    listen:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED);
    listen:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED);
    self.listener = listen;
    local event = cc.Director:getInstance():getEventDispatcher();
    event:addEventListenerWithSceneGraphPriority(listen, self.view:displayObject());
end

function HallowEllipse:getOffsetX(angle)
    return self.radiusX * math.sin(angle)
end

function HallowEllipse:getOffsetY(angle)
    return self.radiusY * math.cos(angle)
end

function HallowEllipse:updateFunc(dt)
    if (self.isTouching) then return end;
    for i = 1, 5 do
        self:ellipsePos(dt, i);
    end
end

function HallowEllipse:ellipsePos(dt, index)
    local info = self.hallows[index];
    info.angle = info.angle + dt * 0.23;
    if (info.angle > math.pi) then
        info.angle = info.angle - 2 * math.pi
    end
    local x = self:getOffsetX(info.angle);
    local y = self:getOffsetY(info.angle);
    local p = cc.pAdd(self.center, cc.p(x, y));
    info.hallow:setPosition(p.x, p.y);
    local scale = (math.cos(math.abs(info.angle)) + 1) * 0.15 + 0.75;
    info.hallow:setScale(scale, scale);
    info.hallow:setSortingOrder(y < 0 and 0 or 2);
end

function HallowEllipse:_exit()
    if (self.timer) then
        Scheduler.unschedule(self.timer);
    end
    -- 移除触摸
    local event = cc.Director:getInstance():getEventDispatcher();
    event:removeEventListener(self.listener)
end

return HallowEllipse