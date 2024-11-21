--format: [Destination] [From] [Message]
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
component = require("component")
event = require("event")
m = component.modem
words = {}
mainport = 1 --Change to change port, also change top comment
door = component.os_doorcontroller
serialization  = require("serialization")
__packet =
{
    routing data =
    {
        destination = nil
        from = name
    }
    data = nil
}
__encryptedpacket = 
{
    header =
    {
        iv = nil
        sPublic = nil
    }
    data = nil
}
function pong(receiver, from, port, distance, message)
    if message == "ping" then
        print("ping")
        m.send(from, port, "pong")
        print("pong")
    end
end
m.open(mainport)
print(m.isOpen(mainport))
router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9" --change to router's
print("router =", router)
event.listen("modem_message", pong)
while true do
    local eventName, address, playerName, cardData, cardUniqueId, isCardLocked, side = event.pull("magData") --takes data from magreader
    m.send(router, mainport, "mainframe ACS1 openrequest " .. tostring(cardData))
    print("Authorizing")
    event.ignore("modem_message", pong)
    words = {}
    local receiver, from, port, dist, message = event.pull("modem_message")
    event.listen("modem_message", pong)
    for w in string.gmatch(message, "[^ ]+") do --splits the message by word into table words
        table.insert(words, w)
    end
    print("Got a message from " .. from .. " on port " .. port .. ":" .. tostring(message))
    if message == "ping" then
        pong()
        goto 28
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


