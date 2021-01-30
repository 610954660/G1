--added by wyang
--加载资源路径读取器
PathConfiger = {}

local effecPath={
	Spine= "Spine",
	battle = "Effect/battle",
	Settlement="Effect/UI",
	
	downEffect=  "Ef_battle_enter_down",
	upEffect="Ef_battle_enter_up",
}

--获取id获取头像icon
function PathConfiger.getHeroOfMonsterIcon(monsterId,fashionId)
	if not monsterId then return "" end
	local configMonster = DynamicConfigData.t_monster[monsterId]
	local id = monsterId
	if configMonster then
		id = configMonster.model;
		local configInfo = DynamicConfigData.t_AllResource[id]
		if not configInfo then
			return PathConfiger.getHeroHead(id,fashionId)
		end
		id = configInfo.heroCard
	end
	return PathConfiger.getHeroCard(id,fashionId)
end

--获取id获取立绘
function PathConfiger.getHeroDraw(heroId, fashionId)
	if not heroId then return "" end

	local configInfo= DynamicConfigData.t_AllResource[heroId]
	if not configInfo then
		return false
	end
	--时装处理
	if fashionId then 
		local fanshionInfo = DynamicConfigData.t_Fashion[heroId] and DynamicConfigData.t_Fashion[heroId][fashionId] 
		if fanshionInfo then 
			if TableUtil.isEmpty(fanshionInfo.fashionIndex) then 
				return "lihui",configInfo.name.."_lihui"
			else
				local DrawId = fanshionInfo.fashionIndex and fanshionInfo.fashionIndex[2] 
				if DrawId and DrawId ~= 0 then 
					return "lihui",configInfo.name.."_"..DrawId.."_lihui"
				else
					return "lihui",configInfo.name.."_lihui"
				end
			end
		else
			return "lihui",configInfo.name.."_lihui"
		end
	else
		return "lihui",configInfo.name.."_lihui"
	end
end

--获取id获取半身像icon
function PathConfiger.getHeroOfMonsterDex(monsterId)
	if not monsterId then return "" end
	local configMonster= DynamicConfigData.t_monster[monsterId]
	if not configMonster then
		return ''
	end
	local id=configMonster.model;
	local configInfo= DynamicConfigData.t_AllResource[id]
	return string.format("%s%s.png", "Icon/heroCardex/", configInfo.heroCardex) 
end



--获取卡牌种族图标
function PathConfiger.getCardCategory(category)
	return string.format("%s%s.png", "Icon/heroCard/", "cardcategory" ..category)
end

--获取卡牌种族图标
function PathConfiger.getCardSmallCategory(category)
	return string.format("%s%s.png", "Icon/heroCard/", "cardcategory_small" ..category)
end

--获取种族加成激活的图标
function PathConfiger.getCampIconAFrame(category)
	return string.format("%s%s.png", "Icon/battle/camp/", "category" ..category),string.format("%s%s.png", "Icon/battle/camp/", "frame" ..category)
end


--获取卡牌种族图标 64x64
function PathConfiger.getCardCategory64(category)
	return string.format("%s%s.png", "Icon/heroCard/", "cardcategory" ..category.."x64")
end
--获取卡牌种族图标 带颜色
function PathConfiger.getCardCategoryColor(category)
	return string.format("%s%s.png", "Icon/heroCard/", "cardcategorycolor" ..category)
end


--获取卡牌颜色条（长）
function PathConfiger.getCardQualitybg(color)
	if color > 6 then color = 6 end --大于6星的都是显示红色
	return string.format("%s%s.png","Icon/heroCard/cardqualitybg",color)
end

--获取卡牌种族图标
function PathConfiger.getCardCategoryBg(category)
	return string.format("%s%s.png", "Icon/heroCard/", "cardcategory_bg" ..category)
end

--获取卡牌框（背景）
function PathConfiger.getHeroFrame(star)
	if not star then return "" end
	if star > 6 then star = 6 end --大于6星的都是显示红色
	local resInfo= DynamicConfigData.t_heroResource[star]
	if resInfo then
		return string.format("%s%s.png","Icon/heroFrame/heroFrame",resInfo.qualityRes)
	end
	if star==0 then
		return string.format("%s%s.png","Icon/heroFrame/heroFrame",1)
	end
	return ""
