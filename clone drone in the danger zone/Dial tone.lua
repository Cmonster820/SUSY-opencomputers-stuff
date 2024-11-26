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
d.move(homex, homey, homez)
