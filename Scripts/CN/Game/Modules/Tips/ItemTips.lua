--道具tips
--added by xhd
local ItemTips = class("ItemTips",View)
local ItemCell = require "Game.UI.Global.ItemCell"
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
function ItemTips:ctor( ... )
	self._packName = "ToolTip"
    self._compName = "ItemTipsView"
    self._rootDepth = self._args.rootDepth and self._args.rootDepth or  LayerDepth.Tips
	
	self.data = self._args
	self.codeType = self._args.codeType
	self.itemData = self._args.data
	self.winType = self._args.winType and self._args.winType or false
	
	self.viewListHead = false
	self.viewListMid = false
	self.viewListBottom = false
	self.viewListRight = false
	self.closeBtn = false
	self.tipsPanel = false
	self.img_bg = false
	
 
    
    self._isFullScreen = true
	
	--debug专用按钮
	self.debug_btns = false
	self.btn_add1 = false
	self.btn_add2 = false
	self.btn_add3 = false
	self.txt_itemCode = false
end

function ItemTips:init( ... )
	-- body
end


-- [子类重写] 初始化UI方法
function ItemTips:_initUI( ... )
	self.viewListHead = FGUIUtil.getChild(self.view,"viewListHead","GList")
	self.viewListMid = FGUIUtil.getChild(self.view,"viewListMid","GList")
	self.viewListRight = FGUIUtil.getChild(self.view,"viewListRight","GList")
	self.tipsPanel = self.view:getChildAutoType("tipsPanel") --分解
	self.closeBtn = self.view:getChildAutoType("closeBtn1")
	self.img_bg = self.view:getChildAutoType("img_bg")
	local type = self.codeType
	if type == CodeType.PASSIVE_SKILL then
		local config = DynamicConfigData.t_passiveSkill[self.itemData.id]
		self:addSkillHead()
		self:addDesc(Desc.itemtips_skillDesc, config.desc)
		if self.data.btnShow then
			self:addSkillBtns()
		end
	elseif type == CodeType.SKILL then
		self:addHeroSkillDesc()
		if self.data.btnShow then
			self:addSkillBtns()
		end
	elseif type == CodeType.GUIILD_SKILL then
		self:addGuildSkillDesc()
		if self.data.btnShow then
			self:addSkillBtns()
		end
	elseif type == CodeType.EQUIPMENT_SKILL then
		local config = DynamicConfigData.t_equipskill[self._args.id]
		self:addSkillHead()
		self:addDesc(Desc.itemtips_skillDesc, config.skillDesc)
	elseif type == CodeType.HALLOW_SKILL then
		self:addHallowSkillDesc()
	else
		local itemInfo = self.itemData:getItemInfo()
		if itemInfo.category == GameDef.Category.Normal or itemInfo.category == GameDef.Category.Special or itemInfo.category == GameDef.Category.HeroComponent
			or itemInfo.category == GameDef.Category.PveStarItem then
			self:addItemHead()
			if self.winType == "bag" then
				self:addBtnPanel()
			end
			if itemInfo.type == GameDef.ItemType.OptionalGiftGroup and self.winType ~= "bag" then
				self:addGiftList()
			elseif itemInfo.type == GameDef.ItemType.GiftBoxEx and self.winType ~= "bag" then 
				self:addDesc(Desc.itemtips_itemDesc, self.itemData:getDescStr(), itemInfo.effectEx )
			else
				self:addDesc(Desc.itemtips_itemDesc, self.itemData:getDescStr())
			end
			--27类型的物品道具要显示使用后的收益（收益是拿挂机实时的来算的）
			if itemInfo.type == 27 then
				local cityId = PushMapModel.curOnhookInfo.chapterCity or 1
				local chapterId = PushMapModel.curOnhookInfo.chapterPoint or 1
				local pointId = PushMapModel.curOnhookInfo.chapterLevel or 1
				local chapterInfo = DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
				if chapterInfo then
					local configInfo = DynamicConfigData.t_chaptersPointFightFd[chapterInfo.fightfd]
					local greward = configInfo.greward
					local gainStr = ""
					for _,v in ipairs(greward) do
						for _,configReward in ipairs(itemInfo.effectEx) do
							if v.type == configReward.type and v.code == configReward.code then
								gainStr = gainStr..   ItemConfiger.getItemNameByCode(v.code, v.type)..DescAuto[320]..StringUtil.transValue(v.amount * itemInfo.effect).."\n" -- [320]="："
							end
						end
					end
					self:addDesc(Desc.itemtips_itemGain, gainStr)
				end
			end
		elseif itemInfo.category == GameDef.Category.Rune then
			self:addItemHead()
			self:addRuneAttr()
			self:addDesc(Desc.itemtips_itemDesc, self.itemData:getDescStr())
		elseif itemInfo.category == GameDef.Category.Equipment then
			self:addEquipHead()
			self:addEquipAttr()
			self:addEquipSuitAttr()
			self:addEquipSkill()
			if self.winType == "bag" then
				self:addBtnPanel()
			end
			self:addDesc(Desc.itemtips_itemDesc, self.itemData:getDescStr())
		elseif itemInfo.category == GameDef.Category.Jewelry then
			printTable(2233, self.itemData:getUuid());
			self:addItemHead()
			-- self:addJewelryAttr();
			self:addDesc(Desc.itemtips_itemDesc, self.itemData:getDescStr())
		elseif itemInfo.category == 10 then
			self:addItemHead()
			self:addDesc(Desc.itemtips_itemDesc, self.itemData:getDescStr())
			self:addEmblemPre()
		else
			self:addItemHead()
			self:addDesc(Desc.itemtips_itemDesc, self.itemData:getDescStr())
		end
		if itemInfo.source then
			self:addItemFrom()
		end
	end

	self:updateSize()
	self.debug_btns = self.view:getChildAutoType("debug_btns")
	self.btn_add1 = self.view:getChildAutoType("btn_add1")
	self.btn_add2 = self.view:getChildAutoType("btn_add2")
	self.btn_add3 = self.view:getChildAutoType("btn_add3")
	self.txt_itemCode = self.view:getChildAutoType("txt_itemCode")
	
	--self:regOpenWay()
