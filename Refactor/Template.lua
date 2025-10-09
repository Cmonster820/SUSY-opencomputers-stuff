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
if filesystem.exists("/home/data") == false then
    filesystem.makeDirectory("/home/data/")
    names = io.open("/home/data/names.txt", "a")
    loadingScreen:refresh(33, "Names File Created, Creating Addresses File", _, _)
    names:close
    addresses = io.open("/home/data/addresses.txt", "a")
    loadingScreen:refresh(67, "Addresses File Created, Creating Log File", _, _)
    addresses:close
    log = io.open("/home/data/log.txt", "a")
    loadingScreen:refresh(100, "Log File Created, Setup Complete", _, _)
    log:close
    g.fill(0, 0, g.getResolution(), " ")
    LoadingScreen = nil
end