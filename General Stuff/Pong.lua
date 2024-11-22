--INTENDED FOR COMPUTERS BECAUSE I TRIED WITH MICROCONTROLLERS AND IT DIDNT WORK
--ROUTER: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
--PORT: 1

--to add more to network, you must get the address of the modem and add it to the ping server's list

local component = require("component")
local event = require("event")
local m = component.modem
local r = component.redstone
local words = {}
local mainport = 1 --Change to change port, also change top comment
local devicename = "pong1" --change sequentially
local allon = {15, 15, 15, 15, 15, 15}
local alloff = {0, 0, 0, 0, 0, 0}
m.open(mainport)
print(m.isOpen(mainport))
local router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9" --change to router's
print("router = ", router)
while true do
    words = {}
    local _, _, from, port, _, message = event.pull("modem_message")
    os.sleep(0.06)
    for w in string.gmatch(message, "[^ ]+") do --splits the message by word into table words
        table.insert(words, w)
    end
    print("Got a message from " .. from .. " on port " .. port .. ":" .. tostring(message))
    for k, v in pairs(words) do --looks through words
        print(k, v)
        if v == "ping" then
            print("ping")
            r.setOutput(allon)
            os.sleep(0.1)
            r.setOutput(alloff)
            local _, _, oldValue, newValue = event.pull("redstone_changed")
            if oldValue < newValue then
                m.send(from, mainport,"pong")
                print("pong")
            end
        end
    end
end