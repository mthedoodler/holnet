function newNode()
    local o = {}
    o.children = {}
    o.type = ""
    o.attributes = {}
    return o
end

function makeCSSPropertyName(str)
    out = ""
    for token in string.gmatch(str, "[^-]+") do --Make string do the thing
        print(token)
        out = out .. token:sub(1,1):upper() .. token:sub(2,-1):lower()
    end
    out = out:sub(1,1):lower() .. out:sub(2,-1)
    return out
end

function parse(html)
    local root = newNode()
    local stack = {root}

    for tag, attributes, content in html:gfind("<([/%w%d]+)%s*([^<>]*)>[%s]*([^<>\n]*)[%s]*") do
        --print("Tag: "..tag)
        --print("Content:" .. content)
        if tag:sub(1,1) ~= "/" then

            local node = newNode()
            node.type = tag

            if attributes then
                print("Attributes: " .. attributes)
                for key, value in attributes:gfind("[%s]*([-%a]+)%s*=%s*[\"](*+)[\"]*") do
                    print(key)
                    node.attributes[key] = value
                end
            end

            table.insert(stack[#stack].children, node)
            table.insert(stack, node)
        else
            if tag:sub(2, -1) ~= stack[#stack].type then error("Tag <" .. stack[#stack].type .. "> not closed.") end
            stack[#stack] = nil
        end

        if content then
            local textNode = newNode()
            textNode.textContent = "text"
            textNode.textContent = content
            table.insert(stack[#stack].children,textNode)
        end
    end

    return root
end

myHTML = [[
    <html>
        <head>
            <title tag="1" tagp=2>
            Hel lo!
            </title>
        </head>
        <body style="background-color: red;">
            P
            <div></div>
            P
        </body>
    </html>
]]

myRoot = parse(myHTML)

print(myRoot.children[1].children[1].type) -- Should print 'head'
print(makeCSSPropertyName("background-color"))

fs.open("log.txt", "w").write(textutils.serialize(parse(myHTML))).close()
