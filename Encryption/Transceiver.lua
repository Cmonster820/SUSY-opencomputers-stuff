--internetwork encryption transceiver
--all internetwork messages will be serialized
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
Function handshake(receiver, from, port, dist, message)
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
  m.send(encryptedrouter, mainport, tostring(from) .. " " .. tostring(name) .. " rPublic:" .. tostring(rPublic.serialize()))
end
Function processRX(receiver, from, port, dist, message)
  words = {}
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
end
Function awaitKeyAndEncryptAndSend(destination, subdestination, passfrom, subfrom, passmessage)
  local receiver, from, port, dist, message = event.pull("modem_message")
  if string.find(message, "rPublic:") == nil then
    goto 
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
  print("Encrypting [         ]")
  rPublic = serialization.unserialize(rPublic)
  print("Encrypting [=        ]")
  rPublic = d.deserializeky(rPublic, "ec-public")
  print("Encrypting [==       ]")
  sPublic, sPrivate = d.generateKeyPair(384)
  print("Encrypting [===      ]")
  encryptionKey = d.md5(d.ecdh(sPrivate, rPublic))
  print("Encrypting [====     ]")
  __packet.header.iv = component.data.random(16)
  print("Encrypting [=====    ]")
  __packet.header.sPublic = sPublic.serialize()
  print("Encrypting [======   ]")
  __packet.data = tostring(destination) .. " " .. tostring(passfrom) .. " " .. passmessage .. " " .. tostring(subdestination) .. " " .. tostring(subfrom)
  print("Encrypting [=======  ]")
  __packet.data = d.encrypt(serialization.serialize(__packet.data), encryptionKey, __packet.header.iv)
  print("Encrypting [======== ]")
  print("Encrypting [=========]")
  print("Encrypting COMPLETE")
  print("Encrypted COMPLETE")
  print("Encrypted")
  print("Sending [ ]")
  m.send(encryptedrouter, mainport, tostring(destination) .. " " .. name .. " " .. serialization.serialize(__packet))
  print("Sending [=]")
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
  goto 
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
    m.send(encryptedrouter, mainport, tostring(destination) .. " " .. tostring(name) .. " " .. "prepare")
    awaitKeyAndEncryptAndSend(destination, subdestination, from, subfrom, message)
end
Function MainFunc(receiver, from, port, dist, message)
  words = {}
  if string.find(message, "prepare") ~= nil then
    handshake(receiver, from, port, dist, message)
  elseif from == router then
    processTX(receiver, from, port, dist, message)
  elseif from == encryptedrouter then
    processRX(receiver, from, port, dist, message)
  end
end
event.listen("modem_message", MainFunc)
event.pull("interrupted")
event.ignore("modem_message", MainFunc)
