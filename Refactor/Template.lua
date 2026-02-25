--This file is the template for all devices, it contains the negotiation script required to automatically join a network
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
local g = component.gpu
assert((m.isOpen(mainport) && m.isOpen(newdeviceport) && m.isOpen(negotiationport))=true,"Error detected, halting operation")
print("All ports opened successfully, proceeding with bootup")
local packet = 
{
    routingData = 
    {
        destination = nil,
        from = nil,
        fromaddr = component.modem.address
    },
    data = nil
}
local resX, resY = g.getResolution
if filesystem.exists("/home/data") == false then
    filesystem.makeDirectory("/home/data/")
    local ownName = io.open("/home/data/name.txt","a")
    ownName:write() --put default name here
    local data = io.open("/home/data/data.csv", "a")
    data:close()
    local log = io.open("/home/data/log.txt", "a")
    ownName:close()
    log:close()
else
    local dataCache = {}
    for line in io.lines("/home/data/data.csv") do
        local commaIndex = line:find(",")
        dataCache[line:sub(1,commaIndex-1)] = line:sub(commaIndex+1)
    end
    local namefile = io.open("/home/data/name.txt","a")
    local name = namefile:read()
    namefile:close()
end
local function negotiate()
    local data = io.open("/home/data/data.csv","a") 
    local namefile = io.open("/home/data/name.txt","a")
    local log = io.open("/home/data/log.txt", "a")
    packet.from = name
    m.broadcast(newdeviceport, serialization.serialize(packet))
    log:write("Message broadcasted:\n"+serialization.serialize(packet)+"\n\n\n")
    local receiveraddr, sender, port, distance, message = event.pull("modem_message")
    log:write("Message received from "+sender+" on port "+port+" message reads:\n"+serialization.unserialize(message)+"\n\n\n")
    data:write("router",sender)
    message = serialization.unserialize(message)
    if message.data == "Negotiation Successful" then
        print("Negotiation Successful")
        log:close()
        data:close()
        namefile:close()
    elseif message == "Name Taken" then
        --[[
        io.stderr:write("Error: name taken, halting operation")
        os.exit()
        ]] --above is if only one can exist (ex.: security mainframe), below is if multiple of the device can exist (ex.: access control node)
        --[[taken = true
        i = 1
        while taken do
            name:gsub("%d", "")
            i++
            name = name+tostring(i)
            packet.routingData.from = name
            m.send(router, negotiationport, serialization.serialize(packet))
            log:write("message sent to router on "+negotiationport+" contents:\n"+serialization.serialize(packet)+"\n\n\n")
            local receiveraddr, sender, port, distance, message = event.pull("modem_message")
            log:write("message recieved from "+sender+" on "+port+" contains:\n"+message+"\n\n\n")
            taken = not(serialization.deserialize(message)=="Name Taken")
        end
        log:close()
        data:close()
        namefile:close()
        filesystem.remove("/home/data/name.txt")
        namefile = io.open("/home/data/name.txt", "a")
        namefile:write(name)
        namefile:close()
        print("Negotiation Complete")
        return nil]]
    end
end
if dataCache[router] == nil then
    negotiate()
end
function mainfunction(receiveraddr, sender, port, distance, message) --rename if needed
end
event.listen("modem_message", mainfunction)
event.pull("interrupted")
event.ignore("modem_message", mainfunction)