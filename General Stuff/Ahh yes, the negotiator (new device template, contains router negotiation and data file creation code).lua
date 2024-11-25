component = require("component")
event = require("event")
m = component.modem
fs = require("filesystem")
mainport = 1 --Change to change port, also change top comment (which doesn't exist anymore because I changed everything since I made the source)
serialization  = require("serialization")
m.open(mainport)
print(m.isOpen(mainport))
if fs.exists("/home/data.txt") == true then
    local n = 0
    for line in io.lines("/home/data.txt") do
        local n = n+1
        if n == 1 then
            router = line
        elseif n == 2 then
            name = line
        end
    end
    local n = 0
elseif fs.exists("/home/data.txt") == false then
    datafile = io.open("/home/data.txt", "a")
    m.broadcast(mainport, "newtonetwork")
    local _, receiver, from, port, dist, message = event.pull("modem_message")
    datafile:write(tostring(from))
    router = from
    os.sleep(0.25)
    m.send(router, port, "ACS1") --replace "ACS1" with base name (or final name if only one can exist)
    local _, receiver, from, port, dist, message = event.pull("modem_message")
    --[[if message == "name taken" then --this section will, for things that can have multiple of them on the network (In the case of where I took this from, access controllers), automatically increase the number in the name until the name is not taken
        local n = 1
        while message == "name taken" do
            n = n+1
            local _, receiver, from, port, dist, message = event.pull("modem_message")
            name = "ACS" .. tostring(n)
            m.send(router, mainport, name)
        end
    end]]
    --[[if message == "name taken" then --this section will, for things that can only have one of them on the network, flash an error and automatically exit the program in the event that their name is already taken
        io.stderr:write("Name Taken, Exiting")
        os.exit()
    end]]
    datafile:write("\n" .. tostring(name))
    datafile:close()
end
--the following is a definition of the packet structure, when clearing it after sending, DO NOT USE "__packet = nil", THAT WILL BREAK EVERYTHING, instead use "__packet.routingData.destination = nil" and "__packet.data = nil"
__packet =
{
    routingData =
    {
        destination = nil,
        from = name
    },
    data = nil
}
--If you're stupid like I was when I first made this (before the packet rework) and don't know how to send objects more complex than strings, you do it with "serialization.serialize(<object>)" where <object> is replaced with the variable name