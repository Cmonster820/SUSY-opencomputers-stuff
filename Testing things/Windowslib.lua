--[[ This library is intended for use by myself to be able to 
create "windows," which can display text in them and stuff]]
component = require("component")
g = component.gpu
g.setBackground(0x000000) 
--[[g.setForeground(0x000000)
g.fill(1,1,g.maxResolution(),"█")]]
g.fill(1,1,g.maxResolution()," ")
window = {
    label = "",
    barcol = nil,
    position = {
        x = nil,
        y = nil,
        w = nil,
        h = nil
    },
    color = nil,
    char = "█",
    text = {
        text = "",
        offsetx = nil,
        offsety = nil,
        color = nil
    }
}
function window:new(o, label, barcol, x, y, w, h, wincol, text, toffsetx, toffsety, textcol)
    o = o or {}
    o.label = label
    
    o.position.x = x
    o.position.y = y
    o.position.w = w
    o.position.h = h
    if wincol == nil then
        local oldfg, _ = gpu.getForeground()
        gpu.setForeground()

    return o
end
function closewindow(win)
    g.fill(win.position.x,win.position.y,win.position.w,win.position.h,"█")
    local win = nil
    return win
end