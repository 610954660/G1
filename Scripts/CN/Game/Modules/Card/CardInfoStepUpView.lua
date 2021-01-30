---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardInfoStepUpView,Super = class("CardInfoStepUpView",Window)

function CardInfoStepUpView:ctor(view)
	self._packName = "CardSystem"
	self._compName = "CardInfoStepUpView"
	self._rootDepth = LayerDepth.Window
	
	self._isFullScreen = true
	--GList
	self.cardStepList=false
	self.listAttrName=false
	--GButton
	self.upStep=false
	--GTextField
	self.heroStep=false
	self.playerIcon = false
	self.heroNextstep=false
	self.heroLevel=false--卡牌升级等级
	self.heroNextlevel=false
	self.heroUpStepCost=false--升级升阶消耗
	self._cost = false
	self.costBar =  false
	self.skillCtrl = false
	self.txt_skillLv0 = false
	self.txt_skillLv1 = false
	self.txt_skillLv2 = false
	self.skillCell0 = false
	self.skillCell1 = false
	self.skillCell2 = false
	self.uuid = 0
	
	self.curAllAttr = false
	self.nextAllAttr = false
	self.attrs = false
end    

function CardInfoStepUpView:_initUI()
	local viewRoot = self.view
	viewRoot:getChild("loader_bg"):setURL("UI/CardSystem/card_stepup.png")
	self.skillCtrl = self.view:getController("skill")
	self.skillNumCtrl = self.view:getController("skillNum")
	self.heroStep=viewRoot:getChild("txt_step");
	self.heroNextstep=viewRoot:getChild("txt_nextstep");
	self.heroLevel=viewRoot:getChild("txt_level")
	self.heroNextlevel=viewRoot:getChild("txt_nextlevel")
	local costBar = viewRoot:getChildAutoType("costBar")
	self.costBar = BindManager.bindCostBar(costBar)
	self.costBar:setDarkBg(true)
	self.upStep=viewRoot:getChildAutoType("btn_step")
	self.listAttrName=FGUIUtil.getChild(viewRoot,"list_attrName","GList")
	self.cardStepList=FGUIUtil.getChild(viewRoot,"list_attr","GList")
	local playerIcon = viewRoot:getChildAutoType("playerIcon")
	self.playerIcon = BindManager.bindLihuiDisplay(playerIcon)
	self.txt_skillLv0 = viewRoot:getChildAutoType("txt_skillLv0")
	self.txt_skillLv1 = viewRoot:getChildAutoType("txt_skillLv1")
	self.txt_skillLv2 = viewRoot:getChildAutoType("txt_skillLv2")
	self.skillCell0 = viewRoot:getChildAutoType("skillCell0")
	self.skillCell1 = viewRoot:getChildAutoType("skillCell1")
	self.skillCell2 = viewRoot:getChildAutoType("skillCell2")
	self.skillCell0 = BindManager.bindSkillCell(self.skillCell0)
	self.skillCell1 = BindManager.bindSkillCell(self.skillCell1)
	self.skillCell2 = BindManager.bindSkillCell(self.skillCell2)
	self:bindEvent()
	self:showStep();
	
	local info = ModelManager.CardLibModel.curCardStepInfo
	self:changeHeroShow(info.heroId,info.fashionId)
end

--绑定事件
function CardInfoStepUpView:bindEvent()
	self.upStep:addClickListener(function (context)
		local heroInfo= ModelManager.CardLibModel.curCardStepInfo;
		local config = DynamicConfigData.t_hero[heroInfo.heroId]
		local stageInfo = DynamicConfigData.t_heroStage[heroInfo.stage + 1]
		if stageInfo and heroInfo.star < stageInfo.StarLimit then
			RollTips.show(string.format(Desc.card_StepUpStarLimit, stageInfo.StarLimit))
			return
		end
        print(5,heroInfo.uuid,"升阶")
		if not ModelManager.PlayerModel:isCostEnough(self._cost) then
			return
		end
        local soundId = 0
		if config.sound2 and #config.sound2>0 then
			if config.sound2[2] then
				soundId = config.sound2[2]
			end
		end
		ModelManager.CardLibModel:heroUpgrade(heroInfo.uuid, TableUtil.DeepCopy(self.attrs), TableUtil.DeepCopy(self.curAllAttr), TableUtil.DeepCopy(self.nextAllAttr),soundId);
		ViewManager.close('CardInfoStepUpView');
	end)
end


--改变骨骼显示的动画
function CardInfoStepUpView:changeHeroShow(heroId, fashionId)
	self.playerIcon:setData(heroId,nil,nil,fashionId)
end

--[[function CardInfoStepUpView:_refresh()
	local indexID = ModelManager.CardLibModel:getCarIndex()
    self:setDetailsById(indexID)
end

function CardInfoStepUpView:cardView_updateInfo(_, data)
	local indexID = ModelManager.CardLibModel:getCarIndex()
    self:setDetailsById(indexID)
end--]]

