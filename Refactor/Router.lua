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
negotiationport = 9
m.open(negotiationport)
g = component.gpu
if (m.isOpen(mainport) && m.isOpen(newdeviceport) && m.isOpen(negotiationport))=true then
    print("All ports opened successfully, proceeding with bootup")
else
    print("Error detected, halting operation")
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
if filesystem.exists("/home/router") == false then
    filesystem.makeDirectory("/home/router/")
    names = io.open("/home/router/names.txt", "a")
    names:close
    addresses = io.open("/home/router/addressestxt", "a")
    addresses:close
    log = io.open("/home/router/log.txt", "a")
    log:close
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
    m.send(temptable[message.from], mainport)
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
    if temptable[message.from] == message.fromaddr then
        return true
    else
        return false
    end
    currentLine = nil
end
function routing(receiveraddr, sender, port, distance, message)
    message = serialization.deserialize(message)
    print("received message\nmessage reads:\n"+message)
    if verifyMessage(message, sender) then
        print(relayMessage(message))
    else print("Message invalid") end
end
event.listen("modem_message", routing)
event.pull("interrupted")
event.ignore("modem_message", routing)