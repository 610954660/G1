--added by wyang
--可显示超链接的聊天文本框
local ChatTextCell = class("ChatTextCell")
local ChatObjType = require "Game.Consts.ChatObjType"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function ChatTextCell:ctor(view,colorType)
    self._str = ""
    self._objData = {}
    self.view = view
    self.items = false
    self.colorType=colorType or 0
    self.view:removeEventListener(FUIEventType.ClickLink, 11)
    local tag=false
    self.view:addEventListener(
        FUIEventType.ClickLink,
        function(data)
            local index = tonumber(data:getDataValue())
            self:onClickLink(self._objData[index])
            tag=true
        end,
        11
    )

    self.view:addEventListener(
        FUIEventType.Click,
        function(data)
            if tag==true then
                data:stopPropagation()
            end
            tag=false
        end,
        11
    )
end

function ChatTextCell:init(...)
    --	self.frameLoader = self.view:getChildAutoType("frameLoader")
end

function ChatTextCell:setText(textStr, data)
    if not textStr then
       return 
    end
    self._str = textStr
    if data and data.items then
        self.items = data.items
    end
    self:paraseObj()
    printTable(12, ">>>>>>>>>>>iiiiiiiiias11223", self._str)
    self.view:setText(self._str)
end

--把所有MsgObj的对象数据提取出来
function ChatTextCell:paraseObj()
    local htmltext = self._str
    local firstIdx = 1 --文本段开始位置
    local length = string.len(htmltext)
    local resultStr = ""
    while (firstIdx < length + 1) do
        local starIdx = string.find(htmltext, "<MsgObj>", firstIdx)
        --printTable(9,'>>>>>>>>>>>>1',self._str,length,starIdx);
        if not starIdx then
            resultStr = resultStr .. string.sub(htmltext, firstIdx, length)
            firstIdx = length
            break
        else
            resultStr = resultStr .. string.sub(htmltext, firstIdx, starIdx - 1)
            firstIdx = starIdx + 8
            local fontEnd = string.find(htmltext, "</MsgObj>", starIdx)
            if not fontEnd then
                fontEnd = starIdx
            else
                resultStr = resultStr .. self:getObjDipsplayStr(string.sub(htmltext, firstIdx, fontEnd - 1))
            end
            firstIdx = fontEnd + 9
        end
    end

    self._str = resultStr
end

