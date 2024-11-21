--format: [Destination] [From] [Message] (Message is serialized- change to format made 11/21/24)
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
component = require("component")
event = require("event")
m = component.modem
words = {}
mainport = 1 --Change to change port, also change top comment
m.open(mainport)
print(m.isOpen(mainport))
nameList = {mainframe, ACS1} --list of names, parallel with addresses
addressList = {"5287b40b-8bcb-4bfc-af82-fbd76ce133ed", "a21d01d1-fefa-4bf5-8af9-77850f43f60c"}
serialization = require("serialization")
if filesystem.exists("/usr/router/") == false then
  filesystem.makeDirectory("/usr/router/")
  names = io.open("/usr/router/names.txt", "a")
  names:close()
  addresses = io.open("user/router/addresses.txt", "a")
  addresses:close()
end
Function ProcessRouterCommands(receiver, from, port, dist, message)
  event.ignore("modem_message", MainFunc)
  words = {}
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if k == 1 then
      local target = v
    elseif k == 2 then
      local sender = v
    elseif k == 3 and v == "newtonetwork" then
      m.send(from, port, "Transmit Name in 1 second") --name will be sent as the entire message part, not serialized, so splitting is not necessary
    end
  end
  local receiver, secondfrom, port, dist, message = event.pull("modem_message")
  if secondfrom ~= from then
    goto 36
  else
    local secondfrom = from
  end
  local name = message
  for line in io.lines("/usr/router/names.txt") do
    if line == name then
      m.send(from, port, "name taken")
      goto 36
    end
  end
  io.open("/usr/router/names.txt", "a")
  names:write("\n" .. tostring(name))
  names:close()
  io.open("/usr/router/addresses.txt", "a")
  addresses:write("\n" .. tostring(from))
  addresses:close()
  goto 89
end
Function MainFunc(receiver, from, port, dist, message)
  words = {}
  for w in string.gmatch(tostring(message), "[^ ]+") do
    table.insert(words, w)
  end
  for k, v in pairs(words) do
    if k == 1 and v == "router" then
      ProcessRouterCommands(receiver, from, port, dist, message)
    end
    if k == 1 then
      local simpletarget = v
      for line in io.lines("/usr/names.txt") do
        if line == v then
          local lineinaddresses = k
          names:close()
        end
      end
    elseif k == 2 then
      local simplefrom = v
    elseif k == 3 then
      local data = v
    end
  end
  local n = 1
  for line in io.lines("/usr/addresses.txt") do
    local n = n+1
    if n == lineinaddresses then
      local target = line
    end
  end
  m.send(target, mainport, tostring(simpletarget) .. " " .. tostring(simplefrom) .. " " .. tostring(data))
end
event.listen("modem_message", MainFunc)
event.pull("interrupted")
event.ignore("modem_message", MainFunc)
