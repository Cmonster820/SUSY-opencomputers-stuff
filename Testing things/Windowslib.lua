--[[This library is intended for use by myself to be able to 
create "windows," which can display text in them and stuff]]
component = require("component")
g = component.gpu
g.setBackground(0x000000) 
g.setForeground(0xFFFFFF)
--[[g.fill(1,1,g.maxResolution(),"█")]]
g.fill(1,1,g.maxResolution()," ") -- refresh screen
window = {
    label = "",
    barcol = nil, -- color of the bar at the top of the window
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
    },
    closebutton = {
        x = self.position.w+self.position.x,
        y = self.position.y
    }
}
function window:new(o, label, barcol, x, y, w, h, wincol, text, toffsetx, toffsety, textcol)
    o = o or {}
    o.label = label
    o.barcol = barcol 
    o.position.x = x
    o.position.y = y
    o.position.w = w
    o.position.h = h
    o.text.text = text
    o.text.offsetx = toffsetx
    o.text.offsety = toffsety
    local width = math.abs(w-x)
    local height = math.abs(h-y)
    if wincol == nil then
        wincol = 0xFFFFFF
    end
    o.color = wincol
    if barcol == nil then
        barcol = 0x5793f2
    end
    o.barcol = barcol
    if textcol == nil then
        textcol = 0x000000
    end
    o.text.color = textcol
    local oldfg, _ = g.getForeground()
    local oldbg, _ = g.getBackground()
    g.setForeground(o.color) --makes next operation the right color
    g.fill(o.position.x, o.position.y, o.position.w, o.position.h, o.char) --makes window box
    g.setForeground(o.barcol) --makes bar the right color
    g.fill(o.position.x, o.position.y, o.position.w, 1, o.char) --makes bar at top
    g.setForeground(0xFFFFFF)
    g.setBackground(o.barcol) -- hopefully this works
    g.set(o.position.x+1, o.position.y, o.label)
    g.setBackground(0xFF0000)
    g.set(o.closebutton.x, o.closebutton.y, "X")
    g.setBackground(oldbg) --returns background to original color
    g.setForeground(o.text.color)
    g.setBackground(o.color)
    g.set(o.text.offsetx-string.len(o.text.text),o.text.offsety,o.text.text)
    g.setForeground(oldfg)
    g.setBackground(oldbg)
    return o
end