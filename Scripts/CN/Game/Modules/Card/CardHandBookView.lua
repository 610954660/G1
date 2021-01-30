local  CardHandBookView,Super = class("CardHandBookView", Window)
local  UpdateDescription = require "Configs.Handwork.UpdateDescription"
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
function CardHandBookView:ctor()
	self._packName = "CardSystem"
	self._compName = "CardHandBookView"
	self._showParticle=true
	self.__reoloadPacket = true

	self._cardCategory = {1,2,3,4,5}
	self._cardCurCategory=1;
	self.btn_handbook=false;
	self.btn_help=false;
	self._cardIconList = false;
	self._cardZero = false;
	
	self.cardStarkey={}
	self._cardInfoList = false
	self.redIndex = false
	self.firstRedTag = false
end

function CardHandBookView:_initUI()
	
	self:setBg("card_handbook3.jpg")
	local viewRoot = self.view
	self._cardLabelList=viewRoot:getChildAutoType("list_cardType")
	self._cardIconList=viewRoot:getChildAutoType("list_card")
	local bgLoader = self.view:getChildAutoType("bgLoader")

	bgLoader:setURL(PathConfiger.getBg("card_handbook4.png"))
	local descTxt={Desc.CardHandBook1,Desc.CardHandBook2,Desc.CardHandBook3,Desc.CardHandBook4}
	local descColor={"#993737","#775407","#733298","#2e4b8b"}
	self._cardIconList:setVirtual()
	self._cardIconList:setItemRenderer(function(index,obj)
		local starKey=self.cardStarkey[index+1]
		local cardInfo= self._cardInfoList[starKey]
		local icon=obj:getChildAutoType("icon")
		icon:setURL("UI/CardSystem/cardHandBook"..(starKey)..".png")
		local title=obj:getChildAutoType("title")
		title:setText(ColorUtil.formatColorString1(descTxt[starKey],descColor[starKey]))
		local cardItemObg=obj:getChildAutoType("list_item")
		cardItemObg:setVirtual()
		cardItemObg:setItemRenderer(function(index2,obj)
				obj:setGrayed(false)
				local heroId = cardInfo[index2+1].hero
				local cardItem = obj:getChildAutoType("cardItem")
				local img_red = obj:getChildAutoType("img_red")
				local btn_click = cardItem:getChildAutoType("btn_click")
				btn_click:removeClickListener()--池子里面原来的事件注销掉
				btn_click:addClickListener(function(context)
						--printTable(8,">>>>>>>>>>>>>>11",CardList[index+1].uuid)	
						--ModelManager.CardLibModel.curCardStepInfo = CardList[index+1]
						--ModelManager.CardLibModel:setCarByPosInfo(CardList[index+1].code,CardList[index+1].uuid,index+1)
						--Dispatcher.dispatchEvent(EventType.cardView_showDetial)
						--HandbookModel.firstRedHero[heroId] = nil
						ViewManager.open("HeroInfoView",{index = index2+1,heroId = heroId,heroList = cardInfo })
					end)
					
				local cardCell = BindManager.bindCardCell(cardItem)
				cardCell:setData(heroId)
				--cardCell:setStatus(ModelManager.HandbookModel:isCardGot(heroId) and 0 or 5)
				local txt_num = obj:getChildAutoType("txt_num")
				txt_num:setText(ModelManager.HandbookModel:GetLinkingLevelById(heroId))
				RedManager.register("V_HANDBOOK_NEW_HERO"..heroId, img_red)
				obj:setGrayed(not ModelManager.HandbookModel:isCardGot(heroId))
			end
		)
		cardItemObg:setNumItems(#cardInfo)	
		cardItemObg:resizeToFit(#cardInfo)
		if self.redIndex and self.firstRedTag == index+1 then
			cardItemObg:scrollToView(self.redIndex-1,false)
		end
	end)



	
	self.btn_handbook=viewRoot:getChild('btn_handbook');
	self.btn_help=viewRoot:getChild('btn_help');
	self._cardZero=viewRoot:getController('c1'); 

	self._cardLabelList:setSelectedIndex(0)
	self._cardLabelList:regUnscrollItemClick(function (index,obj)
		local category = self._cardCategory[index + 1]
		self:setCardsByCategory(category)
	end)
	self._cardLabelList:setItemRenderer(function(index,obj)
		local txt_num = obj:getChildAutoType("txt_num")
		local img_red = obj:getChildAutoType("img_red")
		local category = self._cardCategory[index + 1]
		local totalNum = 0
		local activeNum = 0
		for _,v in pairs(self:getTimeLimitHeros(category)) do
			totalNum = totalNum + 1
			if ModelManager.HandbookModel:isCardGot(v.hero) then
				activeNum = activeNum + 1
			end
		end
		RedManager.register("V_HANDBOOK_NEW_CATEGORY"..category,img_red)
		txt_num:setText("("..activeNum.."/"..totalNum..")")
	end)
	
	self._cardLabelList:setNumItems(self._cardLabelList:getNumItems())
	
	self.btn_handbook:addClickListener(
		function (...)
			ViewManager.open("HerobookView")
		end
	)

	self.btn_help:addClickListener(
		function (...)
			--ViewManager.open("HerobookView")
			RollTips.showHelp("", Desc.help_handBook)
		end
	)
	for i = 1,5 do--预处理
		self:getTimeLimitHeros(i)
	end

	self:updateActiveNum()	
	self:setCardsByCategory(1)
	self._cardIconList:setSelectedIndex(self._cardCurCategory)

	self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1, false)
end
function CardHandBookView:checkHeroChange()
	local categoryHeros = self:getTimeLimitHeros(self._cardCurCategory)
	for key,value in pairs(categoryHeros) do
		if self.curCategoryHeros[key] then
			if value.hero ~= self.curCategoryHeros[key].hero then
				self:setCardsByCategory(self._cardCurCategory)
				self._cardLabelList:setNumItems(self._cardLabelList:getNumItems())
				return
			end
		else
			self:setCardsByCategory(self._cardCurCategory)
			self._cardLabelList:setNumItems(self._cardLabelList:getNumItems())
			return
		end
	end
end
function CardHandBookView:update()
	self:checkHeroChange()
end
function CardHandBookView:HeroTotems_UpdateLiking(_,data )
	self:setCardsByCategory(self._cardCurCategory)
end
--刷新次数
function CardHandBookView:updateActiveNum()	
	self._cardLabelList:setNumItems(#self._cardCategory);
end
function CardHandBookView:getTimeLimitHeros(category)
	local openSeverTime = ServerTimeModel:getOpenDateTime()
	local curSeverTime = ServerTimeModel:getServerTime()
	local dayNum = ServerTimeModel:getOpenDay() + 1
	local list = {}
	local categoryHeros = DynamicConfigData.t_HeroTotems[category]
	for _,v in pairs(categoryHeros) do
		local state = false
		if dayNum >= v.date[1].start and (dayNum <= v.date[1].endTime or v.date[1].endTime == 0)then
			state = true
		end
		if v.startDt ~= "" and v.endDt ~= ""  and state then
			if curSeverTime >= DateUtil.getDateSecByStr(v.startDt) and curSeverTime <= DateUtil.getDateSecByStr(v.endDt) then
				state = true
			else
				state = false
			end
		end
		if state then
			table.insert(list,v)
		else
			RedManager.updateValue("V_HANDBOOK_NEW_HERO"..v.hero, false)
		end
	end
	return list
end
--设置卡牌(英雄)详情
function CardHandBookView:setCardsByCategory(category)
	self._cardCurCategory=category
	local categoryHeros = self:getTimeLimitHeros(category)
	self.curCategoryHeros = categoryHeros
	local configInfo=DynamicConfigData.t_hero
	self.cardStarkey={}
	self._cardInfoList = {}
	self.firstRedTag = false
	self.redIndex = false
	for _,v in pairs(categoryHeros) do
		local tag=1
		local heroId= v.hero
		local configHero=configInfo[heroId]
		if configHero then
			if  configHero.heroStar>=5 and configHero.skill4 and #configHero.skill4>0 then
				tag=1
			elseif  configHero.heroStar>=5 and configHero.skill4 and #configHero.skill4==0 then
				tag=2
			elseif configHero.heroStar==4 then
				tag=3
			elseif configHero.heroStar==3 then
				tag=4
			end
		end
		if HandbookModel.firstRedHero[heroId] then
			self.firstRedTag = tag
		end
		if not 	self._cardInfoList[tag] then
			self._cardInfoList[tag]={}
		end
		table.insert(self._cardInfoList[tag], v)	
	end
	for key, value in pairs(self._cardInfoList) do
		table.insert(self.cardStarkey, key)		
		TableUtil.sortByMap(value, {{key="id",asc=false}})
	end
	
	if self.firstRedTag then
		for i=1, #self._cardInfoList[self.firstRedTag] do
			if HandbookModel.firstRedHero[self._cardInfoList[self.firstRedTag][i].hero] then
				self.redIndex =  i
				break;
			end
		end
	end
	
	self._cardIconList:setNumItems(#self.cardStarkey);
	if self.firstRedTag then
		self._cardIconList:scrollToView(self.firstRedTag-1)
	end
	printTable(33,"3333333333333333333333333333",HandbookModel.firstRedHero)
	print(33,"setCardsByCategory",self.firstRedTag,self.redIndex)
end



function CardHandBookView:_enter()

end

function CardHandBookView:_exit()
	self._cardCurCategory=1
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		self.timer = false
	end
end

return CardHandBookView