Node = require("Node2").Node

Element = Node:new()

function Element:appendChild(node)
    table.insert(self.children, node)
end


x = Element:new()
print(x.childNodes)