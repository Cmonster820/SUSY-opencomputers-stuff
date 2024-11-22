--[[
DEPRECATED
internetwork encryption transceiver
all internetwork messages will be serialized
format: [Destination] [From] [Message or command] [message if 3 command] [subdestination] [subfrom]
PORT: 1 (encrypted messages on 2)
Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
THIS FILE IS INTENDED FOR ROUTING MESSAGES TO NODES OUTSIDE OF A ROUTING NETWORK, THROUGH A LARGER NETWORK, INTO A NODE INSIDE ANOTHER, I WILL MAKE A SEPARATE SET OF FILES (or most likely a tranceiver file) FOR INTRANETWORK ENCRYPTION
]]--
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
simplesubfrom = nil
simpledestination = nil
simplesubdestination = nil
storemessagetosend = nil
messagetopass = nil
m.open(mainport)
m.open(mainportl)
__packet = 
{
  header =
  {
    sPublic = nil,
    iv = nil
  },

  data = nil
}
Function awaitAndProcessRX(receiver, from, port)
  words = {}
  print("Awaiting Message")
  local receiver, addressfrom, sourceport, dist, message = event.pull("modem_message")
  print("Message Received")
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if k == 3 then
      local message = v
    end
  end
  print("Decrypting Packet [    ] - Unserializing Packet")
  local message = serialization.unserialize(message)
  print("Decrypting Packet [=   ] - Message Unserialized, Deserializing Key")
  sPublic = d.deserializeKey(message.header.sPublic,"ec-public")
  print("Decrypting Packet [==  ] - Key Deserialized, Generating Decryption Key")
  local decryptionKey = d.md5(d.ecdh(rPrivate, sPublic))
  print("Decrypting Packet [=== ] - Decryption Key Generated, Decrypting Packet")
  message = d.decrypt(message.data, decryptionKey, message.header.iv)
  print("Decrypting Packet [====] - Packet Decrypted")
  print("Packet Decrypted")
  print("Unserializing Routing Data")
  message = serialization.unserialize(message)
  print("Routing Data Unserialized, Disassembling Data")
  words = {}
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  print("Parsing Routing Data [    ] - Data Disassembled, Acquiring Origin Network")
  for k, v in pairs(words) do
    if k == 1 then
      local destination = v
    elseif k == 2 then
      local from = v
      print("Parsing Routing Data [=   ] - Origin Network Acquired, Acquiring Serialized Message")
    elseif k == 3 then
      local serializedmessage = v
      print("Parsing Routing Data [==  ] - Serialized Message Acquired, Acquiring Destination Within Local Network")
    elseif k == 4 then
      local destination = v
      print("Parsing Message [=== ] - Destination Within Local Network Acquired, Acquiring Origin Node In Origin Network")
    elseif k == 5 then
      local subfrom = v
      print("Parsing Message [==== ] - Origin Node In Origin Network Acquired, Reconstructing Message")
    end
  end
  print("Parsing Message [=====] - Reconstructing Message")
  print("Message Parsed")
  local message = serialization.unserialize(serializedmessage)
  local from = from .. "/" .. subfrom
  print("Sending Message [ ] - Message Reconstructed, Sending")
  m.send(router, mainportl, tostring(destination) .. " " .. tostring(from) .. " " .. tostring(message))
  print("Sending Message [=] - Sent")
  print("Message Sent")
  sPublic = nil
  sPrivate = nil
  rPublic = nil
  rPrivate = nil
  message = nil
  words = {}
  goto 209
end
Function handshake(receiver, from, port, dist, message)
  event.ignore("modem_message", MainFunc)
  words = {}
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if k == 2 then
      local from = v
    end
  end
  rPublic, rPrivate = component.data.generateKeyPair(384)
  m.send(encryptedrouter, mainport, tostring(from) .. " " .. tostring(name) .. " rPublic: " .. tostring(serialization.serialize(rPublic.serialize())))
  awaitAndProcessRX(receiver, from, port)
end
Function processRX(receiver, from, port, dist, message)
  words = {}
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
end
Function awaitKeyAndEncryptAndSend(destination, subdestination, from, subfrom, passmessage)
  local _, receiver, from, port, dist, message = event.pull("modem_message")
  if string.find(message, "rPublic:") == nil then
    goto 126
  end
  words = {}
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if v == "rPublic:" then
      local rPublicIsNext = 1
    elseif k == 4 and rPublicIsNext == 1 then
      local rPublicIsNext = 0
      rPublic = v
    end
  end
  print("Encrypting [         ] - Unserializing rPublic")
  rPublic = serialization.unserialize(rPublic)
  print("Encrypting [=        ] - rPublic Unserialized, Reconstructing rPublic")
  rPublic = d.deserializekey(rPublic, "ec-public")
  print("Encrypting [==       ] - rPublic Reconstructed, Generating sPublic, sPrivate")
  sPublic, sPrivate = d.generateKeyPair(384)
  print("Encrypting [===      ] - sPublic, sPrivate Generated, Generating Encryption Key")
  encryptionKey = d.md5(d.ecdh(sPrivate, rPublic))
  print("Encrypting [====     ] - Encryption Key Generated, Generating Initiation Vector")
  __packet.header.iv = d.random(16)
  print("Encrypting [=====    ] - Initiation Vector Generated, Serializing sPublic")
  __packet.header.sPublic = sPublic.serialize()
  print("Encrypting [======   ] - sPublic Serialized, Constructing Packet Data")
  __packet.data = tostring(destination) .. " " .. tostring(from) .. " " .. passmessage .. " " .. tostring(subdestination) .. " " .. tostring(subfrom)
  print("Encrypting [=======  ] - Packet Data Constructed, Encrypting Packet")
  __packet.data = d.encrypt(serialization.serialize(__packet.data), encryptionKey, __packet.header.iv)
  print("Encrypting [======== ] - Encrypting Packet")
  print("Encrypting [=========] - Packet Encrypted")
  print("Encrypting COMPLETE")
  print("Encrypted COMPLETE")
  print("Encrypted")
  print("Sending [ ] - Sending Packet With Appended Internetwork Routing Data")
  m.send(encryptedrouter, mainport, tostring(destination) .. " " .. name .. " " .. serialization.serialize(__packet))
  print("Sending [=] - Packet Sent With Appended Internetwork Routing Data")
  print("Sending COMPLETE")
  print("Sent COMPLETE")
  print("Sent")
  __packet.data = nil
  __packet.header.sPublic = nil
  __packet.header.iv = nil
  rPublic = nil
  sPublic = nil
  sPrivate = nil
  messagetopass = nil
  goto 209
end
Function processTX(receiver, from, port, dist, message)
  event.ignore("modem_message", MainFunc)
  words = {}
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if k == 1  then
      local destination = v
    elseif k == 2 then
      local from = v
    elseif k == 3 then
      messagetopass = tostring(v)
    elseif k == 4 then
      local subdestination = v
    elseif k == 5 then
      local subfrom = v
    end
  end
  messagetopass = serialization.serialize(messagetopass)
  m.send(encryptedrouter, mainport, tostring(destination) .. " " .. tostring(name) .. " " .. "prepare")
  awaitKeyAndEncryptAndSend(destination, subdestination, name, subfrom, messagetopass)
end
Function MainFunc(_, receiver, from, port, dist, message)
  words = {}
  if string.find(message, "prepare") ~= nil then
    handshake(receiver, from, port, dist, message)
  elseif from == router then
    processTX(receiver, from, port, dist, message)
  end
end
event.listen("modem_message", MainFunc)
event.pull("interrupted")
event.ignore("modem_message", MainFunc)
