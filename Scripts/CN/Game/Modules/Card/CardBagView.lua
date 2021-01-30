local  CardBagView,Super = class("CardBagView", Window)
local  UpdateDescription = require "Configs.Handwork.UpdateDescription"
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local ArrayName = require "Game.Consts.ArrayName"
function CardBagView:ctor()
	self._packName = "CardSystem"
	self._compName = "CardBagView"
	self._cardIconList=false
	self._cardLabelList=false
	self._cardNumber=false
	self.txt_num =false
	self.txt_maxNum =false
	self._cardZero=false
	self._cardDecompose=false
	self.btn_reset=false
	self.btn_back = false;
	self.btn_battleSet=false
	self.btn_handbook=false
	self._showParticle=true
	self.list_sortType = false;
	self.curSortType = 1;
	self._cardCategory = {0,1,2,3,4,5}
	self.schedulerArr = {}
	self.needEffect = true
	self._cardCurCategory=ModelManager.CardLibModel.cardBagCategory;
	self._willOpenInBattle=true --如果战斗中打开要减慢速度
end

function CardBagView:_initUI()
	--self:setBg("bg_cardInfo.jpg")
	local viewRoot = self.view
	self._cardLabelList=FGUIUtil.getChild(viewRoot,"list_cardType","GList")
	self._cardIconList=FGUIUtil.getChild(viewRoot,"n2","GList")
	
	self._cardIconList:setSelectedIndex(self._cardCurCategory)
	self._cardNumber=FGUIUtil.getChild(viewRoot,"txt_cardNum","GTextField")
	self.txt_num = viewRoot:getChildAutoType("txt_num")
	self.txt_maxNum = viewRoot:getChildAutoType("txt_maxNum")
	self._cardDecompose=viewRoot:getChild('btn_decompose');
	self.btn_battleSet=viewRoot:getChild('btn_battleSet');
	self.btn_reset=viewRoot:getChild('btn_reset');
	self.btn_back=viewRoot:getChildAutoType("btn_back");
	self.btn_handbook=viewRoot:getChild('btn_handbook');
	self.list_sortType=viewRoot:getChildAutoType("list_sortType");
	self._cardZero=viewRoot:getController('c1'); 
	self._args.page=self._args.page or 0
	self:setCardsByCategory(self._args.page)
	
	self._cardLabelList:setSelectedIndex(self._args.page)
	self._cardLabelList:regUnscrollItemClick(function (index,obj)
		local category = self._cardCategory[index + 1]
		self:setCardsByCategory(category)
	end)

	self.list_sortType:setSelectedIndex(0);
	self.list_sortType:addClickListener(function ()
		self.curSortType = self.list_sortType:getSelectedIndex() + 1;
		self:setCardList();
	end)
	
	self._cardLabelList:setItemRenderer(function(index,obj)
		local img_red = obj:getChildAutoType("img_red")
		RedManager.register("V_CardCategory"..index, img_red)
	end)
	
	local btn_closePic = self.view:getChild("btn_closePic")
	btn_closePic:addClickListener(function(...)
		cc.TextureCache:getInstance():setAliasTexParameters()
	end)
	
	self._cardLabelList:setNumItems(self._cardLabelList:getNumItems())
	local cardNumber=ModelManager.CardLibModel:getActivationCardNumber();
	local cardAllNumber= 200 + VipModel:getVipPrivilige(15);--#(DynamicConfigData.t_hero);
	--printTable(5,'yfyyfyyyy',cardNumber,cardAllNumber);
	self.txt_num:setText(cardNumber)
	--self.txt_num:setText(150)
	self.txt_maxNum:setText("/"..cardAllNumber)
	self._cardNumber:setText(Desc.card_DetailsStr13);
	if cardNumber==0 then
		self._cardZero:setSelectedIndex(1);
	else
		self._cardZero:setSelectedIndex(0);
	end

	self._cardDecompose:addClickListener(
		function (...)
			ViewManager.open('CardDetailsDecompose');
		end
	)

	self.btn_handbook:addClickListener(
		function (...)
			ViewManager.open('CardHandBookView');
		end
	)
	self.btn_reset:addClickListener(
		function (...)
			ViewManager.open('HeroResetView');
		end
	)

	self.btn_back:addClickListener(function ()
		ViewManager.open("ResetHeroView");
	end)
	
	self.btn_battleSet:addClickListener(
		function (...)
			if BattleModel:getRunArrayType() then
				RollTips.show(string.format(Desc.card_waitBattleEnd, ArrayName[BattleModel:getRunArrayType()]))
				return 
			end
			
			local fightID = DynamicConfigData.t_chaptersPoint[1][1][1].fightfd
			local cityId,chapterId,pointId  = ModelManager.PushMapModel:getCurCityAndrChapterAndLevel()
			local copyConfig=DynamicConfigData.t_chaptersPoint[cityId][chapterId];
			local guankaInfo=copyConfig[pointId];
				
			Dispatcher.dispatchEvent(EventType.battle_requestFunc,function(name)
				if (name == "begin") then
					RollTips.show(Desc.card_battleSaveSuc)
				else
					self:setCardList();
				end
				
		    end,{fightID=fightID,configType=GameDef.BattleArrayType.Chapters, chapterInfo=guankaInfo, isSetting = true})
			
			
			
			Dispatcher.dispatchEvent(EventType.battle_setBattleFunc, function (name)
					if (name == "begin") then
						RollTips.show(Desc.card_battleSaveSuc)
					else
						self:setCardList();
					end
			end,{configType=GameDef.BattleArrayType.ArenaDef});--布阵里面还有竞技场防守的消息要监听
			
			
		end
	)
	RedManager.register("V_HANDBOOK_NEW", self.btn_handbook:getChildAutoType("img_red"), ModuleId.Handbook.id )
	--GuideModel:checkGuideActivate("texing",ModuleId.CardTalent.id)
