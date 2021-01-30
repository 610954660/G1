--added by wyang
--道具框封裝
local HeroCell = class("HeroCell")
function HeroCell:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);

	self.headIcon= false
	self.img_frame= false
	self.img_quality= false
	self.img_category= false
	self.img_uniqueWeapon = false
	self.level=false
	self.starList=false
	self.frameBG=false
	self.grayCtrl = false
	self.cardStar = false
	self.uuid=false
	self.code=false
end


function HeroCell:init( ... )

	self.headIcon= self.view:getChildAutoType("img_icon")--头像框
	self.img_frame= self.view:getChildAutoType("img_frame")--星级框
	self.img_quality= self.view:getChildAutoType("img_quality")--星级框
	self.img_category_frame = self.view:getChildAutoType("n49")--种族框底
	self.img_category= self.view:getChildAutoType("img_category")--种族框
	self.img_career= self.view:getChildAutoType("img_career")--职业框
	self.img_uniqueWeapon = self.view:getChildAutoType("img_uniqueWeapon")--专武图标
	self.level_frame = self.view:getChildAutoType("n56")--等级框
	self.level=self.view:getChildAutoType("level")--等级
	self.hpProgressBar=self.view:getChildAutoType("progressBar")
	self.npProgressBar=self.view:getChildAutoType("nqprogressBar")
	self.grayCtrl = self.view:getController("grayCtrl")
	local cardStar = self.view:getChild("cardStar")
	self.cardStar = BindManager.bindCardStar(cardStar)

end

--不扩展这个基础数据方法不然很难通用
function HeroCell:setBaseData(data)
	self.img_category_frame:setVisible(data ~= nil)
	self.img_category:setVisible(data ~= nil)
	self.level_frame:setVisible(data ~= nil)
	self.img_career:setVisible(data ~= nil)
	self.img_uniqueWeapon:setVisible(data ~= nil)
	self.level:setVisible(data ~= nil)
	--self.img_quality:setVisible(data ~= nil)
	self.headIcon:setVisible(data ~= nil)
	self.cardStar:setVisible(data ~= nil)
	

	if not data then
		self.img_frame:setURL(PathConfiger.getHeroFrame(0))
		return
	end
	if not data.star then
		data.star=1
	end
	local heroStarInfo = DynamicConfigData.t_heroResource[data.star]
	
	
	local professional=0
	local config =false
	

	
	if data.type and data.type==2 then
		config=DynamicConfigData.t_monster[data.code]--读怪物表的数据 monster_pro
		professional=config.monsterPro
	else
		config = DynamicConfigData.t_hero[data.code]
		if config then
			professional=config.professional
		end
	end
	
	

	
	
	
	
	local category = config and config.category or data.category;
	self.img_category:setURL(PathConfiger.getCardCategory(category))
	if config and self.img_career then self.img_career:setURL(PathConfiger.getCardProfessional(professional)) end
	
	if config and self.img_uniqueWeapon then self.img_uniqueWeapon:setURL(PathConfiger.getUniqueWeaponLevel(data.uniqueWeapon or data.uniqueWeaponLevel or -1)) end
	
	if (config and config.star) then
		self.img_quality:setURL(PathConfiger.getHeroFrameLine(config.star))
	end
	self.img_frame:setURL(PathConfiger.getHeroFrame(data.star))
	self.headIcon:setURL(PathConfiger.getHeroOfMonsterIcon(data.heroId or  data.code ,data.fashion or data.fashionId or data.fashionCode))--放了卡牌头像
	
	self.level:setText("Lv."..data.level)

	self.view:getController("grayCtrl"):setSelectedIndex(0)

	self.cardStar:setData(data.star)
	if data.uuid then
		self.uuid=data.uuid
	end
    if data.code then
    	self.code=data.code
    end
	
	local cleanCtrl= self.view:getController("empty")
	if cleanCtrl then
		cleanCtrl:setSelectedIndex(0)
	end
end

--直接设设置code的数据
function HeroCell:setData(data)
	-- printTable(1,"HeroCell:setData",data)
	self:setBaseData(data)
	--血条
	if not data then return end

	if data.hp and data.maxHp then
		self.hpProgressBar:setMax(data.maxHp)
		self.hpProgressBar:setValue(data.hp)
		self.view:getController("hadHPCtrl"):setSelectedIndex(1)
		if data.hp <=0 then
			self.grayCtrl:setSelectedIndex(1)
		end
	else
		self.view:getController("hadHPCtrl"):setSelectedIndex(0)
		self.grayCtrl:setSelectedIndex(0)
	end
	

	--是否雇佣
	if data.mirror and data.mirror>=1 then
		self.view:getController("mirrorCtrl"):setSelectedIndex(1)
	else
		self.view:getController("mirrorCtrl"):setSelectedIndex(0)
	end

end

function HeroCell:setEmptyData()
	-- printTable(1,"HeroCell:setData",data)
	local cleanCtrl= self.view:getController("empty")
	self.img_frame:setURL(PathConfiger.getHeroFrame(0))
	cleanCtrl:setSelectedIndex(1)
	self.headIcon:setVisible(true)
	self.headIcon:setURL(PathConfiger.getHeroCard(10000))--放个灰色头像

end

function HeroCell:setSelected(state)
	local ctrl = self.view:getController("state");
	ctrl:setSelectedIndex(state == true and 1 or 0);
end

--血条类型  0头像下面 1头像右边(竖向)
function HeroCell:showNp(np)
	self.view:getController("npCtrl"):setSelectedIndex(1)
	self.npProgressBar:setMax(DynamicConfigData.Const.BattleMaxRage)
	self.npProgressBar:setValue(np)
end

function HeroCell:setShowHp(isShow)
	self.view:getController("hadHPCtrl"):setSelectedIndex(isShow and 1 or 0)
end
--重新设置星级
function HeroCell:setStar(star)
	self.cardStar:setVisible(star ~= 0)
	self.cardStar:setData(star)
end
--退出操作 在close执行之前
function HeroCell:__onExit()
	print(1,"HeroCell __onExit")
end

return HeroCell