md = require("MeshData")
a = md.new()
a:show()
a:help()
a:addPosition(1.0, 0.5, 1.0)

print('After modified.')
a:show()

a:addNormal(0.2, 0.2, 0.2)
a:addTangentU(0.3, 0.3, 0.3)
a:addTextureCoord(0.4, 0.4)

a:addVertex(1, 1, 1, 1)
a:addIndex(1)
a:show()
