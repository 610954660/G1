--快速挂机
local PushMapQuickOnhookView,Super = class("PushMapQuickOnhookView", Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
function PushMapQuickOnhookView:ctor()
	LuaLogE("PushMapQuickOnhookView ctor")
	self._packName = "PushMap"
	self._compName = "PushMapQuickOnhookView"
	self._rootDepth = LayerDepth.PopWindow
	self.Btn_agglutination= false
	self.Btn_free= false
	self.Btn_gray = false
	self.vip_tips = false;
	self.vip_goto = false;
	self.img_ani=false;
	self.nextDianjiAnima=false
end


function PushMapQuickOnhookView:_initUI()
	LuaLogE("PushMapQuickOnhookView _initUI")
	local agglutination= self.view:getChildAutoType("Btn_agglutination")
	self.Btn_free= self.view:getChildAutoType("Btn_free")
	self.Btn_gray = self.view:getChildAutoType("btn_gray")
	self.vip_tips = self.view:getChildAutoType("vip_tips");
	self.vip_goto = self.view:getChildAutoType("vip_goto");
	self.img_ani= self.view:getChildAutoType("img_ani")
	self.Btn_agglutination = BindManager.bindCostButton(agglutination)
	
	self:PriviligeGift_upGiftData(false);
	self:showJiantou()
end

function PushMapQuickOnhookView:showJiantou()
	if not self.nextDianjiAnima then
		printTable(152,"2222222222222")
		self.nextDianjiAnima=PushMapModel:getNextBtnAnim(self.img_ani)
		self.nextDianjiAnima:setScale(0.6)
	end
end

function PushMapQuickOnhookView:upViewInfo()
	local txt_remine = self.view:getChildAutoType("txt_remine")
	local times = self.view:getChildAutoType("times")
	local gCtr=self.view:getController("c1")
	local txt_reTimeDec = self.view:getChildAutoType("txt_reTimeDec")

	local isFree = self._args.usrFreeTimes - self._args.freeTimes 	-- 免费次数
	local isNoFree = self._args.usrPayTimes - self._args.payTimes 	-- 付费次数
	isFree = isFree > 0 and isFree or 0
	isNoFree = isNoFree > 0 and isNoFree or 0

	if isFree > 0 then
		gCtr:setSelectedIndex(0)
		txt_reTimeDec:setText(Desc.PushMapQuickOnhook_reTimeFreeDec)
		times:setText(isFree)
	elseif isNoFree > 0 then 
		gCtr:setSelectedIndex(1)
		txt_reTimeDec:setText(Desc.PushMapQuickOnhook_reTimeNoFreeDec)
		times:setText(isNoFree)
		-- local count  = PushMapModel.pushMaponHookInfo.fastCount
		local conf = DynamicConfigData.t_chapterSpeed
		local times = math.min(self._args.payTimes + 1, #conf)
		local config =	conf[times]
		-- if not config then
		-- 	config=DynamicConfigData.t_chapterSpeed[self._args.payTimes]
		-- end
		local _cost = {type =CodeType.MONEY, code = 2, amount = config.diamonds }
		self.Btn_agglutination:setData(_cost)
	else
		gCtr:setSelectedIndex(2)
		-- self.Btn_gray:setTouchable(false)
		-- self.Btn_gray:getController("button"):setSelectedIndex(2)
		times:setText(isNoFree)
	end

	local curTime = ServerTimeModel:getServerTime()
	local dayTime=  TimeLib.GetDateStamp(curTime *1000) /1000
	local day = 60*60*24
	local difference = dayTime+day - curTime
	printTable(9,'>>>>>>>>>>>>>>>>',curTime,dayTime,difference)
	local hstr = math.floor(difference/(60*60)) 
	local mstr = math.floor(difference/60)%60
	local sstr = math.floor(difference%60)
	txt_remine:setText(Desc.pushmap_ningjutime:format(hstr,mstr,sstr))
end

function  PushMapQuickOnhookView:getReward()
	local greward={}
	local cityId=PushMapModel.curOnhookInfo.chapterCity or 1;
	local chapterId=PushMapModel.curOnhookInfo.chapterPoint or 1;
	local pointId=PushMapModel.curOnhookInfo.chapterLevel or 1;
	local chapterInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId];
	if not chapterInfo then
		return greward
	end
	local configInfo= DynamicConfigData.t_chaptersPointFightFd[chapterInfo.fightfd];
	if not configInfo then
		return greward
	end
	 greward= configInfo.greward
	 return greward
end

--UI初始化
function PushMapQuickOnhookView:_initEvent(...)
	self.Btn_agglutination:addClickListener(
		function(...)
			local configRewardInfo=self:getReward()
			local amount=0
			for key, value in pairs(configRewardInfo) do
				if value.type==2 and value.code==9 then
					amount=value.amount
				end
			end 
			printTable(16,">>>>>sdfwe",amount)
			local max=DelegateModel:beyondPointMax(amount*120)
			if max==false then
				PushMapModel:FastBattle() 
				self:closeView()
			else
				local info = {}
				info.text = string.format(Desc.pushmap_str3,max)
				info.type = "yes_no"
				info.mask = true
				info.yesText = Desc.pushmap_str4;
				info.noText = Desc.pushmap_str5;
				info.onYes = function()
					PushMapModel:FastBattle() 
					self:closeView()
				end
				info.onNo = function ()
					ModuleUtil.openModule(ModuleId.Delegate, true);
				end
				Alert.show(info)
			end 
        end
	)
	self.Btn_free:addClickListener(
		function(...)
			local configRewardInfo=self:getReward()
			local amount=0
			for key, value in pairs(configRewardInfo) do
				if value.type==2 and value.code==9 then
					amount=value.amount
				end
			end 
			local max=DelegateModel:beyondPointMax(amount*120)
			if max==false then
				PushMapModel:FastBattle() 
				self:closeView()
			else
				local info = {}
				info.text = string.format(Desc.pushmap_str3,max)
				info.type = "yes_no"
				info.mask = true
				info.yesText = Desc.pushmap_str4;
				info.noText = Desc.pushmap_str5;
				info.onYes = function()
					PushMapModel:FastBattle() 
					self:closeView()
				end
				info.onNo = function ()
					ModuleUtil.openModule(ModuleId.Delegate, true);
				end
				Alert.show(info)
			end 
        end
	)

	self.Btn_gray:addClickListener(
        function(...)
			ModuleUtil.openModule(ModuleId.Vip.id)
        end
	)

end

-- 更新免费次数
function PushMapQuickOnhookView: PriviligeGift_upGiftData(refreshData)
	local ctrl = self.view:getController("vip");
	if (not PriviligeGiftModel:getPriviligeGift(1)) then
		ctrl:setSelectedIndex(1);
		local conf = DynamicConfigData.t_Privilige[1];
		local free = conf and conf.count1+1 or 0;
		local buy = conf and conf.count2 or 0;
		self.vip_tips:setText(string.format(Desc.PushMapQuickOnhook_vipTips, free, buy));
		self.vip_goto:removeClickListener(222);
		self.vip_goto:addClickListener(function ()
			ModuleUtil.openModule(ModuleId.PriviligeGiftView, true);
		end,222)
	else
		ctrl:setSelectedIndex(0);
	end

	refreshData = refreshData == nil and refreshData or true;
	if (refreshData) then
		RPCReq.Chapters_GetFastTimes({},function(args)
			self._args = args;
			if tolua.isnull(self.view) then return end
			self:upViewInfo();
		end)
	else
		self:upViewInfo();
	end
end

--页面退出时执行
function PushMapQuickOnhookView:_exit( ... )
    SpineUtil.clearEffect(self.nextDianjiAnima)   
end

return PushMapQuickOnhookView