---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardStarUpSuccessView,Super = class("CardStarUpSuccessView",Window)

function CardStarUpSuccessView:ctor(args)
	self._packName = "CardSystem"
	self._compName = "CardStarUpSuccessView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.content = false
	self.data = args
	self.lihuiDisplay = false
	self.heroInfo = false
	self.animation = false
	self.cardStepList = false
	self.curAllAttr = args.curAllAttr --升阶前属性
	self.nextAllAttr = args.nextAllAttr --升阶后属性
	--self.attrs = args.attrs --升级前英雄本身属性
	self.skillCtrl = false
	self.skillNumCtrl = false
	self.btn_matchPoint = false
	self.txt_freePoint = false
end    

function CardStarUpSuccessView:_initUI()	
	self.content = self.view:getChildAutoType("content")
	self.skillCtrl = self.content:getController("skill")
	self.skillNumCtrl = self.content:getController("skillNum")
	self.btn_matchPoint = self.content:getChild("btn_matchPoint")
	
	local cardStar1 = self.content:getChild("cardStar1")
	local cardStar2 = self.content:getChild("cardStar2")
	local txt_oldLevel = self.content:getChild("txt_oldLevel")
	local txt_newLevel = self.content:getChild("txt_newLevel")
	self.txt_freePoint = self.content:getChild("txt_freePoint")
	self.cardStepList=FGUIUtil.getChild(self.content,"list_attr","GList")
	
	self.txt_skillLv0 = self.content:getChildAutoType("txt_skillLv0")
	self.txt_skillLv1 = self.content:getChildAutoType("txt_skillLv1")
	self.txt_skillLv2 = self.content:getChildAutoType("txt_skillLv2")
	local skillCell0 = self.content:getChildAutoType("skillCell0")
	local skillCell1 = self.content:getChildAutoType("skillCell1")
	local skillCell2 = self.content:getChildAutoType("skillCell2")
	self.skillCell0 = BindManager.bindSkillCell(skillCell0)
	self.skillCell1 = BindManager.bindSkillCell(skillCell1)
	self.skillCell2 = BindManager.bindSkillCell(skillCell2)

	local loader_success = self.content:getChildAutoType("loader_success")
	
	if not self.animation then
		self.animation = SpineUtil.createSpineObj(loader_success, vertex2(loader_success:getWidth()/2,loader_success:getHeight()/2), "shengxingchenggong", "Effect/UI", "shengxingchenggong_texiao", "shengxingchenggong_texiao",true)
	end
	txt_oldLevel:setText(self.data.oldLevel)
	txt_newLevel:setText(self.data.newLevel)
	
	cardStar1 = BindManager.bindCardStar(cardStar1)
	cardStar2 = BindManager.bindCardStar(cardStar2)
	cardStar1:setData(self.data.oldStar)
	cardStar2:setData(self.data.newStar)
	
	self.btn_matchPoint:addClickListener(function (context)
		ViewManager.open("MatchPointView", self.heroInfo)
	end)
	
	self.content:getChildAutoType("bg_left"):setURL(PathConfiger.getBg("bg_starUpSuccess1.png"))
	self.content:getChildAutoType("bg_right"):setURL(PathConfiger.getBg("bg_starUpSuccess2.png"))
	local lihuiDisplay = self.content:getChildAutoType("lihuiDisplay")
	
	self.lihuiDisplay = BindManager.bindLihuiDisplay(lihuiDisplay)
	
	self:bindEvent()
	
	self.heroInfo = self.data.heroInfo
	self.lihuiDisplay:setData(self.heroInfo.heroId, nil,nil, self.heroInfo.fashionId)

	-- local point = self._args.hallowPoint or 0
	-- local pointCtrl = self.content:getController("pointCtrl");

	-- pointCtrl:setSelectedIndex(1);
	-- self.content:getChildAutoType("loader_point"):setIcon(ItemConfiger.getItemIconByCode(2017));
	-- self.content:getChildAutoType("txt_point"):setText("+"..point);

	
	local leftPoint = 0
	if self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId] then
		leftPoint = self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum
	end
	self.txt_freePoint:setText(leftPoint)
	
	self:setCardAttr(self.curAllAttr , self.nextAllAttr);
	
	local heroLeveInfo=DynamicConfigData.t_heroStage[self.data.nextStage]--读表的数据
	local curLeveInfo=DynamicConfigData.t_heroStage[self.data.curStage]--读表的数据
	
	local skillUpId
	local skillUpFrom = 0
	local skillUpTo = 0
	if heroLeveInfo then
		for i = 1,4,1 do
			skillUpFrom = curLeveInfo.skillLevel[i]
			skillUpTo = heroLeveInfo.skillLevel[i]
			if skillUpTo > skillUpFrom then
				skillUpId = self.heroInfo.heroDataConfiger["skill"..i]
				break
			end
		end
	end
	if skillUpId  and #skillUpId >= skillUpTo then
		self.skillCtrl:setSelectedIndex(1)
		
		if skillUpFrom == 0 then
			self.skillNumCtrl:setSelectedIndex(0)
			self.txt_skillLv0:setText("Lv."..skillUpTo)
			self.skillCell0:setData(skillUpId[skillUpTo],true, self.heroInfo.heroDataConfiger.heroId)
		else
			self.skillNumCtrl:setSelectedIndex(1)
			self.txt_skillLv1:setText("Lv."..skillUpFrom)
			self.txt_skillLv2:setText("Lv."..skillUpTo)
			self.skillCell1:setData(skillUpId[skillUpFrom],true, self.heroInfo.heroDataConfiger.heroId)
			self.skillCell2:setData(skillUpId[skillUpTo],true, self.heroInfo.heroDataConfiger.heroId)
		end
		
	else
		self.skillCtrl:setSelectedIndex(0)
	end
	if (self._args.hideTop) then
		local ctrl = self.content:getController("segmentCtrl")
		ctrl:setSelectedIndex(1);
	end
end

--设置卡牌属性名展示
function CardStarUpSuccessView:setCardAttr(curAllAttr, nextAllAttr)
	self.cardStepList:setItemRenderer(function(index,obj)
		obj:getController("c1"):setSelectedIndex(index%6)
		obj:removeClickListener()--池子里面原来的事件注销掉
		local value=curAllAttr[index+1];
		--local add = nextAllAttr and (nextAllAttr[value.id].value - curAllAttr[value.id].value) or 0
		local next=nextAllAttr[index+1].value --+ add;--value.value+ModelManager.CardLibModel.cardStepAddAttr[value.id];
	
		
		local txt_attrName = obj:getChild("txt_attrName")
		local txt_cur = obj:getChild("txt_cur")
		local txt_next = obj:getChild("txt_next")
		txt_attrName:setText(ModelManager.CardLibModel.cardAttrName[value.id])
		txt_cur:setText(" " .. value.value)
		txt_next:setText(" " .. next)
	end
)
self.cardStepList:setNumItems(#curAllAttr);
end


--绑定事件
function CardStarUpSuccessView:bindEvent()
	
end

function CardStarUpSuccessView:cardView_configurationPoint()
	local leftPoint = 0
	if self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId] then
		leftPoint = self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum
	end
	self.txt_freePoint:setText(leftPoint)
end

function CardStarUpSuccessView:_enter()

end
function CardStarUpSuccessView:_exit()
	Dispatcher.dispatchEvent(EventType.CardStarUpSuccessView_Close);
end

return CardStarUpSuccessView