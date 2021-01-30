--可以支持多行的飘字
local FightPointAddView,Super = class("FightPointAddView", View)


function FightPointAddView:ctor(args)
	--LuaLogE("RollTips ctor")
	self._packName = "UIPublic_Window"
	self._compName = "FightPointAddView"
	self._rootDepth = LayerDepth.Message
	self.args = args
	
	
	self.txt_power = false
	self.posCtrl = false
	self._updateId  = false
	self._eachPower = 0;
	self._addPower = 0;
	self. _curPower = 0;
	self._idx = 0;
	self._isShowing = false;
end


function FightPointAddView:_initUI()
	self.txt_power = self.view:getChildAutoType("txt_power")
	self.posCtrl = self.view:getController("posCtrl")
	local effectLoader = self.view:getChildAutoType("effectLoader")
	SpineUtil.createSpineObj(effectLoader, vertex2(0,0), "animation2", "Spine/ui/fightPoint", "Ef_zongshanghai", "Ef_zongshanghai",false)
	self:show(0, self.args.addNum)
	if self.args.pos and self.args.pos == "center" then
		self.posCtrl:setSelectedIndex(1)
	end
end

function FightPointAddView:show(oldPower, newPower)
	if self._isShowing then return end
	self.view:setVisible(true)
	--if(oldPower >= newPower)  then return end
	self._addPower = newPower - oldPower;	
	self._eachPower = math.round( self._addPower / 10 ); 	
	self._curPower = 0
	self.txt_power:setText(self._curPower )
	self._idx = 0;


	self._updateId  = Scheduler.schedule(function()
		self:upEffect()
	end,0.06)
	self._isShowing = true;
	self._isInHide = false;
end


function FightPointAddView:upEffect()
	self._idx = self._idx + 1;
	if(self._idx>=10) then		
		Scheduler.unschedule(self._updateId)
		if self._addPower > 0 then
			self.txt_power:setText("+"..self._addPower)
		else
			self.txt_power:setText(self._addPower)
		end
		local onComplete = function()
			self._isShowing = false
			self:closeView()
		end
		TweenUtil.alphaTo(self.clound, {from = 1, to = 1, time = 0.5, ease = EaseType.Linear, onComplete=onComplete})
		return;
	end
	self._curPower = self._curPower + self._eachPower;
	if self._curPower > 0 then
		self.txt_power:setText("+"..self._curPower)
	else
		self.txt_power:setText(self._curPower)
	end
end

function FightPointAddView:_exit()
	
end

return FightPointAddView