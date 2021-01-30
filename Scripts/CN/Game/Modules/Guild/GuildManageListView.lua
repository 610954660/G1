--added by wyang 公会管理列表
local GuildManageListView, Super = class("GuildManageListView", Window)
function GuildManageListView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildManageListView"
    self._rootDepth = LayerDepth.PopWindow
    self._btnListSetting = {
        {action = 2, lable = Desc.CohesionReward_str33, priority = 2},
	}
end

-------------------常用------------------------
--UI初始化
function GuildManageListView:_initUI(...)
    self.list_btns = self.view:getChildAutoType("list_btns")
    self.list_btns:setItemRenderer(
        function(index, obj)
            local itemData = self._btnListData[index + 1]
            obj:setTitle(itemData.lable)
            obj:removeClickListener(100) --需要移除事件，不然会连续点好几次
            obj:addClickListener(
                function(...)
                    self:onManagerBtnClick(itemData.action)
                end,
                100
            )
        end
    )
    local posTion= GuildModel.guildList.myGuildPosition;
    printTable(19,"asdfqwr>>>>>>>>>dasfadsf",posTion)
    self:showManagerBtns(posTion)
end

function GuildManageListView:showManagerBtns(priority)
    local array= DynamicConfigData.t_guildPosition[priority] 
    local listData = {}
    for _, v in ipairs(self._btnListSetting) do
        if (table.indexof(array.privilegeList,v.priority))~=false then
            table.insert(listData, v)
        end
    end
    table.insert( listData,  {action = 6, lable = Desc.CohesionReward_str34, priority = 6} ) 
    self._btnListData = listData;
    self.list_btns:setData(self._btnListData)
    self.list_btns:resizeToFit(table.getn(self._btnListData))
end

function GuildManageListView:onManagerBtnClick(action)
 if (action == 2) then --公会设置
     ViewManager.open("GuildSettingView")
    elseif (action == 6) then --退出公会
        local posTion = GuildModel.guildList.myGuildPosition or 3
        if posTion==1 then
            local info = {}
            info.text = Desc.guild_checkStr1
            info.type = "yes_no"
            info.mask = true
            info.onYes = function()
                self:showTips()
            end
            Alert.show(info)
            else
                self:showTips()
            end
    end
end

function GuildManageListView:showTips()
	if ModelManager.PlayerModel.level <= 35 then
		GuildModel:leaveGuildReq()
		ViewManager.close("GuildManageListView")
	else
		local info = {}
		info.text = Desc.guild_checkStr
		info.type = "yes_no"
		info.mask = true
		info.onYes = function()
			GuildModel:leaveGuildReq()
			ViewManager.close("GuildManageListView")
		end
		Alert.show(info)
	end
end

--initEvent后执行
function GuildManageListView:_enter(...)
end

--页面退出时执行
function GuildManageListView:_exit(...)
    --	self.itemcellArrs = {}
end

-------------------常用------------------------

return GuildManageListView
