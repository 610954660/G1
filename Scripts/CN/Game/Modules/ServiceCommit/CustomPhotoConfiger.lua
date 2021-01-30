-- local CustomPhotoConfiger = class("CustomPhotoConfiger")

local CustomPhotoConfiger = {}
function CustomPhotoConfiger.ctor()
end

function CustomPhotoConfiger.init()
end

--临时文件路径
function CustomPhotoConfiger.getTempPhotoPath()
    local _customPhotoFolder = false
    local _fileUtil = cc.FileUtils:getInstance()
    local _customPhotoFolder = _fileUtil:getWritablePath() .. "photo/"
    if not _fileUtil:isDirectoryExist(_customPhotoFolder) then
        _fileUtil:createDirectory(_customPhotoFolder)
    end
    return _customPhotoFolder .. "temp11"
end

return CustomPhotoConfiger
