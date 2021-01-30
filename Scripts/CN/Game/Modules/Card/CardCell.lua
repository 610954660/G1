--added by wyang
--卡牌封裝

local CardCell,Super = class("CardCell",BindView)
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"

function CardCell:ctor()
    self._packName = "CardSystem"
    self._compName = "CardCell"
    self.heroIcon= false
    self.qualityIcon= false
    self.imgCategory= false
    self.img_lvBg= false
    self.img_frame= false
    self.txt_level= false
    self.cardName= false
    self.txt_Fighting = false
    self.starImg = false
    self.cardStar = false
    self.statusCtrl = false
    self.categoryCtrl = false
    self._isSmall = false
    self._data =false
    self.frameSkeleton = false
    self.fiveStarSkeFlag = false
    self.grayCtrl = false
    self.img_battle = false
    self.img_uniqueWeapon = false
	self.showNameCtrl = false
end

function CardCell:_initUI()
    local obj = self.view
    self.img_battle= obj:getChildAutoType("img_battle") 
    self.heroIcon= obj:getChildAutoType("img_icon") 
    self.qualityIcon= obj:getChildAutoType("img_quality")
    self.imgCategory= obj:getChildAutoType("img_category")
    self.imgProfessional= obj:getChildAutoType("img_professional")
    self.img_frame= obj:getChildAutoType("img_frame")
    self.img_lvBg= obj:getChildAutoType("img_lvBg")
    self.txt_level= obj:getChildAutoType("txt_level")
    self.cardName= obj:getChildAutoType("txt_name")
    self.txt_Fighting= obj:getChildAutoType("txt_fighting")
    self.img_uniqueWeapon= obj:getChildAutoType("img_uniqueWeapon")
    self.statusCtrl = obj:getController("c1")
    self.runeCtrl = obj:getController("runeCtrl")
    self.categoryCtrl = obj:getController("showCategory")
    self.grayCtrl = obj:getController("grayCtrl")
    self.extraText = obj:getChildAutoType("extraText")
    self.txt_star=obj:getChild('txt_star');
    self.txt_star=obj:getChild('txt_star');
	self.showNameCtrl = obj:getController("showName") or false
    self.showMaskCtrl = obj:getController("showMask") or false
    local cardStar = obj:getChild("cardStar")
    self.cardStar = BindManager.bindCardStar(cardStar)
end

function CardCell:setSelected(seleted)
    if type(seleted) == "boolean"  then
        self.view:getController("c1"):setSelectedIndex(seleted and 2 or 1)
    else
        self.view:getController("c1"):setSelectedIndex(seleted)
    end
end

function CardCell:getSelected(seleted)
    return self.view:getController("c1"):getSelectedIndex() == 2
end

--设置灰化
function CardCell:setGrayed(isGray, noColor)
    if noColor then
        --之前设置过为true，然后图标变过后，再设会不起效，先设为false，再设置就有效了
        self.heroIcon:setGrayed(false)
        --self.imgCategory:setGrayed(false)
        self.img_frame:setGrayed(false)
        self.qualityIcon:setGrayed(false)
        
        self.heroIcon:setGrayed(isGray)
        --self.imgCategory:setGrayed(isGray)
        self.img_frame:setGrayed(isGray)
        self.qualityIcon:setGrayed(isGray)
    else
        self.view:getController("c1"):setSelectedIndex(isGray and 8 or 0)
    end
   
end

function CardCell:setRuneName(txt)
   if txt then
        self.runeCtrl:setSelectedIndex(1)
        if self.extraText then
        self.extraText:setText(txt)
        end 
   else
        self.runeCtrl:setSelectedIndex(0)
        if self.extraText then
        self.extraText:setText("")
        end 
   end
end



function CardCell:setFiveStarSkeFlag( flag )
    self.fiveStarSkeFlag = flag
end

function CardCell:setFrameSkeVisible( flag )
    if self.frameSkeleton then
        self.frameSkeleton:setVisible(flag)
    end
end

function CardCell:setIsNew( flag )
    local index = flag and 1 or 0
    if self.view:getController("isNewCtrl") then
        self.view:getController("isNewCtrl"):setSelectedIndex(index)
    end
end

--data 可以有三种格式
    --1、直接是heroid
    --2、带heroDataConfiger的，一般是服端传回来的结构
    --3、table {heroId = 10001, heroStar=5,level=3}
