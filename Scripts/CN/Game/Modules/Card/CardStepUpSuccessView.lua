---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardStepUpSuccessView,Super = class("CardStepUpSuccessView",Window)

function CardStepUpSuccessView:ctor(args)
	self._packName = "CardSystem"
	self._compName = "CardStepUpSuccessView"
	self._rootDepth = LayerDepth.PopWindow
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
	self.txt_fight=false
	self.txt_fightNext=false
	
	self.txt_skillLv0 = false
	self.txt_skillLv1 = false
	self.txt_skillLv2 = false
	self.skillCell0 = false
	self.skillCell1 = false
	self.skillCell2 = false
	
	
	self.skillUpLvInfo = false-- 是否有技能升等级了
	self.oldCombat = args.oldCombat  -- 升阶前战力
	self.newCombat = args.newCombat --升阶后战力
	self.curAllAttr = args.curAllAttr --升阶前属性
	self.nextAllAttr = args.nextAllAttr --升阶后属性
	self.attrs = args.attrs --升级前英雄本身属性
	self.soundId = args.soundId
	self.heroInfo = args.heroInfo
	
end    

function CardStepUpSuccessView:_initUI()
	local viewRoot = self.view
	viewRoot:getChild("loader_bg"):setURL("UI/CardSystem/card_stepup.png")
	if self.soundId >0 then
		self.soundId = SoundManager.playSound(self.soundId,false)
	end
	self.heroStep=viewRoot:getChild("txt_step");
	self.heroNextstep=viewRoot:getChild("txt_nextstep");
	self.heroLevel=viewRoot:getChild("txt_level")
	self.heroNextlevel=viewRoot:getChild("txt_nextlevel")
	self.txt_fight=viewRoot:getChild("txt_fight")
	self.txt_fightNext=viewRoot:getChild("txt_fightNext")

	self.listAttrName=FGUIUtil.getChild(viewRoot,"list_attrName","GList")
	self.cardStepList=FGUIUtil.getChild(viewRoot,"list_attr","GList")
	local playerIcon = viewRoot:getChildAutoType("playerIcon")
	self.playerIcon = BindManager.bindLihuiDisplay(playerIcon)
	self:bindEvent()
	self:showStep();

	self:changeHeroShow(self.heroInfo.heroId, self.heroInfo.fashionId)
end

--绑定事件
function CardStepUpSuccessView:bindEvent()
	
end


--改变骨骼显示的动画
function CardStepUpSuccessView:changeHeroShow(heroId, fashionId)
	self.playerIcon:setData(heroId, nil, nil, fashionId)
end

function CardStepUpSuccessView:cardView_stepUpSuc(_,data)
	printTable(5,"卡牌阶级请求返回yfyf",data)
	if data then
		self:showStep();
	end
end

--设置卡牌等级阶级信息
function CardStepUpSuccessView:showStep()
	
	local heroInfo= self.heroInfo
	self.heroStep:setText(heroInfo.stage - 1)
	self.heroNextstep:setText(heroInfo.stage);
	
	
	local heroLeveInfo=DynamicConfigData.t_heroStage[(heroInfo.stage)]--读表的数据
	local curLeveInfo=DynamicConfigData.t_heroStage[(heroInfo.stage - 1)]--读表的数据
	
	
	self.txt_fight:setText(self.oldCombat)
	self.txt_fightNext:setText(self.newCombat)
	
	if heroLeveInfo==nil then
		heroLeveInfo=curLeveInfo;
	end
	self.heroLevel:setText(string.format("%s",curLeveInfo.LevelMax))--卡牌升级等级
	self.heroNextlevel:setText(string.format('%s',heroLeveInfo.LevelMax))
	
	self:setCardAttr(self.attrs,self.curAllAttr , self.nextAllAttr);
	
	local skillUpId
	local skillUpFrom = 0
	local skillUpTo = 0
	for i = 1,4,1 do
		skillUpFrom = curLeveInfo.skillLevel[i]
		skillUpTo = heroLeveInfo.skillLevel[i]
		if skillUpTo > skillUpFrom then
			skillUpId = heroInfo.heroDataConfiger["skill"..i]
			if skillUpId and #skillUpId >= skillUpTo then
				self.skillUpLvInfo = {from = skillUpFrom, to = skillUpTo, heroInfo = heroInfo, upIndex = i}
			end
			break
		end
	end
end

--设置卡牌属性名展示
function CardStepUpSuccessView:setCardAttr(curAttr,curAllAttr, nextAllAttr)
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


function CardStepUpSuccessView:closeView()
	print(5, "ViewManager.close", self._viewName)
	--作为子页的时候不能调用关闭 需要执行主窗口的closeView
	if self._parentWin then
		self._parentWin:closeView()
	else
    	ViewManager.close(self._viewName)
	end
	
	if self.skillUpLvInfo then
		ViewManager.open("CardSkillUpView", self.skillUpLvInfo)
	end
end
function CardStepUpSuccessView:_enter()

end
function CardStepUpSuccessView:_exit()
	SoundManager.stopSound(self.soundId)
end

return CardStepUpSuccessView