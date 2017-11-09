require "NameObject"

Geometry = class(FileObject)

local GeoPart = {}

GeoPart.Geometry = Geometry
GeoPart.GeometrySet = {}

-- This will add the Geometry Instance to the GeoPart.AllGeoSet
function Geometry:addToGlobalSet()
    GeoPart.GeometrySet[self.name] = self
end

function Geometry:showDetail()
    print("******** Geometry:\t"..self.name)
    print("Obj file from:\t"..self.file)
end

return GeoPart
