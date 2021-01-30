local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
---@class RollTips
local RollTips = {}
----@param args {
-- text:string,  本文描述 必填
-- }

local rollTipsView  = {}
local flyRewardList={}
local _alertPushMapIconView=false
function RollTips.show(text,time,depth)
	if not text or text == "" then return end
	local args = {}
	args.id = UIDUtil:getUID()
	args.className = "RollTipsView"
	args.viewName = args.className .. args.id
	args.text = text
	args.time = time
	args._rootDepth = depth
	local view = ViewManager.open(args.viewName, args)
	for k,view in pairs(rollTipsView) do
		if not tolua.isnull(view) then
			view:displayObject():runAction(cc.MoveBy:create(0.2,cc.p(0,50)))
		else
			rollTipsView[k] = nil
		end
	end
	rollTipsView[args.viewName] = view.view
end

function RollTips.showError(errorTable)
	if errorTable.repErrorStr then
		local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
		local errInfo =GameDef.ErrorCodeDict[tonumber(errorTable.repError)];
		if errorTable.repError==123 then--后端说这个code需要转换
			local baseInfo =ItemConfiger.getInfoByCode(tonumber(errorTable.repErrorStr));
			if baseInfo and errInfo then
				RollTips.show(baseInfo.name..errInfo.desc);
			else
				RollTips.show(errorTable.repErrorStr);
			end
		else
			local res = string.gsub(errInfo.desc, "%%s",errorTable.repErrorStr )
			RollTips.show(res);
		end
	elseif GameDef.ErrorCodeDict[errorTable.repError] then
		RollTips.show(GameDef.ErrorCodeDict[errorTable.repError].desc)
	else
		RollTips.show("erroe code = "..errorTable.repError)
	end
end

--一次显示多行提示
function RollTips.showTipsList(msgList)
	--[[for _,v in ipairs(msgList) do
		RollTips.show(v)
	end--]]
	
	
	local viewInfo = ViewManager.getViewInfo("RollTipsListView")
	if viewInfo then
		viewInfo.window:addMsgList(msgList)
	else
		ViewManager.open("RollTipsListView", msgList)
	end
	
end


function RollTips.showTipsGetRewardList(msgList)
	local viewInfo = ViewManager.getViewInfo("RollTipsGetRewardListView")
	if viewInfo then
		viewInfo.window:addMsgList(msgList)
	else
		ViewManager.open("RollTipsGetRewardListView", msgList)
	end
end

--显示帮助窗口
function RollTips.showHelp(title, desc)
	local args = {}
	args.title = title
	if title == "" then
		args.title = Desc.help_defaultTitle
	end
	args.desc = desc
	ViewManager.open("GetPublicHelpView", args)
end

--显示图片帮助窗口
--fromPos 从哪个位置开始zoomin
function RollTips.showPicHelp(picUrl, fromPos)
	local args = {}
	args.picUrl = picUrl
	args.fromPos = fromPos
	ViewManager.open("PublicPicHelpPanel", args)
end



--显示图片帮助窗口
--fromPos 从哪个位置开始zoomin
function RollTips.showRateTips(rateData)
	ViewManager.open("PublicRateTipsView", rateData)
end

--显示网页窗口
function RollTips.showWebPage(title, url)
	local args = {}
	args.title = title
	args.url = url
	ViewManager.open("WebPageView", args)
end

--显示获得奖励窗口
function RollTips.showReward(reward, closeCallBack, autoCloseTime, isShow, exParam)
	--如果奖励里面有时装的，那么先用获得英雄的特效显示时装，然后再显示其他奖励
	local rewardList = {}
	local fashionList = {}
	for _,v in ipairs(reward) do
		if v.type == CodeType.ITEM then
			local config = ItemConfiger.getInfoByCode(v.code)
			if config.type == GameDef.ItemType.Fashion then
				table.insert(fashionList, v)
			else
				table.insert(rewardList, v)
			end
		else
			table.insert(rewardList, v)
		end
	end
	local onFashionShowClose
	
	onFashionShowClose = function()
		if #fashionList > 0 then
			local config = ItemConfiger.getInfoByCode(fashionList[1].code)
			local fashion = DynamicConfigData.t_Fashion[math.floor(config.effect/ 1000)][config.effect]
			--ViewManager.open("GetHeroCardShowView",{data = {code = fashion.heroCode, isNew = false, fashionCode = config.code, closeCallback = onFashionShowClose},speFlag= true})
			ViewManager.open("GetFshionShowView",{code = fashion.heroCode, fashionCode = config.code, closeCallback = onFashionShowClose})
			table.remove(fashionList, 1)
		else
			if #rewardList > 0 then
				local data = exParam or {}
				data.reward = rewardList
				data.autoCloseTime = autoCloseTime
				data.closeCallBack = closeCallBack
				if TableUtil.GetTableLen(rewardList) ~= 0 then
					ViewManager.open("AwardShowView",data);
				end
			end
		end
	end
	
	onFashionShowClose()
end