function CardInfoStepUpView:cardView_stepUpSuc(_,data)
	printTable(5,"卡牌阶级请求返回yfyf",data)
	if data then
		--ModelManager.CardLibModel.curCardStepInfo=data.hero;
		--ModelManager.CardLibModel.__cardAttrAdd=data.hero.attrs;
		if not tolua.isnull(self.view) then return end
		self:showStep();
	end
end

--设置卡牌等级阶级信息
function CardInfoStepUpView:showStep()
	local heroInfo= ModelManager.CardLibModel.curCardStepInfo;
	if not heroInfo then return end
	self.heroStep:setText(string.format(Desc.card_step, heroInfo.stage))
	self.heroNextstep:setText(string.format(Desc.card_step, heroInfo.stage+1));
	local heroLeveInfo=DynamicConfigData.t_heroStage[(heroInfo.stage+1)]--读表的数据
	local curLeveInfo=DynamicConfigData.t_heroStage[(heroInfo.stage)]--读表的数据
	if heroLeveInfo==nil then
		heroLeveInfo=curLeveInfo;
	end
	self.heroLevel:setText(string.format("%s",curLeveInfo.LevelMax))--卡牌升级等级
	self.heroNextlevel:setText(string.format('%s',heroLeveInfo.LevelMax))
	--printTable(5,"yfyfyyf",heroInfo,heroLeveInfo);
	--[[local itemInfo = DynamicConfigData.t_item[tonumber(heroLeveInfo.code)];
	if not itemInfo then
		printTable(5,"物品表没有物品信息",heroLeveInfo.code);
		return;
	end--]]
	--self.heroUpStepCost:setText(string.format("%s: %s",itemInfo.name,heroLeveInfo.amount));--升级升阶消耗
	self._cost = heroLeveInfo.costList
	self.costBar:setData(self._cost, false)
		
	self.curAllAttr= ModelManager.CardLibModel:getCardAllAttrInfo(heroInfo,heroInfo.level,heroInfo.stage,heroInfo.star);
	self.nextAllAttr= ModelManager.CardLibModel:getCardAllAttrInfo(heroInfo,heroInfo.level,heroInfo.stage+1,heroInfo.star);
	self.attrs = heroInfo.attrs
	self:setCardAttr(heroInfo.attrs,self.curAllAttr, self.nextAllAttr);
	
	local skillUpId
	local skillUpFrom = 0
	local skillUpTo = 0
	for i = 1,4,1 do
		skillUpFrom = curLeveInfo.skillLevel[i]
		skillUpTo = heroLeveInfo.skillLevel[i]
		if skillUpTo > skillUpFrom then
			skillUpId = heroInfo.heroDataConfiger["skill"..i]
			break
		end
	end
	if skillUpId  and #skillUpId >= skillUpTo then
		self.skillCtrl:setSelectedIndex(1)
		
		if skillUpFrom == 0 then
			self.skillNumCtrl:setSelectedIndex(0)
			self.txt_skillLv0:setText("Lv."..skillUpTo)
			self.skillCell0:setData(skillUpId[skillUpTo],true, heroInfo.heroDataConfiger.heroId)
		else
			self.skillNumCtrl:setSelectedIndex(1)
			self.txt_skillLv1:setText("Lv."..skillUpFrom)
			self.txt_skillLv2:setText("Lv."..skillUpTo)
			self.skillCell1:setData(skillUpId[skillUpFrom],true, heroInfo.heroDataConfiger.heroId)
			self.skillCell2:setData(skillUpId[skillUpTo],true, heroInfo.heroDataConfiger.heroId)
		end
		
	else
		self.skillCtrl:setSelectedIndex(0)
	end
end

--设置卡牌属性名展示
function CardInfoStepUpView:setCardAttr(curAttr,curAllAttr, nextAllAttr)
	--[[self.listAttrName:setItemRenderer(function(index,obj)
			obj:removeClickListener()--池子里面原来的事件注销掉
			local value=curAttr[index+1];
			local attrName=ModelManager.CardLibModel.cardAttrName[value.id]
			obj:setText(string.format("%s",attrName));
		end
	)
	self.listAttrName:setNumItems(#curAttr);--]]

	self.cardStepList:setItemRenderer(function(index,obj)
		obj:removeClickListener()--池子里面原来的事件注销掉
		local value=curAttr[index+1];
		local add = nextAllAttr and (nextAllAttr[value.id] - curAllAttr[value.id]) or 0
		local next=curAttr[index+1].value + add;--value.value+ModelManager.CardLibModel.cardStepAddAttr[value.id];
	
		
		local txt_attrName = obj:getChild("txt_attrName")
		local txt_cur = obj:getChild("txt_cur")
		local txt_next = obj:getChild("txt_next")
		txt_attrName:setText(ModelManager.CardLibModel.cardAttrName[value.id])
		txt_cur:setText(" " .. value.value)
		txt_next:setText(" " .. next)
	end
)
self.cardStepList:setNumItems(#curAttr);
end


function CardInfoStepUpView:_enter()

end

function CardInfoStepUpView:_exit()
end

return CardInfoStepUpView