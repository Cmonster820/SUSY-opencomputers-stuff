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
        x = math.abs(self.position.x+(self.position.w/2))-string.len(self.text.text)/2,
        y = math.abs(self.position.y+(self.position.h/2))
    }
}
gauge = {
    vertical = false,
    position = {
        x = nil,
        y = nil,
        w = nil,
        h = nil
    },
    fillcolor = nil,
    emptycolor = nil,
    fillLevel = nil,
    char = "█",
    label = {
        enabled = false,
        text = "",
        x = math.abs(self.position.x+(self.position.w/2))-string.len(self.label.text),
        y = self.position.y-1,
        color = nil
    },
    optimal = {
        enabled = false,
        level = nil,
        color = nil,
        x = if self.vertical == false then
                self.optimal.x = ((self.optimal.level*self.position.w)/100)+self.position.x
            elseif self.vertical == true then
                self.optimal.x = self.position.x
            end,
        y = if self.vertical == false then
                self.optimal.y = self.position.y
            elseif self.vertical == true then
                self.optimal.y = ((self.optimal.level*self.position.h)/100)-(self.position.h+self.position.y)
            end
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
    local oldfg, _ = g.getForeground()
    local oldbg, _ = g.getBackground()
    g.setForeground(o.color) --makes next operation the right color
    g.fill(o.position.x, o.position.y, o.position.w, o.position.h, o.char) --makes Button box
    g.setForeground(o.text.color)
    g.setBackground(o.color)
    g.set(o.text.x, o.text.y, o.text.text)
    g.setForeground(oldfg)
    g.setBackground(oldbg)
end
function gauge:new(o, vert, x, y, w, h, fcol, ecol, flvl, lenabled, ltxt, lcol, optenabled, optcol, optlvl)

end