MatPart = require("MaterialPart")
TexPart = require("TexturePart")
GeoPart = require("GeometryPart")
RItemPart = require("RenderItemPart")

-- This script is used to check all the Material/Texture/RenderItem
-- exist, because all the reference is by name.
-- In the RenderItem, we will try to check that the 
-- Material exist,
-- and in the material, all the texture exist.

-- Is there any error with all the ritem?
local isError = false


-- from the ritem aspect.
for i, v in pairs(RItemPart.RenderItemSet) do
    -- Is the Ritem an error?
    local isErrorRitem = false
    
    -- check geometry, here we don't check if the obj file exist,
    -- just the geometry.
    if GeoPart.GeometrySet[v.geometry] == nil then
        print("error: missing geometry")
        isErrorRitem = true
    end
    
    -- check material
    if MatPart.MaterialSet[v.material] == nil then
        print("error: missing material")
        isErrorRitem = true
    end
    
    if isErrorRitem then
        v:showDetail()
        -- notify the outer error flag.
        isError = true
    end
end

-- from the material aspect, missing any texture?
-- again, now we don't care about the real file.
for k, m in pairs(MatPart.MaterialSet) do
    -- Is the material an error?
    local isErrorMaterial = false
    
    -- check diffuse map
    if m.diffuseMap ~= nil and TexPart.TextureSet[m.diffuseMap] == nil then
        print("error: missing diffuseMap")
        isErrorMaterial = true
    end
    
    -- check normal map
    if m.normalMap ~= nil and TexPart.TextureSet[m.normalMap] == nil then
        print("error: missing normalMap")
        isErrorMaterial = true
    end
    
    if isErrorMaterial then
        m:showDetail()
        -- notify the outer error flag.
        isError = true
    end
end


-- conclude
if isError then
    print("Assembling failed!")
else
    print("Assembling success.")
end

return isError
