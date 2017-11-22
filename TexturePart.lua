require "NameObject"


_ENV = {_G = _G}
_G.setmetatable(_ENV, {__index = _G})


_G.Texture = class(FileObject)

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
