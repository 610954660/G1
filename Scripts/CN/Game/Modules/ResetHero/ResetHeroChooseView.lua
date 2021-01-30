-- add by zn
-- description
local CardChooseView = require("Game.Modules.Card.CardChooseView");
local ResetHeroChooseView, Super = class("ResetHeroChooseView", CardChooseView)

function ResetHeroChooseView:ctor()
	self._packName = "ResetHero";
	self._compName = "ResetHeroChooseView";
	self._maxStar = self._args and self._args.maxStar or false;
	self._minStar = self._args and self._args.minStar or false;
	local excludeStar = self._args and self._args.excludeStar or {};
	self.excludeStar = {}
	for _,v in pairs(excludeStar) do
		self.excludeStar[v] = 1
	end
end

function ResetHeroChooseView:_initUI()
	Super._initUI(self);
	local txt_none = self.view:getChildAutoType("txt_none");
	local str = Desc["ResetHero_chooseTips"..ResetHeroModel.resetType];
	txt_none:setText(str);
end

function ResetHeroChooseView:setCardsByCategory(Category)
	self.tempInfo = ModelManager.CardLibModel:getCardByCategory(Category, self.excludeUuidList, self._minStar, self._minLevel)
	if (#self.tempInfo > 0 and self._maxStar and self._maxStar > self._minStar) then
		local idx = 1;
		for i = 1, #self.tempInfo, 1 do
			if (idx > #self.tempInfo) then
				break;
			end
			local v = self.tempInfo[idx];
			local star = v.star
			if self.excludeStar[star] then
				table.remove(self.tempInfo, idx);
			elseif (star > self._maxStar) then
				table.remove(self.tempInfo, idx);
			elseif (star >= 19) then
				local starSegment = v.starSegment and v.starSegment[star] or false;
				local segment = starSegment and starSegment.starSegment or false;
				if (segment) then
					for i = 1, 4 do
						if (segment[i] and segment[i].isActivate) then
							table.remove(self.tempInfo, idx);
							break;
						end
					end 
				end
				idx = idx + 1;
			else
				idx = idx + 1;
			end
		end
		TableUtil.sortByMap(self.tempInfo, {{key="star",asc=true},{key="level",asc=true}})
	end
	local ctrl = self.view:getController("c1");
	if (#self.tempInfo == 0) then
		ctrl:setSelectedIndex(0);
	else
		ctrl:setSelectedIndex(1);
		self:setCardList()
	end
end

return ResetHeroChooseView