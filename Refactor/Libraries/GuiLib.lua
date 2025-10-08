--[[ This library is intended for use by myself to be able to 
create guis which can display text in them and stuff
■█]]
--I remade it because I really don't want to look through the old library and fix it
component = require("component")
event = require("event")
math = require("math")
g = component.gpu
g.setBackground(0x000000) 
g.setForeground(0xFFFFFF)
--[[g.fill(1,1,g.maxResolution(),"■")]]
g.fill(1,1,g.maxResolution()," ") -- refresh screen
g.setDepth(g.maxDepth())
gauge = --define horizontal gauge object
{
    position =
    {
        x = 0,
        y = 0,
        w = 0,
        h = 0
    },
    label = "",
    readOut = "",
    readOutCol = 0,
    fillLvl = 0,
    fillCol = 0,
    emptyCol = 0,
    textCol = 0,
    optimalEnabled = false,
    optimalLvl = 0,
    optimalCol = 0,
    rendererdata =
    {
        fillbar =
        {
            x = self.position.x,
            y = self.position.y,
            w = math.floor((self.position.w/(self.fillLvl/100))+0.5),
            h = self.position.h
        },
        emptybar =
        {
            x = self.position.x+math.floor((self.position.w/(self.fillLvl/100))+0.5),
            y = self.position.y,
            w = self.position.w-math.floor((self.position.w/(self.fillLvl/100))+0.5),
            h = self.position.h
        }
        labelData =
        {
            x = (self.position.x+((1/2)*self.position.w)-((1/2)*string.len(self.label))),
            y = self.position.y+self.position.h+1
        },
        readOutData =
        {
            x = (self.position.x+(self.position.w/2)-math.floor((string.len(self.readOut)/2))),
            y = self.position.y+self.position.h/2,
            fillLen = self.rendererdata.fillbar.w-(self.position.x+(self.position.w/2)-math.floor((string.len(self.readOut)/2)))
        },
        OptimalData =
        {
            x = math.floor((self.position.w/(self.optimalLvl/100))+0.5),
            y = self.position.y,
            optimalstring = string.rep("|", self.position.h)
        }
    }
}
verticalGauge =
{

}
button = 
{

}
border = 
{

}

function gauge:new(x, y, h, w, label, labelCol, readOut, readOutCol, fillLvl, fillCol, emptyCol, optimalEnabled, optimalLvl, optimalCol)
    o = {}
    setmetatable(o, self)
    self.__index = self
    --store all params to object
    self.position.x = x
    self.position.y = y
    self.position.h = h
    self.position.w = w
    self.label = label or ""
    self.textCol = labelCol or 0xFFFFFF -- #FFFFFF
    self.readOut = readOut or ""
    self.readOutCol = readOutCol or 0xFFFFFF -- #FFFFFF
    self.fillLvl = fillLvl
    self.fillCol = fillCol or 0x55FF55 -- #55FF55
    self.emptyCol = emptyCol or 0xFF0000 -- #FF0000
    self.optimalEnabled = optimalEnabled or false
    self.optimalLvl = optimalLvl or nil
    self.optimalCol = optimalCol or if optimalEnabled then 0xFFA600 else nil --if enabled be #FFA600 else nil 
    --rendering time
    oldbg = g.getBackground()
    oldfg = g.getForeground()
    --draw filled in part
    g.setBackground(self.fillCol)
    g.fill(self.rendererdata.fillbar.x, self.rendererdata.fillbar.y, self.rendererdata.fillbar.w, self.rendererdata.fillbar.h, " ")
    --draw empty part
    g.setBackground(self.emptyCol)
    g.fill(self.rendererdata.emptybar.x, self.rendererdata.emptybar.y, self.rendererdata.emptybar.w, self.rendererdata.emptybar.h, " ")
    --draw label
    g.setBackground(oldbg)
    g.setForeground(self.textCol)
    g.set(self.rendererdata.labelData.x, self.rendererdata.labelData.y, self.label)
    --draw readout
    g.setBackground(self.fillCol)
    g.setForeground(self.readOutCol)
    --draw part in filled in bit
    g.set(self.rendererdata.readOutData.x, self.rendererdata.readOutData.y, string.sub(self.readOut, 1,self.rendererdata.readOutData.fillLen))
    --draw part in empty bit
    g.set(self.rendererdata.readOutData.x+self.rendererdata.readOutData.fillLen, self.rendererdata.readOutData.y, string.sub(self.readOut, self.rendererdata.readOutData.fillLen, -1))
    --draw optimal line
    if self.optimalEnabled then
        g.setForeground(self.optimalCol)
        g.set(self.rendererdata.OptimalData.x, self.rendererdata.OptimalData.y, self.rendererdata.OptimalData.optimalstring, true)
    end
    g.setForeground(oldfg)
    g.setBackground(oldbg)
    return o
end