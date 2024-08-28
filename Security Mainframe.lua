--format: [Destination] [From] [Message]
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
local component = require("component")
local event = require("event")
local m = component.modem
local words = {}
local mainport = 1 --Change to change port, also change top comment
local Cards = {"123"}
m.open(mainport)
print(m.isOpen(mainport))
local router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9" --change to router's
print("router = ", router)
while true do
    local requestType = ""
    words = {}
    local _, _, from, port, _, message = event.pull("modem_message")
    os.sleep(0.06)
    for w in string.gmatch(message, "[^ ]+") do --splits the message by word into table words
        table.insert(words, w)
    end
    print("Got a message from " .. from .. " on port " .. port .. ":" .. tostring(message))
    for k, v in pairs(words) do --looks through words
        print(k, v)
        if k == 2 then
            from = v
        elseif k == 3 and v == "openrequest" then
            requestType = "openDoor"
        elseif k == 4 and requestType == "openDoor" then
            for h, j in pairs(Cards) do
                if v == j then
                    m.send(router, 1, tostring(from) .. " mainframe authorized")
                end
            end
        end
        os.sleep(0.06)
    end
end