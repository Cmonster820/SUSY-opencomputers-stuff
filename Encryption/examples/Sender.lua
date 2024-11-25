local serialization  = require("serialization")
local component      = require("component")

-- This table contains the data that will be sent to the receiving c.
-- Along with header information the receiver will use to decrypt the message.
local __packet =
{
    header =
    {
        sPublic    = nil,
        iv         = nil
    },

    data = nil
}

-- Read the public key file.
local file = io.open("rPublic","rb")

local rPublic = file:read("*a")

file:close()

-- Unserialize the public key into binary form.
local rPublic = serialization.unserialize(rPublic)

-- Rebuild the public key object.
local rPublic = component.data.deserializeKey(rPublic,"ec-public")

-- Generate a public and private keypair for this session.
local sPublic, sPrivate = component.data.generateKeyPair(384)

-- Generate an encryption key.
local encryptionKey = component.data.md5(component.data.ecdh(sPrivate, rPublic))

-- Set the header value 'iv' to a randomly generated 16 digit string.
__packet.header.iv = component.data.random(16)

-- Set the header value 'sPublic' to a string.
__packet.header.sPublic = sPublic.serialize()

-- The data that is to be encrypted.
__packet.data = "lorem ipsum"

-- Data is serialized and encrypted.
__packet.data = component.data.encrypt(serialization.serialize(__packet.data), encryptionKey, __packet.header.iv)

-- For simplicity, in this example the computers are using a Linked Card (ocdoc.cil.li/item:linked_card)
component.tunnel.send(serialization.serialize(__packet))