end

function ItemTips:changeCategory( idx,data)
	-- local config = self.itemData:geteEfectEx()
	-- local data ={}
	-- for i,v in ipairs(config) do
	--     if v.type == GameDef.GameResType.Hero then --卡牌英雄
	--     	local category = DynamicConfigData.t_hero[v.code].category
	--     	if idx == category then
	--     		table.insert(data,v)
	--     	end
	--     end
	-- end
	self.list:setData(data[idx])
end


--添加卡牌技能描述
function ItemTips:addHeroSkillDesc()
	local skillId = self.data.id
	
	local activeLv = self.data.activeLv or 1
	local skillidLv1 = self.data.id --1级技能id
	local skillIds = false  --技能多个等级的id
	local skillIndex = 0
	
	--local HeroConfiger:getSkillListByStep(step, hero)
	
	if self.data.heroId and self.data.heroId ~= 0  then
		local heroInfo = HeroConfiger.getHeroInfoByID(self.data.heroId)
		if heroInfo then
			--找出技能id落在哪个技能里
			for i = 1,4,1 do
				local skills = heroInfo["skill"..i]
				for lv,v in ipairs(skills) do
					if skillId == v then
						skillidLv1 = skills[1]
						skillIndex = i
						activeLv = lv--HeroConfiger.getSkillActiveStep(skillIndex, lv) --lv--HeroConfiger.getSkillActiveStep(i)
						skillIds = skills
						break
					end
				end
				if skillIds then break end
			end
		end
	end
	
	self.data.skillidLv1 = skillidLv1
	--if activeLv ~= 0 then
	self.data.activeLv = activeLv
	--end
	self:addSkillHead()
	
	local config = DynamicConfigData.t_skill[skillidLv1]
	local step = self.data.hero and self.data.hero.stage or 100
	local activeStep = HeroConfiger.getSkillActiveStep(skillIndex) 
	if activeStep <= step then
		self:addDesc(Desc.itemtips_skillDesc, config.showName)
	else
		local skillInfo = DynamicConfigData.t_skill[skillIds[1]]
		self:addDesc(Desc.itemtips_skillDesc, string.format(Desc.itemtips_skillDescNotActiveLv1, config.showName,activeStep ))
	end
	
	local descStr = ""
	local step = self.data.hero and self.data.hero.stage or 100
	if skillIds then
		for i = 2,#skillIds,1 do
			local activeStep = HeroConfiger.getSkillActiveStep(skillIndex, i)
			local skillInfo = DynamicConfigData.t_skill[skillIds[i]]
			
			if step >= activeStep then
				descStr = descStr..string.format(Desc.itemtips_skillDescActive, i, skillInfo.showName)
			else
				descStr = descStr..string.format(Desc.itemtips_skillDescNotActive, i, skillInfo.showName, skillInfo.unlock)
			end
			if i < #skillIds then
				descStr = descStr.."<br>"
			end
		end
		self:addDesc(DescAuto[321], descStr) -- [321]="技能升级"
	end
	
