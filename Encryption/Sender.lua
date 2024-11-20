--format: [Destination] [From] [Message]
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
local component = require("component")
local event = require("event")
local m = component.modem
local words = {}
local mainport = 1 --Change to change port, also change top comment
