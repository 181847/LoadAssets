require "class"
textSet = require "TextureSet"
Material = class();

-- Store the material that will use to be rendering.
gMaterialSet = {}

-- Create a material with the name, through which we will find it in the gMaterialSet.
function material:ctor(name)
    self.name = name
    self.diffuseAlbedo = {1.0, 1.0, 1.0, 1.0}
    self.fresnelR = {0.01, 0.01, 0.01}
    self.roughness = 0.5;
    
    -- the next two map is not necessary.
    self.diffuseMap = nil
    self.normalMap = nil
end

function material:showDetail()
    print(string.format("\"%s\"", self.name, ))
    print(string.format("diffuseAlbedo: %f,\t%f,\t%f,\t%f", unpack(self.diffuseAlbedo)))
    print(string.format("fresnelR: %f,\t%f,\t%f", unpack(self.fresnelR)))
    print(string.format("roughness: %f", self.roughness)
    
    if self.diffuseMap then
        print("diffuseMap: "..self.diffuseMap)
    end
    
    if self.normalMap then
        print("diffuseMap: "..self.normalMap)
    end
end
