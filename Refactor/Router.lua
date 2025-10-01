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
gui = require("GuiLib")
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
        from = nil
    },
    data = nil
}
originalFg = g.getForeground()
originalBg = g.getBackground()
screenw, screenh = g.getResolution()
if filesystem.exists("/home/router") == false then
    g.setBackground(0XFFFFFF)
    loadingBar = gui.gauge:new(_, false, (screenw/2)-(screenw/4), (screenh/2)-1, screenw/2, 3, _, _, 0, true, "Creating Data Files-")
    filesystem.makeDirectory("/home/router/")
    names = io.open("/home/router/names.txt")
    names:close
    addresses = io.open("/home/router/addressestxt")
    addresses:close
end