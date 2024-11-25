--format: see __packet
--PORT: 1
--Router address:  (testing world)
component = require("component")
event = require("event")
m = component.modem
filesystem = require("filesystem")
words = {}
mainport = 1 --Change to change port, also change top comment
m.open(mainport)
print(m.isOpen(mainport))
serialization = require("serialization")
__packet =
{
  routingData =
  {
    from = nil,
    destination = nil
  },
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
  ::rereceivename::
  local _, receiver, from, port, dist, message = event.pull("modem_message")
  for line in io.lines("/home/router/names.txt") do
    if message == line then
      m.send(from, port, "name taken")
      goto rereceivename
    end
  end
  names = io.open("/home/router/names.txt", "a")
  names:write(message .. "\n")
  names:close()
  addresses = io.open("/home/router/addresses.txt", "a")
  addresses:write(from .. "\n")
  addresses:close()
end
function ProcessRouterCommands(receiver, from, port, dist, message)
  if message == "LOCKDOWN" or message == "ALARM" then
    for line in io.lines("/home/router/addresses.txt") do
      m.send(line, mainport, "ALARM")
    end
  end
end
function MainFunc(_, receiver, from, port, dist, message)
  print("Got a message from " .. from .. " on port " .. port .. ", message reads: " .. message)
  if message == "newtonetwork" then
    AddDeviceToNetwork(receiver, from, port, dist, message)
  elseif message == "requestmainframe" then
    local n = 1
    for line in io.lines("/home/router/names.txt") do
      if line == "mainframe" then
        local lineinaddresses = n
      end
      local n += 1
    end
    local n = 1
    for line in io.lines("/home/router/addresses.txt") do
      if n == lineinaddresses then
        m.send(from, port, line)
      end
      local n += 1
    end
    local n = 1
  elseif message == "requestping" then
    for line in io.lines("/home/router/names.txt") do
      if line == "pingserver" then
        local lineinaddresses = n
      end
      local n = n+1
    end
    local n = 1
  end
  local message = serialization.unserialize(message)
  if message.routingData.from == "router" then
    ProcessRouterCommands(receiver, from, port, dist, message)
    return nil
  end
  local n = 1
    for line in io.lines("/home/router/names.txt") do
      if line == message.routingData.from then
        local lineinaddresses = n
      end
      local n = n+1
    end
  local n = 1
  for line in io.lines("/home/router/addresses.txt") do
    if n == lineinaddresses then
      local target = line
    end
    local n = n+1
  end
  m.send(target, mainport, serialization.serialize(message))
end
event.listen("modem_message", MainFunc)
event.pull("interrupted")
event.ignore("modem_message", MainFunc)
