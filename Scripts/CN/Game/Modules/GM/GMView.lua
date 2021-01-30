--示测试页
local GMView,Super = class("GMView", MutiWindow)
local GMLogView = require "Game.Modules.GM.GMLogView"

local _instance = false

function GMView:ctor()
	LuaLogE("GMView ctor")
	self._packName = "GM"
	self._compName = "GMView"
	self.msgNameText = ""
	self.infoTable= {}
	self.sendMsgView = false
	self.checkDataView = false
	self.window = false
	self.viewCtrlName = "gm"
	self._tabBarName = "btlist"
end


function GMView.open()
	if _instance and not tolua.isnull(_instance.window) then _instance.window:setVisible(true) return end
	
	_instance = GMView.new()
	
	local  win = fgui.Window:create();
	local info = UIPackageManager.getPackageInfo("GM") --查看是否包还存在
	if not info then

		UIPackageManager.addPackage("GM")
	end
	_instance.window = win
	_instance.view = UIPackageManager.createGComponent("GM", "GMView")
	_instance:__toInit()
	win:setSortingOrder(9999)
	win:setContentPane( _instance.view )
	
	win:show();
	--_GRoot:bringToFront(win) 
	
	--win:bringToFront();
	rawset(_G,"_GMView",_instance)
end

function GMView:Sleep(n)
	os.execute("sleep " .. n)
end

function GMView:_initUI()
	
	self.GMSendMsgView = self.view:getChildAutoType("GMSendMsgView")
	self.GMCheckDataView = self.view:getChildAutoType("GMCheckDataView")
	self.btlist = self.view:getChildAutoType("btlist")
	self.btlist:setSortingOrder(22)
	
	
	local closeBt = self.view:getChildAutoType("frame/close")
	closeBt:addClickListener(function()
			print(33,"hide")
			--self.window:hide();
			self.window:setVisible(false)
	end)

	--local testF = self.view:getChildAutoType("testf")
	--testF:setText("我们的是这样4as54dasfasf5454a5g4a5sd47g5454565655745a457s4d5a745454")
	--self.FilmEditView = self.view:getChildAutoType("FilmEditView")
	--print(33,"self.FilmEditView = ",self.FilmEditView)
	self:_initReflashLua()
	
	GMLogView:initLog(self,self.view)
			
end
 

--监听多页切换，并构建
function GMView:onViewControllerChanged()
	
	
	
	if self.viewCtrl:getSelectedPage() == "FilmEditView" then
		ViewManager.open("FilmEditView")
		self.window:setVisible(false)
		self:_setPage(self._prePage,false)
	elseif self.viewCtrl:getSelectedPage() == "CardTestView" then
		ViewManager.open("CardTestView")
		self.window:setVisible(false)
		self:_setPage(self._prePage,false)
	elseif self.viewCtrl:getSelectedPage() == "BattleTestView" then
		ViewManager.open("BattleTestView")
		self.window:setVisible(false)
		self:_setPage(self._prePage,false)
	elseif self.viewCtrl:getSelectedPage() == "GuideEditView" then
		ViewManager.open("GuideEditView")
		self.window:setVisible(false)
		self:_setPage(self._prePage,false)
	elseif self.viewCtrl:getSelectedPage() == "BattleEditView" then
		--Dispatcher.dispatchEvent(EventType.Battle_playEditBattle,{fightID=DynamicConfigData.t_endlessRoadConst[1].fightId,configType=GameDef.BattleArrayType.EndlessRoad})
		ViewManager.open("BattleEditView")
		self.window:setVisible(false)
		self:_setPage(self._prePage,false)
	else
		Super.onViewControllerChanged(self)
	end
	
	
	
end

function GMView:_initReflashLua()
	local ListLua = self.view:getChildAutoType("ListLua")
	local reflashLua = self.view:getChildAutoType("reflashLua")
	local checkLua = self.view:getChildAutoType("checkLua")
	
	local infoLua = {}
	
	local type = 1
	ListLua:setItemRenderer(function(index,obj)
			local rtext = obj:getChildAutoType("rtext")
			local title = obj:getChildAutoType("title")
			rtext:setVisible(false)
			title:setVisible(false)
			if type == 1 then
				title:setVisible(true)
				title:setText(GMModel.changeLuaFile[index+1]..DescAuto[126]) -- [126]="   -->已重新加载"
			elseif type == 2 then
				rtext:setVisible(true)
				if tonumber(GMModel.gameStartTime) < tonumber(infoLua[index+1].t) then
					rtext:setText(infoLua[index+1].k.."      [color=##FF0000]["..os.date("%Y-%m-%d %H:%M %S", infoLua[index+1].t)..DescAuto[127]) -- [127]="] 已修改 [/color]"
				else
					rtext:setText(infoLua[index+1].k.."      [color=##555500]["..os.date("%Y-%m-%d %H:%M %S", infoLua[index+1].t).."][/color]")
				end
			end
		end)
		 
	reflashLua:addClickListener(function()
			GMModel:findChangeLua(true)
			type = 1
			if #GMModel.changeLuaFile == 0 then
				
			else
				ListLua:setNumItems(#GMModel.changeLuaFile)
			end
		end) 
	checkLua:addClickListener(function()
			
			infoLua = {}
			for k,v in pairs(package.loaded) do
				local ifs = {}
				ifs.k = k
				ifs.t = GMModel:getLuaFileTime (k) or 0
				table.insert(infoLua,ifs)
			end
			table.sort(infoLua,function(a,b)
					return a.t > b.t
			end)
			type = 2
			ListLua:setNumItems(#infoLua)
		end)
	
end  
 
function GMView.showLuaError(_,str)
	if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM == CC_PLATFORM_MAC then
		print(33,str)
		local labelText = cc.Label:create()
		
		labelText:setSystemFontSize(24)
		labelText:setAnchorPoint(0.5,1)
		labelText:setPosition(display.width/2, -10)
		labelText:setDimensions(display.width-20,display.height-20 )
		labelText:setVerticalAlignment(0)
		labelText:setString(str)
		labelText:setColor({r=255,g=0,b=0})
		--display.getRunningScene():addChild(labelText,999)
		 
		ViewManager.getParentLayer(LayerDepth.Alert):displayObject():addChild(labelText,999)
		
		labelText:runAction(cc.Sequence:create(cc.DelayTime:create(3),
				cc.FadeOut:create(2),
				cc.CallFunc:create(function()
						labelText:removeFromParentAndCleanup(true)
		end)))
	end
end

return GMView