end
--获取卡牌框（作为道具 背景）
function PathConfiger.getHeroShowFrame(star)
	if not star then return "" end
	if star > 6 then star = 6 end --大于6星的都是显示红色
	local resInfo= DynamicConfigData.t_heroResource[star]
	if resInfo then
		return string.format("%s%s.png","Icon/heroFrameShow/heroFrame",resInfo.qualityRes)
	end
	return ""
end

--获取卡牌框（上面的菱形）
function PathConfiger.getHeroFrameLine(star)
	if not star then return "" end
	if star > 6 then star = 6 end --大于6星的都是显示红色
	local resInfo= DynamicConfigData.t_heroResource[star]
	if resInfo then
		return string.format("%s%s.png","Icon/heroFrame/heroFrame",resInfo.qualityRes)
	end
	return ""
end

--获取卡牌框（作为道具 正方形）
function PathConfiger.getHeroShowFrameLine(star)
	if not star then return "" end
	if star > 6 then star = 6 end --大于6星的都是显示红色
	local resInfo= DynamicConfigData.t_heroResource[star]
	if resInfo then
		return string.format("%s%s.png","Icon/heroFrameShow/heroFrameLine",resInfo.qualityRes)
	end
	return ""
end

--获取卡牌颜色条（短）
function PathConfiger.getCardQuaColor(color)
	if not color then return "" end
	if color > 6 then color = 6 end --大于6星的都是显示红色
	return string.format("%s%s.png","Icon/heroCard/quacolor",color)
end

--获取卡牌星星路径
function PathConfiger.getCardStar(star)
	return string.format("%s%s.png","Icon/heroCard/cardStar_",star)
end

--获取卡牌图片
function PathConfiger.getHeroCard(id,fashionId)
	if fashionId then --时装处理
		local fanshionInfo = DynamicConfigData.t_Fashion[id] and DynamicConfigData.t_Fashion[id][fashionId] 
		if fanshionInfo then 
			if TableUtil.isEmpty(fanshionInfo.fashionIndex) then 
				return string.format("%s%s.png","Icon/heroCard/",id)
			else
				local DrawId = fanshionInfo.fashionIndex and fanshionInfo.fashionIndex[3] 
				if DrawId and DrawId ~= 0 then 
					local cardId = id..DrawId
					return string.format("%s%s.png","Icon/heroCard/",cardId)
				else
					return string.format("%s%s.png","Icon/heroCard/",id)
				end
			end
		else
			return string.format("%s%s.png","Icon/heroCard/",id)
		end
	else
		return  PathConfiger.getPlayerHead(id)-- string.format("%s%s.png","Icon/heroCard/",id)
	end
end

--获取战斗失败结算指引图片
function PathConfiger.getLoseGuide(id)
	return string.format("%s%s.png","Icon/loseGuide/",id)
end




--获取卡牌星星路径
function PathConfiger.getHeroHead(id,fashionId)
	if fashionId then --时装处理
		local fanshionInfo = DynamicConfigData.t_Fashion[id] and DynamicConfigData.t_Fashion[id][fashionId] 
		if fanshionInfo then 
			if TableUtil.isEmpty(fanshionInfo.fashionIndex) then 
				return string.format("%s%s.png","Icon/heroCard/",id)
			else
				local DrawId = fanshionInfo.fashionIndex and fanshionInfo.fashionIndex[3] 
				if DrawId and DrawId ~= 0 then 
					local cardId = id..DrawId
					return string.format("%s%s.png","Icon/heroCard/",cardId)
				else
					return string.format("%s%s.png","Icon/heroCard/",id)
				end
			end
		else
			return string.format("%s%s.png","Icon/heroCard/",id)
		end
	else
		return string.format("%s%s.png","Icon/heroCard/",id)
	end
end


function PathConfiger.getHeroIconModel(id)
	return string.format("%s%s.png","Icon/heroIcon/",id)
end

function PathConfiger.getCardProfessional(position)
	return string.format("%s%s.png","Icon/heroCard/cardProfessional_",position)
end

function PathConfiger.getCardProfessionalWhite(position)
	return string.format("%s%s.png","Icon/heroCard/cardProfessional_",position)
end

--尺寸为64
function PathConfiger.getCardProfessional64(position)
	return string.format("%s%s.png","Icon/heroCard/cardProfessional_",position)
end


function PathConfiger.getSpineRoot()
	return effecPath.Spine
end

function PathConfiger.getSettlementRoot()
	return effecPath.Settlement
end

function PathConfiger.getBattleFxRoot()
	return effecPath.battle
