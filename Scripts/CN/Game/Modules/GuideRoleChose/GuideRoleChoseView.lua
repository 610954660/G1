
-- added by zn
-- 新手选性别界面

local GuideRoleChoseView = class("GuideRoleChoseView", Window)

function GuideRoleChoseView: ctor()
    self.maleId = 44005; -- 初始角色 凯文
    self.femaleId = 44004; -- 初始角色 安妮

    self._packName = "GuideRoleChose";
    self._compName = "GuideRoleChoseView";
    self.btn_male = false;
    self.btn_female = false;
    self.btn_sure = false;

    self.role_loader = false; -- 角色
    self.bg = false;
    self.category_loader = false; -- 种族
    self.profes_loader = false; -- 职业
    
    self.txt_category = false;
    self.txt_name = false;
    self.txt_profes = false;
    self.list_skill = false;

    self.skeletonNode = false;
    self.selected = 2; -- 默认选择的 女
end

function GuideRoleChoseView: _initUI()
	
    self.bg = self.view:getChild('bg');
    self.bg:setIcon(PathConfiger.getBg('bg_roleChose.png'));

    self.btn_male = self.view:getChild('male');
    self.btn_female = self.view:getChild('female');
    self.btn_sure = self.view:getChild('btn_sure');
    local role_loader = self.view:getChild('role_loader');
	self.role_loader = BindManager.bindLihuiDisplay(role_loader)
    self.category_loader = self.view:getChild('category_loader');
    self.profes_loader = self.view:getChild('profes_loader');
    self.txt_category = self.view:getChild('txt_category');
    self.txt_name = self.view:getChild('txt_name');
    self.txt_profes = self.view:getChild('txt_profes');
    self.list_skill = self.view:getChild('list_skill');

    self:changeView();
end

function GuideRoleChoseView: _initEvent()
    self.btn_male:addClickListener(function ()
        if (self.selected ~= 1) then
            self.selected = 1;
            self:changeView();
        end
    end)

    self.btn_female:addClickListener(function ()
        if (self.selected ~= 2) then
            self.selected = 2;
            self:changeView();
        end
    end)

    self.btn_sure:addClickListener(function ()
		
        ViewManager.open("GuideSetNameView", {sex = self.selected});
    end)
end

function GuideRoleChoseView: changeView()
    local roleId = self.selected == 1 and self.maleId or self.femaleId;
    local conf = DynamicConfigData.t_hero[roleId];
    if conf then
        local categoryUrl = PathConfiger.getCardCategory(conf.category)
        self.category_loader:setIcon(categoryUrl);
        self.txt_category:setText(Desc['card_category'..conf.category]);
        self.txt_name:setText(conf.heroName);

        local profesUrl = PathConfiger.getCardProfessional(conf.professional);
        self.profes_loader:setIcon(profesUrl);
        self.txt_profes:setText(conf.protext);

        -- 人物立绘

        if self.skeletonNode then 
            self.skeletonNode:removeFromParent()
            self.skeletonNode = false
        end
        local PosX = self.selected == 1 and 50 or 0;
		self.role_loader:setData(roleId)

        -- 技能展示
        local skills = {}
        for i = 1, 4 do
            local id = conf['skill'..i][1];
            if (id) then
                table.insert(skills, id);
            end
        end
        
        self.list_skill:setItemRenderer(function (idx, obj)
            local conf = DynamicConfigData.t_skill[skills[idx + 1]];
            obj:getChild('icon'):setIcon(CardLibModel:getItemIconByskillId(conf.icon));
            obj:removeClickListener();
            obj:addClickListener(function ()
                if conf then
                    ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skills[idx + 1], heroId = roleId})
                end
            end)
        end)
        self.list_skill:setNumItems(#skills);
    end
end

return GuideRoleChoseView