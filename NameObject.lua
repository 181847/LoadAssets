require "class"

_ENV = {_G = _G}
_G.setmetatable(_ENV, {__index = _G})

_G.NameObject = class()

function NameObject:ctor(name)
    _, _, self.name = assert(type(name) == "string", "Must use a string as the name.", name)
end

_G.FileObject = class(NameObject)

function FileObject:ctor(name, file)
    self.file = file
end
