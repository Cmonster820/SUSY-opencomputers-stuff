local component = require("component")
local event = require("event")
local m = component.modem
local words = {}
local alarm = component.os_alarm
local door = component.os_doorcontroller
m.open(1)
print(m.isOpen(1))
while true do
    words = {}
    local _, _, from, port, _, message = event.pull("modem_message")
    os.sleep(0.06)
    for w in string.gmatch(message, "[^ ]+") do
        table.insert(words, w)
    end
    print("Got a message from " .. from .. " on port " .. port .. ":" .. tostring(message))
    for k, v in pairs(words) do
        print(k, v)
        if tostring(v) == "alarmon" and k == 1 then
            alarm.activate()
            print("Alarm On")
        elseif tostring(v) == "alarmoff" and k == 1 then
            alarm.deactivate()
            print("Alarm Off")
        elseif tostring(v) == "opendoor" and k == 2 then
            door.open()
            print("Door Open")
        elseif tostring(v) =="closedoor" and k ==2 then
            door.close()
            print("Door Closed")
        end
    end
end