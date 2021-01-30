
-- added by zn
-- 问卷调查

local QuesSurveyModel = class("QuesSurveyModel", BaseModel);

function QuesSurveyModel:ctor()
    self.allQues = {};
    self.reward = {};
    self.endTime = 0;
    self.curQuestion = 1;
    self:initListeners();
    -- 已经选择的
    self.selectedList = {};
    -- 描述文本
    self.content_txt = "";
    -- 奖励领取状态
    self.rewardStatus = false;
    -- 已做答答案
    self.answerList = {};

    self.mainActiveId = 1;
end

function QuesSurveyModel:initData(param)
    if (param and param.showContent and type(param.showContent) == "table") then
        self.allQues = param.showContent.allQues;
        self.reward = param.showContent.reward;
        self.endTime = param.realEndMs / 1000;
        self.mainActiveId = param.showContent.mainActiveId;
    end
end

-- 更新数据
function QuesSurveyModel:upData(param)
    self.answerList = param.answerList or {};
    self.rewardStatus = param.rewardStatus or false; --or self.rewardStatus;
    self.curQuestion = math.max(1, math.min(#self.answerList + 1, #self.allQues));
    if (param.rewardStatus) then
        ActivityModel:speDeleteSeverData(GameDef.ActivityType.QuestionnaireSurvey)
    end
    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.QuestionnaireSurvey, not param.rewardStatus);
    Dispatcher.dispatchEvent(EventType.QuestionnaireSurvey_upData);
end

-- 获取当前题目
function QuesSurveyModel:getCurQues()
    if (not self.allQues) then return nil end;
    return self.allQues[self.curQuestion];
end

function QuesSurveyModel:nextQues(cb)
    local quesInfo = self:getCurQues();
    -- 判断是否满足最低选项要求
    if (#self.selectedList < quesInfo.numMin) then
        -- LuaLogE(Desc.quesSurvey_needChooseMore)
        RollTips.show(string.format(Desc.quesSurvey_needChooseMore, quesInfo.numMin - #self.selectedList));
        return false;
    end
    -- 判断能否进入下一题
    local info = {
        quesId = quesInfo.quesId,
        contentText = self.content_txt or "",
        options = self.selectedList;
    }
    RPCReq.Activity_QuestionnaireSurvey_AnswerQues(info);
    
    return true;
end

-- 获取当前题目的答题状态
function QuesSurveyModel:isFinalQues()
    return self.curQuestion >= #self.allQues;
end

-- 1 单选 2 问答
function QuesSurveyModel:getQuesType(quesId)
    if (not self.allQues or #self.allQues == 0) then return 0 end;
    quesId = quesId == nil and self.curQuestion or quesId;
    local data = self.allQues[quesId]
    local quesType = data.quesType; -- 只区分选择跟填空
    local type = 2; -- 默认是多选 1 单选 2 多选 3问答
    if (quesType == 2) then
        type = 3;
    elseif (data.numMin == data.numMax and data.numMin == 1) then
        type = 1;
    end
    return quesType, type;
end

-- 选择
function QuesSurveyModel:select(idx)
    local conf = self:getCurQues();
    if (conf.numMax == 1) then
        self.selectedList = {
           [1]=idx
        }
        return true;
    elseif (#self.selectedList >= conf.numMax) then
        RollTips.show(Desc.quesSurvey_chooseMax);
        return false;
    end
    table.insert(self.selectedList, idx);
    return true;
end

-- 是否已经选择
function QuesSurveyModel:isSelected(idx)
    for _, index in ipairs(self.selectedList) do
        if (idx == index) then
            return true;
        end
    end
    return false;
end

-- 取消选择
function QuesSurveyModel:unselect(idx)
    for i in ipairs(self.selectedList) do
        if (idx == self.selectedList[i]) then
            table.remove(self.selectedList, i);
            return;
        end
    end
end

function QuesSurveyModel:getQuesTitle()
    local data = self:getCurQues();
    local base = data.ques;
    local pre = "";
    if (data.quesType == 2) then  -- 问答
        pre = Desc.quesSurvey_quesType3..": ";
    elseif (data.numMin == data.numMax and data.numMin == 1) then -- 单选
        pre = Desc.quesSurvey_quesType1..": ";
    else -- 多选
        pre = Desc.quesSurvey_quesType2..": ";
    end
    local tail = string.format(" ([color=#FFC35B]%s[/color]/%s)", self.curQuestion, #self.allQues);
    return pre..base..tail;
end

function QuesSurveyModel:resetSelected()
    self.selectedList = {};
    self.content_txt = "";
end

return QuesSurveyModel