--format: [Destination] [From] [Message or command] [message if 3 command] [subdestination] [subfrom]
--PORT: 1 (encrypted messages on 2)
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
component = require("component")
event = require("event")
m = component.modem
words = {}
mainport = 2 --Change to change port, also change top comment
d = component.data
name = "" --the name of this node
serialization = require("serialization")
router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9"
rPublic = nil
rPrivate = nil
sPublic = nil
sPrivate = nil
simplefrom = nil
Function receiveMessage()
  local receiver, from, port, dist, message = event.pull("modem_message")
  words = {}
  
  local message = serialization.unserialize(message)
  
end
Function shakeHands(receiver, simplefrom, port, dist, message, from) -- in this case, from is the encrypted message router
  rPublic, rPrivate = component.data.generateKeyPair(384)
  m.send(from, mainport, tostring(simplefrom) .. " " .. tostring(name) .. " rPublic:" .. rPublic.serialize())
  receiveMessage()
end
Function MainFunc(receiver, from, port, dist, message)
  words = {}
  print("Got a message from " .. from .. " on port " .. port .. ":" .. tostring(message))
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if k == 1 then
      destination = v
    elseif k == 2 then
      simplefrom = v
    elseif k == 3 and v == "prepare" then
      shakeHands(receiver, simplefrom, port, dist, message, from)
    end
  end
end
event.listen("modem_message", MainFunc)
event.pull("interrupted")
event.ignore("modem_message", MainFunc)
