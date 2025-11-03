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
    local dataT1 = (getmetatable(t1)==tensor_MT) and t1.data or t1
    local dataT2 = (getmetatable(t2)==tensor_MT) and t2.data or t2
    local resultData = main.addRec(dataT1, dataT2)
    return main.tensor.new(resultData)
end
function main.addRec(dat1,dat2)
    if type(dat1)=="number" and type(dat2)=="number" then
        return dat1+dat2
    end
    if type(data1) ~= "table" or type(data2) ~= "table" or #data1 ~= #data2 then
        error("Attempted to add tensors with incompatible shapes or types",2)
    end
    local result = {}
    for i = 1, #data1 do
        result[i] = main.addRec(dat1[i],dat2[i])
    end
    return result
end
function tensor_MT.__unm(t)
end