end

--设置卡牌展示
function CardBagView:setCardList()
	if tolua.isnull(self.view) then return end
	local cardNumber=ModelManager.CardLibModel:getActivationCardNumber();
	local cardAllNumber= '200';
	self.txt_num:setText(cardNumber)
	--self._cardNumber:setText(string.format("%s:%s",Desc.card_DetailsStr13,cardNumber.."/"..cardAllNumber));
	ModelManager.CardLibModel:setCardsByCategory(self._cardCurCategory)
	local CardList=ModelManager.CardLibModel:getHeroInfoToIndex(true, self.curSortType)
	
	self._cardIconList:addEventListener(FUIEventType.Scroll,function ( ... )
		self.needEffect = false
	end)
	
	self._cardIconList:setVirtual()
	self._cardIconList:setItemRenderer(function(index,obj)
		if index + 1 > #CardList then return end
		obj:setName(CardList[index+1].heroId)
		local cardItem = obj:getChildAutoType("cardItem")
		local btn_lock = obj:getChildAutoType("btn_lock")
		local btn_click = cardItem:getChildAutoType("btn_click")
		local btn_copyUuid = obj:getChildAutoType("btn_copyUuid")
		local btn_copyCode = obj:getChildAutoType("btn_copyCode")
		local img_red = cardItem:getChildAutoType("img_red")
		RedManager.register("V_Card"..CardList[index+1].uuid, img_red)
		
		if self.needEffect then
			local maxShow = #CardList < 12 and #CardList or 12
			local interTime = 0.5/maxShow
			if interTime >= 0.1 then
				interTime = 0.1
			end
			obj:setVisible(false)
			self.schedulerArr[index] = Scheduler.scheduleOnce(index*interTime, function( ... )
					if obj and  (not tolua.isnull(obj)) then
						obj:setVisible(true)
						obj:getTransition("t0"):play(function( ... )
						end);
					end
			end)
		end
		
			
		
		if not __IS_RELEASE__ then
			btn_copyUuid:setVisible(true)
			btn_copyCode:setVisible(true)
		end

		btn_copyUuid:removeClickListener()--池子里面原来的事件注销掉
		btn_copyUuid:addClickListener(function(context)
			gy.GYDeviceUtil:setClipboardStr(CardList[index+1].uuid.."")
			end)
		btn_copyCode:removeClickListener()--池子里面原来的事件注销掉
		btn_copyCode:addClickListener(function(context)
			gy.GYDeviceUtil:setClipboardStr(CardList[index+1].code.."")
			end)
				
		
			btn_click:removeClickListener()--池子里面原来的事件注销掉
			btn_click:addClickListener(function(context)
					--Dispatcher.dispatchEvent(EventType.hero_cardViewShowDetail)
					--printTable(8,">>>>>>>>>>>>>>11",CardList[index+1].uuid)	
					ModelManager.CardLibModel.curCardStepInfo = CardList[index+1]
					ModelManager.CardLibModel:setCarByPosInfo(CardList[index+1].code,CardList[index+1].uuid,index+1)
					Dispatcher.dispatchEvent(EventType.cardView_showDetial)
				end)
				
			local cardCell = BindManager.bindCardCell(cardItem)
			cardCell:setData(CardList[index+1])
			
		end
	)
	self._cardIconList:scrollToView(0)
	self._cardIconList:setNumItems(#CardList);
end

--设置卡牌(英雄)详情
function CardBagView:setCardsByCategory(category)
	
	self._cardCurCategory=category
	ModelManager.CardLibModel.cardBagCategory = category
		
	local CardslList
	--if(Category == 0) then
	--	CardslList = ModelManager.CardLibModel:getAllCards()
	--else
		ModelManager.CardLibModel:setCardsByCategory(category)
		CardslList=ModelManager.CardLibModel:getHeroInfoToIndex(true, self.curSortType)
	--end
	print(5,CardslList,"CardslList")
	self._cardIconList:scrollToView(0)
	self.needEffect = true
	self:setCardList(CardslList)--demo随机展示几个技能
end

function CardBagView:cardView_levelUpSuc(_,data)
	--[[local CardslList=ModelManager.CardLibModel:getHeroInfoToIndex()
	print(5,CardslList,"CardslList")--]]
	self:setCardList()--demo随机展示几个技能
end


function CardBagView:cardView_DecomposeSuc(_,data)--分解成功
	printTable(8, "卡牌分解请求返回刷新12")
	--[[local cardNumber=ModelManager.CardLibModel:getActivationCardNumber();
	local cardAllNumber= '200';--#(DynamicConfigData.t_hero);
	printTable(5,'yfyyfyyyy',cardNumber,cardAllNumber);
	self._cardNumber:setText(string.format("%s:%s",Desc.card_DetailsStr13,cardNumber.."/"..cardAllNumber));
	ModelManager.CardLibModel:setCardsByCategory(self._cardCurCategory)
	local CardslList=ModelManager.CardLibModel:getHeroInfoToIndex()--]]
	self:setCardList()--demo随机展示几个技能
end

function CardBagView:cardView_activeSkillSuc()
	--[[ModelManager.CardLibModel:setCardsByCategory(self._cardCurCategory)
	local CardslList=ModelManager.CardLibModel:getHeroInfoToIndex()
	print(5,CardslList,"CardslList")--]]
	self:setCardList()--demo随机展示几个技能
end

function CardBagView:cardView_updateInfo()
	self:setCardList()
end

function CardBagView:ResetHero_reset()
	self:setCardList()
end

function CardBagView:cardView_starUpSuc(_,data)
	printTable(5,"卡牌升星",data)
	if data then
	--local cardNumber=ModelManager.CardLibModel:getActivationCardNumber();
	--local cardAllNumber= '200';--#(DynamicConfigData.t_hero);
	--printTable(5,'yfyyfyyyy',cardNumber,cardAllNumber);
	--self._cardNumber:setText(Desc.card_DetailsStr13);
	
	ModelManager.CardLibModel:setCardsByCategory(self._cardCurCategory)
	local CardslList=ModelManager.CardLibModel:getHeroInfoToIndex(true, self.curSortType)
	print(5,CardslList,"CardslList")
	self:setCardList(CardslList)--demo随机展示几个技能
	end
end

function CardBagView:cardView_CardAddAndDeleInfo()
	self:setCardList()
end

function CardBagView:_enter()

end

function CardBagView:_exit()
	self._cardCurCategory=1
	
	for i,v in ipairs(self.schedulerArr) do
		if self.schedulerArr[i] then
        	Scheduler.unschedule(self.schedulerArr[i])
        	self.schedulerArr[i] = false
        end
	end
	BattleModel:updateGameSpeed()
end

return CardBagView