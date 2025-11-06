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
    x0 = nil,
    y0 = nil,
    xf = nil,
    yf = nil,
    m = nil,
    colorstart = nil,
    colorend = nil,
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