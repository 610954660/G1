--added by wyang
--秘境摇骰子组件
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local TwistRegimentMapItem,Super = class("TwistRegimentMapItem",BindView)
function TwistRegimentMapItem:ctor(view)
	self.data = false
	self.iconLoder = false
	self.c1 = false
	self.btn_roll = false
	self.txt_name = false
	self.txt_title = false
	self.txt_num = false
	--self.img_shadow = false
	self.clound = false
	self._isShow = false
	self._spineModel = false
	self.ItemEvent=false  --每个item 触发的Event
end

function TwistRegimentMapItem:_initUI( ... )
	self.iconLoder = self.view:getChildAutoType("icon")
	self.c1 = self.view:getController("c1")
	self.btn_roll = self.view:getChildAutoType("btn_roll")
	--self.txt_name = self.view:getChildAutoType("txt_name")
	self.txt_title = self.view:getChildAutoType("txt_title")
	self.txt_num = self.view:getChildAutoType("txt_num")
	self.clound = self.view:getChildAutoType("clound")
	self.gridStateCtr = self.view:getController("gridState")
	
	self.btn_reward=self.view:getChildAutoType("btn_reward")
	--self.img_shadow = self.view:getChildAutoType("img_shadow")
end

--有状态更新
function TwistRegimentMapItem:fairyLand_gotRewardUpdate(event, data)
	if(self.data and data.floor == self.data.floor ) then
		
		if not tolua.isnull(self.iconLoder) then
			if self.data.type == GameDef.MonopolyEventType.DoubleReward or self.data.type == GameDef.MonopolyEventType.Common then
				self.view:getTransition("t0"):play(function()
						self.iconLoder:setVisible(false)
						self.iconLoder:setAlpha(1)
						self.iconLoder:setPosition(-4,-47)
						self.iconLoder:setScale(0.6,0.6)
					end)
			else
				self.iconLoder:setVisible(false)
			end
			--self.txt_name:setVisible(false)
			self.c1:setSelectedIndex(0)
		end
	end
end

function TwistRegimentMapItem:setData(data)
	self.data = data
end

function TwistRegimentMapItem:setState(isShow, isInit)
	if isInit then
		self:clear()
	end
	if self._isShow  ~= isShow or isInit then
		self._isShow  = isShow
		self:updateState(isInit)
	end
end

function TwistRegimentMapItem:updateState(isInit)

	--if self._isShow then
		--local onComplete = function()
			--if tolua.isnull(self.view) then return end
			--self:updateIcon()
			--self.clound:setAlpha(0)
			--self.clound:setVisible(false)
		--end
		--if isInit then
			--onComplete()
		--else
			--TweenUtil.alphaTo(self.clound, {from = 1, to = 0, time = 0.5, ease = EaseType.Linear, onComplete=onComplete})
		--end
		----self.c1:setSelectedIndex(0)
	--else
		--local onComplete = function()
			--self:clear()
			--self.clound:setAlpha(1)
			--self.clound:setVisible(true)
			----self.c1:setSelectedIndex(1)
		--end
		--if isInit then
			--onComplete()
		--else
			--self.clound:setVisible(true)
			--TweenUtil.alphaTo(self.clound, {from = 0, to = 1, time = 0.5, ease = EaseType.Linear, onComplete=onComplete})
		--end
	--end
end

function TwistRegimentMapItem:clear()
	self.iconLoder:setURL("")
	self.txt_title:setText("")
	if self._spineModel then
		self._spineModel:removeFromParent()
		self._spineModel = false
	end
end


--return {
	--Common 			= 1, --	普通奖励事件
	--Box				= 2, --	宝箱
	--DoubleReward  	= 3, --	下一次普通奖励 多次奖励事件 奖励倍数
	--Special			= 4, --	获得指定色子事件  命运骰子
	--Monster 		    = 5, --	怪物事件
	--Boss			    = 6, --	大boss
--}


