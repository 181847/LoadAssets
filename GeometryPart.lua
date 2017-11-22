require("NameObject")
_ENV = {_G = _G}
_G.setmetatable(_ENV, {__index = _G})

_G.Geometry = class(FileObject)
-- MeshData is a C Module which will store the vertices and indices,
-- the information will be loaded from the specific *.obj file
MeshData = require("MeshData")
ObjModule = require("ReadObjModule")

local GeoPart = {}

GeoPart.Geometry = Geometry
GeoPart.GeometrySet = {}


-- ************ Geometry Class Defination *******************
-- This will add the Geometry Instance to the GeoPart.AllGeoSet
function Geometry:addToGlobalSet()
    GeoPart.GeometrySet[self.name] = self
end

-- show some detail of the geometry
function Geometry:showDetail()
    print("******** Geometry:\t"..self.name)
    print("Obj file from:\t"..self.file)
    if self.meshData then
        self.meshData:show();
    end
    if self.subMeshes then
        ObjModule.printSubMesh(self.subMeshes)
    end
end

-- here the Geometry will add a new meshData as a memeber field.
-- then read from self.file and fill into the meshData.
-- the meshData is a userData which is defined in the LuaMeshData.h,
-- subMeshes is a table look link
--[[
subMeshes 
    box1
        1
        2
    sphere
        3
        15
--]]  
function Geometry:readFile()
    -- read the file,
    -- if the file dosen't exist,
    -- return nil
    local meshData, subMeshes = ObjModule.readFile(self.file)
    if meshData and subMeshes then
        self.meshData = meshData
        self.subMeshes = subMeshese
        return true
    else
        return false
    end        
end

return GeoPart
