--intended for use with t3 screens AND gpus
--█
component = require("component")
event = require("event")
fs = require("filesystem")
s = require("serialization")
term = require("term")
gpu = component.gpu
m = component.modem
gpu.setResolution(gpu.maxResolution)
w, h = gpu.getResolution
gpu.setBackground(0xFFFFFF)