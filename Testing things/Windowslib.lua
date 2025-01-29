--[[ This library is intended for use by myself to be able to 
create "windows," which can display text in them and stuff]]
component = require("component")
g = component.gpu
g.setBackground(0x000000) 
--[[g.setForeground(0x000000)
g.fill(1,1,g.maxResolution(),"█")]]
g.fill(1,1,g.maxResolution()," ")
window = {
    position = {
        x = nil,
        y = nil,
        w = nil,
        h = nil
    },
    char = "█"
}
function window:new(o, x, y, w, h)
    o = o or {}
    o.position.x = x
    o.position.y = y
    o.position.w = w
    o.position.h = h
    return o
end
function closewindow(win)
    g.fill(win.position.x,win.position.y,win.position.w,win.position.h,"█")
    local win = nil
    return win
end