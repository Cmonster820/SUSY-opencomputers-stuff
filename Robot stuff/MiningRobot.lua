component = require("component")
event = require("event")
m = component.modem
c = component.computer
n = component.navigation
fs = require("filesystem")
miningNetPort = 5
db = component.database
invcont = component.inventory_controller
r = require("robot")
waypoints = n.findwaypoints(100)
for k, v in pairs(waypoint) do
    if v.label == "miningref" then
        