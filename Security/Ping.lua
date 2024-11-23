component = require("component")
event = require("event")
m = component.modem
tempongs = {}
serialization = require("serialization")
fs = require("filesystem")
mainport = 1 --Change to change port, also change top comment (you can tell I used copy and paste here because there is no top comment
m.open(mainport)
print(m.isOpen(mainport))
name = nil
countervalue = 0
strikes = 0
__packet =
{
    routingData =
    {
        destination = nil,
        from = name
    },
    data = nil
}
if fs.exists("/home/data.txt") == true then
    local n = 0
    for line in io.lines("/home/data.txt")
        local n = n+1
        if n == 1 then
            router = line
        elseif n == 2 then
            name = line
        elseif n == 3 then
            mainframe = line
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
    name = "pingserver"
    m.send(router, port, name)
    local _, receiver, from, port, dist, message = event.pull("modem_message")
    if message == "name taken" then
        io.stderr:write("Name Taken, Exiting")
        os.exit()
    end
    datafile:write("\n" .. tostring(name))
    m.send(router, port, "requestmainframe")
    local _,receiver,from,port,dist,message = event.pull("modem_message")
    datafile:write("\n" .. tostring(message))
    datafile:close()
end
if fs.exists("/home/pongs.txt") == false then
    pongslist = io.open("/home/pongs.txt", "a")
    pongslist:close()
end
function AddtoPongs(receiver, from, port, dist, message)
    pongslist = io.open("/home/pongs.txt","a")
    pongslist:write("\n" .. tostring(from))
    pongslist:close()
end
function MainFunc(_, receiver, from, port, dist, message)
    if message ~= "pong" then
        AddtoPongs(receiver, from, port, dist, message)
    else
        countervalue += 1
    end
end
function DetectIssuesAndPing()
    for line in io.lines("/home/pongs.txt") do
        table.insert(tempongs, line)
    end
    if countervalue < #tempongs then
        strikes += 1
    end
    if strikes == 5 then
        m.send(mainframe, mainport, "LOCKDOWN")
    end
    for line in io.lines("/home/pongs.txt") do
        m.send(line, mainport, "ping")
    end
end
timerid = event.timer(20, DetectIssuesAndPing, math.huge)
event.listen("modem_message", MainFunc)
event.pull("interrupted")
event.ignore("modem_message", MainFunc)