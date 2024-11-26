--Router for drone swarm, my original idea was completely fucked
--THIS GOES IN TABLET RUNNING OPENOS
--now to figure out how unserialization works so I can send packets to the drones
component = require("component")
event = require("event")
m = component.modem
fs = require("filesystem")
s = require("serialization")
n = component.navigation
c = component.computer
