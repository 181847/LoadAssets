require "NameObject"
local textSet = require "TexturePart"

Material = class(NameObject)

local MatPart = {}

MatPart.Material = Material
-- Store the material that will use to be rendering.
MatPart.MaterialSet = {}

-- Create a material with the name, through which we will find it in the MatPart.gMaterialSet.
function Material:ctor(name)
    self.diffuseAlbedo = {1.0, 1.0, 1.0, 1.0}
    self.fresnelR = {0.01, 0.01, 0.01}
    self.roughness = 0.5;
    
    -- the next two map is not necessary.
    self.diffuseMap = nil
    self.normalMap = nil
end

function Material:showDetail()
    print(string.format("******Material \"%s\" detail:", self.name))
    print(string.format("diffuseAlbedo:\t%f,\t%f,\t%f,\t%f", table.unpack(self.diffuseAlbedo)))
    print(string.format("fresnelR:\t%f,\t%f,\t%f", table.unpack(self.fresnelR)))
    print(string.format("roughness:\t%f", self.roughness))
    
    
    if self.diffuseMap then
        print("diffuseMap:\t"..self.diffuseMap)
    end
    
    if self.normalMap then
        print("diffuseMap:\t"..self.normalMap)
    end
end

-- Add the Material instance to the 
function Material:addToGlobalSet()
    MatPart.MaterialSet[self.name] = self
end

return MatPart