end

--添加公会技能描述
function ItemTips:addGuildSkillDesc()
	local guildId = self.data.guild
	local skillId = self.data.id
	local activeLv = 1
	local skillidLv1 = self.data.id --1级技能id
	local skillIds = false  --技能多个等级的id
	local skillIndex = 0
		local heroInfo = DynamicConfigData.t_guildPassiveSkill[guildId]
		if heroInfo then
			for i = 1,3,1 do
				local skills = heroInfo["skill"..i]
				for lv,v in ipairs(skills) do
					if skillId == v then
						skillidLv1 = skills[1]
						skillIndex = i
						activeLv = lv
						skillIds = skills
						break
					end
				end
				if skillIds then break end
			end
		end
	
	self.data.skillidLv1 = skillidLv1
	--if activeLv ~= 0 then
	self.data.activeLv = activeLv
	--end
	self:addSkillHead()
	GuildModel:setGuildSkillOpenLv()
	local config = DynamicConfigData.t_skill[skillidLv1]
	local step = GuildModel:getguildskillLevel(guildId)
	local activeStep =GuildModel:getGuildSkillOpenLv(skillidLv1) --GuildModel:curSkillIsJihuo(guildId,step,skillidLv1)
	printTable(31,"激活等级11111",activeStep)
	if activeStep <=step then
		self:addDesc(Desc.itemtips_skillDesc, config.showName)
	else
		self:addDesc(Desc.itemtips_skillDesc, string.format(Desc.itemtips_guildskillDescNotActiveLv1, config.showName,config.unlock ))
	end
	
	local descStr = ""
	if skillIds then
		for i = 2,#skillIds,1 do
			local skillInfo = DynamicConfigData.t_skill[skillIds[i]]
			local activeStep = GuildModel:getGuildSkillOpenLv(skillIds[i])-- GuildModel:curSkillIsJihuo(guildId,step,skillIds[i])
			printTable(31,"激活等级222222",activeStep)
			if activeStep<=step  then
				descStr = descStr..string.format(Desc.itemtips_skillDescActive, i, skillInfo.showName)
			else
				descStr = descStr..string.format(Desc.itemtips_skillDescNotActive, i, skillInfo.showName, skillInfo.unlock)
			end
			if i < #skillIds then
				descStr = descStr.."<br>"
			end
		end
		self:addDesc(DescAuto[321], descStr) -- [321]="技能升级"
	end
	
end