--显示战力提升
function RollTips.showAddFightPoint(addNum, isCenter)
	if addNum == 0 then return end
	local data = {
		addNum = addNum,
		pos = isCenter and "center" or "left"
	}
	--local viewInfo = ViewManager.getViewInfo("FightPointAddView")
	--if viewInfo then
		--viewInfo.window:show(0, addNum)
	--else
		ViewManager.open("FightPointAddView",data);
	--end
end


--显示属性改变飘字
function RollTips.showAttrTips(oldAttr, newAttr)
	local tipsList = {}
	for key,v in pairs(newAttr) do
		local oldValue = oldAttr[key] and oldAttr[key].value or 0
		local newValue = v.value
		local addNum = newValue - oldValue
		local str = Desc["common_fightAttr"..key]
		if not str then
			print(1, "卡牌属性名称没找到 key="..key)
		else
			str = str.."  "
			--这里等于0的时候不显示
			if addNum > 0 then
				str = {str, "+"..addNum}
				table.insert(tipsList, str)
			elseif addNum < 0 then
				str = {str, ""..addNum}
				table.insert(tipsList, str)
			end
		end
	end
	if #tipsList > 0 then
		RollTips.showTipsList(tipsList)
	end
end


-- function RollTips.showCohesionRewardView(data)
-- 	CohesionRewardView.new():show(data)
-- end

function RollTips.showCohesionRewardView(data)
	--  local data = {
    --    leftLevelName = "",
    --    rightLevelName = "",
    --    rewardList = {
    --        {{type=2,code=2,amount=200,}, {type=2,code=2,amount=200,}},
    --        {{type=2,code=2,amount=200,}, {type=2,code=2,amount=200,}},
    --        {{type=2,code=2,amount=200,}, {type=2,code=2,amount=200,}},
    --    }
    -- }
	if data then
		ViewManager.open("CohesionRewardView",{reward=data})
	end
	--CohesionRewardView.new():show(data)
end

--经验、金钱动画
function RollTips.flyMoney(type, code, num, fromTarget)
	local fromPos = fromTarget;
	printTable(26,"转换之后的位置>>>>>>>>>",fromPos) 
	local target
	local mainUIView = ViewManager.getView("MainUIView")
	if type == 2 and  code==1  then--金币
		local moneyComp = mainUIView.view:getChild("moneyComp"):getChild("list_money")
		target = moneyComp:getChildAt(moneyComp:numChildren() - 2):getChild("icon")
	elseif type == 2 and  code==2  then--钻石
		local moneyComp = mainUIView.view:getChild("moneyComp"):getChild("list_money")
		target = moneyComp:getChildAt(moneyComp:numChildren() - 1):getChild("icon")
	elseif type == 1 then 
		target = mainUIView.view:getChild("avatar"):getChild("playerIcon")
	end
	
	local packPos = target:getPosition()
	packPos.x = packPos.x - 20
	packPos.y = packPos.y - 20
	local packPos = target:getParent():localToGlobal({x = packPos.x, y = packPos.y})
	local items = {}
	if num>=15 then
		num=15
	end
	local scale=0.25
	for i = 1,num,1 do
		local icon = fgui.GLoader:create()
		local url = ItemConfiger.getItemIconByCode(code, type)
		icon:setScale(scale,scale)
		icon:displayObject():setAnchorPoint(0.5,0.5)
		icon:setURL(url)
		local parentObj = ViewManager.getParentLayer(LayerDepth.Tips)
		local pos = parentObj:globalToLocal(fromPos)
		parentObj:addChild(icon)
		icon:setPosition(pos.x, pos.y+70)
		
		table.insert(items, icon)
	end
	
	for k,icon in ipairs(items) do
		local onComplete = function()
			if not tolua.isnull(icon) then
				icon:getParent():removeChild(icon)
			end
			--TweenUtil.to(bagBtn, {x = packPos.y - 5, time = 0.1})
		end
		local randomX = math.ceil(math.random() * 150) + fromPos.x - 75
		local randomY = math.ceil(math.random() * 150) + fromPos.y - 75
		TweenUtil.to(icon, {x = randomX, y = randomY, time = 0.3, onComplete = function()
			local randomTime=0.5 + math.random() * 1
			TweenUtil.to(icon, {x = packPos.x, y = packPos.y, time = randomTime, onComplete = onComplete,ease = EaseType.SineIn})
		--TweenUtil.scaleTo(icon, {from = {x = scale, y = scale}, to = {x = 0, y =0}, time = randomTime, ease = EaseType.QuadIn})
		end,ease = EaseType.SineOut})
	end
end

-- --物品飞到背包动画
-- function RollTips.flyReward(rewardList, fromTarget)
-- 	local fromPos = fromTarget:getParent():localToGlobal(fromTarget:getPosition())
-- 	local mainUIView = ViewManager.getView("MainUIView")
-- 	local bagBtn = mainUIView.bagBtn
-- 	local packPos = bagBtn:getPosition()
-- 	local packPos = bagBtn:getParent():localToGlobal({x = packPos.x + bagBtn:getWidth()/2, y = packPos.y})
-- 	local items = {}
-- 	for _,reward in ipairs(rewardList) do
-- 		if reward.amount > 0 then
-- 			local icon = fgui.GLoader:create()
-- 			local url = ItemConfiger.getItemIconByCode(reward.code)
-- 			icon:setURL(url)
-- 			icon:setScale(0.5,0.5)
			
