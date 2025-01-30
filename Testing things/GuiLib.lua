--[[ This library is intended for use by myself to be able to 
create guis which can display text in them and stuff]]
component = require("component")
event = require("event")
g = component.gpu
g.setBackground(0x000000) 
g.setForeground(0xFFFFFF)
--[[g.fill(1,1,g.maxResolution(),"█")]]
g.fill(1,1,g.maxResolution()," ") -- refresh screen
--[[labeldat = {
        text = "",
        col = nil,
        x = math.abs(self.position.x-self.position.w)-string.len(self.text.text)/2,
        y = self.position.y-1
    },]]
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
function button:new(o, x, y, w, h, col, text, textcol)
    o = o or {}
    o.position.x = x
    o.position.y = y
    o.position.w = w
    o.position.h = h
    if col == nil then
        col = 0x000000
    end
    o.color = col
    o.text.text = text
    if textcol == nil then
        textcol = 0xFFFFFF
    end
    o.text.color = textcol
end