--format: [Destination] [From] [Message]
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
component = require("component")
event = require("event")
m = component.modem
d = component.data
words = {}
mainport = 1 --Change to change port, also change top comment
door = component.os_doorcontroller
serialization  = require("serialization")
name = nil --change this to from a file later
__packet =
{
    routingData =
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
Function Handshake()
    event.ignore("modem_message", pong)
    print("Handshake [     ] - Constructing Packet")
    __packet.routingData.destination = "mainframe"
    __packet.data = "prepare"
    print("Handshake [=    ] - Packet Constructed, Sending Packet")
    local packet = serialization.serialize(__packet)
    m.send(router, mainport, packet)
    print("Handshake [==   ] - Packet Sent, Awaiting rPublic")
    local receiver, from, port, dist, message = event.pull("modem_message")
    print("Handshake [===  ] - Packet Received, Deserializing")
    local message = serialization.unserialize(message)
    print("Handshake [==== ] - Packet Deserialized, Reconstructing Key Object")
    local rPublic = d.deserializeKey(message.data,"ec-public")
    print("Handshake [=====] - Key Object Reconstructed, Handshake Complete")
    print("Handshake COMPLETE")
    print("Hands Have Been Shaken")
    return rPublic
end
Function EncryptAndSendCardData(cardData)
    rPublic = Handshake()
    
end
while true do
    local eventName, address, playerName, cardData, cardUniqueId, isCardLocked, side = event.pull("magData") --takes data from magreader
    EncryptAndSendCardData(cardData)
    print("Authorizing")
    event.ignore("modem_message", pong)
    words = {}
    local receiver, from, port, dist, message = event.pull("modem_message")
    event.listen("modem_message", pong)
    print("Got a message from " .. from .. " on port " .. port .. ":" .. tostring(message))
    if message == "ping" then
        pong(receiver, from, port, distance, message)
        goto 
    end
    local message = serialization.unserialize(message)
    if message.data == "authorized" then
        print("Authorized")
        door.open()
        print("Door Open")
        os.sleep(2)
        door.close()
        print("Door Closed")
    elseif message.data == "denied" then
        print("Access Denied")
        door.close()
    end
end


