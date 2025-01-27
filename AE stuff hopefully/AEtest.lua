--This file is meant as a test file for figuring out the AE2 API, this specific file connects to an interface
event = require("event")
component = require("component")
ME = component.me_interface
m = component.modem
print("getCpus() output:")
for k, v in ME.getCpus() do
    print(k, v)
end
print("getCraftables() output:")
for k, v in ME.getCpus() do
    print(k, v)
end
print("getItemsInNetwork() output:")
for k, v in ME.getItemsInNetwork() do
    print(k, v)
end
print("NOTE: store() function skipped")
print("getFluidsInNetwork() output:")
for k, v in ME.getFluidsInNetwork() do
    print(k, v)
end
print("getAvgPowerInjection() output:")
print(ME.getAvgPowerInjection())
print("getAvgPowerUsage() output:")
print(ME.getAvgPowerUsage())
print("getIdlePowerUsage() output:")
print(ME.getIdlePowerUsage())
print("getMaxStoredPower() output:")
print(ME.getMaxStoredPower())
print("getStoredPower() output:")
print(ME.getStoredPower())