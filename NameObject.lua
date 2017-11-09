require "class"

NameObject = class()

function NameObject:ctor(name)
    _, _, self.name = assert(type(name) == "string", "Must use a string as the name.", name)
end

FileObject = class(NameObject)

function FileObject:ctor(name, file)
    self.file = file
end
