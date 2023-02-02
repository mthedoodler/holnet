--Modified from https://gist.github.com/RyanPattison/0f7307ee39a5238270a0

local NamedNodeMap = {}

-- private unique keys
local _values = {}
local _keys = {}

function NamedNodeMap.insert(t, k, v)

end

local function find(t, v)
  for i,val in ipairs(t) do
    if v == val then
      return i
    end
  end
end

function NamedNodeMap.remove(t, k)
  local tv = t[_values]
  local v = tv[k]
  if v ~= nil then
    local tk = t[_keys]
    table.remove(tk, assert(find(tk, k)))
    tv[k] = nil
  end 
  return v
end

-- set metamethods for ordered_table "class"
NamedNodeMap.__newindex=NamedNodeMap.insert -- called for updates too since we store the value in `_values` instead. 
NamedNodeMap.__len=function(t) return #t[_keys] end
NamedNodeMap.__pairs=NamedNodeMap.pairs
NamedNodeMap.__index=function(t, k) return t[_values][k] end -- function so we can share between tables 

function NamedNodeMap:new(init)
  init = init or {}
  local key_table = {}
  local value_table = {}
  local t = {[_keys]=key_table, [_values]=value_table}
  local n = #init
  if n % 2 ~= 0 then
    error("key: "..tostring(init[#init]).." is missing value", 2)
  end
  for i=1,n/2 do
    local k = init[i * 2 - 1]
    local v = init[i * 2]
    if value_table[k] ~= nil then
      error("duplicated key:"..tostring(k), 2)
    end
    key_table[#key_table + 1]  = k
    value_table[k] = v
  end
  return setmetatable(t, self)
end

