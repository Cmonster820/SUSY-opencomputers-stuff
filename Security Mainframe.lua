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
name = nil --change this to from a file later
sPublic = nil
sPrivate = nil
rPublic = nil
rPrivate = nil
__packet =
{
    routingData =
    {
        destination = nil
        from = name
    }
    data = nil
}
__encryptedpacket = 
{
    header =
    {
        iv = nil
        sPublic = nil
    }
    data = nil
}
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
    event.ignore("modem_message", MainFunc)
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
    if message.data = "prepare" then
        RespondToHandshake(receiver, from, port, distance, message)
    end
end
m.open(mainport)
print(m.isOpen(mainport))
router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9" --change to router's
print("router =", router)
event.listen("modem_message", MainFunc)
