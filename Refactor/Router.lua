--This file is a rewrite of the original router code because it kind of sucked
--this will have an option to store all packets to a file, to change the location, edit the code
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
if (m.isOpen(mainport) && m.isOpen(newdeviceport) && m.isOpen(negotiationport))==true then
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
        from = nil
    },
    data = nil
}
originalFg = g.getForeground
originalBg = g.getBackground
screenw, screenh = g.getResolution()
if filesystem.exists("/home/router") == false then
    oldFg = g.getForeground
    oldBg = g.getBackground
    g.setBackground(0xFFFFFF) -- #FFFFFF
    g.setForeground(0xFF0000) -- #FF0000 
    g.fill(1,1,g.maxResolution()," ")
    g.fill(screenw/4, (screenh/2)-1, ((3*screenw)/4), 2, "■")
    g.setForeground(0x00FF00) -- #00FF00
    
    filesystem.makeDirectory("/home/router/")
    names = io.open("/home/router/names.txt")
    names:close
    addresses = io.open("/home/router/addresses.txt")
    addresses:close
end