--枚举
--网络未连接
gy.NETWORK_STATUS_NOT_CONNECTED = 0
--wifi网络
gy.NETWORK_STATUS_WIFI = 1
--移动网络
gy.NETWORK_STATUS_MOBILE = 2

gy.DEVICE_ORIENTATION_UNKNOWN = 0
gy.DEVICE_ORIENTATION_PORTRAIT = 1
gy.DEVICE_ORIENTATION_PORTRAIT_UPSIDE_DOWN = 2
gy.DEVICE_ORIENTATION_LANDSCAPE_LEFT = 3
gy.DEVICE_ORIENTATION_LANDSCAPE_RIGHT = 4
gy.DEVICE_ORIENTATION_FACE_UP = 5
gy.DEVICE_ORIENTATION_FACE_DOWN = 6

--传感器类型
gy.SENSOR_TYPE_GRAVITY = 9

--引擎新接口方法兼容
if not FRMD5 then
    function FRMD5(str)
        return gy.GYStringUtil:getStringMD5(str)
    end
end

