local component = require("component")
local event = require("event")
local Cooper = "339c525b-40ed-4c9d-8586-25d869297a4a"
local words = {}
local door = component.os_doorcontroller

while true do
    words = {}
    local address, reader_uuid, player_uuid =  event.pull("bioReader", onRead)
    print(tostring(address), tostring(reader_uuid), tostring(player_uuid))
    print(tostring(player_uuid) .. " entered!") -- print the UUID of the player that was scanned.

    for w in string.gmatch(tostring(player_uuid), "[^ ]+") do
        table.insert(words, w)
    end

    for k, v in pairs(words) do
        print(k, v)
        if tostring(v) == Cooper then
            door.open()
            os.sleep(2)
            door.close()
        end
    end
end