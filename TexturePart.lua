require "NameObject"

Texture = class(FileObject)

local TextPart = {};

TextPart.TextureSet = {}
TextPart.Texture = Texture

function Texture:addToGlobalSet()
    TextPart.TextureSet[self.name] = self
end

function Texture:showDetail()
    print("******** Texture:\t"..self.name)
    print("Texture file from:\t"..self.file)
end

return TextPart
