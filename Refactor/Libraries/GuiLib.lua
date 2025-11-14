--[[ This library is intended for use by myself to be able to 
create guis which can display text in them and stuff
■█]]
--I remade it because I really don't want to look through the old library and fix it
--I'm rewriting it again :customer service smile: (11/06/25)
component = require("component")
event = require("event")
math = require("math")
g = component.gpu
g.setBackground(0x000000) 
g.setForeground(0xFFFFFF)
--[[g.fill(1,1,g.maxResolution(),"■")]]
g.fill(1,1,g.maxResolution()," ") -- refresh screen
g.setDepth(g.maxDepth())
main = {}
line = {
    x0 = 0,
    y0 = 0,
    xf = 0,
    yf = 0,
    m = 0,
    colorstart = 0,
    colorend = 0,
    coords = {}
}
main.basic.line = line
function line.new(x0,y0,xf,yf,colorstart, colorend)
    local result = {}
    result.x0 = x0
    result.y0 = y0
    result.xf = xf
    result.yf = yf
    result.colorstart = colorstart or 0xFFFFFF
    result.colorend = colorend or result.colorstart
    result.m = (yf-y0)/(xf-x0)
    result.len = math.sqrt((xf-x0)^2+(yf-y0)^2)
    result.coords = {}
    result = setmetatable(result,line)
    result:draw()
    return result
end
function line:draw()
    local oldbg = g.getBackground()
    local coordIndex = 1
    for i = self.x0, self.xf do
        local r0 = self.colorstart//65536
        local rf = self.colorend//65536
        local g0 = (self.colorstart//256)//256
        local gf = (self.colorend//256)//256
        local b0 = self.colorstart%256
        local bf = self.colorend%256
        local percent = math.sqrt((i-self.x0)^2+(self.m*(i-self.x0)+self.y0)^2)/self.len
        local r = r0+percent*(rf-r0)
        local g = g0+percent*(gf-g0)
        local b = b0+percent*(bf-b0)
        local col = r*65536+g*256+b
        g.setBackground(col)
        g.set(i, math.floor(self.m*(i-self.x0)+self.y0+0.5)," ")
        self.coords[coordIndex] = {i, math.floor(self.m*(i-self.x0)+self.y0+0.5), col}
        coordIndex = coordIndex+1
    end
    return
end
poly = {
    hollow = true,
    points = {},
    color = 0,
    lines = {},
    touchthing = false,
    touchfunc = nil
}
main.basic.poly = poly
function poly.new(points, color, hollow, button, buttonfunc)
    result = {}
    result.points = points
    result.hollow = hollow or true
    result.color = color
    result.touchthing = button or false
    result.touchfunc = button and buttonfunc or nil
    result.lines = {}
    local lineIndex = 1
    for i = 1, #points-1 do
        result.lines[lineIndex] = main.basic.line.new(points[i][1],points[i][2], points[i+1][1],points[i+1][2],color)
    end
    if not hollow then
        result = setmetatable(result, poly)
        result:draw()
    end
    return setmetatable(result, poly)
end
function poly:draw()
    points = self.points
    color = self.color
    lines = self.lines
    maxY = -500 --screen scanner algorithm
    for i = 1, #points do
        if points[i][2] > maxY then
            maxY = points[i][2]
        end
    end
    minY = 500
    for i = 1, #points do
        if points[i][2]<minY then
            minY = points[i][2]
        end
    end
    for i = maxY, minY do
        dodraw = false
        for j = 1, g.getResolution()[1] do
            for k = 1, #lines do
                if (lines[k].coords[1] == j) and (lines[k].coords[2] == i) then
                    dodraw = not dodraw
                    break
                end
            end
            if dodraw then
                oldbg = g.getBackground()
                g.setBackground(color)
                g.set(j,i, " ")
                g.setBackground(oldbg)
            end
        end
    end
end
function main.isinsidepoly(polylist, coords)
    --find bounds on screen
    local maxY = -500
    local minY = 500
    local maxX = -1000
    local minX = 1000
    for i = 1, #polylist do
        for j = 1, #polylist[i].points do
            if polylist[i].points[2]>maxY then
                maxY = polylist[i].points[2]
            end
            if polylist[i].points[2]<minY then
                minY = polylist[i].points[2]
            end
            if polylist[i].points[1]>maxX then
                maxX = polylist[i].points[1]
            end
            if polylist[i].points[1]<minX then
                minX = polylist[i].points[1]
            end
        end
    end
    if not ((coords[1]<=maxX and coords[1]>=minX) and (coords[2]<=maxY and coords[2]>=minY)) then
        return false
    end
    --find which poly
    local poly = 0
    for i = 1, #polylist do
        if poly!=0 then
            break
        end
        maxY = -500
        minY = 500
        maxX = -1000
        minX = 1000
        for j = 1, #polylist[i].points do
            if polylist[i].points[2]>maxY then
                maxY = polylist[i].points[2]
            end
            if polylist[i].points[2]<minY then
                minY = polylist[i].points[2]
            end
            if polylist[i].points[1]>maxX then
                maxX = polylist[i].points[1]
            end
            if polylist[i].points[1]<minX then
                minX = polylist[i].points[1]
            end
            if (coords[1]<=maxX and coords[1]>=minX) and (coords[2]<=maxY and coords[2]>=minY) then
                poly = i
                break
            end
        end
    end
    if poly == 0 then
        return false
    end
    local raycount = 0
    for i = coords[1], maxX do
        for j = 1, #polylist[poly].lines do
            for k = 1, #polylist[poly].lines[j].coords do
                if i==polylist[poly].lines[j].coords[k][1] then
                    raycount = raycount+1
                end
            end
        end
    end
    if raycount%2==0 then
        return false
    end
    return poly
end
gauge = {
    x1 = 0,
    y1 = 0,
    x2 = 0,
    y2 = 0,
    fillcol = 0x000000,
    emptycol = 0x000000,
    fillLvl = 0,
    label = "",
    optimalData = {
        optimalEnabled = false,
        optimalLvl = 0,
        optimalCol = 0x000000,
        optimalThresh = 0
    },
    internal = {
        vertical = y2-y1>x2-x1,
        polyList = {}
    }
}
main.gui.gauge = gauge
function gauge.new(x1,y1,x2,y2,fillCol,emptyCol,fillLvl,label,optimal,oplvl,opcol,opthresh)
    result = {}
    result.x1 = x1
    result.x2 = x2
    result.y1 = y1
    result.y2 = y2
    result.internal.vertical = y2-y1>x2-x1
    result.fillCol = fillCol or 0x00FF00 -- #00ff00
    result.emptyCol = emptyCol or 0xFF0000 -- #ff0000
    result.fillLvl = fillLvl or 0
    result.label = label or ""
    result.optimalData.optimalEnabled = optimal or false
    result.optimalData.optimalLvl = optimal and oplvl or 0
    result.optimalData.optimalCol = optimal and opcol or 0x000000
    result.optimalData.optimalThresh = optimal and opthresh or 0

end