-- 			local parentObj = ViewManager.getParentLayer(LayerDepth.Tips)
-- 			parentObj:addChild(icon)
			
-- 			icon:setPosition(fromPos.x, fromPos.y+70)
			
-- 			table.insert(items, icon)
-- 		end
-- 	end
	
-- 	for k,icon in ipairs(items) do
-- 		local onComplete = function()
-- 			if not tolua.isnull(icon) then
-- 				icon:getParent():removeChild(icon)
-- 			end
-- 			--TweenUtil.to(bagBtn, {x = packPos.y - 5, time = 0.1})
-- 		end
-- 		TweenUtil.to(icon, {x = packPos.x, y = packPos.y, time = 0.5 + k*0.2, onComplete = onComplete, ease = EaseType.BackIn})
-- 	end
-- end
function  RollTips.getflyRewardAndPos(rewardList,listObj,listPos)
	local rewardItem={}
	local rewardItemAmount={}
	local tag=0--1传位置 2传列表需要页面不关闭
	if listPos then
		tag=1
	end
	for key, info in pairs(rewardList) do
		local type=0
		if info.type==1 and info.code==1 then--经验
			type=1
		elseif info.type==2 and info.code==1 then--金币
			type=2
		elseif info.type==2 and info.code==2 then--钻石
			type=3
		else
			type=4
		end
		local  amount=rewardItemAmount[type]
		if not amount then
			amount={}
		end
		table.insert(amount, info)
		rewardItemAmount[type]=amount
		if tag==1 then
			local  map=rewardItem[type]
			if not map then
				map={}
			end
			if listPos[key] then
				table.insert(map, listPos[key])
			end
			rewardItem[type]=map
		else
			local obj= listObj:getChildAt(tonumber(key)-1)
			local  map=rewardItem[type]
			if not map then
				map={}
			end
			if obj then
				table.insert(map, obj:localToGlobal(Vector2.zero))
			else
				table.insert(map, {x=0,y=0})
			end
			rewardItem[type]=map
		end
	end
	return rewardItemAmount, rewardItem
end

function RollTips.startflyRewardList(rewardItemAmount,rewardItem)
	for key, value in pairs(rewardItemAmount) do
		local rewardMap=rewardItem[key]
		if key==4 then
			RollTips.flyRewardList(value,rewardMap)
		end
	end
	 Scheduler.scheduleOnce(0.3,function()
		for key, value in pairs(rewardItemAmount) do
			local rewardMap=rewardItem[key]
			if key<=3 then
				RollTips.flyMoney(value[1].type, value[1].code, value[1].amount, rewardMap[1])
			end
		end
	end)

end


--物品飞到背包动画
function RollTips.flyRewardList(itemList, rewardList)
	local mainUIView = ViewManager.getView("MainUIView")
	local bottomBtns = mainUIView.bottomBtns
	local list_page = bottomBtns:getChildAutoType("list_page");
	local com_btns= list_page:getChildAt(0)
	 local list_btns= com_btns:getChildAutoType("list_btns");
	local bagBtn=list_btns:getChildAt(1)
	if not bagBtn then
		bagBtn=list_btns:getChildAt(0)
	end
	local packPos = bagBtn:getPosition()
	 packPos = bagBtn:getParent():localToGlobal({x = packPos.x + bagBtn:getWidth()/2, y = packPos.y})
	local items = {}
	local scale=1
	for k,reward in ipairs(itemList) do
		local amount= reward.amount or 1
		if amount > 0 then
			 local	fromPos =rewardList[k]
			printTable(26,"转换之后的物品是的33333333位置>>>>>>>>>",fromPos) 
			local icon = fgui.GLoader:create()
			local url = ItemConfiger.getItemIconByCode(reward.code)
			if reward.type and reward.type	== GameDef.GameResType.Hero then
				url=PathConfiger.getHeroOfMonsterIcon(reward.code)
			end 
			icon:setURL(url)
			icon:setScale(scale,scale)
			local parentObj = ViewManager.getParentLayer(LayerDepth.Tips)
			local pos = parentObj:globalToLocal(fromPos)
			parentObj:addChild(icon)
			icon:setPosition(pos.x, pos.y+70)
			table.insert(items, icon)
		end
	end
	
	for k,icon in ipairs(items) do
		local onComplete = function()
			if not tolua.isnull(icon) then
				icon:getParent():removeChild(icon)
			end
			--TweenUtil.to(bagBtn, {x = packPos.y - 5, time = 0.1})
		end
		local randomTime= 0.8 --0.5 + k*0.2
		TweenUtil.to(icon, {x = packPos.x, y = packPos.y, time = randomTime, onComplete = onComplete, ease = EaseType.SineIn})
		TweenUtil.scaleTo(icon, {from = {x = scale, y = scale}, to = {x = 0.25, y =0.25}, time =  randomTime, ease = EaseType.SineIn})
	end
end

function RollTips.close(viewName)
	rollTipsView[viewName] = nil
	ViewManager.close(viewName)
end

return RollTips
