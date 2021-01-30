--Name : JewelryCompareView.lua
--Author : generated by FairyGUI
--Date : 2020-4-2
--Desc : 

local JewelryCompareView,Super = class("JewelryCompareView", Window)
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"

function JewelryCompareView:ctor()
	--LuaLog("JewelryCompareView ctor")
	self._packName = "Jewelry"
	self._compName = "JewelryCompareView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function JewelryCompareView:_initEvent( )
	
end

function JewelryCompareView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Equipment.JewelryCompareView
		local eqinfoBox1 = viewNode:getChildAutoType("$eqinfoBox1")--
		vmRoot.eqinfoBox1 = eqinfoBox1
			eqinfoBox1.bgLoader = viewNode:getChildAutoType("$eqinfoBox1/$bgLoader")--list
			eqinfoBox1.jineng = viewNode:getChildAutoType("$eqinfoBox1/$jineng")--list
			eqinfoBox1.title = viewNode:getChildAutoType("$eqinfoBox1/$title")--text
			eqinfoBox1.shuxing = viewNode:getChildAutoType("$eqinfoBox1/$shuxing")--list
			eqinfoBox1.itemCell = viewNode:getChildAutoType("$eqinfoBox1/$itemCell")--Button
			eqinfoBox1.shuxingExtra = viewNode:getChildAutoType("$eqinfoBox1/$shuxingExtra")
			-- eqinfoBox1.star = viewNode:getChildAutoType("$eqinfoBox1/$star")--list
		
	--{vmFieldsEnd}:Equipment.JewelryCompareView
	--Do not modify above code-------------
	vmRoot.btns = viewNode:getChildAutoType("btns")--Button
	vmRoot.btn2 = vmRoot.btns:getChildAutoType("$btn2")--Button
	vmRoot.btn3 = vmRoot.btns:getChildAutoType("$btn3")--Button
	vmRoot.btn1 = vmRoot.btns:getChildAutoType("$btn1")--Button
	
end

function JewelryCompareView:_initUI( )
	self:_initVM()
	
	self.baseCtl = self.btns:getController("base");
	if self._args.eqtype then
		self.baseCtl:setSelectedIndex(self._args.eqtype)
	end
	

	self:initViewData()
	
	-- self:initViewPos()

end

-- function JewelryCompareView:initViewPos( )
	-- if self._args.node then
	-- 	local pos = self._args.node:localToGlobal(Vector2.zero)
	-- 	local tsize = self.view:getChildAutoType("size")
	-- 	local taget = self.view:getChildAutoType("taget")
	-- 	if pos.y +tsize:getHeight() > self.view:getHeight() then
	-- 		pos.y = self.view:getHeight() - tsize:getHeight()
	-- 	end
	-- 	if pos.x +tsize:getWidth() > self.view:getWidth() then
	-- 		pos.x = self.view:getWidth() - tsize:getWidth()
	-- 	end
	-- 	taget:setPosition(pos.x,pos.y)
	-- end
	
	--local taget = self.view:getChildAutoType("taget")
	--taget:setPosition(300,150)
-- end

function JewelryCompareView:initViewData( )
	-- 更换
	self.btn1:removeClickListener(88)
	self.btn1:addClickListener(function()
			if self._args.eqtype == 1 then
				ViewManager.open("JewelryChoseListView", {pos = self._args.pos})
			end
			
			self:closeView()
		end,88)

	-- 培养
	self.btn2:removeClickListener(88)
	self.btn2:addClickListener(function()
			ViewManager.open("EquipmentforgeView", {page = "JewelryRebuildView"})
			Scheduler.scheduleNextFrame(function ()
				local uuid = self._args.eqdata.uuid;
				Dispatcher.dispatchEvent("jewelry_rebuildChoose", uuid)
			end)
			self:closeView()
		end,88)

	-- 卸下
	self.btn3:removeClickListener(88)
	self.btn3:addClickListener(function (context)
			JewelryModel:takeOffJewelry(self._args.pos);
			self:closeView()
		end,88)
	
	--if self._args.weardata then
		--self.baseCtl:setSelectedIndex(2)
		--self:initBoxData(self.eqinfoBox1,self._args.weardata)
		--self:initBoxData(self.eqinfoBox2,self._args.eqdata,self._args.weardata)
	--elseif self._args.eqdata then
		self:initBoxData(self.eqinfoBox1,self._args.eqdata)
	--end
	
	
	-- self.btn1:getChild("img_red"):setVisible(self:hasBetterEquip())
