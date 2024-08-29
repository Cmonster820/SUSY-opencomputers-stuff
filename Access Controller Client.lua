--format: [Destination] [From] [Message]
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
local component = require("component")
local event = require("event")
local m = component.modem
local words = {}
local mainport = 1 --Change to change port, also change top comment
local door = component.os_doorcontroller
function pong(address, from, port, distance, message)
    if message == "ping" then
        print("ping")
        m.send(from, port, "pong")
        print("pong")
    end
end
function stop()
    os.exit() 
end
m.open(mainport)
print(m.isOpen(mainport))
local router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9" --change to router's
print("router = ", router)
event.listen("modem_message", pong())
event.listen("interrupted", stop())
while true do
    local eventName, address, playerName, cardData, cardUniqueId, isCardLocked, side = event.pull("magData") --takes data from magreader
    m.send(router, mainport, "mainframe ACS1 openrequest " .. tostring(cardData))
    print("Authorizing")
    words = {}
    local _, _, from, port, _, message = event.pull("modem_message")
    os.sleep(0.06)
    for w in string.gmatch(message, "[^ ]+") do --splits the message by word into table words
        table.insert(words, w)
    end
    print("Got a message from " .. from .. " on port " .. port .. ":" .. tostring(message))
    if message == "ping" then
        pong()
    end
    for k, v in pairs(words) do --looks through words
        print(k, v)
        if k == 3 and v == "authorized" then
            print("Authorized")
            door.open()
            print("Door Open")
            os.sleep(2)
            door.close()
            print("Door Closed")
        elseif k == 3 and v == "denied" then
            print("Access Denied")
            door.close()
        end
    end
end