--添加圣器技能描述
function ItemTips:addHallowSkillDesc()
	-- local guildId = self.data.guild
	local skillId = self.data.id
	-- local activeLv = self.data.activeLv
	local skillIds = {}  --技能多个等级的id
	local skillIndex = 0
	local skillBase = skillId - skillId % 10;
	for i = 1, 3 do
		local id = skillBase + i
		if (id == skillId) then
			skillIndex = i;
		end
		table.insert(skillIds, id);
	end
	
	local skillidLv1 = skillIds[1] --1级技能id
	self:addSkillHead()
	local config = DynamicConfigData.t_skill[skillidLv1]
	local step = self.data.hallowLv
	local activeStep = HallowSysModel:getSkillOpenLv(skillId, self.data.hallowType)
	if activeStep <=step then
		self:addDesc(Desc.itemtips_skillDesc, config.showName)
	else
		self:addDesc(Desc.itemtips_skillDesc, string.format(Desc.itemtips_guildskillDescNotActiveLv1, config.showName,config.unlock ))
	end
	
	local descStr = ""
	if skillIds then
		for i = 2,#skillIds do
			local skillInfo = DynamicConfigData.t_skill[skillIds[i]]
			local activeStep = HallowSysModel:getSkillOpenLv(skillIds[i], self.data.hallowType)-- GuildModel:curSkillIsJihuo(guildId,step,skillIds[i])
			if activeStep<=step  then
				descStr = descStr..string.format(Desc.itemtips_skillDescActive, i, skillInfo.showName)
			else
				descStr = descStr..string.format(Desc.itemtips_skillDescNotActive, i, skillInfo.showName, skillInfo.unlock)
			end
			if i < #skillIds then
				descStr = descStr.."<br>"
			end
		end
		self:addDesc(DescAuto[321], descStr) -- [321]="技能升级"
	end
	
end

--添加物品头
function ItemTips:addItemHead()
	local ItemTipsItemHead = require "Game.Modules.Tips.ItemTipsItemHead"
	local head = ItemTipsItemHead.new({parent = self.viewListHead, data=self.itemData})
	head:toCreate()
end

function ItemTips:addEquipHead()
	local ItemTipsEquipHead = require "Game.Modules.Tips.ItemTipsEquipHead"
	local head = ItemTipsEquipHead.new({parent = self.viewListHead, data=self.itemData})
	head:toCreate()
end

function ItemTips:addSkillHead()
	local ItemTipsSkillHead = require "Game.Modules.Tips.ItemTipsSkillHead"
	local head = ItemTipsSkillHead.new({parent = self.viewListHead, data=self.data})
	head:toCreate()
end

function ItemTips:addEquipAttr()
	print(1,"addEquipAttr")
	local ItemTipsEquipAttr = require "Game.Modules.Tips.ItemTipsEquipAttr"
	local head = ItemTipsEquipAttr.new({parent = self.viewListMid, data=self.itemData})
	head:toCreate()
end

function ItemTips:addEquipSuitAttr()--套装属性
	print(1,"addEquipSuitAttr")
	local ItemTipsEquipSuitAttr = require "Game.Modules.Tips.ItemTipsEquipSuitAttr"
	local head = ItemTipsEquipSuitAttr.new({parent = self.viewListMid, data=self.itemData, winType = "itemTips"})
	head:toCreate()
end


function ItemTips:addRuneAttr()
	print(1,"addRuneAttr")
	local ItemTipsRuneAttr = require "Game.Modules.Tips.ItemTipsRuneAttr"
	local head = ItemTipsRuneAttr.new({parent = self.viewListMid, data=self.itemData})
	head:toCreate()
end

function ItemTips:addEquipSkill()
	local uuid = self.itemData:getUuid()
	local skilldata = EquipmentModel:getSkillData(uuid)
	if skilldata then
		local ItemTipsEquipSkill = require "Game.Modules.Tips.ItemTipsEquipSkill"
		local head = ItemTipsEquipSkill.new({parent = self.viewListMid, data=self.itemData})
		head:toCreate()
	end
end

function ItemTips:addItemFrom()
	local source = self.itemData:getItemInfo().source
	if source and #source > 0 then
		local ItemTipsItemFrom = require "Game.Modules.Tips.ItemTipsItemFrom"
		local head = ItemTipsItemFrom.new({parent = self.viewListMid, data=source})
		head:toCreate()
	end
