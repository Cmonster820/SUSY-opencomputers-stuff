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
        fromaddr = component.modem.address
    },
    data = nil
}
name = io.read("/home/data/name.txt", "*l")
resX, resY = g.getResolution
if filesystem.exists("/home/data") == false then
    loadingScreen = gui.gauge:new(resX//4, (resY//2)-1, (3*resX)//4, 3, "Setup", _, "Creating Data Files-Names", _, 0, _, _, _, _, _)
    filesystem.makeDirectory("/home/data/")
    names = io.open("/home/data/names.txt", "a")
    loadingScreen:refresh(33, "Names File Created, Creating Addresses File", _, _)
    names:close()
    addresses = io.open("/home/data/addresses.txt", "a")
    loadingScreen:refresh(67, "Addresses File Created, Creating Log File", _, _)
    addresses:close()
    log = io.open("/home/data/log.txt", "a")
    loadingScreen:refresh(100, "Log File Created, Setup Complete", _, _)
    log:close()
    g.fill(0, 0, g.getResolution(), " ")
    LoadingScreen = nil
end
dataTable = {}
curline = 1
for line in io.lines("/home/data/names.txt") do
    local namel = line:gsub("\n", "")
    local othercurline = 1
    for otherline in io.lines("/home/data/addresses.txt") do
        address = otherline:gsub("\n", "")
        if curline == othercurline then
            dataTable[namel] = address
            break
        end
        othercurline++
    end
    othercurline = nil
    curline++
end
curline = nil
function negotiate()
    names = io.open("/home/data/names.txt","a")
    addresses = io.open("/home/data/addresses.txt","a")
    namefile = io.open("/home/data/name.txt","a")
    log = io.open("/home/data/log.txt", "a")
    packet.from = name
    m.broadcast(newdeviceport, serialization.serialize(packet))
    log:write("Message broadcasted:\n"+serialization.serialize(packet)+"\n\n\n")
    local receiveraddr, sender, port, distance, message = event.pull("modem_message")
    log:write("Message received from "+sender+" on port "+port+" message reads:\n"+serialization.deserialize(message)+"\n\n\n")
    names:write("router\n")
    addresses:write(sender+"\n")
    if message == "Negotiation Successful" then
        print("Negotiation Successful")
        log:close()
        names:close()
        namefile:close()
        addresses:close()
    elseif message == "Name Taken" then
        --[[
        io.stderr:write("Error: name taken, halting operation")
        os.exit()
        ]]
        taken = true
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
        addresses:close()
        namefile:write(name)
        namefile:close()
        names:close()
        print("Negotiation Complete")
        return nil
    end
end
if dataTable[router] == nil then
    negotiate()
end
function mainfunction(receiveraddr, sender, port, distance, message) --rename if needed
end
event.listen("modem_message", mainfunction)
event.pull("interrupted")
event.ignore("modem_message", mainfunction)