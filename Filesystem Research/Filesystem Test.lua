--format: see __packet
--PORT: 1
--Router address:  (testing world)
component = require("component")
event = require("event")
m = component.modem
words = {}
mainport = 1 --Change to change port, also change top comment
m.open(mainport)
print(m.isOpen(mainport))
serialization = require("serialization")
__packet =
{
  routingData =
  {
    from = nil
    destination = nil
  }
  data = nil
}
if filesystem.exists("/home/router/") == false then
  filesystem.makeDirectory("/home/router/")
  names = io.open("/home/router/names.txt", "a")
  names:close()
  addresses = io.open("user/router/addresses.txt", "a")
  addresses:close()
end
function AddDeviceToNetwork(receiver, from, port, dist, message)
  m.send(from, port, "send name in 0.25 seconds")
  local _, receiver, from, port, dist, message = event.pull("modem_message")
  for line in io.lines("/home/router/names.txt") do
    if message == line then
      m.send(from, port, "name taken")
      goto 29
    end
  end
  names = io.open("/home/router/names.txt", "a")
  names:write(message .. "\n")
  names:close()
  addresses = io.open("/home/router/addresses.txt", "a")
  addresses:write(from .. "\n")
  addresses:close()
  goto 77
end
function ProcessRouterCommands(receiver, from, port, dist, message)
  event.ignore("modem_message", MainFunc)
  if message == "LOCKDOWN" or message == "ALARM" then
    for line in io.lines("/home/router/addresses.txt") do
      m.send(line, mainport, "ALARM")
    end
  elseif message == "newtonetwork" then
    AddDeviceToNetwork(receiver, from, port, dist, message)
  end
end
function MainFunc(_, receiver, from, port, dist, message)
  local message = serialization.unserialize(message)
  if message.routingData.from == "router" then
    ProcessRouterCommands(receiver, from, port, dist, message)
  end
  local n = 1
    for line in io.lines("/home/router/names.txt") do
      local n = n+1
      if line == message.routingData.from then
        local lineinaddresses = n
      end
    end
  local n = 1
  for line in io.lines("/home/router/addresses.txt") do
    local n = n+1
    if n == lineinaddresses then
      local target = line
    end
  end
  addresses:close()
  m.send(target, mainport, serialization.serialize(message))
end
event.listen("modem_message", MainFunc)
event.pull("interrupted")
event.ignore("modem_message", MainFunc)
