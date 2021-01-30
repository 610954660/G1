--added by wyang
--卡牌作为道具展示
local HeroCellShow = class("HeroCellShow")
function HeroCellShow:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);

	self.headIcon= false
	self.img_frame= false
	self.img_quality= false
	self.img_category= false
	self.level=false
	self.starList=false
	self.frameBG=false
	self.grayCtrl = false
	self.cardStar = false
end


function HeroCellShow:init( ... )

	self.headIcon= self.view:getChildAutoType("img_icon")--头像框
	self.img_frame= self.view:getChildAutoType("img_frame")--星级框
	self.img_quality= self.view:getChildAutoType("img_quality")--星级框
	self.img_category= self.view:getChildAutoType("img_category")--星级框
	self.level = self.view:getChildAutoType("level")--等级
	self.num = self.view:getChildAutoType("num")
	local cardStar = self.view:getChild("cardStar")
	self.cardStar = BindManager.bindCardStar(cardStar)

end

--不扩展这个基础数据方法不然很难通用
function HeroCellShow:setBaseData(data)

	local heroStarInfo = DynamicConfigData.t_heroResource[data.star]
	
	self.img_category:setURL(PathConfiger.getCardCategory(data.category))
	
	self.img_quality:setURL(PathConfiger.getHeroShowFrameLine(data.star))
	self.img_frame:setURL(PathConfiger.getHeroShowFrame(data.star))
		
	self.headIcon:setURL(PathConfiger.getHeroOfMonsterIcon(data.heroId or  data.code, data.fashionId ))--放了卡牌头像
	
	self.level:setText(data.level..DescAuto[251]) -- [251]="级"
	self.cardStar:setData(data.star)
	self.num:setText(data.amount or "")
end

--直接设设置code的数据
function HeroCellShow:setData(data)
	self:setBaseData(data)
end


--退出操作 在close执行之前
function HeroCellShow:__onExit()
	print(1,"HeroCellShow __onExit")
end

return HeroCellShow
