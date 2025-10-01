--format: [Destination] [From] [Message or command] [message if 3 command] [subdestination] [subfrom]
--PORT: 1 (encrypted messages on 2)
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
--THIS FILE IS INTENDED FOR ROUTING MESSAGES TO NODES OUTSIDE OF A ROUTING NETWORK, THROUGH A LARGER NETWORK, INTO A NODE INSIDE ANOTHER, I WILL MAKE A SEPARATE SET OF FILES (or most likely a tranceiver file) FOR INTRANETWORK ENCRYPTION
component = require("component")
event = require("event")
m = component.modem
words = {}
mainport = 2 --Change to change port, also change top comment
mainportl = 1
d = component.data
name = "" --the name of this node
serialization = require("serialization")
router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9" --local router address
encryptedrouter = "" --replace with address of encrypted messages router, not necessary if used for internal security
rPublic = nil
rPrivate = nil
sPublic = nil
sPrivate = nil
simplefrom = nil
Function reconstructMessage(message)
  words = {}
  local message = serialization.unserialize(message)
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if k == 2 then
      local from = v
    elseif k == 3 then
      local message = v
    elseif k == 4 then
      local destination = v
    elseif k == 5 then
      local from = from .. "/" .. v
    end
  end
  m.send(router, mainportl, destination .. " " .. from .. " " .. message)
  rPublic = nil
  rPrivate = nil
  sPublic = nil
  sPrivate = nil
  simplefrom = nil
  words = {}
  goto 89
end
Function receiveMessage()
  event.ignore("modem_message", MainFunc)
  local receiver, from, port, dist, message = event.pull("modem_message")
  words = {}
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if k == 2 then
      simplefrom = v
    elseif k == 3 then
      local message = v
    end
  end
  local message = serialization.unserialize(message)
  sPublic = d.deserializeKey(message.header.sPublic,"ec-public")
  local decryptionKey = d.md5(d.ecdh(rPrivate, sPublic))
  local data = d.decrypt(message.data, decryptionKey, message.header.iv)
  local message = serialization.unserialize(data)
  reconstructMessage(message)
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
