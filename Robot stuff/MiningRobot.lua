--robot MUST be placed facing forwards
component = require("component")
event = require("event")
m = component.modem
c = component.computer
n = component.navigation
fs = require("filesystem")
miningNetPort = 5
db = component.database
invcont = component.inventory_controller
r = require("robot")
sides = require("sides")
waypoints = n.findwaypoints(100)
for k, v in pairs(waypoint) do
    if v.label == "miningref" then
        for l, b in v.position do
            if l == 1 then
                refx = -1*b
            elseif l == 2 then
                refy = -1*b
            elseif l == 3 then
                refz = -1*b
            end
        end
        break
    end
end
function move(x, y, z)
    if x > 0 then
        for i, x, 1 do
            robot.swing()
            robot.forward()
            refx = refx+1
        end
    elseif x < 0 then
        robot.turnAround()
        for i, math.abs(x), 1 do
            robot.swing()
            robot.forward()
            refx = refx-1
        end
        robot.turnAround()
    end
    if y > 0 then
        for i, y, 1 do
            robot.swingUp()
            robot.up()
            refy = refy+1
        end
    elseif y < 0 then
        for i, math.abs(y), 1 do
            robot.swingDown()
            robot.down()
            refy = refy-1
        end
    end
    if z > 0 then
        robot.turnRight()
        for i, z, 1 do
            robot.swing()
            robot.forward()
            refz = refz+1
        end
        robot.turnLeft()
    elseif z < 0 then
        robot.turnLeft()
        for i, math.abs(z), 1 do
            robot.swing()
            robot.forward()
            refz = refz-1
        end
        robot.turnRight()
    end
end
function mineArea(corn1x, corn1y, corn1z, corn2x, corn2y, corn2z)

end