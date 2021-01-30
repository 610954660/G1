--added by wyang
--道具框封裝
--local CardStar = class("CardStar")
local CardStar,Super = class("CardStar",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local maxInterTime = 1
local lastInterTime = 0.5
function CardStar:ctor(view)
	self.txt_star = false
	self.list_star = false
	self.starCtrl = false
	self.starNum = false
	
	self.starImg = false
	self.aniFlag = false
	self.schedulerArr = {}
end


function CardStar:_initUI( ... )
	self.starCtrl = self.view:getController("star")
	self.txt_star = self.view:getChildAutoType("txt_star")
	self.list_star = self.view:getChildAutoType("list_star")
	self.list_star:setItemRenderer(function(index,obj)
		if self.aniFlag then
			-- local interTime = maxInterTime/self.starNum
			-- if interTime >= lastInterTime then
			-- 	interTime = lastInterTime
			-- end
			local interTime = 0.1
			obj:setVisible(false)
			self.schedulerArr[index] = Scheduler.scheduleOnce(index*interTime, function( ... )
					if obj and  (not tolua.isnull(obj)) then
						obj:setVisible(true)
						obj:getTransition("t0"):play(function( ... )
							local ui_xingxing_chuxian =  SpineUtil.createSpineObj(obj, vertex2(23,25), "ui_xingxing_chuxian", "Spine/ui/chouka", "jixiyou_texiao", "jixiyou_texiao",false)
						end);
					end
			end)
		end
		obj:removeClickListener()--池子里面原来的事件注销掉
		local starIcon= obj:getChild("img_star");
		starIcon:setURL(PathConfiger.getCardStar(self.starImg))--放了卡牌图片
		end
	)
end

--直接设设置code的数据
function CardStar:setData(star,starImg)
	if not star then return end
	local starNum = 0
	if star <= 5 then
		starNum = star
		if starImg then
			self.starImg = starImg
		else
			self.starImg = 1
		end
		self.starCtrl:setSelectedIndex(1)
	elseif star <= 9 then
		starNum = star - 5
		self.starImg = 2
		self.starCtrl:setSelectedIndex(1)
	else
		starNum = star - 10
		self.starCtrl:setSelectedIndex(0) 
		if self.txt_star then self.txt_star:setText(starNum > 0 and starNum or "") end
	end
	self.starNum = starNum
	self.list_star:setNumItems(starNum)--设置卡牌的星级
end

function CardStar:setAniFlag( type )
	self.aniFlag = type
end


--退出操作 在close执行之前 
function CardStar:_onExit()
	print(1,"CardStar __onExit")
	for i,v in ipairs(self.schedulerArr) do
		if self.schedulerArr[i] then
        	Scheduler.unschedule(self.schedulerArr[i])
        	self.schedulerArr[i] = false
        end
	end
end

return CardStar