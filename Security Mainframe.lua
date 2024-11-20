--format: [Destination] [From] [Message]
--PORT: 1
--Router address: a88bbfe2-7e88-48a6-9c58-a67e48f07ee9 (testing world)
component = require("component")
event = require("event")
m = component.modem
words = {}
mainport = 1 --Change to change port, also change top comment
Cards = {"123"}
m.open(mainport)
print(m.isOpen(mainport))
router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9" --change to router's
print("router = ", router)
Function AlarmManager(lockdown)
    if lockdown == true then
        m.broadcast(mainport, LOCKDOWNBEGIN)
    elseif lockdown == false then
        m.broadcast(mainport, ALLCLEAR)
    end
end
Function DoorManager(from, card)
    for h, j in pairs(Cards) do
        if card == j then
            m.send(router, mainport, tostring(from) .. " mainframe authorized")
        elseif card ~= j and h == #Cards then
            m.send(router, mainport, tostring(from) .. " mainframe denied")
        end
    end
end
Function RequestManager(requestType,from,data)
    if requestType == "open" then
        DoorManager(from,data)
    end
end
Function MainFunc(receiver, sender, port, dist, message)
    os.sleep(0.06)
    words = {}
    print("Got a message from " .. from .. " on port " .. port .. ":" .. tostring(message))
    if message == ALARM or message == LOCKDOWN then
        AlarmManager(true)
    end
    for w in string.gmatch(message, "[^ ]+") do --splits the message by word into table words
        table.insert(words, w)
    end
    for k, v in pairs(words) do --looks through words
        print(k, v)
        if k == 2 then
            from = v
        elseif k == 3 and v == "openrequest" then
            requestType == "openDoor"
        elseif k == 4 and requestType == "openDoor" then
            RequestManager("open",from,v)
        end
    end
end
event.listen("modem_message", MainFunc)
