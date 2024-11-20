--format: [Destination] [From] [Message or command] [message if 3 command] [subdestination] [subfrom]
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
component = require("component")
event = require("event")
m = component.modem
words = {}
mainport = 2 --Change to change port, also change top comment (testing world is 2 for encrypted, 1 for unencrypted)
d = component.data
serialization = require("serialization")
router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9"
simpledestination = "" --replace with target, may also make something to automatically set this
simplefrom = "" --replace with device name
truedestination = ""
nameList = {} --parallel with addresslist, see router for better explanation maybe I actually dont remember if i put one there
addressList = {}
storeMessageToSend = nil
rPublic = nil
nextIsrPublic = nil
simplesubdestination = nil
simplesubfrom = nil
name = "" --name of this node
incompletedata = nil
rPrivate = nil --change to result of key pair generation, the same for all senders
__packet = 
{
  header =
  {
    sPublic = nil,
    iv = nil
  },

  data = nil
}
Function RequestrPublic(destination)
  m.send(destination, mainport, tostring(simpledestination) .. " " .. tostring(name) .. " prepare")
end
Function sendEncrypted(destination, data, rPublic)
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
  __packet.data = data
  print("Encrypting [=======  ]")
  __packet.data = d.encrypt(serialization.serialize(__packet.data), encryptionKey, __packet.header.iv)
  print("Encrypting [======== ]")
  __packet.data = tostring(simpledestination) .. " " .. tostring(name) .. " " .. __packet.data .. " " .. tostring(simplesubdestination) .. " " .. tostring(simplefrom)
  print("Encrypting [=========]")
  print("Encrypted")
  print("Sending [  ]")
  m.send(destination, mainport, simpledestination .. " " .. name .. " " .. serialization.serialize(__packet))
  rPublic = nil
  incompletedata = nil
  simplesubdestination = nil
  simplefrom = nil
  packet.header.sPublic = nil
end
Function MainFunc(receiver, from, port, dist, message)
  words = {}
  print("Got a message from " .. from .. " on port " .. port .. ":" .. tostring(message))
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if k == 1 then
      simpledestination = v
    elseif k == 2 then
      simplefrom = v
    elseif k == 3 and v == "sendEncrypted" then
      storeMessageToSend = 1
      for l, b in pairs(nameList) do
        if b == simplefrom then
          truedestination = addressList[l]
        end
      end
    elseif k == 3 and v ~= "sendEncrypted" and storeMessageToSend == 1 then
      storeMessageToSend = 0
      k = 2
    elseif k == 3 and v == "rPublic:" then
      nextIsrPublic = 1
    elseif k == 3 and v ~= "rPublic:" and nextIsrPublic == 1  then
      nextIsrPublic = 0
      k = 2
    elseif k == 4 and storeMessageToSend = 1 then
      incompletedata = v
    elseif k == 4 and nextIsrPublic == 1 then
      rPublic = v
    elseif k == 5 then
      simplesubdestination = v
    elseif k == 6 then
      simplesubfrom = v
    elseif __packet.data ~= nil and rPublic ~= nil and incompletedata ~= nil then
      sendEncrypted(truedestination, incompletedata, rPublic)
    end
  end
end
event.listen("modem_message", MainFunc)
