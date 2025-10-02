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
gauge =
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
            x = self.position.x
            y = self.position.y
            w = math.floor(self.position.w/fillLvl)
            h = self.position.h
        },
        labelData =
        {
            x = (self.position.x+((1/2)*self.position.w)-((1/2)*string.len(self.label))),
            y = self.position.y+(self.position.h/2),
            filledpart = string.sub( self.label, 1, )
        }
    }
}
button = 
{

}
border = 
{

}