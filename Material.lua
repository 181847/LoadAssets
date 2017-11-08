require "class"
textSet = require "TextureSet"
Material = class();

-- Store the material that will use to be rendering.
gMaterialSet = {}

-- Create a material with the name, through which we will find it in the gMaterialSet.
function material:ctor(name)
    self.name = name
    self.diffuseAlbedo = {1.0, 1.0, 1.0, 1.0}
    self.FresnelR = {0.01, 0.01, 0.01}
    self.Roughness = 0.5f;
    
    -- 贴图是在一个贴图集合中的贴图的名称
    self.diffuseAlbedo = nil
    self.NormalMap = nil
end

function material:showDetail()
    print(string.format("\"%s\"", self.name, ))
end
