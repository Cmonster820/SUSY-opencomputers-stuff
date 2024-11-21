--format: see __packet and __encryptedpacket
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
component = require("component")
event = require("event")
m = component.modem
d = component.data
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
    print("Handing off to Encryption Processor")
    return rPublic
end
Function EncryptAndSendCardData(cardData)
    rPublic = Handshake()
    print("Picking Up Encryption Process")
    print("Encrypting [      ] - Generating Key Pair")
    local sPublic, sPrivate = d.generateKeyPair(384)
    print("Encrypting [=     ] - Key Pair Generated, Generating Encryption Key")
    local encryptionKey = d.md5(d.ecdh(sPrivate, rPublic))
    print("Encrypting [==    ] - Encryption Key Generated, Generating Initiation Vector")
    __encryptedpacket.header.iv = d.random(16)
    print("Encrypting [===   ] - Initiation Vector Generated, Storing sPublic to Packet Header")
    __encryptedpacket.header.sPublic = sPublic.serialize()
    print("Encrypting [====  ] - sPublic Stored to Packet Header, Storing cardData to Packet Data")
    __encryptedpacket.data = cardData
    print("Encrypting [===== ] - cardData Stored to Packet Data, Serializing and Encrypting Packet Data")
    __encryptedpacket.data = d.encrypt(serialization.serialize(__encryptedpacket.data), encryptionKey, __encryptedpacket.header.iv)
    print("Encrypting [======] - Packet Data Encrypted and Serialized")
    print("Encrypted [======]")
    print("Constructing and Sending Packet [    ] - Storing Target to Routing Data")
    __packet.routingData.destination = "mainframe"
    print("Constructing and Sending Packet [=   ] - Target Stored to Routing Data, Storing Encrypted Packet to Data")
    __packet.data = __encryptedpacket
    print("Constructing and Sending Packet [==  ] - Encrypted Packet Stored to Data, Serializing Packet")
    local message = serialization.serialize(__packet)
    print("Packet Constructed, Sending Packet [=== ] - Packet Serialized, Sending Packet")
    m.send(router, mainport, message)
    print("Sending Packet [====] - Packet Sent")
    print("Packet Sent")
    __packet.routingData.destination = nil
    __packet.data = nil
    __encryptedpacket.header.iv = nil
    __encryptedpacket.header.sPublic = nil
    __encryptedpacket.data = nil
    print("Packets Reset, Resuming Operation")
    event.listen("modem_message", pong)
end
while true do
    local eventName, address, playerName, cardData, cardUniqueId, isCardLocked, side = event.pull("magData") --takes data from magreader
    EncryptAndSendCardData(cardData)
    print("Authorizing")
    event.ignore("modem_message", pong)
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


