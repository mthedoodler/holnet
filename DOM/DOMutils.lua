local classutils = require("classutils")
require("DOMdatatypes")
require("tableutils")
local pretty = require("cc.pretty")
local expect = classutils.expect

local WHITESPACE = { --Uses these whitespaces instead of unicode's ones as computercraft uses a modified ISO-8859-1 + Codepage 437 for encoding strings. 
    [0x09] = true, --Tab
    [0x0A] = true, --Newline
    [0x0D] = true, --Carraige Return
    [0x20] = true, --Space
    [0xA0] = true, --Non Line-Breaking Space
}

local MATCH_QUALIFIEDNAME_NAMESTARTCHAR = "^[%a_:À-ÖØ-öø-ÿ]$" -- Matches all the corresponding characters valid for NameStartChar according to the XML spec(https://www.w3.org/TR/REC-xml).	
local MATCH_QUALIFIEDNAME_NAMECHAR = "^[%a_:À-ÖØ-öø-ÿ%-.%d·]$" --Matches all the corresponding characters valid for NameChar
local MATCH_QUALIFIEDNAME_NAME = "^[%a_:À-ÖØ-öø-ÿ][%a_:À-ÖØ-öø-ÿ%-.%d·]*$" --Matches all the corresponding characters valid for Name
local MATCH_QUALIFIEDNAME_NCNAME = "^[%a_:À-ÖØ-öø-ÿ][%a_À-ÖØ-öø-ÿ%-.%d·]*$" --Matches all the corresponding characters valid for NCName

local XML_NAMESPACE = "http://www.w3.org/XML/1998/namespace"
local XMLNS_NAMESPACE = "http://www.w3.org/2000/xmlns/"

local function isWhitespace(c)
    return WHITESPACE[string.byte(c)] == true
end

local function isNotWhitespace(c)
    return not isWhitespace(c)
end

local function collectSequence(_input, condition, position)
    expect(1, _input, "string")
    expect(2, condition, "function")
    expect(3, position, "number")

    local result = ""
    while (position <= #_input and condition(_input:sub(position, position))) do
        result = result .. _input:sub(position, position)
        position = position + 1
    end
    return result, position
end

local function splitOnWhitespace(_input)
    expect(1, _input, "string")
    local position = 1
    local tokens = {}
    local result
    _, position = collectSequence(_input, isWhitespace, position)

    while (position <= #_input) do
        result, position = collectSequence(_input, isNotWhitespace, position)
        table.insert(tokens, result)
        _, position = collectSequence(_input, isWhitespace, position)
    end

    return tokens
end

local function strictlySplit(_input, delimiter)
    expect(1, _input, "string")
    expect(2, delimiter, "string")
    local position = 1
    local tokens = {}
    local result
    local token
    result, position = collectSequence(_input, function(x) return x ~= delimiter end, position)
    table.insert(tokens, result)

    while position < #_input do
        --print(position)
        --print(_input:sub(position,position))
        --print(delimiter)
        --print(_input:sub(position,position) ~= delimiter)
        if _input:sub(position,position) ~= delimiter then error("Something went wrong!") end

        position = position + 1
        token, position = collectSequence(_input, function(x) return x ~= delimiter end, position)
        table.insert(tokens, token)
    end

    return tokens
end

print(collectSequence("hello world", function(x) return x ~= " " end, 1))
pretty.pretty_print(strictlySplit("hello!world", "!"))

local function orderedSetParser(_input)
    expect(1, _input, "string")

    local inputTokens = splitOnWhitespace(_input)
    local tokens = OrderedSet({})
    for _, token in pairs(inputTokens) do
        table.insert(tokens, token)
    end

    return tokens
end

local function orderedSetSerializer(set)
    expect(1, set, "table")
    return table.concat(set, "\x20")
end

local function validateQName(qualifiedName)
    expect(1, qualifiedName, "string")
    local colon = qualifiedName:find(":")
    if colon then
        local prefix = qualifiedName:sub(1, colon-1)
        local localPart = qualifiedName:sub(colon+1, -1)
        print(prefix:match(MATCH_QUALIFIEDNAME_NCNAME))
        if prefix:match(MATCH_QUALIFIEDNAME_NCNAME) and localPart:match(MATCH_QUALIFIEDNAME_NCNAME) then
            return prefix, localPart
        end

    else
        local localPart = qualifiedName:sub(colon+1, -1)
        if localPart:match(MATCH_QUALIFIEDNAME_NCNAME) then
            return nil, localPart
        end
    end

    error("InvalidCharacterError: DOMException", 3)
end

validateQName("Hello:BITCH")
--validateQName("H/ello:BITCH")
--validateQName("123:vsa")

local function validateAndExtractQName(namespace, qualifiedName)
    expect(1, namespace, "string")
    expect(2, qualifiedName, "string")

    if namespace == "" then
        namespace = nil
    end

    validateQName(qualifiedName)
    local prefix = nil
    local localName = qualifiedName
    local splitResult
    if qualifiedName:find(":") then
        splitResult = strictlySplit(qualifiedName, ":")
        prefix = splitResult[1]
        localName = splitResult[2]
    end

    if prefix == nil and namespace == nil then
        error("NamespaceError: DOMException", 3)
    end

    if prefix == "xml" and namespace ~= XML_NAMESPACE then
        error("NamespaceError: DOMException", 3)
    end

    if prefix == "xmlns" and namespace ~= XMLNS_NAMESPACE then
        error("NamespaceError: DOMException", 3)
    end

    if namespace == XMLNS_NAMESPACE and (qualifiedName ~= "xmlms" or prefix ~= "xmlns") then
        error("NamespaceError: DOMException", 3)
    end

    return namespace, prefix, localName
end



pretty.pretty_print(splitOnWhitespace("123\t456\n789"))
pretty.pretty_print(orderedSetParser("hello world hello"))
pretty.pretty_print(orderedSetSerializer(orderedSetParser("hello world hello")))

print(validateAndExtractQName("http://www.w3.org/XML/1998/namespace", "xml:iwonder2"))
--print(validateAndExtractQName("a", "xml:iwonder2"))
--print(validateAndExtractQName("potato", "a233:iwonder2"))

return orderedSetParser