end

-- function ItemTips:addJewelryHead()
-- 	local itemData = self.itemData.__data;
-- 	local uuid = self.itemData:getUuid()
-- 	if (not uuid) then
-- 		return;
-- 	elseif (not itemData.specialData) or (not itemData.specialData.jewelry) then
-- 		self.itemData = PackModel:getJewelryBag():getItemByUuid(self.itemData:getItemCode(), uuid)
-- 		itemData = self.itemData.__data;
-- 	end
-- 	local jewelryData = itemData.specialData.jewelry;
-- 	local data = jewelryData;
-- 	if data then
-- 		local ItemTipsJewelryHead = require "Game.Modules.Tips.ItemTipsJewelryHead"
-- 		local head = ItemTipsJewelryHead.new({parent = self.viewListHead, data=data})
-- 		head:toCreate()
-- 	end
-- end

function ItemTips: addJewelryAttr()
	local itemData = self.itemData.__data;
	local uuid = self.itemData:getUuid()
	if (not uuid) then
		return;
	elseif (not itemData.specialData) or (not itemData.specialData.jewelry) then
		self.itemData = PackModel:getJewelryBag():getItemByUuid(self.itemData:getItemCode(), uuid)
		itemData = self.itemData.__data;
	end
	local jewelryData = itemData.specialData.jewelry;
	local data = jewelryData;
	if data then
		local ItemTipsJewelryAttr = require "Game.Modules.Tips.ItemTipsJewelryAttr"
		local head = ItemTipsJewelryAttr.new({parent = self.viewListMid, data=data.attr})
		head:toCreate()
	end
end

function ItemTips:addDesc(title, desc, reward)
	local vieCls
	if reward then
		local ItemTipsDesc = require "Game.Modules.Tips.ItemTipsGiftBox"
		vieCls = ItemTipsDesc.new({parent = self.viewListMid, data={title = title, desc = desc, reward = reward}})
	else
		local ItemTipsDesc = require "Game.Modules.Tips.ItemTipsDesc"
		vieCls = ItemTipsDesc.new({parent = self.viewListMid, data={title = title, desc = desc}})
	end
	vieCls:toCreate()
end


function ItemTips:addGiftList()
	local ItemTipsGiftList = require "Game.Modules.Tips.ItemTipsGiftList"
	local vieCls = ItemTipsGiftList.new({parent = self.viewListMid, data=self.itemData})
	vieCls:toCreate()
end

function ItemTips:addBtnPanel()
	local ItemTipsBtnPanel = require "Game.Modules.Tips.ItemTipsBtnPanel"
	local vieCls = ItemTipsBtnPanel.new({parent = self.viewListRight, data=self.itemData})
	vieCls:toCreate()
end

function ItemTips:addSkillBtns( ... )
	local SkillTipsBtnPanel = require "Game.Modules.Tips.SkillTipsBtnPanel"
	local vieCls = SkillTipsBtnPanel.new({parent = self.viewListRight, data=self.data.id})
	vieCls:toCreate()
end

function ItemTips:addEmblemPre()
	local ItemTipsEmblemPre = require "Game.Modules.Tips.ItemTipsEmblemPre"
	local vieCls = ItemTipsEmblemPre.new({parent = self.viewListMid, data=self.itemData})
	vieCls:toCreate()
end

--根据列表高度决定是否需要滚动，然后做居中处理
function ItemTips:updateSize()
	
	self.viewListHead:resizeToFit(self.viewListHead:getNumItems()) --设置成头的高度
	self.viewListRight:resizeToFit(self.viewListRight:getNumItems())
	self.viewListMid:resizeToFit(self.viewListMid:getNumItems())
	
	if(self.viewListMid:getHeight() > 430) then
		self.viewListMid:setHeight(430)
	end
	
	if(self.viewListMid:getHeight() < 370) then
		self.viewListMid:setHeight(370)
	end

	local totalHeight = self.viewListHead:getHeight() + self.viewListMid:getHeight() + 20
	self.tipsPanel:setPosition(self.tipsPanel:getPosition().x, (720 -totalHeight)/2 )
