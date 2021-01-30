
-- added by zn

local QuesSurveyController = class("QuesSurveyController", Controller);

function QuesSurveyController: activity_update()
    local params = ActivityModel.actData;
    for _, data in pairs(params) do
        if data.type == GameDef.ActivityType.QuestionnaireSurvey then
            -- printTable(2233, "问卷数据", data);
            QuesSurveyModel:initData(data);
        end
    end
end

function QuesSurveyController: Activity_UpdateData(_, param)
    if param.type == GameDef.ActivityType.QuestionnaireSurvey then
		QuesSurveyModel:upData(param.questionnaireSurvey)
	end
end

return QuesSurveyController;