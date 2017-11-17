
function Assemble()
    -- restrict the var name inside the function
    _ENV = {_G = _G}
    _G.setmetatable(_ENV, {__index = _G})
    
    MatPart = require("MaterialPart")
    TexPart = require("TexturePart")
    GeoPart = require("GeometryPart")
    RItemPart = require("RenderItemPart")
    
    -- store all the Part in the assembleSet
    local assembleSet = {
        MatPart = MatPart,
        TexPart = TexPart,
        GeoPart = GeoPart,
        RItemPart = RItemPart,
        MaterialQueue = {n = 0}, -- use the MaterialSet to store the Material using number as key, n store the counter.
        TextureQueue = {n = 0}
    }
    
    -- This script is used to check all the Material/Texture/RenderItem
    -- exist, because all the reference is by name.
    -- In the RenderItem, we will try to check that the 
    -- Material exist,
    -- and in the material, all the texture exist.
    
    -- Is there any error with all the ritem?
    local isError = false
    
    -- use a local var to refer to the set, 
    -- because the name is too long.
    local ritemSet = RItemPart.RenderItemSet
    
    -- from the ritem aspect.
    for i = 1, #ritemSet do
        
        -- Is the Ritem an error?
        local isErrorRitem = false
        
        -- check geometry, here we don't check if the obj file exist,
        -- just the geometry.
        if GeoPart.GeometrySet[ritemSet[i].geometry] == nil then
            print("error: missing geometry")
            isErrorRitem = true
        end
        
        -- check material
        if MatPart.MaterialSet[ritemSet[i].material] == nil then
            print("error: missing material")
            isErrorRitem = true
        end
        
        if isErrorRitem then
            ritemSet[i]:showDetail()
            -- notify the outer error flag.
            isError = true
        end
    end
    
    -- arrange texture this must before the material
    for k, t in pairs(TexPart.TextureSet) do
        local isErrorTexture = false
        
        -- for now, don't check any error
        assembleSet.TextureQueue.n = assembleSet.TextureQueue.n + 1
        -- add a index to the Texture
        t.index = assembleSet.TextureQueue.n
        assembleSet.TextureQueue[t.index] = t;
    end
    
    -- from the material aspect, missing any texture?
    -- again, now we don't care about the real file.
    for k, m in pairs(MatPart.MaterialSet) do
        -- Is the material an error?
        local isErrorMaterial = false
        
        t = TexPart.TextureSet[m.diffuseMap]
        -- check diffuse map
        if m.diffuseMap ~= nil and t == nil then
            print("error: missing diffuseMap")
            isErrorMaterial = true
        elseif m.diffuseMap ~= nil then
            m.diffuseMapIndex = t.index
        end
        
        t = TexPart.TextureSet[m.normalMap]
        -- check normal map
        if m.normalMap ~= nil and t == nil then
            print("error: missing normalMap")
            isErrorMaterial = true
        elseif m.normalMap ~= nil then
            m.normalMapIndex = t.index
        end
        
        -- some error
        if isErrorMaterial then
            m:showDetail()
            -- notify the outer error flag.
            isError = true
        else -- no error, add to a map using number as key.
            assembleSet.MaterialQueue.n = assembleSet.MaterialQueue.n + 1
            assembleSet.MaterialQueue[assembleSet.MaterialQueue.n] = m
        end
    end
    
    
    -- conclude
    if isError then
        print("Assembling failed!")
    else
        print("Assembling success.")
    end
    
    -- show the statics
    print(string.format("Materials Count: \t\t%d", assembleSet.MaterialQueue.n))
    
    return isError, assembleSet
end

return Assemble
