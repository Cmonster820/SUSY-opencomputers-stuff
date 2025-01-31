--[[ This library is intended for use by myself to be able to 
create guis which can display text in them and stuff
■█]]
component = require("component")
event = require("event")
g = component.gpu
g.setBackground(0x000000) 
g.setForeground(0xFFFFFF)
--[[g.fill(1,1,g.maxResolution(),"■")]]
g.fill(1,1,g.maxResolution()," ") -- refresh screen
g.setDepth(g.maxDepth())
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
    char = "■",
    text = {
        color = nil,
        text = nil,
        x = math.abs(self.position.x+(self.position.w/2))-string.len(self.text.text)/2,
        y = math.abs(self.position.y+(self.position.h/2))
    }
}
gauge = {             --gauge object
    vertical = false, --whether or not the gauge is vertical
    position = {
        x = nil,
        y = nil,
        w = nil,
        h = nil
    },
    fillcolor = nil,  --color the filled in part is
    emptycolor = nil, --color the empty part is
    fillLevel = nil,  --fill level out of 100
    char = "■",
    label = {
        enabled = false,
        text = "",
        x = math.abs(self.position.x+(self.position.w/2))-string.len(self.label.text),
        y = self.position.y-1,
        color = nil
    },
    readout = "",
    optimal = {       --I should've probably called this "limit," but this chunk defines the little red (by default) line that indicates standard operating levels for the gauge 
        enabled = false,
        level = nil,  --level of optimal position out of 100
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
border = {
    position = {
        x = nil,
        y = nil,
        w = nil,
        h = nil
    },
    color = nil,
    char = "■",
    label = "",
    thickness = nil,
    labelColor = nil
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
        if optcol == nil then
            optcol = 0xFF0000
        end
        o.optimal.color = optcol
        o.optimal.level = optlvl
    elseif optenabled == false then
        o.optimal.enabled = optenabled
    end
    local oldfg, _ = g.getForeground()
    local oldbg, _ = g.getBackground()
    g.setForeground(o.emptycolor)
    g.fill(o.position.x,o.position.y,o.position.w,o.position.h, o.char)
    if o.vertical == false then
        g.setForeground(o.fillcolor)
        g.fill(o.position.x,o.position.y, (((o.fillLevel*o.position.w)/100)+o.position.x),o.position.h,o.char)
        local rposx = o.position.x+(o.fillLevel/2)
        g.setForeground(0xFFFFFF)
        g.setBackground(o.fillcolor)
        g.set(rposx, (o.position.y+(o.position.h)/2), readout)
        if o.optimal.enabled == true then
            g.setForeground(o.optimal.color)
            if flvl >= o.optimal.level then
                g.setBackground(o.fillcolor)
            else
                g.setBackground(o.emptycolor)
            end
            for i=o.position.y, o.position.h+o.position.y, 1 do
                g.set(o.optimal.x, i, "|")
            end
        end
    elseif o.vertical == true then
        g.setForeground(o.fillcolor)
        g.fill(o.position.x,o.position.y, o.position.w, (((o.fillLevel*o.position.h)/100)-(o.position.h+o.position.y)), o.char)
        local rposx = o.position.x+(o.position.w/2)
        local rposy = o.position.y-((100-o.fillLevel)/2)
        g.setForeground(0xFFFFFF)
        g.setBackground(o.fillcolor)
        g.set(rposx,rposy,readout)
        if o.optimal.enabled == true then
            g.setForeground(o.optimal.color)
            if flvl >= o.optimal.level then
                g.setBackground(o.fillcolor)
            else
                g.setBackground(o.emptycolor)
            end
            for i = o.position.x, o.position.w+o.position.x, 1 do
                g.set(i, o.optimal.y, "_")
            end
        end
    end
    g.setForeground(oldfg)
    g.setBackground(oldbg)
end
function border:new(o, x, y, w, h, col, label, lcol, thickness)
    o = o or {}
    o.position.x = x
    o.position.y = y
    o.position.w = w
    o.position.h = h
    if col == nil then
        col = 0x000000
    end
    o.color = col
    if lcol == nil then
        lcol = 0x000000
    end
    o.labelColor = lcol
    if thickness == 0 or thickness == nil then
        thickness = 1
    end
    o.thickness = thickness
    local oldfg, _ = g.getForeground()
    local oldbg, _ = g.getBackground()
    g.setForeground(col)
    g.setBackground(col)
    g.fill(o.position.x, o.position.y, o.position.w, o.thickness, o.char)--create top border ‾
    g.fill(o.position.x, o.position.y, o.thickness, o.position.h, o.char)--create left border |‾
    g.fill(o.position.x+o.position.w, o.position.y, o.thickness, o.position.h, o.char)--create right border |‾|
    g.fill(o.position.x, o.position.y+o.position.h, o.position.w, o.thickness, o.char)--create bottom border ☐
    g.setForeground(o.labelColor)
    g.set((o.position.x+(o.position.w/2)-string.len(o.label)), o.position.y+1, o.label)
    g.setForeground(oldfg)
    g.setBackground(oldbg)
end
function gauge:refresh(o, flvl, readout)
    o.fillLevel = flvl
    o.readout = readout
    local oldfg, _ = g.getForeground()
    local oldbg, _ = g.getBackground()
    g.setForeground(o.emptycolor)
    g.fill(o.position.x,o.position.y,o.position.w,o.position.h, o.char)
    if o.vertical == false then
        g.setForeground(o.fillcolor)
        g.fill(o.position.x,o.position.y, (((o.fillLevel*o.position.w)/100)+o.position.x),o.position.h,o.char)
        local rposx = o.position.x+(o.fillLevel/2)
        g.setForeground(0xFFFFFF)
        g.setBackground(o.fillcolor)
        g.set(rposx, (o.position.y+(o.position.h)/2), readout)
        if o.optimal.enabled == true then
            g.setForeground(o.optimal.color)
            if flvl >= o.optimal.level then
                g.setBackground(o.fillcolor)
            else
                g.setBackground(o.emptycolor)
            end
            for i=o.position.y, o.position.h+o.position.y, 1 do
                g.set(o.optimal.x, i, "|")
            end
        end
    elseif o.vertical == true then
        g.setForeground(o.fillcolor)
        g.fill(o.position.x,o.position.y, o.position.w, (((o.fillLevel*o.position.h)/100)-(o.position.h+o.position.y)), o.char)
        local rposx = o.position.x+(o.position.w/2)
        local rposy = o.position.y-((100-o.fillLevel)/2)
        g.setForeground(0xFFFFFF)
        g.setBackground(o.fillcolor)
        g.set(rposx,rposy,readout)
        if o.optimal.enabled == true then
            g.setForeground(o.optimal.color)
            if flvl >= o.optimal.level then
                g.setBackground(o.fillcolor)
            else
                g.setBackground(o.emptycolor)
            end
            for i = o.position.x, o.position.w+o.position.x, 1 do
                g.set(i, o.optimal.y, "_")
            end
        end
    end
    g.setForeground(oldfg)
    g.setBackground(oldbg)
end
function closeall() -- called at the end of the program, resets screen to default black/white
    g.setForeground(0xFFFFFF)
    g.setBackground(0x000000)
    g.fill(1,1,g.maxResolution(), " ") -- clears screen
end