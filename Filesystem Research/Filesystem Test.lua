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
if filesystem.exists("/usr/router/") == false then
  filesystem.makeDirectory("/usr/router/")
  names = io.open("/usr/router/names.txt", "a")
  names:close()
  addresses = io.open("user/router/addresses.txt", "a")
  addresses:close()
end
function ProcessRouterCommands(receiver, from, port, dist, message)
  event.ignore("modem_message", MainFunc)
  end
end
function MainFunc(receiver, from, port, dist, message)
  local message = serialization.unserialize(message)
  io.open("/usr/router/names.txt", "r")
  local n = 1
    for line in io.lines("/usr/router/names.txt") do
      local n = n+1
      if line == message.routingData.from then
        local lineinaddresses = n
        names:close()
      end
    end
  io.open("/usr/router/addresses.txt", "r")
  local n = 1
  for line in io.lines("/usr/addresses.txt") do
    local n = n+1
    if n == lineinaddresses then
      local target = line
    end
  end
  addresses:close()
  m.send(target, mainport, tostring(simpletarget) .. " " .. tostring(simplefrom) .. " " .. tostring(data))
end
event.listen("modem_message", MainFunc)
event.pull("interrupted")
event.ignore("modem_message", MainFunc)
