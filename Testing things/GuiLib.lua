--[[ This library is intended for use by myself to be able to 
create guis which can display text in them and stuff]]
component = require("component")
event = require("event")
g = component.gpu
g.setBackground(0x000000) 
g.setForeground(0xFFFFFF)
--[[g.fill(1,1,g.maxResolution(),"█")]]
g.fill(1,1,g.maxResolution()," ") -- refresh screen
button = {
    position = {
        x = nil,
        y = nil,
        w = nil,
        h = nil
    },
    color = nil,
    char = "█",
    text = {
        color = nil,
        text = nil,
        x = math.abs(self.position.x-self.position.w)-string.len(self.text.text)/2,
        y = math.abs(self.position.y-self.position.h)
    }
}