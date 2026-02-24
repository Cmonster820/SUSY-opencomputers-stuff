--new security mainframe, likely will give up before finishing because this is just a project to
--stop me from getting bored before I leave and go home and can do the ai agent part of boot.dev
local component = require("component")
local event = require("event")
local m = component.modem
local filesystem = require("filesystem")
local serialization = require("serialization")
local io = require("io")
local mainport = 1
m.open(mainport)
local newdeviceport = 2
m.open(newdeviceport)
local negotiationport = 3
m.open(negotiationport)
local sPublic, sPrivate = d.generateKeyPair(384)
local d = component.data
local g = component.gpu
assert((m.isOpen(mainport) && m.isOpen(newdeviceport) && m.isOpen(negotiationport))=true,"Error detected, halting operation")
print("All ports opened successfully, proceeding with bootup")
local resX, resY = g.getResolution
if filesystem.exists("/home/data") == false then
    filesystem.makeDirectory("/home/data/")
    local ownName = io.open("/home/data/name.txt","a")
    ownName:write("mainframe")
    name = "mainframe"
    local data = io.open("/home/data/data.csv", "a")
    data:close()
    local log = io.open("/home/data/log.txt", "a")
    log:close()
    ownName:close()
    local dataCache = {}
else
    local dataCache = {}
    for line in io.lines("/home/data/data.csv") do
        local commaIndex = line:find(",")
        dataCache[line:sub(1,commaIndex-1)] = line:sub(commaIndex+1)
    end
    local name = "mainframe"
end
local packet = 
{
    routingData = 
    {
        destination = nil,
        from = name,
        fromaddr = component.modem.address
    },
    data = nil
}
local encryptedpacket = 
{
    header =
    {
        iv = nil,
        sPublic = nil
    },
    data = nil
}
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
    m.send(dataCache["router"], mainport, serialization.serialize(packet))
    packet.data.header.iv = nil
    packet.data.header.sPublic = nil
    packet.data.data = nil
    packet.routingData.destination = nil
end
function ReceiveAndDecrypt()
    local _, receiver, from, port, distance, message = event.pull("modem_message")
    local message = serialization.unserialize(message)
    local rPublic = d.deserializeKey(message.data.data.header.sPublic,"ec-public")
    local decryptionKey = d.md5(d.ecdh(sPrivate, rPublic))
    local data = d.decrypt(message.data.data.data, decryptionKey, message.data.data.header.iv)
    local data = serialization.unserialize(data)
    local from = message.routingData.from
    ProcessMessage(from, data)
end
function RespondToHandshake(receiver, from, port, distance, message)
    packet.routingData.destination = message.routingData.from
    packet.data = sPublic.serialize()
    m.send(from, port, serialization.serialize(packet))
    packet.routingData.destination = nil
    packet.data = nil
    ReceiveAndDecrypt()
end

function mainfunction(receiveraddr, sender, port, distance, message)
    message = serialization.unserialize(message)
    
end
event.listen("modem_message", mainfunction)
event.pull("interrupted")
event.ignore("modem_message", mainfunction)