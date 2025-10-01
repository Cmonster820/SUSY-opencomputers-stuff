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