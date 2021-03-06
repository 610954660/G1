--Name : GroupList.lua
--Author : generated by FairyGUI
--Date : 2020-5-9
--Desc : 

local GroupList,Super = class("GroupList",BindView)

function GroupList:ctor(viewObj)
		self._view = false;
		self._list=false
		self._listData ={}
		self._showName=false
		self._fontSize=false
		self._firstSelect=0
		self._firstSelect1=0
		self._itemRenderThisObj=false
		self._itemRenderer=false
		self._itemClickThisObj=false
		self._itemClick=false
		self._selectedId=false
		self._selectedIndex=false
		self._selectedGroup=false
		self._groupOpenState ={}
		self._dispData ={}    
		self._state = 0;--0:共存 1:互斥
		self:initObj(viewObj)
end

function GroupList:initObj(viewObj)
	self._view=viewObj
	self:initView();
end

function GroupList:initView() 
	self._list = self._view;
	self._list:setVirtual();
	self._list:setItemRenderer(function(indexList,obj)
		obj:removeClickListener(100)--池子里面原来的事件注销掉
	   local index=indexList+1
	   local data = self._dispData[index];
	--printTable(15,"iiiiiiiooooooooo",data)
	   local groupIndex = data.groupIndex;
	   local itemIndex = data.index;
	   local indexStr = groupIndex .."_" ..itemIndex;
	   local gCtr1=obj:getController("c1");  --0  1 2 3
	   if data.isGroup then
		   local cIndex = (self._groupOpenState[groupIndex] and 1 or 0) --+ (self._selectedGroup == groupIndex and 2 or 0)
		-- local str="打印的"..index.."组"
		--    printTable(15,str,index,cIndex,self._groupOpenState,self._selectedGroup,groupIndex)
		   gCtr1:setSelectedIndex(cIndex);
		   if groupIndex == self._selectedGroup then
			   self._selectedIndex = index;
			end
			   obj:removeClickListener(100)
			   obj:addClickListener(function( ... )
				if self._state == 1 and self._selectedGroup ~= groupIndex then 
					self._groupOpenState[self._selectedGroup] = false
				end
			   self._groupOpenState[groupIndex] = not self._groupOpenState[groupIndex];
			   if (self._groupOpenState[groupIndex])  then --展开的时候,选中第一个
				   local itemData = self._listData[groupIndex].data[1];
				   if (itemData) then
					   self._selectedId = groupIndex .. "_" .. 1;
					   self._selectedGroup = groupIndex;
					   if self._itemClick then 
						self:_itemClick(groupIndex, itemIndex, itemData)
					   end
					end
				end
			   self:refreshList()
			   end,100)
		   if self._itemRenderer ~= nil then
			-- printTable(15,">>>>>>>iiiiiiaq",groupIndex,obj,self._listData[groupIndex],data.data)
			self:_itemRenderer(groupIndex, -1, obj, self._listData[groupIndex], data.data)
		   end
	   else 
		local ctrIndex=4
		if indexStr == self._selectedId then
			ctrIndex=5
		end
		printTable(15,"打印的控制器",indexStr,self._selectedId,ctrIndex)
			gCtr1:setSelectedIndex(ctrIndex);
		   obj:removeClickListener(100)
		   obj:addClickListener(function( ... )
			if (indexStr ~= self._selectedId) then
				self._selectedId = indexStr;
				self._selectedGroup = groupIndex;
				self:updateList(false);
				if (self._itemClick) then
					self:_itemClick(groupIndex, itemIndex, data.data)
				end
			end
			end)
		   if self._itemRenderer ~= nil then
			-- printTable(15,">>>>>>>iiiiiiaq>>>>>>>",groupIndex,itemIndex,obj,data.data)
				self:_itemRenderer(groupIndex, itemIndex, obj, data.data)
		   end
		end
	end)
	self._list:setNumItems(0);
end


function GroupList:setState(state)
	self._state = state;
end


function  GroupList:updateList(isGroupClick) 
	if self._list then
		self._list:setNumItems(#self._dispData)
		--self._list:setSelectedIndex(self._selectedIndex)
	end
	if isGroupClick then--只有点了组的按钮才需要滚动到可见位置
		printTable(16,"sdafffffffff",self._selectedIndex)
		self._list:scrollToView(self._selectedIndex, true, false)
	end
end

function  GroupList:refeashRed() 
	if self._list then
		self._list:setNumItems(#self._dispData)
	end
end


function GroupList:refreshVirtualList()--/** 刷新列表数据 */
	if self._list then
		self._list:setNumItems(#self._dispData)
		self._list:refreshVirtualList();
	end
end

function GroupList:resetList()
	if self._groupOpenState then
		for i = 1, #self._groupOpenState, 1 do
			self._groupOpenState[i] = false;
		end
	end
end

function GroupList:setFirstSele()
	if self._groupOpenState then
		for i = 1, #self._groupOpenState, 1 do
			self._groupOpenState[i] = false;
		end
	end
end

function GroupList:setFirstSelect(group,sele)
	self._firstSelect=group;
	self._firstSelect1=sele;
end

function GroupList:refreshList()
	self._dispData = {};
	for i = 1, #self._listData, 1 do
		table.insert( self._dispData, { isGroup= true, selected= 0, groupIndex= i, index= -1, data= self._listData[i] })
		if self._groupOpenState[i] then
			local datas = self._listData[i].data;
			for k = 1, #datas, 1 do
				table.insert(self._dispData,{ isGroup= false, selected= 0, groupIndex= i, index= k, data= self._listData[i].data[k] })
			end
		end
	end
	--printTable(15,"da>>>>>>>>",self._dispData)
	self:updateList(false);
end



--   data:[{name:name,open:open,data:group,color:color}] 只用到了
--   group:[];  这个是list 处理的时候使用
function GroupList:listData(data) 
	printTable(15,"挡圈答题的睡得水电费我",data)
	if self._state == 1 then
		self:resetList();
	end
	self._selectedId = self._firstSelect.."_"..self._firstSelect1;
	self._selectedGroup = 1;
	self._selectedIndex=1;
	self._listData = data;
	for i = 1, #data, 1 do
		if data[i] and data[i].open then
			self._groupOpenState[i] = data[i].open;
			if data[i].open then
				self._selectedGroup=i
				self._selectedIndex=i;
				break;
			end
		end
	end

	if #data > 0 and #(data[1].data) > 0 then
		if self._state==0 then
			self:_itemClick(0, 0, data[1].data[1])--初始化的时候选中第一个，回调一次
		else
			--printTable(15,"当前选中的",self._selectedGroup,self._firstSelect1,data[self._selectedGroup].data[self._firstSelect1])
			self:_itemClick(self._selectedGroup, self._firstSelect1, data[self._selectedGroup].data[self._firstSelect1])
		end
	end
	self:refreshList();
end

function GroupList:setRenderItem(callBack) --设置ItemRender回调
   self._itemRenderer = callBack;
end


function GroupList:setItemClick(callBack) 
	self._itemClick = callBack;
end


function GroupList:_exit()
	if(self._list)then
		self._list:setNumItems(0)
	end
	--self._list = false;
	self._view = false;
	self._listData = {};
	self._firstSelect=0;
	self._firstSelect1=0;
	self._showName = false;
end


return GroupList