--把MsgObj对象数据转成htmlText
function ChatTextCell:getObjDipsplayStr(dataStr)
    local data = string.split(dataStr, ",")
    local returnStr = ""
    if (data[1] == ChatObjType.ITEMLIST) then--多个物品
        if self.items then
            for key, value in pairs(self.items) do
                local itemData = ItemConfiger.getInfoByCode(value.code, value.type)
                local linkData = {type = data[1], itemCode = value.code, itemType = value.type}
                table.insert(self._objData, linkData)
                local nameStr =GMethodUtil:formatBracketsStr(itemData.name)
                nameStr =
                    string.format("<font color='%s'>%s</font>",ColorUtil.getChatColorStr(itemData.color,self.colorType), nameStr)
                returnStr = returnStr .. self:getHerfStr(#self._objData, nameStr)
                if tonumber(key) == #self.items then
                    returnStr =string.format( "%sX%s",returnStr, value.amount)
                else
                    returnStr = string.format( "%sX%s%s",returnStr ,value.amount,DescAuto[357])-- [357]="、"
                end
            end
        else
            return ""
        end
    elseif (data[1] == ChatObjType.ITEM) then--单个物品
        local configInfo=ItemConfiger.getInfoByCode(tonumber(data[3]),tonumber(data[2]))
        local color=configInfo.color
        local linkData = {itemType =data[2], itemCode = data[3], amount = data[4]}
        table.insert(self._objData, linkData)
        local nameStr = string.format("%s", ColorUtil.formatColorString(GMethodUtil:formatBracketsStr(configInfo.name),ColorUtil.getChatColorStr(color,self.colorType)))..ColorUtil.formatColorString("X"..data[3],"#119717") 
        returnStr = self:getHerfStr(#self._objData, nameStr)
    elseif (data[1] == ChatObjType.PLAYER) then
        local linkData = {type = data[1], playerId = data[2], serverId = tonumber(data[3]), playerName = data[4]}
        table.insert(self._objData, linkData)
        local color = ColorUtil.getChatColorStr(0,self.colorType)
        local nameStr = string.format("%s", ColorUtil.formatColorString(GMethodUtil:formatBracketsStr(data[4]), color))
        returnStr = self:getHerfStr(#self._objData, nameStr)
    elseif (data[1] == ChatObjType.GUILD) then
        local linkData = {type = data[1], itemCode = tonumber(data[2]), uid = data[3]}
        table.insert(self._objData, linkData)
        local nameStr = ItemConfiger.getItemNameByCode(data[2])
        returnStr = self:getHerfStr(#self._objData, nameStr)
    elseif (data[1] == ChatObjType.DIVINATION) then
        local linkData = {type = data[1], playerId = tonumber(data[2]), serverId = tonumber(data[3])}
        table.insert(self._objData, linkData)
        local color =ColorUtil.getChatColorStr(7,self.colorType)
        local chaolianjieName = data[4]
        if chaolianjieName == nil then
            chaolianjieName = "**"
        end
        local nameStr = string.format("%s", ColorUtil.formatColorString(GMethodUtil:formatBracketsStr(chaolianjieName), color))
        returnStr = self:getHerfStr(#self._objData, nameStr)
    elseif (data[1] == ChatObjType.HERO) then --'卡牌英雄'
        local itemData = DynamicConfigData.t_hero[tonumber(data[2])]
        if (itemData) then
            local linkData = {type = data[1], itemCode = data[2], uid = data[3]}
            table.insert(self._objData, linkData)
            local nameStr = itemData.heroName
            local resInfo = DynamicConfigData.t_heroResource[itemData.heroStar]
            local qualityRes=2
            if resInfo then
                qualityRes=resInfo.qualityRes
            end
            local color =ColorUtil.getChatColorStr(qualityRes,self.colorType)
            nameStr = string.format("<font color='%s'>%s</font>", color,GMethodUtil:formatBracketsStr(nameStr))
            returnStr = self:getHerfStr(#self._objData, nameStr)
        else
            return ""
        end
    elseif (data[1] == ChatObjType.SHARECARD) then --"分享卡牌"
        local itemData = DynamicConfigData.t_hero[tonumber(data[2])]
        if (itemData) then
            local linkData = {
                type = data[1],
                cardId = data[2],
                cardUid = data[3],
                cardStar = data[4],
                playerId = data[5],
                serverId = data[6]
            }
            
            table.insert(self._objData, linkData)
            local nameStr = itemData.heroName
            local resInfo = DynamicConfigData.t_heroResource[itemData.heroStar]
            local color =ColorUtil.getChatColorStr(resInfo.qualityRes,self.colorType) 
            nameStr = string.format("<font color='%s'>%s</font>", color,GMethodUtil:formatBracketsStr(nameStr))
            if (data[7] and tonumber(data[7]) > 0) then
                linkData.rank = data[7];
                local rankStr = string.format(Desc.chat_shar_card_rank, Desc["card_category"..itemData.category], linkData.rank)
                nameStr = string.format("<font color='%s'>%s</font>", color, rankStr..GMethodUtil:formatBracketsStr(itemData.heroName))
            end
            
            returnStr = self:getHerfStr(#self._objData, nameStr)
        else
            return ""
        end
    elseif (data[1] == ChatObjType.SHAREROLENAME) then --"分享角色名字"
            local linkData = {
                type = data[1],
                heroName = data[2],
                playerId = data[3],
                serverId = data[4],
            }
            table.insert(self._objData, linkData)
            local nameStr = data[2]
            nameStr = string.format("<font color='%s'>%s</font>","#ff9900",GMethodUtil:formatBracketsStr(nameStr))
            returnStr = self:getHerfStr(#self._objData, nameStr)
    elseif (data[1] == ChatObjType.SHAREVIDEO) then --"分享战绩视频"
            local linkData = {
                type = data[1],
                playName=data[2],
                enemyName=data[3], 
                gamePlayType =tonumber(data[4]), 
                fromBattleRecordType =tonumber(data[5]),
                recordId =data[6],
                serverId=tonumber(data[7]),
            }
            table.insert(self._objData, linkData)
            local nameStr = DescAuto[358] -- [358]="点击查看详情"
            local gamePlaystr=ChatModel:getgamePlaytypeStr(linkData.gamePlayType)
            local qianStr=string.format( DescAuto[359],linkData.playName,linkData.enemyName,gamePlaystr) -- [359]="我分享了[color=#119717]%s[/color]VS[color=#119717]%s[/color]的%s的精彩对局,"
            nameStr = string.format("<font color='%s'>%s</font>","#ffa443",GMethodUtil:formatBracketsStr(nameStr))
            returnStr =qianStr..self:getHerfStr(#self._objData, nameStr)
        elseif (data[1] == ChatObjType.MOUDLEOPEN) then --"打开界面"
           local configInfo=  DynamicConfigData.t_ChannelDiscern[tonumber(data[2])]
           if not configInfo then
               return returnStr
           end
            local linkData = {
                type = data[1],
                moduleId=configInfo.moduleId,
            }
            table.insert(self._objData, linkData)
            local nameStr = configInfo.name
            nameStr = string.format("<font color='%s'>%s</font>","#ffa443",  nameStr)
            returnStr =self:getHerfStr(#self._objData, nameStr)
		elseif (data[1] == ChatObjType.GUILDWAR) then --"分享角色名字"
            local nameStr = string.format("<font color='%s'>%s</font>","#ff9900", data[2])
			local linkData = {
				type = data[1]
             }
            table.insert(self._objData, linkData)
            returnStr = self:getHerfStr(#self._objData, nameStr)
        elseif (data[1] == ChatObjType.COLOR) then --"颜色"
            local configInfo=  DynamicConfigData.t_ChatColor[tonumber(data[2])]
            if not configInfo then
                return returnStr
            end
             local linkData = {
             }
             table.insert(self._objData, linkData)
             local nameStr = configInfo.name
             returnStr =self:getHerfStr(#self._objData, nameStr)
		elseif (data[1] == ChatObjType.APIRIT) then --"精灵"
            local configInfo=  DynamicConfigData.t_ElfMain[tonumber(data[2])]
            if not configInfo then
                return returnStr
            end
			configInfo = configInfo[1] --读第一个就行了
             local linkData = {
             }
             --table.insert(self._objData, linkData)
			local color =ColorUtil.getChatColorStr(configInfo.color,self.colorType)
             local nameStr = string.format("%s", ColorUtil.formatColorString(GMethodUtil:formatBracketsStr(configInfo.elfName), color))
			returnStr = nameStr
            -- returnStr =self:getHerfStr(#self._objData, nameStr)
        elseif (data[1] == ChatObjType.ATOTHER) then --"@别人"
            local key= data[2] 
            local playName=data[3] 
            local itemIndex=data[4] 
        elseif (data[1] == ChatObjType.SERCERSTR) then --里面包含字符串服务器要求的
             local linkData = {
             }
            --  table.insert(self._objData, linkData)
             returnStr =data[2]
    end
    return returnStr
end

--点击了链接
function ChatTextCell:onClickLink(data)
    print(1, "ChatTextCell onClickLink")
    printTable(21, data)
    Dispatcher.dispatchEvent(EventType.chat_clickLink, data)
end

function ChatTextCell:getHerfStr(index, text)
    --return "<font color='#00FF00'><a href='"..index.."'>"..text.."</a></font>";
    return  "<a href='" .. index .. "'>" .. text .. "</a>"
end

return ChatTextCell
