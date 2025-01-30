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
    readout = "",
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
function gauge:new(o, vert, x, y, w, h, fcol, ecol, flvl, lenabled, ltxt, lcol, optenabled, optcol, optlvl, readout)
    o = o or {}
    o.vertical = vert
    o.position.x = x
    o.position.y = y
    o.position.w = w
    o.position.h = h
    o.readout = readout
    if fcol == nil then
        fcol = 0x09E335
    end
    o.fillcolor = fcol
    if ecol == nil then
        ecol = 0x474749
    end
    o.emptycolor = ecol
    o.fillLevel = flvl
    if lenabled == true then
        o.label.enabled = lenabled
        o.label.text = ltxt
        o.label.color = lcol
    elseif lenabled == false then
        o.label.enabled = lenabled
    end
    if optenabled == true then
        o.optimal.enabled = optenabled
        o.optimal.color = optcol
        o.optimal.level = optlvl
    elseif optenabled == false then
        o.optimal.enabled = optenabled
    end
    local oldfg, _ = g.getForeground()
    local oldbg, _ = g.getBackground()
    g.setForeground(ecol)
    g.fill(o.position.x,o.position.y,o.position.w,o.position.h, o.char)
    if o.vertical == false then
        g.setForeground(fcol)
        g.fill(o.position.x,o.position.y, (((o.fillLevel*o.position.w)/100)+o.position.x),o.position.h,o.char)
        local rposx = o.position.x+(o.fillLevel/2)
        g.setForeground(0xFFFFFF)
        g.setBackground(fcol)
        g.set(rposx, (o.position.y+(o.position.h)/2), readout)
        if optenabled == true then
            g.setForeground(optcol)
            if flvl >= optlvl then
                g.setBackground(fcol)
            else
                g.setBackground(ecol)
            end
            for i=o.position.y, o.position.h+o.position.y, 1 do
                g.set(o.optimal.x, i, "|")
            end
        end
    elseif o.vertical == true then
        g.setForeground(fcol)
        g.fill(o.position.x,o.position.y, o.position.w, (((o.fillLevel*o.position.h)/100)-(o.position.h+o.position.y)), o.char)
        local rposx = o.position.x+(o.position.w/2)
        local rposy = o.position.y-((100-o.fillLevel)/2)
        g.setForeground(0xFFFFFF)
        g.setBackground(fcol)
        g.set(rposx,rposy,readout)
        if optenabled == true then
            g.setForeground(optcol)
            if flvl >= optlvl then
                g.setBackground(fcol)
            else
                g.setBackground(ecol)
            end
            for i=o.position.x, o.position.w+o.position.x, 1 do
                g.set(i, o.optimal.y, "_")
            end
        end
    end
    g.setForeground(oldfg)
    g.setBackground(oldbg)
end