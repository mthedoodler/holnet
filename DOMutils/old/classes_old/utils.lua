--Took this function from https://luacode.wordpress.com/2011/09/23/lua-function-to-check-if-a-table-is-an-array/
function _isArray(t)
	if type(t)~="table" then return nil,"Argument is not a table! It is: "..type(t) end
	--check if all the table keys are numerical and count their number
	local count=0
	for k,v in pairs(t) do
		if type(k)~="number" then return false else count=count+1 end
	end
	--all keys are numerical. now let's see if they are sequential and start with 1
	for i=1,count do
		--Hint: the VALUE might be "nil", in that case "not t[i]" isn't enough, that's why we check the type
		if not t[i] and type(t[i])~="nil" then return false end
	end
	return true
end

function _isIn(t, el)
    --Returns the index of this element el in the table t, or nil if it's not in the table.
    for index, value in ipairs(t) do
        if el == value then
            return index
        end
    end
    return nil
end
