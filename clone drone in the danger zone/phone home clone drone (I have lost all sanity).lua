m = component.proxy(component.list("modem"))
drone = component.proxy(component.list("drone"))
c = component.proxy(component.list("computer"))
c.beep(20,0.05)
c.beep(50, 0.05)
c.beep(100, 0.05)
c.beep(200, 0.05)
c.beep(400, 0.05)
c.beep(800, 0.05)
c.beep(1000, 0.05)
c.beep(1500, 0.05)
c.beep(2000, 0.05)
setStatusText("We have an intruder!")
os.sleep(1)
for i = 1,2,3 do
    c.beep(1500, 0.25)
    os.sleep(0.05)
end
setStatusText("'ow did 'e get in, intruda window?")
os.sleep(1)
c.beep(2000, 1)
setStatusText("buh-bye")
for i = 1,2,3 do
    c.beep(1500, 0.25)
    os.sleep(0.05)
end