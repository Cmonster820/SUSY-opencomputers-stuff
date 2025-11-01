--linear algebra library
--remember that matrix index notation is row,column so you don't break everything you big dumbo writing this comment
math = require("math")
--below is all vector stuff
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
    elseif getmetatable(v1)==vector and getmetatable(v2)==matrix and #v1==#v2[1] then
        local result = {}
        for i = 1, #v1 do
            local sum = 0
            for j = 1, #v2[i] do
                sum = sum + (v1[i]*v2[i][j])
            end
            result[i] = sum
        end
    elseif getmetatable(v1)==vector and getmetatable(v2)==matrix and #v1~=#v2[1] then
        error("Dimension of vector is not equal to dimension of matrix")
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
function vector:mag()
    sumsquares = 0
    for i = 1, #self do
        sumsquares = sumsquares + self[i]^2
    end
    return math.sqrt(sumsquares)
end
function vector.__mod(v1,v2)--angle between v1 and v2
    return math.acos((v1*v2)/(v1:mag()*v2:mag()))
end
function vector.__idiv(v1,v2) -- cross product is v1//v2 bc scalar division is v1/k
    if #v1~=3 or #v2~=3 then
        error("Ya dumbo cross product only works on 3 and 7 dimensional vectors and this doesnt support 7d because why would it and Idk how to implement octonion operations")
    elseif #v1~=#v2 then
        error("Ya dumbo cross product requires equal dimensions")
    end
    return setmetatable({v1[2]*v2[3]-v1[3]*v2[2], v1[3]*v2[1]-v1[1]*v2[3], v1[1]*v2[2]-v1[2]*v2[1]},vector)
end
function vector.__div(v1,k) --scalar division (v1/k = <v1_1/k,v1_2/k...v1_#v1/k>)
    local result = {}
    for i = 1, #v1 do
        result[i] = v1[i]/k
    end
    return setmetatable(result, vector)
end
function vector.__eq(v1,v2)
    if #v1~=#v2 then
        return false
    end
    for i = 0, #v1 do
        if v1[i]~=v2[i] then
            return false
        end
    end
    return true
end
function vector.__pow(v,exp) --elementwise exponentiation
    local result = {}
    for i = 0, #v do
        result[i] = v[i]^exp
    end
    return setmetatable(result,vector)
end
function vector.pow(v,exp) --dot product thing (v1*v2 applied exp times)
    result = v
    setmetatable(result, vector)
    for i = 0, exp do
        result = result*v
    end
    return setmetatable(result, vector)
end
--everything below is matrix stuff
--row,column reminder
--mtrx[row][column]
matrix = {}
function mtrnew(rows, columns, items)
    if #items > rows*columns then
        error("you really just tried to make a matrix with more items than it can hold, didn't you?")
    end
    local result = {}
    local listiterator = 1
    for i = 1, rows do
        result[i] = {}
        for j = 1, columns do
            result[i][j] = items[listiterator]
            listiterator = listiterator+1
        end
    end
    return setmetatable(result,matrix)
end
function matrix.__unm(m)
    local result = {}
    for i = 1, #m do
        result[i]={}
        for j = 1, #m[1] do 
            result[i][j] = -m[i][j]
        end
    end
    return setmetatable(result,matrix)
end
function matrix.__add(m1, m2)
    if (#m1~=#m2) or (#m1[1]~=#m2[1]) then
        error("Error: matricies are not equal in size")
    end
    local result = {}
    for i = 1, #m1 do
        result[i] = {}
        for j = 1, #m1[1] do
            result[i][j] = m1[i][j]+m2[i][j]
        end
    end
    return setmetatable(result,matrix)
end
function matrix.__sub(m1, m2)
    result = m1+(-m2)
    return setmetatable(result,matrix)
end
function matrix.__mul(m1, m2)
    if type(m1)=="number" then
        local result = {}
        for i = 1, #m2 do
            result[i] = {}
            for j = 1, #m2[i] do
                result[i][j] = m1*m2[i][j]
            end
        end
        return setmetatable(result,matrix)
    elseif getmetatable(m1) == matrix
        if #m1[1]~=#m2 then
            error("Columns of matrix 1 not equal to rows of matrix 2")
        end
        local result = {}
        local resultiterator = 1
        for i = 1, #m1 do
            local sum = 0
            result = {}
            for j = 1, #m1[i] do
                sum = sum + (m1[i][j]*m2[j][i])
            end
            result[i] = sum
        end
        return setmetatable(mtrnew(#m1,#m2[1],result),matrix)
    end
end
function matrix:t()
    result = {}
    for i = 1, #self[i] do
        result[i] = {}
        for j = 1, #self do
            result[i][j] = self[j][i]
        end
    end
    return setmetatable(result, matrix)
end
