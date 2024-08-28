--format: [Destination] [From] [Message]
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
local component = require("component")
local event = require("event")
local m = component.modem
local words = {}
local mainport = 1 --Change to change port, also change top comment
m.open(mainport)
print(m.isOpen(mainport))
local mainframe = "5287b40b-8bcb-4bfc-af82-fbd76ce133ed" --change to mainframe modem address
print("mainframe = ", mainframe)
local ACS1 = "a21d01d1-fefa-4bf5-8af9-77850f43f60c" --change to Access Controller 1 modem address
print("Access Controller 1 = ", ACS1)
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
        --routing part:
        if k == 1 and v == "ACS1" then
            print(m.send(tostring(ACS1), mainport, tostring(message)))
        elseif k == 1 and v == "mainframe" then
            print(m.send(tostring(mainframe), mainport, tostring(message)))
        end
        os.sleep(0.06)
    end
end