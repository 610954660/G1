--绑定组件管理类
--@class BindManager
--使用方法：

local BindManager = {}

local _classPool = {}

--对界面上已经存在的显示对象添加处理类
function BindManager.bindClass(classPath, obj, args)
    local ClassObj = require(classPath)
	
	local classItem = obj:getBindClass()
	if obj:getBindClassPath() ~= classPath then
		classItem = ClassObj.new(obj, args)
		obj:setBindClass(classPath, classItem)
	end
	return classItem
end

------------下面是常用的绑定类,放在这里可以快捷调用-------------
function BindManager.bindPlayerCell(obj)
	return BindManager.bindClass("Game.UI.Global.PlayerCell", obj)
end

function BindManager.bindHeroCell(obj)
	return BindManager.bindClass("Game.UI.Global.HeroCell", obj)
end

function BindManager.bindHeroCellShow(obj)
	return BindManager.bindClass("Game.UI.Global.HeroCellShow", obj)
end


function BindManager.bindCardCell(obj)
	return BindManager.bindClass("Game.Modules.Card.CardCell", obj)
end

function BindManager.bindCostItem(obj)
	return BindManager.bindClass("Game.UI.Global.CostItem", obj)
end

function BindManager.bindHeroQuality(obj)
	return BindManager.bindClass("Game.UI.Global.HeroQuality", obj)
end

function BindManager.bindCostIcon(obj)
	return BindManager.bindClass("Game.UI.Global.CostIcon", obj)
end

function BindManager.bindCostBar(obj)
	return BindManager.bindClass("Game.UI.Global.CostBar", obj)
end

function BindManager.bindItemCell(obj)
	return BindManager.bindClass("Game.UI.Global.ItemCell", obj)
end

function BindManager.bindUniqueWeaponCell(obj)
	return BindManager.bindClass("Game.UI.Global.UniqueWeaponCell", obj)
end

function BindManager.bindRewardCell(obj)
	return BindManager.bindClass("Game.UI.Global.RewardCell", obj)
end

function BindManager.bindCrownTitleCell(obj)
	return BindManager.bindClass("Game.UI.Global.CrownTitleCell", obj)
end

function BindManager.bindSkillCell(obj)
	return BindManager.bindClass("Game.UI.Global.SkillCell", obj)
end

function BindManager.bindCardStar(obj)
	return BindManager.bindClass("Game.UI.Global.CardStar", obj)
end

function BindManager.bindMoneyBar(obj)
	return BindManager.bindClass("Game.UI.Global.MoneyBar", obj)
end

function BindManager.bindGroupList(obj) 
	return BindManager.bindClass("Game.Modules.ActivityFrame.GroupList", obj)
end

function BindManager.bindTacticalCell(obj)
	return BindManager.bindClass("Game.UI.Global.TaticalCell", obj)
end

function BindManager.bindAttrRadar(obj)
	return BindManager.bindClass("Game.UI.Global.AttrRadar", obj)
end

function BindManager.bindCostButton(obj)
	return BindManager.bindClass("Game.UI.Global.CostButton", obj)
end


function BindManager.bindLihuiDisplay(obj)
	return BindManager.bindClass("Game.UI.Global.LihuiDisplay", obj)
end

function BindManager.bindTextInput(obj)
	return BindManager.bindClass("Game.UI.Global.TextInput", obj)
end

function BindManager.bindMatchPointBoard(obj)
	return BindManager.bindClass("Game.Modules.Card.MatchPointBoard", obj)
end

function BindManager.bindRewardRecordBoard(obj)
	return BindManager.bindClass("Game.UI.Global.RewardRecordBoard", obj)
end


function BindManager.bindSeatItem(obj)
	return BindManager.bindClass("Game.Modules.Battle.Cell.SeatItem", obj)
end

function BindManager.bindTraningCell(obj)
	return BindManager.bindClass("Game.Modules.Training.Cell.TrainSeatItem", obj)
end

function BindManager.bindGeographicalBox(obj)
	return BindManager.bindClass("Game.UI.Global.GeographicalBox", obj)
end

function BindManager.bindDeviceStatus(obj)
	return BindManager.bindClass("Game.UI.Global.DeviceStatus", obj)
end

function BindManager.bindSubItem(obj)
	return BindManager.bindClass("Game.Modules.Battle.Cell.SubItem", obj)
end

function BindManager.bindFightItem(obj)
	return BindManager.bindClass("Game.Modules.Battle.Cell.HeroItem", obj)
end



function BindManager.bindChatTextCell(obj)
	return BindManager.bindClass("Game.UI.Global.ChatTextCell", obj)
end

function BindManager.bindEmblemCell(obj)
	return BindManager.bindClass("Game.Modules.Emblem.EmblemCell", obj)
end


function BindManager.bindRecordMenu(obj)
	return BindManager.bindClass("Game.UI.Global.RecordMenu", obj)
end

function BindManager.bindRecordCell(obj)
	return BindManager.bindClass("Game.UI.Global.RecordCell", obj)
end

function BindManager.bindButtonList(obj)
	return BindManager.bindClass("Game.UI.Global.ButtonList", obj)
end

function BindManager.bindStrideCell(obj)
	return BindManager.bindClass("Game.Modules.StrideServer.StrideCell", obj)
end

--浮标按钮
function BindManager.bindBuoyButton(obj)
	return BindManager.bindClass("Game.UI.Global.BuoyButton", obj)
end




return BindManager