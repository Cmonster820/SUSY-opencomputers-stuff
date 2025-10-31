--linear algebra library
--remember that matrix index notation is row,column
math = require("math")
vector = {}
function vnew(...)
    local v = {...}
    return setmetatable(v,vector)
end
function vector.__add(v1,v2)
    local result = {}
    local size = math.max(#v1,#v2)
    for i = 0, size do
        result[i] = (v1[i] or 0)+(v2[i] or 0)
    end
    return setmetatable(result,vector)
end
function vector.__sub(v1,v2)
    local result = {}
    local size = math.max(#v1,#v2)
    for i = 0, size do
        result[i] = (v1[i] or 0)-(v2[i] or 0)
    end
    return setmetatable(result,vector)
end
function vector.__unm(v)
    local result = {}
    for i = 1, #v do
        result[i] = -v[i]
    end
    return setmetatable(result,vector)
end
function vector.__eq(v1,v2)
    if #v1~=#v2 then return false end
    for i = 1, #v1 do
        if v1[i]~=v2[i] then return false end
    end
    return true
end
function vector.__newindex(v)
    error("you just tried a bad (you tried to access a nonexistent index)")
    return nil
end
function vector.__mul(v1,v2)
    if type(v1)=="number" then
        local result = {}
        for i = 1, #v2 do
            result[i] = v2[i]*k
        end
        return setmetatable(result,vector)
    elseif getmetatable(v1)==vector then
        if #v1~=#v2 then
            error("bad bad naughty boy you can't do a vdot with 2 different lengths")
        end
        local sum = 0 
        for i = 1, #v1 do
            sum = sum + (v1[i]*v2[i])
        end
        return sum
    else
        error("what have you done")    
    end
end
function vector.__new(v1, v2) --google ai dont fail me now
    return vector.__mul(v2, v1)
end