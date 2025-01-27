--swarm uses old message system due to lack of serialization
m = component.proxy(component.list("modem"))
d = component.proxy(component.list("drone"))
c = component.proxy(component.list("computer"))
n = component.proxy(component.list("navigation"))
for i = 1,2,3 do
    d.setLightColor(0x00FF00)
    c.beep(1500, 0.25)
    d.setLightColor(0x000000)
    c.beep(1500, 0.25)
end
d.setLightColor(0x00FF00)
function FindHome()
    waypoints = n.findwaypoints(100)
    for k, v in pairs(waypoints) do
        if v.label == "home" then
            for l, b in pairs(v.position) do
                if l == 1 then
                    local homex = b
                    d.setStatusText("Home Relative X Co-ordinate Found")
                elseif l == 2 then
                    local homey = b
                    d.setStatusText("Home Relative Y Co-ordinate Found")
                elseif l == 3 then
                    local homez = b
                    d.setStatusText("Home Relative Z Co-ordinate Found")
                end
            end
            break
        end
    end
    return homex, homey, homez
end
local homex, homey, homez = FindHome()
d.setStatusText("Home Found")
d.setLightColor(0xFFA500)
d.move(homex, homey + 1, homez)
local homex, homey, homez = FindHome()
while homex ~= 0 and homez ~= 0 do
    local homex, _, homez = FindHome()
    d.move(homex, 0, homez)
end
d.setLightColor(0x00FF00)
name = "drone1"
nameslist = {name}
m.open(3)
m.broadcast(3, "addtonetwork")
function ProcessMessages(_, receiver, from, port, dist, message)
    words = {}
    if message == "addtonetwork" then
        ::rerequestname::
        m.send(from, port, "sendname " .. name)
        local eventname = nil
        local eventname, dat1, dat2, dat3, dat4, dat5, dat6, dat7, dat8 = c.pullSignal(0.25)
        if eventname ~= nil then
            if eventname == "modem_message" then
                local message = dat5
                for k, v in pairs(nameslist) do
                    if message == v then
                        m.send(from, port, "name taken")
                        goto rerequestname
                    end
                end
            end
        end
    end
        return nil
    end
    for w in string.gmatch(message, "[^ ]+") do
        table.insert(words, w)
    end
    for k, v in pairs(words) do
        if k == 1 and v == "sendname" then
            storenext = true
        elseif k == 2 and storenext == true then
            if v == name then
                local namenum = 2
                name = "drone"..tostring(namenum)
                m.send(from,port,name)
            end
        end
    end
end
while true do
    local eventname = nil
    local eventname, dat1, dat2, dat3, dat4, dat5, dat6, dat7, dat8 = c.pullSignal(0.25)
    if eventname ~= nil then
        if eventname == "modem_message" then
            ProcessMessages(dat1, dat2, dat3, dat4, dat5, dat6)
        end
    end
end