component = require("component")
event = require("event")
m = component.modem
d = component.data
fs = require("filesystem")
mainport = 1 --Change to change port, also change top comment (which doesn't exist anymore because I changed everything since I made the source)
serialization  = require("serialization")
m.open(mainport)
print(m.isOpen(mainport))
negotiationport = 3
io = require("io")
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
    m.broadcast(mainport, "newtonetwork")
    local _, receiver, from, port, dist, message = event.pull("modem_message")
    datafile:write(tostring(from))
    router = from
    os.sleep(0.25)
    m.send(router, port, "Card Adder") --replace "ACS1" with base name (or final name if only one can exist)
    local _, receiver, from, port, dist, message = event.pull("modem_message")
    --[[if message == "name taken" then --this section will, for things that can have multiple of them on the network (In the case of where I took this from, access controllers), automatically increase the number in the name until the name is not taken
        local n = 1
        while message == "name taken" do
            n = n+1
            local _, receiver, from, port, dist, message = event.pull("modem_message")
            name = "ACS" .. tostring(n)
            m.send(router, port, name)
        end
    end]]
    if message == "name taken" then --this section will, for things that can only have one of them on the network, flash an error and automatically exit the program in the event that their name is already taken
        io.stderr:write("Name Taken, Exiting")
        os.exit()
    end
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
--If you're stupid like I was when I first made this (before the packet rework) and don't know how to send objects more complex than strings, you do it with "serialization.serialize(<object>)" where <object> is replaced with the variable name
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
function Handshake()
    print("Handshake [     ] - Constructing Packet")
    __packet.routingData.destination = "mainframe"
    __packet.data = "prepare"
    print("Handshake [=    ] - Packet Constructed, Sending Packet")
    local packet = serialization.serialize(__packet)
    m.send(router, mainport, packet)
    print("Handshake [==   ] - Packet Sent, Awaiting rPublic")
    ::rereceiverPublic::
    local _, receiver, from, port, dist, message = event.pull("modem_message")
    if port ~= 1 then
        goto rereceiverPublic
    end
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
    print("Packets Reset, Resuming Standard Operation")
end
function MainFunc(eventName, address, playerName, cardData, cardUniqueId, isCardLocked, side)
    print("player " .. playerName .. " used card " .. cardUniqueId .. ", data: " .. cardData)
    print("Transmitting Card Data to Mainframe")
    EncryptAndSendCardData(cardData)
    print("Data Transmitted")
    print("Waiting For CardSwipe")
end
print("Waiting For CardSwipe")
event.listen("magData", myFunction)
event.pull("interrupted")
event.ignore("magData", myFunction)