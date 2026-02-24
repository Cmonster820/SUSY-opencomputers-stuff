--new security mainframe, likely will give up before finishing because this is just a project to
--stop me from getting bored before I leave and go home and can do the ai agent part of boot.dev
component = require("component")
event = require("event")
m = component.modem
filesystem = require("filesystem")
serialization = require("serialization")
io = require("io")
mainport = 1
m.open(mainport)
newdeviceport = 2
m.open(newdeviceport)
negotiationport = 3
m.open(negotiationport)
sPublic, sPrivate = d.generateKeyPair(384)
d = component.data
g = component.gpu
assert((m.isOpen(mainport) && m.isOpen(newdeviceport) && m.isOpen(negotiationport))=true,"Error detected, halting operation")
print("All ports opened successfully, proceeding with bootup")
packet = 
{
    routingData = 
    {
        destination = nil,
        from = nil,
        fromaddr = component.modem.address
    },
    data = nil
}
encryptedpacket = 
{
    header =
    {
        iv = nil,
        sPublic = nil
    },
    data = nil
}
resX, resY = g.getResolution
if filesystem.exists("/home/data") == false then
    filesystem.makeDirectory("/home/data/")
    ownName = io.open("/home/data/name.txt","a")
    data = io.open("/home/data/data.csv", "a")
    data:close()
    log = io.open("/home/data/log.txt", "a")
    log:close()
    dataCache = {}
else
    dataCache = {}
    for line in io.lines("/home/data/data.csv") do
        commaIndex = line:find(",")
        dataCache[line:sub(1,commaIndex-1)] = line:sub(commaIndex+1)
    end
end
function negotiate()
    local data = io.open("/home/data/data.csv","a") 
    local namefile = io.open("/home/data/name.txt","a")
    local log = io.open("/home/data/log.txt", "a")
    packet.from = name
    m.broadcast(newdeviceport, serialization.serialize(packet))
    log:write("Message broadcasted:\n"+serialization.serialize(packet)+"\n\n\n")
    local receiveraddr, sender, port, distance, message = event.pull("modem_message")
    log:write("Message received from "+sender+" on port "+port+" message reads:\n"+serialization.deserialize(message)+"\n\n\n")
    data:write("router",sender)
    if message == "Negotiation Successful" then
        print("Negotiation Successful")
        log:close()
        data:close()
        namefile:close()
    elseif message == "Name Taken" then
        io.stderr:write("Error: name taken, halting operation")
        os.exit()
    end
end
if dataCache["router"] == nil then
    negotiate()
end

function InitiateHandShake(destination)
    packet.routingData.destination = destination
    packet.data = "prepare"
    m.send(router, mainport, serialization.serialize(packet))
    local _, receiver, from, port, dist, message = event.pull("modem_message")
    packet.data = nil
    packet.routingData.destination = nil
    local message = serialization.unserialize(message)
    local rPublic = message.data
    return rPublic
end
function EncryptAndSendMessage(destination,data) 
    local rPublic = InitiateHandShake(destination)
    rPublic = d.deserializeKey(rPublic,"ec-public")
    local encryptionKey = d.md5(d.ecdh(sPrivate, rPublic))
    packet.data.header.iv = d.random(16)
    packet.data.header.sPublic = sPublic.serialize()
    packet.data.data = data
    packet.data = d.encrypt(serialization.serialize(packet.data), encryptionKey, packet.header.iv)
    packet.routingData.destination = destination
    m.send(router, mainport, serialization.serialize(packet))
    packet.data.header.iv = nil
    packet.data.header.sPublic = nil
    packet.data.data = nil
    packet.routingData.destination = nil
end


function mainfunction(receiveraddr, sender, port, distance, message) --rename if needed
end
event.listen("modem_message", mainfunction)
event.pull("interrupted")
event.ignore("modem_message", mainfunction)