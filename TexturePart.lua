require "NameObject"

Texture = class(NameObject)

local TextPart = {};

TextPart.TextureSet = {}
TextPart.Texture = Texture

function Texture:ctor(name, textureFile)
end

function Texture:addToGlobalSet()
    TextPart.TextureSet[self.name] = self
end

function Texture:showDetail()
    print("******** Geometry:\t"..self.name))
    print("Obj file from:\t"..self.objFile)
end

return TextPart
