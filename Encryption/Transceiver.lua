--internetwork encryption transceiver
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
__packet = 
{
  header =
  {
    sPublic = nil,
    iv = nil
  },

  data = nil
}
Function processTX(receiver, from, port, dist, message)
  words = {}
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
end
Function MainFunc(receiver, from, port, dist, message)
  words = {}
  if message == "prepare" then
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
