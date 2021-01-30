--带有icon的Tips
local AlertPushMapIconView = class("AlertPushMapIconView")
function AlertPushMapIconView:ctor()
    self.tweenId=false
    self.tweenId1=false
    self.tweenId2=false
    self._poolLimit = 20;
    self._msgItemPool={}
    self._updateTimeId=false
    self._msgData={}
    self._maxLen=5
    self._isShowing=false
end

function AlertPushMapIconView:init( ... )
end

function AlertPushMapIconView:addMsg(arg1)
    --队列长度上限暂时设置为5个， 超过的话，把之前的顶掉
    if(#self._msgData > self._maxLen) then
      table.remove(self._msgData, 1)
    end
    table.insert(self._msgData,arg1)
    self:showNext();
end

function AlertPushMapIconView:showNext()
    if not self._isShowing then
        if #self._msgData>0 then 
            local time=0.3
            self._isShowing = true
            local msg = table.remove( self._msgData,1) 
            self:showAMsg(msg);
            self._updateTimeId  = Scheduler.scheduleOnce(time,function()
                self._updateTimeId = false
                self._isShowing = false
                self:showNext();
            end)
        end
    end
end


function AlertPushMapIconView:showAMsg(msg) 
    local item = self:getItem();
    -- printTable(28,"wwwwwwwwwwwwwwwwwww",item)
    local parentObj = ViewManager.getParentLayer(LayerDepth.Tips)
    parentObj:addChild(item);
   -- 483 , 343
   local x=display.width/2-191
   local y=display.height/2
    item:setPosition(x,y)
    item:setAlpha(0)
    local img_onhook1= item:getChild("img_onhook1");
    local txt_onhook1= item:getChild("txt_onhook1");
    local txt_onhook2= item:getChild("txt_onhook2");
    local greward1= msg[1]
    local greward2= msg[2]
    local URL=ItemConfiger.getItemIconByCodeAndType(greward1.type,greward1.code)
    img_onhook1:setURL(URL)
    txt_onhook1:setText(greward1.amount..'/分')
    txt_onhook2:setText(greward2.amount..'/分')
    table.insert( self._msgItemPool, item)
    item:retain()
    local function onComplete()
        if not tolua.isnull(item) then
            self.tweenId2= TweenUtil.alphaTo(item, {from = 1, to = 0, time =0.3, ease = EaseType.Linear,onComplete=
            function()
                parentObj:removeChild(item)
            end
        })
        end
    end
    self.tweenId=TweenUtil.to(item, {x=x, y = item:getPosition().y - 200, time = 1.2, onComplete = onComplete,ease = EaseType.Linear})
    self.tweenId1= TweenUtil.alphaTo(item, {from = 0, to = 1, time =0.2, ease = EaseType.Linear})
end

--获取单个item 
function AlertPushMapIconView:getItem() 
    if #self._msgItemPool >= 10 then
        local item= table.remove( self._msgItemPool,1 )
        item:release()
        return item
    else
        local obj  =UIPackageManager.createGComponent("PushMap", "com_iconView")
        obj:retain()
        return  obj;
    end
end


--退出操作 在close执行之前 
function AlertPushMapIconView:__onExit()
    printTable(28,"sssssssssssss")
	if  self.tweenId then
        self.tweenId:kill();
        self.tweenId = nil
   end
   if  self.tweenId1 then
    self.tweenId1:kill();
    self.tweenId1 = nil
    end
end

return  AlertPushMapIconView 
