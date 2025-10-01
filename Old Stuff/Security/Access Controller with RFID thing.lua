--While RFID cards have lower capacity and therefore lower security, they do not require interaction with the reader, and can therefore be used to open a door with it only being within the holder's inventory
component = require("component")
event = require("event")
m = component.modem
fs = require("filesystem")
mainport = 1 --Change to change port, also change top comment (which doesn't exist anymore because I changed everything since I made the source)
serialization  = require("serialization")
door = component.os_doorcontroller
m.open(mainport)
print(m.isOpen(mainport))
negotiationport = 3
if fs.exists("/home/data.txt") == true then
    local n = 0
    for line in io.lines("/home/data.txt") do
        local n = n+1
        if n == 1 then
            router = line
        elseif n == 2 then
            name = line
        end
    end
    local n = 0
elseif fs.exists("/home/data.txt") == false then
    m.open(negotiationport)
    datafile = io.open("/home/data.txt", "a")
    m.broadcast(negotiationport, "newtonetwork")
    local _, receiver, from, port, dist, message = event.pull("modem_message")
    datafile:write(tostring(from))
    router = from
    os.sleep(0.25)
    m.send(router, port, "ACSRFID1") --replace "ACS1" with base name (or final name if only one can exist)
    local _, receiver, from, port, dist, message = event.pull("modem_message")
    if message == "name taken" then --this section will, for things that can have multiple of them on the network (In the case of where I took this from, access controllers), automatically increase the number in the name until the name is not taken
        local n = 1
        while message == "name taken" do
            n = n+1
            local _, receiver, from, port, dist, message = event.pull("modem_message")
            name = "ACSRFID" .. tostring(n)
            m.send(router, port, name)
        end
    end
    --[[if message == "name taken" then --this section will, for things that can only have one of them on the network, flash an error and automatically exit the program in the event that their name is already taken
        io.stderr:write("Name Taken, Exiting")
        os.exit()
    end]]
    datafile:write("\n" .. tostring(name))
    datafile:close()
    m.close(negotiationport)
    print("Negotiation Complete")
end
--the following is a definition of the packet structure, when clearing it after sending, DO NOT USE "__packet = nil", THAT WILL BREAK EVERYTHING, instead use "__packet.routingData.destination = nil" and "__packet.data = nil"
__packet =
{
    routingData =
    {
        destination = nil,
        from = name
    },
    data = nil
}
__encryptedpacket = 
{
    header =
    {
        iv = nil,
        sPublic = nil
    },
    data = nil
}
__requestpacket = 
{
    type = nil,
    data = nil
}
--If you're stupid like I was when I first made this (before the packet rework) and don't know how to send objects more complex than strings, you do it with "serialization.serialize(<object>)" where <object> is replaced with the variable name
r = component.os_rfidreader
d = component.data
mo = component.motion_sensor
print(mo.setSensitivity(0))
function pong(_, receiver, from, port, distance, message)
    if message == "ping" then
        print("ping")
        m.send(from, port, "pong")
        print("pong")
    end
end
function Handshake()
    event.ignore("modem_message", pong)
    print("Handshake [     ] - Constructing Packet")
    __packet.routingData.destination = "mainframe"
    __packet.data = "prepare"
    print("Handshake [=    ] - Packet Constructed, Sending Packet")
    local packet = serialization.serialize(__packet)
    m.send(router, mainport, packet)
    print("Handshake [==   ] - Packet Sent, Awaiting rPublic")
    local _, receiver, from, port, dist, message = event.pull("modem_message")
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
function EncryptAndSendCardData(cardData)
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
    __requestpacket.type = "open"
    __requestpacket.data = tostring(cardData)
    __encryptedpacket.data = __requestpacket
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
    __requestpacket.type = nil
    __requestpacket.data = nil
    print("Packets Reset, Resuming Operation")
    event.listen("modem_message", pong)
end
function MainFunc()
    carddata = r.scan(8)
    for k, v in pairs(carddata) do
        for l, b in pairs(v) do
            if l == "data" then
                local data = b
                EncryptAndSendCardData(data)
            end
        end
    end
end
event.listen("motion_sensor", MainFunc)
event.listen("modem_message", Pong)
event.pull("interrupted")
event.ignore("motion_sensor", MainFunc)
event.ignore("modem_message", Pong)