end

function JewelryCompareView:initBoxData(box, data ,wdata)

	if not box.sitemcell then
		box.sitemcell = BindManager.bindItemCell(box:getChildAutoType("$itemCell"))
		box.sitemcell.view:removeClickListener()
	end
	local conf = DynamicConfigData.t_Jewelry[data.code];
	box.sitemcell:setData(data.code, 0, CodeType.ITEM)
	--box.frame:setURL(PathConfiger.getItemFrame(info	.color, false))
	--box.icon:setURL(EquipmentModel:getEqIconByeCode(info.id))
	local color = data.color or conf.color;
	local name = data.name or conf.itemName;
	box.bgLoader:setURL(PathConfiger.getItemTipsHeadBg(color))
	box.title:setText(name)
	box.title:setColor(ColorUtil.getItemTipsColor(color))
	-- 属性
	local attr = {};
	local conf = DynamicConfigData.t_combat;
	for _,v in pairs(data.attr) do
		table.insert(attr, v);
	end
	box.shuxing:setItemRenderer(function(index,obj)
			local id = attr[index+1].id
			local sxInfo = conf[id];
			local name = obj:getChildAutoType("name")
			-- name:setText(sxInfo.description)
			name:setText(sxInfo.name)
			local value = obj:getChildAutoType("value")
			printTable(2233, sxInfo);
			local val = attr[index+1].value
			-- if (data.percentageValue) then
			-- 	val = val + math.ceil(val * data.percentageValue / 10000);
			-- end
			if (id > 100) then
				value:setText(string.format("+%s%%", val / 100))
			else
				value:setText(string.format("+%s", val))
			end
		end)
	box.shuxing:setNumItems(#attr)
	-- 技能
	local ctrl = box:getController("c1");
	if data.percentageValue and data.percentageValue > 0 then
		ctrl:setSelectedIndex(2);
		local value = data.percentageValue;
		local progress = box:getChildAutoType("progress/progressBar");
		progress:setMax(10000);
		progress:setValue(value);
		progress:getChildAutoType("title"):setText((value / 100).."%");
	elseif data.skill and #data.skill > 0 then
		ctrl:setSelectedIndex(1);
		box.jineng:setItemRenderer(function(index,obj)
			local skillId = tonumber(data.skill[index+1])
			local skillCell = BindManager.bindSkillCell(obj)
			local ultSkillurl = CardLibModel:getItemIconByskillId(skillId);
			skillCell.iconLoader:setURL(ultSkillurl) --放了一张技能图片
			skillCell.view:removeClickListener(100)
			skillCell.view:addClickListener(
				function(context)
					--点击查看技能详情
					ViewManager.open("ItemTips", {codeType = CodeType.PASSIVE_SKILL, id = skillId, data = {id = skillId}});
				end,
				100
			)
			obj:getChildAutoType("n29"):setVisible(false)
		end)
		box.jineng:setNumItems(#data.skill)
	else
		ctrl:setSelectedIndex(0);
	end
	-- end
	-- 战力
	local totalPower = JewelryModel:calcCombat(data)
	box:getChildAutoType("power"):setText(totalPower)

	local c2 = box:getController("c2");
	if (data.percentageValue and data.percentageValue > 0) then
		c2:setSelectedIndex(1)
		local add = data.percentageValue / 10000
		box.shuxingExtra:setItemRenderer(function(index,obj)
			local id = attr[index+1].id
			local sxInfo = conf[id];
			local name = obj:getChildAutoType("name")
			-- name:setText(sxInfo.description)
			name:setText(sxInfo.name)
			local value = obj:getChildAutoType("value")
			local val = math.ceil(attr[index+1].value * add)
			-- if (data.percentageValue) then
			-- 	val = val + math.ceil(val * data.percentageValue / 10000);
			-- end
			if (id > 100) then
				value:setText(string.format("+%s%%", val / 100))
			else
				value:setText(string.format("+%s", val))
			end
		end)
		box.shuxingExtra:setNumItems(#attr)
	else
		c2:setSelectedIndex(0)
	end
	
end



return JewelryCompareView