end


function PathConfiger.getAtackSoundPath(name)
	return string.format("%s%s.mp3","Sound/attack/",name)
end



--获取性别图片
function PathConfiger.getHeroSexIcon(sex)
	return string.format("%s%s.png","Icon/sex/sex",sex)
end

function PathConfiger.getGuildHeroSexIcon(sex)
	return string.format("%s%s.png","Icon/guild/guildsex",sex)
end

--[[function PathConfiger.getHeroHead(position)
	return string.format("%s%s.png","Icon/heroCard/h_",position)
end--]]


--获取半身像
function PathConfiger.getHeroCardex(id,fashionId)
	if fashionId then --时装处理
		local fanshionInfo = DynamicConfigData.t_Fashion[id] and DynamicConfigData.t_Fashion[id][fashionId] 
		if fanshionInfo then 
			if TableUtil.isEmpty(fanshionInfo.fashionIndex) then 
				return string.format("%s%s.png","Icon/heroCardex/",id)
			else
				local DrawId = fanshionInfo.fashionIndex and fanshionInfo.fashionIndex[4] 
				if DrawId and DrawId ~= 0 then 
					local cardId = id..DrawId
					return string.format("%s%s.png","Icon/heroCardex/",cardId)
				else
					return string.format("%s%s.png","Icon/heroCardex/",id)
				end
			end
		else
			return string.format("%s%s.png","Icon/heroCardex/",id)
		end
	else
		return string.format("%s%s.png","Icon/heroCardex/",id)
	end
	return string.format("%s%s.png","Icon/heroCardex/",id)
end


--公会科技图标
function PathConfiger.getGuildTechnologyIcon(type)
	return string.format("%s%s.png","Icon/guild/guildTechnology",type)
end

--获取排行榜类型标题
function PathConfiger.getRankTypeIcon(type)
	return string.format("%s%s.png","UI/Rank/rank_icon_",type)
end


--获取排行榜类型背景
function PathConfiger.getRankTitleBg(type)
	return string.format("%s%s.png","UI/Rank/rank_titleBg_",type)
end

--获取排行榜类型背景
function PathConfiger.getRankConnerBg(type)
	return string.format("%s%s.png","UI/Rank/rank_conner_",type)
end

--获取排行榜1-3 列表背景
function PathConfiger.getRankListFrame(type)
	return string.format("%s%s.png","UI/Rank/rank_frame_",type)
end


--获取排行榜1-3 名图标
function PathConfiger.getRankIcon(rank)
	return string.format("%s%s.png","UI/Rank/Rank_img_",rank)
end


--获取头像关系图标
function PathConfiger.getRelationIcon(relation)
	if relation == 0 then return "" end
	return string.format("%s%s.png","Icon/public/player_relation",relation)
end

--获取物品图标
function PathConfiger.getItemIcon(icon)
	if icon == 0 then return "" end
	return string.format("%s%s.png","Icon/item/",icon)
end

--获取法阵品质图片
function PathConfiger.getArrayImage(headRes)
	return string.format("%s%s.png","Icon/rarity/R_",headRes)
end

--获取血条样式图片
function PathConfiger.getBarImage(barName)
	return string.format("%s%s.png","Icon/battle/",barName)
end


--获取物品框图片
function PathConfiger.getItemFrame(color, size)
	if size == "normal" then
		return string.format("%s%s.png","Icon/itemFrame/itemFrame",color)
	elseif size == "mid" then
		return string.format("%s%s.png","Icon/itemFrame/itemFrameM",color)
	elseif size == "big" then
		return string.format("%s%s.png","Icon/itemFrame/itemFrameBig",color)
	end
end

--获取货币图标
function PathConfiger.getMoneyIcon(moneyType)
	return string.format("%s%s.png","Icon/money/money",moneyType)
end

function PathConfiger.getPassiveSkillFrame(quality)
	return string.format("%s%s.png", "Icon/itemFrame/itemFrameMini", quality);
end

-- 已经修改为读取运营配置
function PathConfiger.getActivityIcon(imgSrc,type)
	if type == 1 then
		if imgSrc then
            return "UI/activity/"..imgSrc..".png"
		end
		return "UI/activity/btn_2401.png"
	elseif type ==2 then
		if imgSrc then
			return "UI/activity/"..imgSrc..".jpg"
		end
		return "UI/activity/banner_3001.jpg"
	end
	
