---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Date: 2020-01-11 17:15:22
--卡牌置换成功界面
---------------------------------------------------------------------
local CardResetSuccessView,Super = class("CardResetSuccessView",Window)
function CardResetSuccessView:ctor(args)
	self._packName = "CardSystem"
	self._compName = "CardResetSuccessView"
	self._rootDepth = LayerDepth.PopWindow
	self.data = args
	self.lihuiDisplay = false
	self.heroInfo = false
	self.animation = false
	self.cardStepList = false
	self.curAllAttr = args.curAllAttr --升阶前属性
	self.nextAllAttr = args.nextAllAttr --升阶后属性
	self.btn_matchPoint = false
	self.txt_freePoint = false
	self.content=false
end    

function CardResetSuccessView:_initUI()	
	self.content =self.view:getChildAutoType("content")
	self.txt_desc = self.content:getChild("txt_desc")
	self.btn_matchPoint = self.content:getChild("btn_matchPoint")
	self.txt_freePoint = self.content:getChild("txt_freePoint")
	self.cardStepList =self.content:getChild("list_attr")
	self.hero1 =self.content:getChild("hero1")
	self.hero2 =self.content:getChild("hero2")

	local loader_success = self.content:getChildAutoType("loader_success")
	
	if not self.animation then
		self.animation = SpineUtil.createSpineObj(loader_success, vertex2(loader_success:getWidth()/2,loader_success:getHeight()/2), "shengxingchenggong", "Effect/UI", "shengxingchenggong_texiao", "shengxingchenggong_texiao",true)
	end
	self.content:getChildAutoType("bg_left"):setURL(PathConfiger.getBg("bg_starUpSuccess1.png"))
	self.content:getChildAutoType("bg_right"):setURL(PathConfiger.getBg("bg_starUpSuccess2.png"))
	local lihuiDisplay = self.content:getChildAutoType("lihuiDisplay")
	self.lihuiDisplay = BindManager.bindLihuiDisplay(lihuiDisplay)
	self.heroInfo = self.data.heroInfo
	self.btn_matchPoint:addClickListener(function (context)
		ViewManager.open("MatchPointView", self.heroInfo)
	end)
	self.lihuiDisplay:setData(self.heroInfo.heroId,nil,nil, self.heroInfo.fashionId)
	local point = self._args.hallowPoint or 0
	local pointCtrl = self.content:getController("pointCtrl");
	if point==0 then
		pointCtrl:setSelectedIndex(0);
		self.content:getChildAutoType("loader_point"):setVisible(false)
		self.content:getChildAutoType("txt_name"):setVisible(false)
		self.content:getChildAutoType("txt_point"):setVisible(false)
	else
		pointCtrl:setSelectedIndex(1);
		self.content:getChildAutoType("loader_point"):setVisible(true)
		self.content:getChildAutoType("txt_name"):setVisible(true)
		self.content:getChildAutoType("txt_point"):setVisible(true)
	end
	self.content:getChildAutoType("loader_point"):setIcon(ItemConfiger.getItemIconByCode(2017));
	self.content:getChildAutoType("txt_point"):setText("+"..point);
	local leftPoint = 0
	if self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId] then
		leftPoint = self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum
	end
	self.txt_freePoint:setText(leftPoint)
	self:setCardAttr(self.curAllAttr , self.nextAllAttr);
	self.txt_desc:setText(self.data.desc)
	local cardcell1 = BindManager.bindCardCell(self.hero1)
	cardcell1:setCardNameVis(false)
	cardcell1:setData(self.data.oldHeroInfo, true)
	local cardcell2 = BindManager.bindCardCell(self.hero2)
	cardcell2:setCardNameVis(false)
	cardcell2:setData(self.heroInfo, true)
end

--设置卡牌属性名展示
function CardResetSuccessView:setCardAttr(curAllAttr, nextAllAttr)
	self.cardStepList:setItemRenderer(function(index,obj)
		obj:getController("c1"):setSelectedIndex(index%6)
		obj:removeClickListener()--池子里面原来的事件注销掉
		local value=curAllAttr[index+1];
		local next=nextAllAttr[index+1].value 
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

function CardResetSuccessView:cardView_configurationPoint()
	local leftPoint = 0
	if self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId] then
		leftPoint = self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum
	end
	self.txt_freePoint:setText(leftPoint)
end

function CardResetSuccessView:_enter()

end
function CardResetSuccessView:_exit()
	Dispatcher.dispatchEvent(EventType.show_gameReward,{gamePlayType=GameDef.GamePlayType.HeroChange})
end

return CardResetSuccessView