end

-- [子类重写] 准备事件
function ItemTips:_initEvent( ... )
    self.closeBtn:addClickListener(function ( ... )
		ViewManager.close("ItemTips")
	end)

	if(not __IS_RELEASE__ and self.itemData and self.itemData.__data) then
		self.txt_itemCode:setText(self.itemData.__data.code)
		self.debug_btns:setVisible(true)
		self.btn_add1:addClickListener(function ( ... )
			local temp={3,1,1,1};
			temp[2] = self.itemData.__data.code;
			temp[3] = 1;
			temp['type']=1;
			ModelManager.CardLibModel:sendProtocol(temp)
		end)
		self.btn_add2:addClickListener(function ( ... )
			local temp={3,1,1,1};
			temp[2] = self.itemData.__data.code;
			temp[3] = 10;
			temp['type']=1;
			ModelManager.CardLibModel:sendProtocol(temp)
		end)
		self.btn_add3:addClickListener(function ( ... )
			local temp={3,1,1,1};
			temp[2] = self.itemData.__data.code;
			temp[3] = 1000;
			temp['type']=1;
			ModelManager.CardLibModel:sendProtocol(temp)
		end)
	else
		self.debug_btns:setVisible(false)
	end
end 

--想加个点击穿透的，ue又说不要了，代码先保留吧
function ItemTips:regOpenWay()
	--local view = ViewManager.getParentLayer(LayerDepth.UIEffect)
	--local layer = cc.Layer:create()
	--view:displayObject():addChild(layer)
	
	local obj = self.view:displayObject()
	local pos = self.img_bg:getPosition()
	local rect = cc.rect(pos.x, pos.y, self.img_bg:getWidth(), self.img_bg:getHeight())

	local function checkTouch(point)
		--if cc.rectContainsPoint(rect,cc.p(point.x, 720- point.y)) then
			return true
		--end
		--return false
	end
	
--	local rectArr = {cc.rect(0, display.height-100, 100, 100),cc.rect(0, display.height-100, 100, 100)
	--[[	,cc.rect(display.width-100, 0, 100, 100),cc.rect(display.width-100, 0, 100, 100),cc.rect(display.width-100, display.height-100, 100, 100),cc.rect(0, display.height-100, 100, 100)}
	local clickStep = 1
	local beginPos = false
	local checkIng = false--]]
	
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(function (touch,event)
		print(69, "click")
		local point = touch:getLocation()
		if checkTouch(point) then
			ViewManager.close("ItemTips")
		end
--			DeviceUtil.screenPowerCheckUpdate()
--			local point = touch:getLocation()
			--printTable(33,"touch begin = ",point)
--			if checkTouch(point,rectArr[clickStep]) then
--				print(69,"click = ")
				--[[clickStep = clickStep + 1
				if clickStep > #rectArr then
					beginPos = point
					checkIng = true
					clickStep = 1
					print(33,"move begin = ",clickStep)
					return true
				end--]]
--			else
--				clickStep = 1
--			end
			
--			checkIng = false
--			return false
		end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function (touch,event)
			--[[local point = touch:getLocation()
			if checkIng and beginPos.x-5 <= point.x and beginPos.y+5 >= point.y then
				beginPos = point
			else
				checkIng = false
			end--]]
			--print(33,"checkIng = ",checkIng,beginPos.x,beginPos.y,point.x,point.y)
		end, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(function (touch,event)
			--[[local point = touch:getLocation()
			--printTable(33,"touch end = ",point)
			
			if checkIng and checkTouch(point,rectArr[3]) then
				GMView.staticCall("open")
			end
			clickStep = 1--]]
		end, cc.Handler.EVENT_TOUCH_ENDED)
	obj:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, obj)
	
end

-- [子类重写] 添加后执行
function ItemTips:_enter()
end

-- [子类重写] 移除后执行
function ItemTips:_exit()
end


return ItemTips
