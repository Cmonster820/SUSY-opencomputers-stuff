--THIS GOES IN A TABLET RUNNING OPENOS
--USED FOR FINDING THE LOCATION OF A BLOCK RELATIVE TO A WAYPOINT, THEN SENDING THAT VIA A LINKED CARD (can be swapped out for network by checking line 5 comment)
--THIS WILL BE USED FOR PRECISION ARTILLERY WHEN GCYW IS RELEASED
component = require("component")
event = require("event")
m = component.tunnel --change out "tunnel" for "modem" to use a network card instead of linked
fs = require("filesystem")
s = require("serialization")
n = component.navigation
c = component.computer
name = "blocklocationtablet"
if fs.exists("/home/data.txt") == false then
    term.write("Waypoint Name:\n")
    waypointname = term.read()
    datafile = io.open("/home/data.txt", "a")
    datafile:write(tostring(waypointname))
    datafile:close()
elseif fs.exists("/home/data.txt") == true then
    local n = 0
    for line in io.lines("/home/data.txt") do
        n = n+1
        if n == 1 then
            waypointname = line
        end
    end
end
__packet = 
{
    routingData = 
    {
        destination = nil,
        from = name
    },
    data = nil
}
function MainFunc() -- I need to get the event structure to put in variables

end
event.listen("tablet_use",MainFunc)
event.pull("interrupted")
event.ignore("tablet_use",MainFunc)