--format: see __packet and __encryptedpacket
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
component = require("component")
event = require("event")
m = component.modem
d = component.data
mainport = 1 --Change to change port, also change top comment
door = component.os_doorcontroller
serialization  = require("serialization")
name = "mainframe"
sPublic = nil
sPrivate = nil
rPublic = nil
rPrivate = nil
cards = {"123"}
m.open(mainport)
print(m.isOpen(mainport))
if fs.exists("/home/data.txt") == true then
  local n = 0
  for line in io.lines("/home/data.txt") do
    local n = n+1
    if n == 1 then
      router = line
    elseif n == 2 then
      name = line
    end
  end
  local n = 0
elseif fs.exists("/home/data.txt") == false then
  datafile = io.open("/home/data.txt", "a")
  m.broadcast(mainport, "newtonetwork")
  local _, receiver, from, port, dist, message = event.pull("modem_message")
  datafile:write(tostring(from))
  router = from
  os.sleep(0.25)
  m.send(router, port, "mainframe")
  local _, receiver, from, port, dist, message = event.pull("modem_message")
  if message == "name taken" then
    io.stderr:write("Name Taken, Exiting")
    os.exit()
  end
  datafile:write("\n" .. tostring(name))
  datafile:close()
end
__packet =
{
    routingData =
    {
        destination = nil,
        from = name
    },
    data = nil
}
__encryptedpacket = 
{
    header =
    {
        iv = nil,
        sPublic = nil
    },
    data = nil
}
function InitiateHandShake(destination)
  __packet.routingData.destination = destination
  __packet.data = "prepare"
  m.send(router, mainport, serialization.serialize(__packet))
  local _, receiver, from, port, dist, message = event.pull("modem_message")
  __packet.data = nil
  __packet.routingData.destination = nil
  local message = serialization.unserialize(message)
  rPublic = message.data
  return rPublic
end
function EncryptAndSendMessage(destination,data) 
  rPublic = InitiateHandShake(destination)
  rPublic = d.deserializeKey(rPublic,"ec-public")
  sPublic, sPrivate = d.generateKeyPair(384)
  local encryptionKey = d.md5(d.ecdh(sPrivate, rPublic))
  __packet.__encryptedpacket.header.iv = component.data.random(16)
  __packet.__encryptedpacket.header.sPublic = sPublic.serialize()
  __packet.__encryptedpacket.data = data
  __packet.data = d.encrypt(serialization.serialize(__packet.data), encryptionKey, __packet.header.iv)
  __packet.routingData.destination = destination
  m.send(router, mainport, serialization.serialize(__packet))
  __packet.__encryptedpacket.header.iv = nil
  __packet.__encryptedpacket.header.sPublic = nil
  __packet.__encryptedpacket.data = nil
  __packet.routingData.destination = nil
  rPublic = nil
  rPrivate = nil
  sPublic = nil
  sPrivate = nil
end
function RequestManager(from, data)
  if data.__requestpacket.type == "open" then
  local amtofnot = 0
  for k, v in pairs(cards) do
    if data.__requestpacket.data == v then
      __packet.routingData.destination = from
      __packet.data = "authorized"
      m.send(router, mainport, serialization.serialize(__packet))
      __packet.routingData.destination = nil
      __packet.data = nil
      break
    elseif data.__requestpacket.data ~= v then
      local amtofnot = amtofnot + 1
    elseif amtofnot == #cards then
      __packet.routingData.destination = from
      __packet.data = "denied"
      m.send(router, mainport, serialization.serialize(__packet))
      __packet.data = nil
      __packet.routingData.destination = nil
    end
  end
end
function ProcessMessage(from, data)
  if data.__requestpacket ~= nil then
    RequestManager(from, data)
  end
end
function ReceiveAndDecrypt()
  local receiver, from, port, distance, message = event.pull("modem_message")
  print("Encrypted Message Received \n Decrypting Message [       ] - Unserializing Packet")
  local message = serialization.unserialize(message)
  print("Decrypting Message [=     ] - Packet Unserialized, Deserializing sPublic")
  sPublic = d.deserializeKey(message.data.__encryptedpacket.header.sPublic,"ec-public")
  print("Decrypting Message [==    ] - sPublic Deserialized, Generating Decryption Key")
  local decryptionKey = d.md5(d.ecdh(rPrivate, sPublic))
  print("Decrypting Message [===   ] - Decryption Key Generated, Decrypting Message")
  local data = d.decrypt(message.data.__encryptedpacket.data, decryptionKey, message.data.__encryptedpacket.header.iv)
  print("Decrypting Message [====  ] - Message Decrypted, Unserializing Message")
  local data = serialization.unserialize(data)
  print("Decrypting Message [===== ] - Message Unserialized, Extracting Routing Data")
  local from = message.routingData.from
  print("Message Decrypted [======]")
  sPublic = nil
  sPrivate = nil
  rPublic = nil
  rPrivate = nil
  ProcessMessage(from, data)
end
function RespondToHandshake(receiver, from, port, distance, message)
  print("Responding to Handshake [    ] - Storing Routing Data")
  __packet.routingData.destination = message.routingData.from
  print("Responding to Handshake [=   ] - Routing Data Stored, Generating Key Pair")
  rPublic, rPrivate = d.generateKeyPair(384)
  print("Responding to Handshake [==  ] - Key Pair Generated, Serializing rPublic and Storing to Packet Data")
  __packet.data = rPublic.serialize()
  print("Responding to Handshake [=== ] - rPublic Serialized and Stored to Packet Data, Serializing and Sending Packet")
  m.send(from, port, serialization.serialize(__packet))
  print("Responding to Handshake [====] - Packet Serialized and Sent")
  print("Hands Have Been Shaken")
  __packet.routingData.destination = nil
  __packet.data = nil
  print("Awaiting Encrypted Message")
  ReceiveAndDecrypt()
end
function MainFunc(receiver, from, port, distance, message)
  local message = serialization.unserialize(message)
  if message.data == "prepare" then
    RespondToHandshake(receiver, from, port, distance, message)
  end
end
print("router =", router)
event.listen("modem_message", MainFunc)
event.pull("interrupted")
event.ignore("modem_message", MainFunc)