--更新图标显示，如果已经领过奖励的不显示
function TwistRegimentMapItem:updateIcon()
	local iconName = ""
	self.iconLoder:setURL("")
	self.iconLoder:setVisible(true)
	self.ItemEvent=false
	local data = self.data
	if(data.type == GameDef.MonopolyEventType.Common) then
		    --self.clound:setVisible(true)
			local url = ItemConfiger.getItemIconByCode(data.p1[1].code)
			self.txt_num:setText("X"..data.p1[1].amount)
		    self.iconLoder:setURL(url)
			self.ItemEvent=function(finished)
			     self:commonEvent(finished)
			end
		elseif(data.type == GameDef.MonopolyEventType.Box) then
		self.iconLoder:setURL(PathConfiger.getItemIcon(self.data.p8))
		--if TwistRegimentModel.monopolyData then
		self.ItemEvent=function(finished)
			if TwistRegimentModel.monopolyData then
				local view = ViewManager.getLayerTopWindow(LayerDepth.Window)
				local fXparent=view.window.view
				local skeletonNode=SpineUtil.createSpineObj(fXparent, Vector2.zero, nil, "Effect/UI", "Ef_yuanzheng_baoxiang", "Ef_yuanzheng_baoxiang",false,true)
				skeletonNode:setAnimation(0,"baoxiang_chuxian",false)
				skeletonNode:setCompleteListener(function ()
						skeletonNode:removeFromParent()
					end)
				GlobalUtil.delayCall(function()end,function ()
						self:commonEvent(finished)
					end,2.5,1)
			end
		end				
		     -- end
		elseif(data.type == GameDef.MonopolyEventType.DoubleReward) then
		       self.iconLoder:setURL(PathConfiger.getItemIcon("110X"))
		       self.ItemEvent=function(finished)
			        self:commonEvent(finished)
		       end       
		elseif(data.type == GameDef.MonopolyEventType.Special) then
		       self.iconLoder:setURL(PathConfiger.getItemIcon("99001"))
		       self.ItemEvent=function(finished)
			        self:commonEvent(finished)
		       end
		elseif(data.type == GameDef.MonopolyEventType.Monster) then	
		    
		    if TwistRegimentModel.cellInfoMap[self.data.id] then
                --已击败
			    self.gridStateCtr:setSelectedPage("defeated")
		    else
			    self.gridStateCtr:setSelectedPage("normal")
			    self.ItemEvent=function(finished)
			   	     self:joinBattleEvent(finished)
			    end
			end
		    self.btn_reward:setVisible(true)
		    self.btn_reward:addClickListener(function ()
				 TwistRegimentModel:showRewardView(self.data)
			end,1)
		
			self.clound:setVisible(true)
			self.clound:setURL(PathConfiger.getItemIcon(self.data.p7))
			
			
		elseif(data.type == GameDef.MonopolyEventType.Boss) then
		      --if self._spineModel then
		      --self._spineModel:removeFromParent()
		      --self._spineModel = false
		      --end
		      --self._spineModel = SpineUtil.createModel(self.iconLoder, {x = 50, y =0}, "stand", 54001,false)
			self.ItemEvent=function(finished)
                 self:joinBattleEvent(finished)
			end
		elseif(data.type == GameDef.FairyLandGridType.Ending) then	
	end
	

	
	
end


function TwistRegimentMapItem:commonEvent(finished)
	printTable(5656,TwistRegimentModel.monopolyData,"commonEvent")
	if finished then
		finished()
	end
	if self.data.type==GameDef.MonopolyEventType.Special or TwistRegimentModel.hadShowReward then
		--添加获得骰子效果
	    return 
	end
	local activeData=TwistRegimentModel:getAcitveData()
	if TwistRegimentModel.monopolyData then
		if self.data.type==GameDef.MonopolyEventType.DoubleReward then
			if not activeData.fromLogin then
				ViewManager.open("TwistDoubleScoreView",{doubleNum=TwistRegimentModel.monopolyData.param})
			end
		else
			RollTips.showReward(TwistRegimentModel.monopolyData.addRes)
			TwistRegimentModel.monopolyData=false
		end
	end
	TwistRegimentModel.hadShowReward=true

end

--触发战斗事件
function TwistRegimentMapItem:joinBattleEvent(finished)
	local activeData=TwistRegimentModel:getAcitveData()
	if not activeData.isAct and TwistRegimentModel:isGirdCanFight() then
		TwistRegimentModel:joinBattleEvent(self.data.id,self.data.p5,finished)
	end

end


--function TwistRegimentMapItem:onFightCancel()
	--local info = {}
	--info.text = Desc.fairyLand_cancelFight
	--info.type = "yes_no"
	--info.yesText = Desc.fairyLand_continueFight
	--info.noText = Desc.fairyLand_closeView
	--info.mask = true
	--info.onYes = function()
		--self:girdEvent()
	--end
	--info.onNo = function()
        --ViewManager.close("TwistRegimentView")
	--end
	--Alert.show(info)
--end


function TwistRegimentMapItem:girdEvent(finished)  
	if self.ItemEvent then
		self.ItemEvent(finished)
	else
		finished()
		print(5656,"无事件粗发")
	end
end



--退出操作 在close执行之前
function TwistRegimentMapItem:__onExit()
	print(1,"TwistRegimentMapItem __onExit")
end

return TwistRegimentMapItem