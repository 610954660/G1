--位置信息
local GeographicalBox, Super = class("GeographicalBox", BindView)

function GeographicalBox:ctor(view)
    self._packName = "UIPublic"
    self._compName = "GeographicalBox"
    self.cityId = 1 --城市
    self.countyId = 1 --省市
    self.com_box1 = false
    self.closeBgBtn = false
    self.list_city = false
    self.list_county = false
    self.countyListInfo = {}
end

function GeographicalBox:_initUI()
    local obj = self.view
    self.com_box1 = obj:getChildAutoType("com_box1")
    self.closeBgBtn = obj:getChildAutoType("btn_close")
    local com_city = obj:getChildAutoType("com_city")
    self.list_city = com_city:getChildAutoType("list_city")
    local com_county = obj:getChildAutoType("com_county")
    self.list_county = com_county:getChildAutoType("list_city")
end

function GeographicalBox:setData(cityId, countyId) --省份 小城市
    if not cityId or cityId == 0 then
        self.cityId = 1
    else
        self.cityId = cityId
    end
    if not countyId or countyId == 0 then
        self.countyId = 1
    else
        self.countyId = countyId
    end
    printTable(152, "外部传过来的城市", cityId, countyId)
    local str = ""
    local array = DynamicConfigData.t_provinces[self.cityId]
    local countyName = self:getCountyName()
    str = array[1].provinces .. countyName
    self.com_box1:setTitle(str)
    local itemPos = 40
    --self.list_city:getChildAt(0):getHeight()
    --local maxY = #DynamicConfigData.t_provinces * itemPos
    --self.list_city:setVirtualAndLoop()
    -- self.list_county:setVirtualAndLoop()
    self:showcityList()
    self:showCountyList(self.cityId)
    self.list_city:removeEventListener(FUIEventType.Scroll, 100)
    self.list_city:addEventListener(
        FUIEventType.Scroll,
        function(context)
            local x = self.list_city:getScrollPane():getPosY()
            if x == 0 then
                self.cityId = 1
            else
                self.cityId = math.ceil(x / itemPos)
            end
            if self.cityId >= #DynamicConfigData.t_provinces then
                self.cityId = #DynamicConfigData.t_provinces
            end
            self.countyListInfo = self:getCountyIdBtn(self.cityId)
            -- printTable(152, "1111111111111", x, math.ceil(x % maxY / itemPos), self.cityId, #self.countyListInfo)
            self.list_county:setNumItems(#self.countyListInfo + 4)
            local pos = self:getScorllPos()
            self.list_county:scrollToView(pos - 1, true, true)
        end,
        100
    )
    local countyitemPos = 40
    --self.list_county:getChildAt(0):getHeight()
    self.list_county:removeEventListener(FUIEventType.Scroll, 100)
    self.list_county:addEventListener(
        FUIEventType.Scroll,
        function(context)
            local y = self.list_county:getScrollPane():getPosY()
            if y == 0 then
                self.countyId = 1
            else
                self.countyId = math.ceil(y / countyitemPos)
            end
            printTable(152, "打印的YYYYYYY", self.countyId, y)
            if self.countyId >= #self.countyListInfo then
                self.countyId = #self.countyListInfo
            end
        end,
        100
    )
end

function GeographicalBox:_initEvent()
    self.com_box1:addClickListener(
        function(...)
            Dispatcher.dispatchEvent(EventType.player_closeGgraphBox, {cityId = self.cityId, countyId = self.countyId})
            printTable(152, "打印的城市", self.cityId, self.countyId)
            local str = ""
            local array = DynamicConfigData.t_provinces[self.cityId]
            local countyName = self:getCountyName()
            str = array[1].provinces .. countyName
            self.com_box1:setTitle(str)
        end
    )

    self.closeBgBtn:addClickListener(
        function(...)
            Dispatcher.dispatchEvent(EventType.player_closeGgraphBox, {cityId = self.cityId, countyId = self.countyId})
            local str = ""
            local array = DynamicConfigData.t_provinces[self.cityId]
            local countyName = self:getCountyName()
            str = array[1].provinces .. countyName
            self.com_box1:setTitle(str)
        end
    )
end

function GeographicalBox:showcityList()
    local array = DynamicConfigData.t_provinces
    self.list_city:setItemRenderer(
        function(index, obj)
            local txt_city = obj:getChild("txt_city")
            local cityInfo = array[index + 1]
            if not cityInfo then
                txt_city:setVisible(false)
            else
                txt_city:setVisible(true)
                local cityName = cityInfo[1].provinces
                txt_city:setText(ColorUtil.formatColorString1(cityName, "#454545"))
            end
        end
    )
    self.list_city:setNumItems(#array + 4)
    local pos = self:getcityScorllPos()
    self.list_city:scrollToView(pos - 1, true, true)
    --  self.list_city:refreshVirtualList()
end

function GeographicalBox:showCountyList(cityId)
    self.countyListInfo = self:getCountyIdBtn(cityId)
    self.list_county:setItemRenderer(
        function(index, obj)
            local txt_city = obj:getChild("txt_city")
            local countyInfo = self.countyListInfo[index + 1]
            if not countyInfo then
                txt_city:setVisible(false)
            else
                txt_city:setVisible(true)
                txt_city:setText(ColorUtil.formatColorString1(self.countyListInfo[index + 1].city, "#1E1E1E"))
            end
        end
    )
    self.list_county:setNumItems(#self.countyListInfo + 4)
    local pos = self:getScorllPos()
    self.list_county:scrollToView(pos - 1, true, true)
    -- self.list_county:refreshVirtualList()
end

function GeographicalBox:getcityScorllPos()
    return self.cityId
end

function GeographicalBox:getScorllPos()
    return self.countyId
end

function GeographicalBox:getCountyName()
    local name = ""
    local array = self:getCountyIdBtn(self.cityId)
    if not array or not array[self.countyId] then
        return name
    end
    name = array[self.countyId].city
    return name
end

function GeographicalBox:getCountyIdBtn(countyId)
    local array = DynamicConfigData.t_provinces
    local curCity = array[countyId]
    return curCity
end

function GeographicalBox:_enter()
end

function GeographicalBox:_exit()
end

return GeographicalBox
