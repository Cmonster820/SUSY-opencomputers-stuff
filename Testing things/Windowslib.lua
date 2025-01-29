--[[ This library is intended for use by myself to be able to 
create "windows," which can display text in them and stuff]]
component = require("component")
g = component.gpu
g.setBackground(0xFFFFFF) -- While I can't draw different color rectangles I can cut holes in a white one
g.setForeground(0x000000)
g.fill(1,1,g.maxResolution(),█)
window = {
    position = {
        x = nil,
        y = nil,
        w = nil,
        h = nil
    },
    char = " "
}
