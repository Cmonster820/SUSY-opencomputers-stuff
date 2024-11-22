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
local nameList = {mainframe, ACS1} --list of names, parallel with addresses
local addressList = {"5287b40b-8bcb-4bfc-af82-fbd76ce133ed", "a21d01d1-fefa-4bf5-8af9-77850f43f60c"}
for k, v in pairs(nameList) do
    print(k, v, addressList[k])
end
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
        for l, b in pairs(namelist) do
            if b == k then
                m.send(addressList[l], mainport, message)
            end
        end
    end
end
