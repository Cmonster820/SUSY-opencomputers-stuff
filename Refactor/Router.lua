--This file is a rewrite of the original router code because it kind of sucked
--this will have an option to store all packets to a file, to change the location, edit the code
--this file requires the guilib library I made in "testing things"
component = require("component")
event = require("event")
m = component.modem
filesystem = require("filesystem")
serialization = require("serialization")
io = require("io")
words = {}
mainport = 1
m.open(mainport)
newdeviceport = 2
m.open(newdeviceport)
negotiationport = 3
m.open(negotiationport)
g = component.gpu
gui = require("GuiLib")
if (m.isOpen(mainport) && m.isOpen(newdeviceport) && m.isOpen(negotiationport))=true then
    print("All ports opened successfully, proceeding with bootup")
else
    io.stderr:write("Error detected, halting operation")
    os.exit()
end
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
loadingScreen = gui.gauge:new(resX//4, (resY//2)-1, (3*resX)//4, 3, "Setup", _, "Creating Data Files-Names", _, 0, _, _, _, _, _)
if filesystem.exists("/home/router") == false then
    filesystem.makeDirectory("/home/router/")
    names = io.open("/home/router/names.txt", "a")
    loadingScreen:refresh(33, "Names File Created, Creating Addresses File", _, _)
    names:close
    addresses = io.open("/home/router/addresses.txt", "a")
    loadingScreen:refresh(67, "Addresses File Created, Creating Log File", _, _)
    addresses:close
    log = io.open("/home/router/log.txt", "a")
    loadingScreen:refresh(100, "Log File Created, Setup Complete", _, _)
    log:close
    g.fill(0, 0, g.getResolution(), " ")
    LoadingScreen = nil
end
function negotiation(sender, port, message)
    name = message.routingData.from+"\n"
    address = message.routingData.fromaddr+"\n"
    log = io.open("/home/router/log.txt", "a")
    log:write(serialization.serialize(message)+"\n\n\n")
    for line in io.lines("/home/router/names.txt") do
        if line == name then
            m.send(address.gsub("\n", ""),port,"Name Taken")
            log:write("Message sent to "+message.routingData.fromaddr+"\n, \"Name Taken\"\n\n\n")
            log:close()
            return nil
        end
    end
    names = io.open("/home/router/names.txt","a")
    addresses = io.open("/home/router/addresses.txt", "a")
    names:write(name)
    addresses:write(address)
    names:close()
    addresses:close()
    m.send(address.gsub("\n", ""), port, "Negotiation Successful")
    log:write("Message sent to "+message.routingData.fromaddr+"\n, \"Negotiation Successful\"\n\n\n")
    log:close()
    name = nil
    address = nil
end
function processNewName(from ,port, message)
    log = io.open("/home/router/log.txt", "a")
    log:write(serialization.serialize(message)+"\n\n\n")
    for line in io.lines("/home/router/names.txt") do
        if message.routingData.from+"\n" == line then
            m.send(message.routingData.fromaddr, port, "Name Taken")
            log:write("Message sent to "+message.routingData.fromaddr+"\n, \"Name Taken\"\n\n\n")
            log:close()
            return nil
        end
    end
    name = message.routingData.from+"\n"
    address = message.routingData.fromaddr+"\n"
    names = io.open("/home/router/names.txt","a")
    addresses = io.open("/home/router/addresses.txt", "a")
    names:write(name)
    addresses:write(address)
    m.send(message.routingData.fromaddr, port, "Negotiation Successful")
    log:write("Message sent to "+message.routingData.fromaddr+"\n, \"Negotiation Successful\"\n\n\n")
    names:close()
    addresses:close()
    log:close()
    name = nil
    address = nil
end
function processRouterCommands(message)
    if message.Data == "RequestPing" then
        for line in io.lines("/home/router/names.txt") do
        currentLine += 1
        line = line:gsub("\n","")
        othercurline = 0
        for otherline in io.lines("/home/router/addresses.txt") do
            otherline = otherline:gsub("\n","")
            othercurline += 1
            if othercurline == currentLine then
                break
            end
        end
        othercurline = nil
        temptable[line] = otherline
        m.send(message.routingData.fromaddr, mainport, temptable[ping])
        temptable = nil
    end
end
function relayMessage(message)
    local temptable = {}
    currentLine = 0
    for line in io.lines("/home/router/names.txt") do
        currentLine += 1
        line = line:gsub("\n","")
        othercurline = 0
        for otherline in io.lines("/home/router/addresses.txt") do
            otherline = otherline:gsub("\n","")
            othercurline += 1
            if othercurline == currentLine then
                break
            end
        end
        othercurline = nil
        temptable[line] = otherline
    end
    log = io.open("/home/router/log.txt", "a")
    log:write(serialization.serialize(message)+"\n\n\n")
    log:close()
    m.send(temptable[message.routingData.destination], mainport, message)
    return "Message relayed successfully"
end
function verifyMessage(message, sender)
    local temptable = {}
    currentLine = 0
    for line in io.lines("/home/router/names.txt") do
        currentLine += 1
        line = line:gsub("\n","")
        othercurline = 0
        for otherline in io.lines("/home/router/addresses.txt") do
            otherline = otherline:gsub("\n","")
            othercurline += 1
            if othercurline == currentLine then
                break
            end
        end
        othercurline = nil
        temptable[line] = otherline 
    end
    if temptable[message.routingData.from] == message.routingData.fromaddr then
        return true
    else
        return false
    end
    currentLine = nil
end
function routing(receiveraddr, sender, port, distance, message)
    message = serialization.deserialize(message)
    print("received message\nmessage reads:\n"+message)
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
    else print("Message invalid") return nil end
end
event.listen("modem_message", routing)
event.pull("interrupted")
event.ignore("modem_message", routing)