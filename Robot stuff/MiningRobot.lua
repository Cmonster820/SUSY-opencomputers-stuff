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
term = require("term")
function findref()
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
return refx, refy, refz
end
print("Reference Waypoint X:")
wayxs = term.read()
print("Stored\nReference Waypoint Y:")
wayys = term.read()
print("Stored\nReference Waypoint Z:")
wayzs = term.read()
print("Stored\nConverting Values from Strings to Numbers")
wayx = tonumber(wayxs)
wayy = tonumber(wayys)
wayz = tonumber(wayzs)
print("Conversion Complete")
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
    refx, refy, refz = findref()
    local corn1x = corn1x-(wayx+refx)
    local corn1y = corn1y-(wayy+refy)
    local corn1z = corn1z-(wayz+refz)
    local corn2x = corn2x-(wayx+refx)
    local corn2y = corn2y-(wayy+refy)
    local corn2z = corn2z-(wayz+refz)
    print("Corner Co-ordinates Converted to Relative Co-ordinates")
    move(corn1x, corn1y, corn1z)
    local corn2x = corn2x-refx
    move(corn2x, 0, 0)
    local corn2z = corn2z-refz
    local corn2y = corn2y-refy
    if corn1y < corn2y then
        if corn1z < corn2z then
            for i, corn2z, 2 do
                move(-1*corn2x, 0, 1)
                move(corn2x, 0, 1)
                if refz == corn2z then
                    break
                end
            end
            move(0, 1, 0)
        elseif corn1z > corn2z then
            for i, math.abs(corn2z), 2 do
                move(-1*corn2x, 0, -1)
                move(corn2x, 0, -1)
                if refz == corn2z then
                    break
                end
            end
            move(0, 1, 0)
        end
    elseif corn1y > corn2y then
        if corn1z < corn2z then
            for i, corn2z, 2 do
                move(-1*corn2x, 0, 1)
                move(corn2x, 0, 1)
                if refz == corn2z then
                    break
                end
            end
            move(0, -1, 0)
        elseif corn1z > corn2z then
            for i, math.abs(corn2z), 2 do
                move(-1*corn2x, 0, -1)
                move(corn2x, 0, -1)
                if refz == corn2z then
                    break
                end
            end
            move(0, -1, 0)
        end
    end
    refx, refy, refz = findref()
    move(refx+1, refy+1, refz)
    move(refx, 0, 0)
    print("Mining Complete")
    print("Awaiting Orders")
end
findref()
while true do
    ::Redo::
    print("Corner 1 X:")
    local corn1x = term.read()
    print("Corner 1 Y:")
    local corn1y = term.read()
    print("Corner 1 Z:")
    local corn1z = term.read()
    print("Corner 2 X:")
    local corn2x = term.read()
    print("Corner 2 Y:")
    local corn2y = term.read()
    print("Corner 2 Z:")
    local corn2z = term.read()
    print("Confirm?")
    local confirmed = term.read()
    if confirmed == "n" then
        goto Redo
    elseif confirmed == "y" then
        print("Command Confirmed.")
        mineArea(tonumber(corn1x),tonumber(corn1y),tonumber(corn1z),tonumber(corn2x),tonumber(corn2y),tonumber(corn2z))
    end
end