local ExtraordinaryPVPBattleView, Super = class("ExtraordinaryPVPBattleView", Window)

function ExtraordinaryPVPBattleView:ctor()
    self._packName = "ExtraordinarylevelPvP"
    self._compName = "ExtraordinaryPVPBattleView"
    --self._rootDepth = LayerDepth.Window
    self.__reloadPacket = true
end

function ExtraordinaryPVPBattleView:_initEvent()
end

function ExtraordinaryPVPBattleView:_initVM()
    local viewNode = self.view
    ---Do not modify following code--------
    --{autoFields}:CrossPVP.CrossPVPBattleView
    self.c1 = viewNode:getController("c1")
    --Controller
    self.c2 = viewNode:getController("c2")
    --Controller
    self.c3 = viewNode:getController("c3")
    --Controller
    self.list_team = viewNode:getChildAutoType("list_team")
    --GList
    --{autoFieldsEnd}:CrossPVP.CrossPVPBattleView
    --Do not modify above code-------------
end

function ExtraordinaryPVPBattleView:_initUI()
    self:_initVM()
    local teamArr = ExtraordinarylevelPvPModel:getPVPEnum()
    ExtraordinarylevelPvPModel:setCurPVPModule(teamArr[1])
    self.list_team:regUnscrollItemClick(
        function(index, obj)
            local mathchType = ExtraordinarylevelPvPModel:getMatchType()
             --得到当前是常规赛还王者赛
            if mathchType == 1 then
                if index == 1 then
                    RollTips.show("王者赛开启第二阵容")
                    self.list_team:setSelectedIndex(0)
                    return
                end
            else
                if index == 1 then
                    local curLv, nextLevel, curexp = SecretWeaponsModel:getEquipLvAndExp()
                    local limtLv = DynamicConfigData.t_Basics[1].Openconditions
                    if limtLv > curLv then
                        RollTips.show(string.format("秘武等级%s开启第二阵容", limtLv))
                        self.list_team:setSelectedIndex(0)
                        return
                    end
                end
            end
            if (self.list_team:getSelectedIndex() + 1 ~= ExtraordinarylevelPvPModel:getCurPVPModule()) then
                ExtraordinarylevelPvPModel:setCurPVPModule(teamArr[self.list_team:getSelectedIndex() + 1])
                Dispatcher.dispatchEvent(
                    EventType.extraordinarylevelPvP_zhenrongUp,
                    teamArr[self.list_team:getSelectedIndex() + 1]
                )
            end
        end
    )
end

function ExtraordinaryPVPBattleView:_refreshView()
end

function ExtraordinaryPVPBattleView:onExit_()
end

return ExtraordinaryPVPBattleView
