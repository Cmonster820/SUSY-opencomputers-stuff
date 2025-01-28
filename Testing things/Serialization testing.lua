--This is NOT to figure out how to use serialization, this is to figure out how it works so I can use it w/o the library (like on drones)
component = require("component")
event = require("event")
serialization = require("serialization")
print("Serializing standardized packet")
__packet =
{
    routingData =
    {
        destination = nil,
        from = nil
    },
    data = nil
}
print("Destination = to, from = away, data = hi")
__packet.routingData.destination = "to"
__packet.routingData.from = "away"
__packet.routingData.data = "hi"
print(serialization.serialize(__packet))