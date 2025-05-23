--format: see __packet
--PORT: 1
--Router address:  (testing world)
--this was originally supposed to be rack or case, but due to recent (8:37pm est, 1/29/2025) discoveries, this will only work on cases
component = require("component")
event = require("event")
m = component.modem
filesystem = require("filesystem")
words = {}
mainport = 1 --Change to change port, also change top comment
m.open(mainport)
print(m.isOpen(mainport))
serialization = require("serialization")
io = require("io")
m.open(3) -- opens port used to negotiate with new devices
print(m.isOpen(3))
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
  print("Data Files Nonexistent, Creating [     ] Creating Router Directory")
  filesystem.makeDirectory("/home/router/")
  print("Data Files Nonexistent, Creating [=    ] Router Directory Created, Creating and Opening Names File")
  names = io.open("/home/router/names.txt", "a")
  print("Data Files Nonexistent, Creating [==   ] Names File Created and Opened, Closing")
  names:close()
  print("Data Files Nonexistent, Creating [===  ] Names File Closed, Creating and Opening Addresses File")
  addresses = io.open("/home/router/addresses.txt", "a")
  print("Data Files Nonexistent, Creating [==== ] Addresses File Created and Opened, Closing")
  addresses:close()
  print("Data Files Nonexistent, Creating [=====] Addresses File Closed, Creation of Data Files Complete")
end
function AddDeviceToNetwork(receiver, from, port, dist, message)
  print("Negotiating [        ] Requesting Name")
  m.send(from, port, "send name in 0.25 seconds")
  print("Negotiating [=       ] Name Requested, Receiving Name")
  ::rereceivename::
  local _, receiver, from, port, dist, message = event.pull("modem_message")
  if port ~= 3 then
    goto rereceivename
  end
  print("Negotiating [==      ] Name Received, Updating File")
  for line in io.lines("/home/router/names.txt") do
    if message == line then
      m.send(from, port, "name taken")
      goto rereceivename
    end
  end
  names = io.open("/home/router/names.txt", "a")
  print("Negotiating [===     ] Updating File")
  names:write(message .. "\n")
  print("Negotiating [====    ] Updating File")
  names:close()
  print("Negotiating [=====   ] File Updated, Updating Address File")
  addresses = io.open("/home/router/addresses.txt", "a")
  print("Negotiating [======  ] Updating File")
  addresses:write(from .. "\n")
  print("Negotiating [======= ] Updating File")
  addresses:close()
  print("Negotiating [========] File Updated")
  print("Negotiation Complete")
end
function ProcessRouterCommands(receiver, from, port, dist, message)
  if message == "LOCKDOWN" or message == "ALARM" then
    for line in io.lines("/home/router/addresses.txt") do -- I don't really know why I'm not just using broadcast here
      m.send(line, mainport, "ALARM")
    end
  end
end
function MainFunc(_, receiver, from, port, dist, message)
  print("Got a message from " .. from .. " on port " .. port .. ", message reads: " .. message)
  if port == 3 then
    AddDeviceToNetwork(receiver, from, port, dist, message)
  elseif message == "requestmainframe" then
    local n = 1
    for line in io.lines("/home/router/names.txt") do
      if line == "mainframe" then
        local lineinaddresses = n
      end
      local n = n + 1
    end
    local n = 1
    for line in io.lines("/home/router/addresses.txt") do
      if n == lineinaddresses then
        m.send(from, port, line)
      end
      local n = n + 1
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
    for line in io.lines("/home/router/addresses.txt") do
      if n == lineinaddresses then
        m.send(from, port, line)
      end
      n = n + 1
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