end


function PathConfiger.getActivityBannerTitleStr(imgSrc)	
	return "UI/activity/"..imgSrc
end



--获取立绘路径 
function PathConfiger.getHeroHraw(heroId)
	return string.format("%s%s.png","Icon/herodraw/",heroId)
end


--获取阵法图标路径 
function PathConfiger.getTacticalIcon(id)
	return string.format("%s%s.png","Icon/tactical/tactical",id)
end

--获取阵法图标路径 (大图标)
function PathConfiger.getTacticalBigIcon(id)
	return string.format("%s%s.png","Icon/tactical/tactical",id)
end

--获取背景图路径
function PathConfiger.getBg(id)
	return string.format("Bg/%s",id)
end

--获取战斗场景图片
function PathConfiger.getMapBg(id)
	return string.format("Map/%s.jpg",id)
end

-- 获取我要变强icon
function PathConfiger.getStronger(id)
	return string.format("Icon/stronger/%s.png", id);
end

--获取头衔路径
function PathConfiger.getHeroTitle(titleId)
	--local level = 1
	--local info = DynamicConfigData.t_HeroTotemsTitleLevel[titleId]
	--if info then level = info.level end
	--local title  = 1
	--if level >=9 then
	--	title = 3
	--elseif level >= 5 then
	--	title = 2
	--end
	return string.format("Icon/heroTitle/%d.png", titleId)
end

--根据Buff表的buffTipsRes字段 读取上buff需要显示的图片
function PathConfiger.getBuffDes(buffTipsRes)
	return string.format("Icon/buffDes/%s.png",buffTipsRes)
end


function PathConfiger.getDutyIcon(id)
	return string.format("%s%s.png","Icon/duty/duty",id)
end

--获取战斗属性图标
function PathConfiger.getFightAttrIcon(id)
	return string.format("%s%s.png","Icon/fightAttr/fightAttr",id)
end

--获取装备技能图标
function PathConfiger.getEquipmentSkillIcon(id)
	return string.format("%s%s.png","Icon/skill/",id)
end

--获取模块图标
function PathConfiger.getModuleIcon(id)
	return string.format("%s%s.png","Icon/module/",id)
end

--获取充值图标
function PathConfiger.getRechargeIcon(id)
	return string.format("%s%s.png","Icon/recharge/recharge",id)
end

--获取充值图标
function PathConfiger.getEndLessRankBg(rank)
	if rank > 4 then rank = 4 end
	return string.format("%s%s.png","UI/Rank/rank_endlessBg",rank)
end

--获取无尽排行榜
function PathConfiger.getEndLessRankBtnIcon(type)
	return string.format("%s%s.png","UI/Rank/rank_endlessBtn",type)
end

--获取秘境排行榜
function PathConfiger.getFairyLandRankBtnIcon(type)
	return string.format("%s%s.png","UI/Rank/rank_fairylandBtn",type)
end

--获取星辰圣所事件图片
function PathConfiger.getStarTempleEventIcon(id)
	return string.format("%s%s.png","Icon/preStarTemple/eventIcon/",id)
end

--获取星辰圣所UI背景
function PathConfiger.getPveStarTempleBG(id)
	return string.format("UI/PveStarTemple/%s.png", id)
end

--获取主界面按钮
function PathConfiger.getMainBtn(id)
	return string.format("UI/MainUI/%s.png", id)
end

-- 获取种族图片
function PathConfiger.getRaceIcon(raceType, gray)
	local formatStr = gray and "%s%sg.png" or "%s%s.png"
	return string.format(formatStr, "Icon/race/", raceType)
end

--次元裂缝 获取段位图标
function PathConfiger.getBossDw(index)
	local rankindex = 1
	if index ==1 then
		rankindex = 6
	elseif index>=2 and index<=4 then
		rankindex = 5
	elseif index>=5 and index<=7 then
		rankindex = 4
	elseif index>=8 and index<=10 then
		rankindex = 3
	elseif index>=11 and index<=13 then
		rankindex = 2
	elseif index>=14 and index<=16 then
		rankindex = 1
	end
	return string.format("Icon/rank/%d.png", rankindex)
end

