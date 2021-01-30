--aded by xhd fgui帮助类
local FGUIUtil = {}
local componentGetterMap = {
    GComponent      = fgui.GRoot.getChildAsGComponent,          --组件  
    GButton         = fgui.GRoot.getChildAsGButton,             --按钮
    GProgressBar    = fgui.GRoot.getChildAsGProgressBar,        --进度条
    GScrollBar      = fgui.GRoot.getChildAsGScrollBar,          --滚动条
    GList           = fgui.GRoot.getChildAsGList,               --滚动容器
    GSlider         = fgui.GRoot.getChildAsGSlider,             --滑动条
    GComboBox       = fgui.GRoot.getChildAsGComboBox,           --下拉框
    GLoader         = fgui.GRoot.getChildAsGLoader,             --装载器 能动态改变图片
    GImage          = fgui.GRoot.getChildAsGImage,              --图片
    GGraph          = fgui.GRoot.getChildAsGGraph,              --图形
    GGroup          = fgui.GRoot.getChildAsGGroup,              --组
    GMovieClip      = fgui.GRoot.getChildAsGMovieClip,          --动画
    GLabel          = fgui.GRoot.getChildAsLabel,               --标签
    GTextField      = fgui.GRoot.getChildAsGTextField,          --文本
    GRichTextField  = fgui.GRoot.getChildAsGRichTextField,      --富文本
    GTextInput      = fgui.GObject.getChildAsGTextInput,        --输入框
    GTree           = fgui.GObject.getChildAsGTree,             --树\
    --GWrap
}

local extendMap = {
     GList   = require "Game.UI.Extend.GList",
     GLoader = require "Game.UI.Extend.GLoader",
     GGraph = require "Game.UI.Extend.GGraph"
}

function FGUIUtil.getChild(parent,name,compType)
	if not parent then
		print(1,"parent not exist")
		return
	end
	local GClass = componentGetterMap[compType](fgui.GRoot,parent,name)
	if not GClass then
		print(4,name," child not exist,GClass = ",GClass)
		return false
	end
    if  extendMap[compType]~=nil then
        local extendClass=extendMap[compType]
        print(4,compType," extendClass fun exist ")
        return extendClass(GClass)
    else
        return GClass
    end
end

--创建fairyGui对象
function FGUIUtil.createObjectFromURL(packName, componentName)
	return fgui.UIPackage:createObjectFromURL(string.format("ui://%s/%s",packName,componentName))
end

--关闭抗锯齿（只对外加载的图片）
function FGUIUtil.closeKangJuci(component)
	component.displayObject():getTexture():setAntiAliasTexParameters()
end

--打开抗锯齿（只对外加载的图片）
function FGUIUtil.openKangJuci(component)
	component.displayObject():getTexture():setAliasTexParameters()
end
return FGUIUtil