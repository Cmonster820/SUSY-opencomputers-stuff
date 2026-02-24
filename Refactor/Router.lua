--This file is a rewrite of the original router code because it kind of sucked
--this will have an option to store all packets to a file, to change the location, edit the code
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
g = component.gpu
assert((m.isOpen(mainport) && m.isOpen(newdeviceport) && m.isOpen(negotiationport))==true,"Error detected, halting operation")
print("All ports opened successfully, proceeding with bootup")

packet = 
{
    routingData = 
    {
        destination = nil,
        from = nil,
        fromaddr = nil
    },
    data = nil
}
resX, resY = g.getResolution
if filesystem.exists("/home/router") == false then
    filesystem.makeDirectory("/home/router/")
    data = io.open("/home/router/data.csv", "a")
    data:close
    log = io.open("/home/router/log.txt", "a")
    log:close
    routingTableCache = {}
else
    routingTableCache = {}
    for line in io.lines("/home/router/data.csv") do
        commaIndex = line:find(",")
        routingTableCache[line:sub(1,commaIndex-1)] = line:sub(commaIndex+1)
    end
end
function negotiation(sender, port, message)
    local name = message.routingData.from
    local address = message.routingData.fromaddr
    local log = io.open("/home/router/log.txt", "a")
    log:write(serialization.serialize(message).."\n\n\n")
    if routingTableCache[name]~=nil then
        m.send(address,port,"Name Taken")
        log:write("Message sent to "..message.routingData.fromaddr.."\n, \"Name Taken\"\n\n\n")
        log:close()
        return nil
    end
    local data = io.open("/home/router/data.csv","a")
    data:write(name..","..address)
    routingTableCache[name] = address
    data:close()
    m.send(address, port, "Negotiation Successful")
    log:write("Message sent to "..message.routingData.fromaddr.."\n, \"Negotiation Successful\"\n\n\n")
    log:close()
end
function processNewName(from ,port, message)
    local log = io.open("/home/router/log.txt", "a")
    log:write(serialization.serialize(message).."\n\n\n")
    local name = message.routingData.from
    local address = message.routingData.fromaddr
    if routingTableCache[name] ~= nil then
        m.send(message.routingData.fromaddr, port, "Name Taken")
        log:write("Message sent to "..message.routingData.fromaddr.."\n, \"Name Taken\"\n\n\n")
        log:close()
        return nil
    end
    local data = io.open("/home/router/data.csv","a")
    data:write(name..","..address)
    routingTableCache[name] = address
    m.send(message.routingData.fromaddr, port, "Negotiation Successful")
    log:write("Message sent to "..message.routingData.fromaddr.."\n, \"Negotiation Successful\"\n\n\n")
    data:close()
    log:close()
end
function processRouterCommands(message)
    if message.Data == "RequestPing" then
        m.send(message.routingData.fromaddr, mainport, routingTableCache["ping"])
    end
end
function relayMessage(message)
    log = io.open("/home/router/log.txt", "a")
    log:write(serialization.serialize(message).."\n\n\n")
    log:close()
    m.send(routingTableCache[message.routingData.destination], mainport, message)
    return "Message relayed successfully"
end
function verifyMessage(message, sender)
    return routingTableCache[message.routingData.from] == message.routingData.fromaddr
end
function routing(receiveraddr, sender, port, distance, message)
    message = serialization.deserialize(message)
    print("received message\nmessage reads:\n"..message)
    if port == newdeviceport then
        negotiation(sender, port, message)
        return nil
    else if port == negotiationport then
        processNewName(sender, port, message)
        return nil
    end
    if verifyMessage(message, sender) then
        if message.routingData.destination~="router" then
           print(relayMessage(message))
           return nil
        else
            processRouterCommands(message)
            return nil
        end
    else print("Message invalid") local log = io.open("/home/router/log.txt","a") log:write("Received invalid message from "..message.routingData.fromaddr.."\n\n\n") log:close() return nil end
end
event.listen("modem_message", routing)
event.pull("interrupted")
event.ignore("modem_message", routing)