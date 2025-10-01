--only works on cases, not servers for whatever reason
local component = require("component")
local event = require("event")
local Cooper = "123" -- what do I care about leaking my name online anymore
local words = {}
local door = component.os_doorcontroller

while true do
    words = {} --clears table words
    local eventName, address, playerName, cardData, cardUniqueId, isCardLocked, side = event.pull("magData") --takes data from magreader
    print(tostring(eventName), tostring(address), tostring(playerName), tostring(cardData), tostring(cardUniqueId), tostring(isCardLocked), tostring(side)) --prints everything
    if cardData == Cooper then --if the card matches whats on mine then
        door.open()            --open the door
        print("Door Open")
        os.sleep(2)            --wait 2 seconds
        print("Door Closed")
        door.close()           --close the door
    end
end