--added by xhd 多页签的窗口基类
local WindowTabBar,Super = class("WindowTabBar",Window)
function WindowTabBar:ctor( args )
    self._tabBar = false
    self._layers = {}
    self._children = {} --所有子页
    self._curChild = false --当前子页
    self._preIndex = false --当前index
    self._updateTitle = false --是否需要更新title
    self.titleImg = false
    self.txtTitle = false
end

function WindowTabBar:__initWindowBase( ... )
    Super.__initWindowBase(self)
    self:__initLayerBuild()
end

--初始化子页构建
function WindowTabBar:__initLayerBuild()
    self._tabBar = FGUIUtil.getChild(self.view,"tabBar","GList")
    self.titleImg = self.view:getChildAutoType("icon")
    self.txtTitle = self.view:getChildAutoType("title")
    local array = self:initTabConfig()
    for k, v in ipairs(array) do
        local flag = false
        -- if type(v.guide) == "boolean" then
        --     flag = v.guide
        -- else
        --     flag = GuideConfig.isOpen(v.guide)
        -- end

        -- if flag then
            table.insert(self._layers, v)
        -- end
    end


    if self._tabBar == false then
        error(string.format("%s _tabBar is nil", self._viewName))
        return
    end

    for k, v in ipairs(self._layers) do
        local classPath = v.path
        assert(classPath ~= nil, "classPath is nil")
        self._children[k] = {
            classPath = classPath,
            view = false,
            createParams = v.createParams or {},
            viewParams = self._args,
            key = v.key,
            openCondition = v.openCondition,
        }
    end
    
    self._tabBar:setItemRenderer(function(index,obj)
			--这里是注册红点
			local btnData = self._layers[index+1]
			local img_red = obj:getChildAutoType("img_red")
			RedManager.register(btnData.red or "", img_red)
            -- obj:removeClickListener()--池子里面原来的事件注销掉
            if btnData.title and type(btnData.title)=="string" then
                local chosenLabel = obj:getChildAutoType("title")
                if chosenLabel then
                   chosenLabel:setText(btnData.title)
                end
                local defaultLabel = obj:getChildAutoType("title")
                if defaultLabel then
                    defaultLabel:setText(btnData.title)
                end
            end
            
            if btnData.titleImg1  then
                local chosenLabel = obj:getChildAutoType("unselect_title")
                if chosenLabel then
                   chosenLabel:setURL(btnData.titleImg1)
                end
            end
            if btnData.titleImg2  then
                local defaultLabel = obj:getChildAutoType("select_title")
                if defaultLabel then
                    defaultLabel:setURL(btnData.titleImg2)
                end
            end


            obj:addClickListener(function( ... )
                if index+1 == self._preIndex then
                    return
                end

                if not self._children[index+1] then
                    return
                end
                --页签开发控制
                -- if childView.openCondition then
                --     -- MsgManager.showRollTipsMsg(childView.openCondition)
                --     if self._preIndex then
                --         self._tabBar:setSelectedIndex(self._preIndex)
                --     end
                --     return
                -- end

                self._tabBar:setSelectedIndex(index)
                self:_createNewLayer(index+1)
            end)
        end
    )
    if #self._layers > 0 then
        self._tabBar:setData(self._layers)
        if self._args.key then --是否配置默认打开key页
            self._tabBar:setSelectedKey(self._args.key, true)
        else
            self._tabBar:setSelectedIndex(0)
            self:_createNewLayer(1)
        end
        print(1,self._tabBar:getSelectedIndex())
        self._tabBar:scrollToView(self._tabBar:getSelectedIndex())
    end
end

--创建子页
function WindowTabBar:_createNewLayer(index)

    if self._preIndex and self._children[self._preIndex].view then
        if self._children[self._preIndex].view:getParent() then
            print(1,"上个页面销毁")
            self._children[self._preIndex].view:close()
            self._children[self._preIndex].view = nil
        end
    end

    local curIndex = index
    self._preIndex = index
    if self._children[index].view then
        print(1,"view 视图存在",index)
        self._children[index].view:setVisible(true)
        self._curChild = self._children[index]
    else
        print(1,"view 视图不存在",index)
        --不存在 创建
        local viewClass = require(self._children[index].classPath)
        local view = viewClass.new({
            parent = self._contentNode, --指定view的parent
            createParams = self._children[index].createParams, -- 创建的 createParams
            viewParams = self._children[index].viewParams, -- 外部传入的 viewParams
            key = self._args.key2, --子tab
            tabBarIndex = index,
        })
        self._children[index].view = view
        self._curChild = self._children[index]
        --调用toCreate方法 统一走资源管理和资源计数
        view:toCreate(function ( obj )
            --标题为图片资源,会分别放到对应的包体里面 加载完后设置
			self.txtTitle:setText(self._layers[index].title)
            --[[if self._updateTitle then
                local ctitleImg = self._layers[index].ctitleImg or ""
                self.titleImg:setURL(ctitleImg)
            else
                self.titleImg:setURL(self.ptitleImg)
            end--]]
        end)
    end

end


function WindowTabBar:setSelectedKey( key1,key2 )
    self._tabBar:setSelectedKey(key1,true)
    if key2 then
        if self._curChild and self._curChild.view and self._curChild.view.setSelectedKey then
            self._curChild.view:setSelectedKey(key2)
        end
    end
end


--打开有动画
function WindowTabBar:_doShowAnimation( ... )
    -- body
end

--关闭有动画
function WindowTabBar:_doHideAnimation( ... )
    -- body
end

--关闭方法
function WindowTabBar:close( ... )
    for k, v in ipairs(self._children) do
        if v.view then
            v.view:close(true)
            self._children[k] = nil
        end
    end
    Super.close(self,true)
end

--获取某个页的对象
function WindowTabBar:getTabView(key)
    for i = 1, #self._children do
        if self._children[i].key == key then
            return self._children[i].view
        end
    end
end

--获取当前选中的页签index
function WindowTabBar:getTabbarIndex( ... )
    return self._tabBar:getSelectedIndex()
end

---------------------------多页面继承可使用方法-----------------------------------
--使用方法： 必须重写  配置多页选项
function WindowTabBar:initTabConfig( ... )
    return {}
end
---------------------------多页面继承可使用方法-----------------------------------



return WindowTabBar