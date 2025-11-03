--administrator-forced restart just deleted this file yay
math = require("math")
linalg = require("LinAlg")
local main = {}
tensor_MT = {}
main.tensor = {
    function new(...)
        return setmetatable({...},tensor_MT)
    end
}
function tensor_MT.__add(t1, t2)
    local resultData = main.addRec(t1, t2)
    return setmetatable(resultData, tensor_MT)
end
local function main.addRec(dat1,dat2)
    if type(dat1)=="number" and type(dat2)=="number" then
        return dat1+dat2
    end
    if type(dat1) ~= "table" or type(dat2) ~= "table" or #dat1 ~= #dat2 then
        error("Attempted to add tensors with incompatible shapes or types",2)
    end
    local result = {}
    for i = 1, #dat1 do
        result[i] = main.addRec(dat1[i],dat2[i])
    end
    return result
end
function tensor_MT.__unm(t)
    local result = main.unmRec(t)
    return setmetatable(result,tensor_MT)
end
local function main.unmRec(dat)
    if type(dat)=="number" then
        return -dat
    end
    if getmetatable(dat)~=tensor_MT then
        error("cannot do the thing to the thing (you somehow managed to call the unm metamethod on a non-tensor metatable)")
    end
    local result = {}
    for i = 1, #dat do
        result[i] = main.unmRec(dat[i])
    end
    return result
end
function tensor_MT.__sub(t1,t2)
    return t1+(-t1)
end
function tensor_MT.div(t1,k)
    if type(k)~="number" then
        error("Can't divide tensors by anything other than a scalar")
    end
    local result = main.divRec(t1,k)
    return setmetatable(result,tensor_MT)
end
local function main.divRec(t,k)
    if type(t1)=="number" then
        return t/k
    end
    local result = {}
    for i = 1, #t do
        result[i] = main.divRec(t[i],k)
    end
    return result
end
function tensor:sum()
    local result = main.sumRec(self)
    return result
end
local function main.sumRec(t)
    if type(t)=="number" then
        return t
    end
    local result = 0
    for i = 1, #t do
        result = result+main.sumRec(t)
    end
    return result
end
function tensor:min()
    local result = main.minRec(self)
    return result
end
local function main.minRec(t)
    local minVal = math.huge
    if type(t)=="table" and type(t[1])=="number"
        for i = 1, #t do
            if t[i]<minVal then
                minVal = t[i]
            end
        end
        return minVal
    end
    for i = 1, #t do
        if main.minRec(t)<minVal then
            minVal = main.minRec(t)
        end
    end
    return minVal
end
function tensor:itemCount()
    local result = main.itemCountRec(self)
    return result
end
local function main.itemCountRec(t)
    if type(t)=="number" then
        return 1
    end
    local sum = 0
    for i = 1, #t do
        sum = sum + main.itemCountRec(t)
    end
    return sum
end
function tensor:mean()
    local result = self:sum()/self:itemCount()
    return result
end
