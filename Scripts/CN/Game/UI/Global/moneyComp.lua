local moneyComp = class("moneyComp")
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
function moneyComp:ctor()
	self.moneyComp=false;
	self.code=false
	self._eventListeners={}
end

function moneyComp:init(view)
	 self.moneyComp=view;
	 self:onClickLink();
	 self:money_change()
end

function moneyComp:onClickLink() 
	self:addEventListener(EventType.money_change,self)
	local zsJiaBtn = self.moneyComp:getChildAutoType("zsJiaBtn")
	local jinbiJiaBtn = self.moneyComp:getChildAutoType("jinbiJiaBtn")
	zsJiaBtn:addClickListener(function ( ... )
	   ViewManager.open("RechargeView")
	end)
	jinbiJiaBtn:addClickListener(function ( ... )
	end)
end

--更新页面金币显示
function moneyComp:money_change()
    if self.moneyComp then --默认显示金币
      local moneyComp = self.moneyComp;
        if moneyComp then
            if moneyComp:getChildAutoType("jinbiText") then
              moneyComp:getChildAutoType("jinbiText"):setText(MathUtil.toSectionStr(ModelManager.PlayerModel:getMoneyByType(GameDef.MoneyType.Gold)))
            end
            if moneyComp:getChildAutoType("zuanshiText") then
              moneyComp:getChildAutoType("zuanshiText"):setText(MathUtil.toSectionStr(ModelManager.PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond)))
			end   
			if moneyComp:getChildAutoType("txtLingqi") then
				printTable(12,'>>>>>>>>>>>>快快快开机键进',self.code)
				moneyComp:getChildAutoType("txtLingqi"):setText(ModelManager.PlayerModel:getMoneyByType(self.code))
			end     
        end
    end
end

function moneyComp:isShowFirstMoney(isShow)
	if self.moneyComp then
		local firstMoney=self.moneyComp:getChildAutoType('n16')
		if isShow then 
			firstMoney:setVisible(true);
		else
			firstMoney:setVisible(false);
		end
	end
end

function moneyComp:showFirstMoney(code,value)
	if self.moneyComp then
		--local firstMoney=self.moneyComp:getChildAutoType('n16')
		if code then 
			self.code=code;
			if self.moneyComp:getChildAutoType("img_money1") then
			local URL="Icon/money/money"..code..".png"
			self.moneyComp:getChildAutoType("img_money1"):setURL(URL);		
			end  
			if self.moneyComp:getChildAutoType("txtLingqi") then
				self.moneyComp:getChildAutoType("txtLingqi"):setText(value)	
			end  
		end
	end
end

--事件监听
function moneyComp:addEventListener(name, listener, listenerCaller, priority)
    Dispatcher.addEventListener(name, listener, listenerCaller, priority)
    table.insert(self._eventListeners, { name = name, listener = listener })
end


-- 删除所有侦听的事件
function moneyComp:clearEventListeners()
    for _, event in ipairs(self._eventListeners) do
        Dispatcher.removeEventListener(event.name, event.listener)
    end
end

return moneyComp