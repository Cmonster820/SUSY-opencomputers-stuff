--format: [Destination] [From] [Message]
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
component = require("component")
event = require("event")
m = component.modem
words = {}
mainport = 1 --Change to change port, also change top comment
d = component.data
serialization = require("serialization")
router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9"
destination = "" --replace with target, may also make something to automatically set this
from = "" --replace with device name
__packet = 
{
  header =
  {
    sPublic = nil,
    iv = nil
  },

  data = nil
}
Function MainFunc(receiver, from, port, dist, message)
  words = {}
  print("Got a message from " .. from .. " on port " .. port .. ":" .. tostring(message))
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if k == 3 and v == ""
  end
end
event.listen("modem_message", MainFunc)
