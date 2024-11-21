local serialization = require("serialization")
local component     = require("component")
local event         = require("event")

-- Read the private key
local file = io.open("rPrivate","rb")

local rPrivate = file:read("*a")

file:close()

-- Unserialize the private key
local rPrivate = serialization.unserialize(rPrivate)

-- Rebuild the private key object
local rPrivate = component.data.deserializeKey(rPrivate,"ec-private")

-- Use event.pull() to receive the message from SENDER.
local _, _, _, _, _, message = event.pull("modem_message")

-- Unserialize the message
local message = serialization.unserialize(message)

-- From the message, deserialize the public key.
local sPublic = component.data.deserializeKey(message.header.sPublic,"ec-public")

-- Generate the decryption key.
local decryptionKey = component.data.md5(component.data.ecdh(rPrivate, sPublic))

-- Use the decryption key and the IV to decrypt the encrypted data in message.data
local data = component.data.decrypt(message.data, decryptionKey, message.header.iv)

-- Unserialize the decrypted data.
local data = serialization.unserialize(data)

-- Print the decrypted data.
print(data)