function PathConfiger.getDwtxt(index)
	-- A王者 B钻石 C白金 D黄金 E白银 F青铜
	local dwData = {
		[31]="Ba",[32]="Bb",[33]="Bc",  -- 小写字母对应 1 2 3 段位
		[34]="Cd",[35]="Ce",[36]="Cf",
		[37]="Dg",[38]="Dh",[39]="Di",
		[40]="Ej",[41]="Ek",[42]="El",
		[43]="Fm",[44]="Fn",[45]="Fo"
	}
	if index >=1 and index <= 30 then
		return "A" 	-- 王者
	else
		return dwData[index]
	end
end

function PathConfiger.getBossHead(bossHead)
	return string.format("UI/Guild/%s.png", bossHead)
end

function PathConfiger.getTimeLimitGiftBG(name)
	return string.format("UI/TimeLimitGift/%s.png", name)
end

--头像路径 
function PathConfiger.getPlayerHead(id)
	if DynamicConfigData.t_HeadEx[id] then
		return string.format("Icon/heroCard/%s.png", DynamicConfigData.t_HeadEx[id].icon)
	end
	return string.format("Icon/heroCard/%s.png", id)
end

function PathConfiger.GetUIFrame(path,extend)
	return string.format("UI/%s.%s",path,extend)
end

function PathConfiger.getSevenDayLeftTopBg(activityType)
	return string.format("Icon/sevenDay/%d.png", activityType)
end

--获取头像框
function PathConfiger.getHeadFrame(frame)
	if not frame then frame = 90000001 end
	return string.format("Icon/headFrame/%s.png", frame)
end

--九宫格活动背景图
function PathConfiger.getSnatchActivityBg(mapId)
	return string.format("UI/activity/SnatchActivity/img_jitu_tu%s.png", mapId)
end
--新英雄Boss背景图
function PathConfiger.getHeroBossActivityBg(name)
	return string.format("UI/activity/%s", name)
end

--战令活动
function PathConfiger.getWarmakesActiveTitle(type)
	return string.format("UI/OperatingActivities/Frame_Title_%s.png", type)
end

--事件广播标题
function PathConfiger.getEventBrocastTtitle(id)
	return string.format("Icon/eventBrocast/%s.png", id)
end

function PathConfiger.getWarmakesActiveFrame(acttype,type)
	if type==1  then
		return string.format("UI/OperatingActivities/Frame_di_%s.png", acttype)
	else
		return string.format("UI/OperatingActivities/Frame_gao_%s.png", acttype)
	end
end

function PathConfiger.getWarmakesActiveIcon(acttype,type)
	if type==1  then
		return string.format("UI/OperatingActivities/Icon_di_%s.png", acttype)
	else
		return string.format("UI/OperatingActivities/Icon_gao_%s.png", acttype)
	end
end

function PathConfiger.getUniqueWeaponIcon(id,level)
	if not level then level = 0 end 
	if id then
		local uniqueWeaponConfig = DynamicConfigData.t_UniqueWeaponConfig[id][level]
		if uniqueWeaponConfig then
			return string.format("Icon/uniqueWeapon/%s.png", uniqueWeaponConfig.icon)
		else
			return ""
		end
	else
		return ""
	end
end

function PathConfiger.getUniqueWeaponFrame(color)
	return string.format("Icon/itemFrame/uniqueWeapoFrame%s.png", color)
end


function PathConfiger.getUniqueWeaponLevel(data)
	if not data then return nil end
	local level = data
	if type(data) == "table" then
		level = data.level
	end
	if level and level >= 0 then
		if level >= 30 then
			return "Icon/uniqueWeapon/level_4.png"
		elseif level >= 20 then
			return "Icon/uniqueWeapon/level_3.png"
		elseif level >= 10 then
			return "Icon/uniqueWeapon/level_2.png"
		else
			return "Icon/uniqueWeapon/level_1.png"
		end
	else
		return nil
	end
end


function PathConfiger.getItemTipsHeadBg(color)
	return string.format("UI/EquipForge/frame%s.png", color)
end

-- 获取段位等级图标  王者  白银 。。。 
function PathConfiger.getRankLevelIcon(iconId)
	return string.format("Icon/rank/%s.png", iconId)
end

-- 获取功能手册图标
function PathConfiger.getFuncManualResource(iconId)
	return string.format("UI/HelpSystem/funcManual/%s.png",iconId)
end


--获取性别图片
function PathConfiger.getSpeedTip(name)
	return string.format("UI/SpeedTips/%s.png",name)
end


--获取节日寄语图片
function PathConfiger.getFestivalWishIcon(name)
	return string.format("UI/FestivalWishActivity/%s.png",name)
end