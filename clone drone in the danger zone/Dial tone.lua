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
m.open(3)
m.broadcast(3, "addtonetwork")
function ProcessMessages(receiver, from, port, dist, message)
    words = {}
    if message == "addtonetwork" then
    end
    for w in string.gmatch(message, "[^ ]+") do
        table.insert(words, w)
    end
    for k, v in pairs(words) do
        if then
        end
    end
end
while true do
    local name = nil
    local name, dat1, dat2, dat3, dat4, dat5, dat6, dat7, dat8 = c.pullSignal(0.25)
    if name ~= nil then
        if name == "modem_message" then
            ProcessMessages(dat1, dat2, dat3, dat4, dat5)
        end
    end
end