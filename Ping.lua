component = require("component")
event = require("event")
m = component.modem
words = {}
serialization = require("serialization")
fs = require("filesystem")
mainport = 1 --Change to change port, also change top comment (you can tell I used copy and paste here because there is no top comment
m.open(mainport)
print(m.isOpen(mainport))
