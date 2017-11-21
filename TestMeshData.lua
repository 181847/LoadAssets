module = require('ReadObjModule')

mesh, subMesh = module.readFile('Tank.obj')

mesh2, subMesh2 = module.readFile('shape.obj')
mesh3, subMesh3 = module.readFile('shapeG.obj')

mesh:show()
module.printSubMesh(subMesh)

print('*******mesh2*******')
mesh2:show()
module.printSubMesh(subMesh2)

print('*******mesh3*******')
mesh3:show()
module.printSubMesh(subMesh3)