function CardCell:setData(data, isSmall)
    if self.frameSkeleton then
        self.frameSkeleton:removeFromParent()
        self.frameSkeleton = false
    end
    self._isSmall = isSmall and isSmall or false
    self._data = data
    if type(data) == "number" then
        local herItem = DynamicConfigData.t_hero[self._data]
        if not herItem then
            herItem =  DynamicConfigData.t_monster[self._data]
        end
        if(herItem) then
            self._data = herItem
            
            --这个只是配置
            self.imgCategory:setURL(PathConfiger.getCardCategory(self._data.category))--放了卡牌图片
            if isSmall then
                self.qualityIcon:setURL(PathConfiger.getHeroFrameLine(self._data.heroStar))
            else
                self.qualityIcon:setURL(PathConfiger.getCardQuaColor(self._data.heroStar))--放了卡牌图片
            end
            if self.img_frame then
                if(self._isSmall) then
                    self.img_frame:setURL(PathConfiger.getHeroFrame(self._data.heroStar))
                else
                    self.img_frame:setURL(PathConfiger.getCardQualitybg(self._data.heroStar))
                end
            end
            if(self._isSmall) then
                self.heroIcon:setURL(PathConfiger.getHeroCard(self._data.heroId))--放了卡牌图片				
            else
                self.heroIcon:setURL(PathConfiger.getHeroCardex(self._data.heroId))--放了卡牌图片
            end
            if self.img_battle then self.img_battle:setVisible(false) end
            self:setLevel(0)
            self.cardName:setText(string.format("%s",self._data.heroName));
            self:setStar(self._data.heroStar);
            self:setProfessional(self._data.professional)
			
			--self:updateUniqueWeapon()
        end
    elseif data.heroDataConfiger then
        --这个是服务端数据
        self._data = data.heroDataConfiger
        
        if isSmall then
            self.qualityIcon:setURL(PathConfiger.getHeroFrameLine(data.star))
        else	
            self.qualityIcon:setURL(PathConfiger.getCardQuaColor(data.star))--放了卡牌图片
        end
        if self.img_frame then
            if(self._isSmall) then
                self.img_frame:setURL(PathConfiger.getHeroFrame(data.star))
            else
                self.img_frame:setURL(PathConfiger.getCardQualitybg(data.star))
            end
        end
        local fashionId = data.fashion and data.fashion.code or false
        if(self._isSmall) then
           -- if fashionId then 
                self.heroIcon:setURL(PathConfiger.getHeroCard(self._data.heroId,fashionId))--放了卡牌图片               
           -- else
            --    self.heroIcon:setURL(PathConfiger.getHeroCard(self._data.heroId))--放了卡牌图片               
            --end

        else
             --if fashionId then 
                self.heroIcon:setURL(PathConfiger.getHeroCardex(self._data.heroId,fashionId))--放了卡牌图片 
            --else
            --    self.heroIcon:setURL(PathConfiger.getHeroCardex(self._data.heroId))--放了卡牌图片
            --end
        end
        self.imgCategory:setURL(PathConfiger.getCardCategory(self._data.category))--放了卡牌图片
        self:setProfessional(self._data.professional)
        self:setLevel(data.level)

        if self.cardName then
            self.cardName:setText(string.format("%s",self._data.heroName));
        end
        if self.img_battle then self.img_battle:setVisible(BattleModel:isInBattle(data.uuid,GameDef.BattleArrayType.Chapters)) end
        self:setStar(data.star);
		
		if self.img_uniqueWeapon then
			if self._data.uniqueWeapon and self._data.uniqueWeapon ~= "" and self._data.uniqueWeapon > 0 then
				self.img_uniqueWeapon:setURL(PathConfiger.getUniqueWeaponLevel(data.uniqueWeapon))
			else
				self.img_uniqueWeapon:setURL(nil)
			end
		end
			
    else
        --这个只是配置
        --self.heroIcon:setURL(PathConfiger.getHeroCardex(self._data.heroId))--放了卡牌图片
		
        local herItem = DynamicConfigData.t_hero[self._data.heroId]
        if not herItem then
            herItem =  DynamicConfigData.t_monster[self._data.heroId]
        end
        -- 是英雄卡的配置
        if herItem then
            if isSmall then
                self.qualityIcon:setURL(PathConfiger.getHeroFrameLine(self._data.heroStar))
            else	
                self.qualityIcon:setURL(PathConfiger.getCardQuaColor(self._data.heroStar))--放了卡牌图片
            end
			local fashionId = data.fashion and data.fashion.code or false
            if self.img_frame then
                if(self._isSmall) then
                    self.img_frame:setURL(PathConfiger.getHeroFrame(self._data.heroStar))
                else
                    self.img_frame:setURL(PathConfiger.getCardQualitybg(self._data.heroStar))
                end
                if self.fiveStarSkeFlag then
                    local aniStr = "fx_sr_a"
                    if self._data.heroStar == 4 then
                        aniStr = "fx_sr_a"
                        self.frameSkeleton = SpineUtil.createSpineObj(self.img_frame, vertex2(self.img_frame:getWidth()/2,self.img_frame:getHeight()/2), aniStr, "Spine/ui/chouka2", "fx_kapai", "fx_kapai",true)
                    elseif self._data.heroStar == 5 then
                        aniStr = "fx_ssr_a"
                        self.frameSkeleton = SpineUtil.createSpineObj(self.img_frame, vertex2(self.img_frame:getWidth()/2,self.img_frame:getHeight()/2), aniStr, "Spine/ui/chouka2", "fx_kapai", "fx_kapai",true)
                    end
                end
            end
            
            if(self._isSmall) then
                self.heroIcon:setURL(PathConfiger.getHeroCard(self._data.heroId, fashionId))--放了卡牌图片				
            else
                self.heroIcon:setURL(PathConfiger.getHeroCardex(self._data.heroId, fashionId))--放了卡牌图片
            end
            
                
            if self.img_battle then self.img_battle:setVisible(BattleModel:isInBattle(herItem.uuid, GameDef.BattleArrayType.Chapters)) end
            self.imgCategory:setURL(PathConfiger.getCardCategory(herItem.category))--放了卡牌图片
            self:setProfessional(self._data.professional)
            self:setLevel(self._data.level)
            if self.cardName then
                self.cardName:setText(string.format("%s",herItem.heroName));
            end
            
            self:setStar(self._data.heroStar);
        -- 是卡牌替身的配置
        elseif (data.category and data.star) then
            local conf = DynamicConfigData.t_BackstarItem[data.category][data.star];
            if (conf.id == data.code) then
                local iconUrl = ItemConfiger.getItemIconByCode(data.code, GameDef.GameResType.Item);
                self.heroIcon:setURL(iconUrl);
                self.imgCategory:setURL(PathConfiger.getCardCategory(data.category));
                self:setLevel(-1);
                self:setStar(data.star);
                self.img_frame:setURL(PathConfiger.getHeroFrame(data.star))
                self.cardName:setText(conf.name);
            end
        else
            if self.img_battle then self.img_battle:setVisible(false) end
            self.imgCategory:setURL("")--放了卡牌图片
            self:setLevel(-1)
            if self.cardName then
                self.cardName:setText("");
            end
            
            self:setStar(0);
        end
    end
    if self._isSmall then
        self:showMask(false)
    end
