--[[ This library is intended for use by myself to be able to 
create guis which can display text in them and stuff
■█]]
--I remade it because I really don't want to look through the old library and fix it
component = require("component")
event = require("event")
g = component.gpu
g.setBackground(0x000000) 
g.setForeground(0xFFFFFF)
--[[g.fill(1,1,g.maxResolution(),"■")]]
g.fill(1,1,g.maxResolution()," ") -- refresh screen
g.setDepth(g.maxDepth())
gauge =
{
    
}
button = 
{

}
border = 
{

}