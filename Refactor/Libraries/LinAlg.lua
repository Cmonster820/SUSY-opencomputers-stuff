--linear algebra library
--remember that matrix index notation is row,column so you don't break everything you big dumbo writing this comment
math = require("math")
--below is all vector stuff
vector_MT = {}
vector_MT.__index = vector_MT
function vnew(...)
    local v = {...}
    return setmetatable(v,vector_MT)
end
function vector_MT.__add(v1,v2)
    local result = {}
    local size = math.max(#v1,#v2)
    for i = 0, size do
        result[i] = (v1[i] or 0)+(v2[i] or 0)
    end
    return setmetatable(result,vector_MT)
end
function vector_MT.__sub(v1,v2)
    local result = {}
    local size = math.max(#v1,#v2)
    for i = 0, size do
        result[i] = (v1[i] or 0)-(v2[i] or 0)
    end
    return setmetatable(result,vector_MT)
end
function vector_MT.__unm(v)
    local result = {}
    for i = 1, #v do
        result[i] = -v[i]
    end
    return setmetatable(result,vector_MT)
end
function vector_MT.__eq(v1,v2)
    if #v1~=#v2 then return false end
    for i = 1, #v1 do
        if v1[i]~=v2[i] then return false end
    end
    return true
end
function vector_MT.__newindex(v)
    error("you just tried a bad (you tried to access a nonexistent index)")
    return nil
end
function vector_MT.__mul(v1,v2)
    if type(v1)=="number" then
        local result = {}
        for i = 1, #v2 do
            result[i] = v2[i]*k
        end
        return setmetatable(result,vector_MT)
    elseif getmetatable(v1)==vector_MT and getmetatable(v2)==matrix_MT and #v1==#v2[1] then
        local result = {}
        for i = 1, #v1 do
            local sum = 0
            for j = 1, #v2[i] do
                sum = sum + (v1[i]*v2[i][j])
            end
            result[i] = sum
        end
    elseif getmetatable(v1)==vector_MT and getmetatable(v2)==matrix_MT and #v1~=#v2[1] then
        error("Dimension of vector is not equal to dimension of matrix_MT")
    elseif getmetatable(v1)==vector_MT then
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
function vector_MT:mag()
    sumsquares = 0
    for i = 1, #self do
        sumsquares = sumsquares + self[i]^2
    end
    return math.sqrt(sumsquares)
end
function vector_MT.__mod(v1,v2)--angle between v1 and v2
    return math.acos((v1*v2)/(v1:mag()*v2:mag()))
end
function vector_MT.__idiv(v1,v2) -- cross product is v1//v2 bc scalar division is v1/k
    if #v1~=3 or #v2~=3 then
        error("Ya dumbo cross product only works on 3 and 7 dimensional vectors and this doesnt support 7d because why would it and Idk how to implement octonion operations")
    elseif #v1~=#v2 then
        error("Ya dumbo cross product requires equal dimensions")
    end
    return setmetatable({v1[2]*v2[3]-v1[3]*v2[2], v1[3]*v2[1]-v1[1]*v2[3], v1[1]*v2[2]-v1[2]*v2[1]},vector_MT)
end
function vector_MT.__div(v1,k) --scalar division (v1/k = <v1_1/k,v1_2/k...v1_#v1/k>)
    local result = {}
    for i = 1, #v1 do
        result[i] = v1[i]/k
    end
    return setmetatable(result, vector_MT)
end
function vector_MT.__eq(v1,v2)
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
function vector_MT.__pow(v,exp) --elementwise exponentiation
    local result = {}
    for i = 0, #v do
        result[i] = v[i]^exp
    end
    return setmetatable(result,vector_MT)
end
function vector_MT.pow(v,exp) --dot product thing (v1*v2 applied exp times)
    result = v
    setmetatable(result, vector_MT)
    for i = 0, exp do
        result = result*v
    end
    return setmetatable(result, vector_MT)
end
--everything below is matrix stuff
--row,column reminder
--mtrx[row][column]
matrix_MT = {}
matrix_MT.__index = matrix_MT
function mtrnew(rows, columns, items) -- idk why I made this tbh this one sucks
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
    return setmetatable(result,matrix_MT)
end
function mnew(...) --for creating from a bunch of tables
    local result = {...}
    return setmetatable(m,matrix_MT)
end
function matrix_MT.__unm(m)
    local result = {}
    for i = 1, #m do
        result[i]={}
        for j = 1, #m[1] do 
            result[i][j] = -m[i][j]
        end
    end
    return setmetatable(result,matrix_MT)
end
function matrix_MT.__add(m1, m2)
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
    return setmetatable(result,matrix_MT)
end
function matrix_MT.__sub(m1, m2)
    result = m1+(-m2)
    return setmetatable(result,matrix_MT)
end
function matrix_MT.__mul(m1, m2)
    if type(m1)=="number" then
        local result = {}
        for i = 1, #m2 do
            result[i] = {}
            for j = 1, #m2[i] do
                result[i][j] = m1*m2[i][j]
            end
        end
        return setmetatable(result,matrix_MT)
    elseif getmetatable(m1) == matrix_MT
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
        return setmetatable(mtrnew(#m1,#m2[1],result),matrix_MT)
    end
end
function matrix_MT:t()
    local result = {}
    for i = 1, #self[1] do
        result[i] = {}
        for j = 1, #self do
            result[i][j] = self[j][i]
        end
    end
    return setmetatable(result, matrix_MT)
end
function matrix_MT.__div(m,k) -- scalar division
    local result = {}
    for i = 1, #m do
        result[i]={}
        for j = 1, #m[i] do
            result[i][j] = m[i][j]/k
        end
    end
    return setmetatable(result,matrix_MT)
end
local function getMinor(m, colExcl, rowExcl)
    local subM = {}
    local subRow = 1
    for i = 1, #m do
        if i ~= rowExcl then
            local subCol = 1
            subM[subRow] = {}
            for j = 1, #m[i] do
                if j~=colExcl then
                    subM[subRow][subCol] = m[i][j]
                    subCol = subCol+1
                end
            end
            subRow = subRow+1
        end
    end
    return setmetatable(subM,matrix_MT)
end
function matrix_MT:det()
    if #self==0 or #self~=#self[1] then
        error("Attempted to find determinant of non-square matrix_MT or empt matrix_MT")
    end
    if #self == 1 then
        return self[1][1]
    end
    if #self==2 then
        return self[1][1]*self[2][2]-self[1][2]*self[2][1]
    else
        local sum = 0
        for i = 1, #self do
            local cofactorSign = ((i+1)%2==0) and 1 or -1
            local minor = getMinor(self, 1, i)
            sum = sum + (self[1][i]*cofactorSign*minor:det())
        end
        return sum
    end
end
function matrix_MT:inv()
    if #self ~= #self[1] then
        error("Matrix must be square to be invertible")
    end
    local det = self:det()
    if det == 0 then
        error("Matrix is singular (whatever that means) and has no inverse")
    end
    if #self == 2 then
        local invDet = 1/det
        return mnew(
            {self[2][2]*invDet,-self[1][2]*invDet},
            {-self[2][1]*invDet,self[1][1]*invDet}
        )
    end
    --google AI don't fail me now
    local cofactorMtr = mnew()
    for i = 1, #self do
        cofactorMtr[i] = {}
        for j = 1, #self[1] do
            local minor = getMinor(self, i, j)
            local minordet = minor:det()
            local sign = ((i+2)%2==0) and 1 or -1
            cofactorMtr[i][j] = sign * minordet
        end
    end
    local adj = cofactorMtr:t() --adjugate matrix
    local inverse = mnew()
    local invDet = 1/det
    inverse = invDet*adj
    return inverse
end
--yay line 300 we're done
--non-standard operation
function matrix_MT:sum()
    local sum = 0
    for i = 1, #self do
        for j = 1, #self[1] do
            sum = sum+self[i][j]
        end
    end
    return sum
end