end

function CardCell:updateUniqueWeapon()
	if self.img_uniqueWeapon then
		if self._data.uniqueWeapon ~= "" and self._data.uniqueWeapon > 0 then
			self.img_uniqueWeapon:setURL(PathConfiger.getUniqueWeaponLevel(self._data.uniqueWeapon or self._data.uniqueWeaponLevel or -1))
		else
			self.img_uniqueWeapon:setURL(nil)
		end
	end
end
function CardCell:setCardNameVis(isShow)
    if isShow==nil then
        isShow=false
    end
	if self.showNameCtrl then
		self.showNameCtrl:setSelectedIndex(isShow and 1 or 0)
	else
		self.cardName:setVisible(isShow)
	end
end

function CardCell:equipment_uniqueWeapon(_,uuid)
	if self._data and uuid == self._data.uuid then
		self:updateUniqueWeapon()
	end
end

function CardCell:setLevel(level)
    if level and level >= 0 then
        if self.txt_level then 
            --if self._isSmall then
                self.txt_level:setText("Lv."..level); 
            --else
            ----	self.txt_level:setText(level); 
            --end
        end
        if self.img_lvBg then self.img_lvBg:setVisible(true) end
        local bg = self.view:getChildAutoType("n56")
        if bg then bg:setVisible(true) end;
    else
        if self.txt_level then self.txt_level:setText("") end
        if self.img_lvBg then self.img_lvBg:setVisible(false) end
        local bg = self.view:getChildAutoType("n56")
        if bg then bg:setVisible(false) end;
    end
end

--设置状态 0 正常 1可选择 2 已选择 3已分解 4出战中 5未激活
function CardCell:setStatus(status)
    self.statusCtrl:setSelectedIndex(status)
end

function CardCell:setStar(star)
    self.cardStar:setData(star)
end

--直接设置图标
function CardCell:setIcon(iconUrl)
    self.heroIcon:setURL(iconUrl)
end

--直接设置种族图标
function CardCell:setCategory(category)
    self.imgCategory:setURL(PathConfiger.getCardCategory(category))--设置种族图标
end

--直接设置是否显示种族图标
function CardCell:setShowCategory(show)
    self.categoryCtrl:setSelectedIndex(show and 0 or 1)
end
--设置职业图标
function CardCell:setProfessional(type)
    if self.imgProfessional then
        self.imgProfessional:setURL(PathConfiger.getCardProfessionalWhite(type))
    end
end

function CardCell:showMask(show)
    if self.showMaskCtrl then
        self.showMaskCtrl:setSelectedIndex(show and 1 or 0)
    end
end

function CardCell:_enter()

end

function CardCell:_exit()
    if self.frameSkeleton then
        SpineUtil.clearEffect(self.frameSkeleton)
        self.frameSkeleton = false
    end
end

return CardCell