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
function ProcessRouterCommands(receiver, from, port, dist, message)
  event.ignore("modem_message", MainFunc)
  end
end
function MainFunc(_, receiver, from, port, dist, message)
  local message = serialization.unserialize(message)
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
