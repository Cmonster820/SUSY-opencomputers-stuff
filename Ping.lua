component = require("component")
event = require("event")
m = component.modem
words = {}
mainport = 1 --Change to change port, also change top comment
pongs = {"a21d01d1-fefa-4bf5-8af9-77850f43f60c"} --update list to be list of everything to ping
m.open(mainport)
print(m.isOpen(mainport))
router = "a88bbfe2-7e88-48a6-9c58-a67e48f07ee9" --change to router's
print("router = ", router)
mainframe = "5287b40b-8bcb-4bfc-af82-fbd76ce133ed" --change to mainframe modem address
print("mainframe = ", mainframe)
countervalue = 0
function detectIssues()
    if countervalue ~= #pongs then
       m.send(mainframe, mainport, "LOCKDOWN") 
    end
    goto 26
end
function mainfunction(_, _, from, port, _, message)
    if message == "pong" then
        countervalue += 1
    end
end
event.listen("modem_message", mainfunction)
words = {}
for k,v in pairs(pongs) do -- looks through pongs for addresses
    m.send(v, mainport, "ping")
end
event.timer(20, detectIssues)

