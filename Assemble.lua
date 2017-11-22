-- This script is used to check all the Material/Texture/RenderItem
-- exist, because all the reference is by name.
-- In the RenderItem, we will try to check that the 
-- Material exist,
-- and in the material, all the texture exist.
-- restrict the var name inside the function

_ENV = {_G = _G}
_G.setmetatable(_ENV, {__index = _G})
MatPart = require("MaterialPart")
TexPart = require("TexturePart")
GeoPart = require("GeometryPart")
RItemPart = require("RenderItemPart")

-- useful function to push asset into some queue(
-- assembleSet{MaterialQueue,TextureQueue, RenderItemQueue, GeometryQueue}.
function PushAsset(ast, targetQueue)
    local newCount = targetQueue.n + 1
    targetQueue.n = newCount
    targetQueue[newCount] = ast
    ast.index = newCount
end

function PushMaterial(mat)
    PushAsset(mat, assembleSet.MaterialQueue)
end

function PushTexture(text)
    PushAsset(text, assembleSet.TextureQueue)
end

function PushGeometry(geo)
    PushAsset(geo, assembleSet.GeometryQueue)
end

function PushRenderItem(ritem)
    PushAsset(ritem, assembleSet.RenderItemQueue)
end


-- check and push geometry
function CheckGeometries()
    local haveErrorGeometry = false
    for k, g in pairs(GeoPart.GeometrySet) do
        local isErrorGeometry = false
        
        if g:readFile() then
            PushGeometry(g)
        else
            isErrorGeometry = true
            haveErrorGeometry = true
        end
    end
    return haveErrorGeometry
end

-- check the renderItems
function CheckRenderItems()
    
    local haveErrorRitem = false
    -- use a local var to refer to the set, 
    -- because the name is too long.
    local ritemSet = RItemPart.RenderItemSet
    
    -- from the ritem aspect.
    for i = 1, #ritemSet do
        
        -- Is the Ritem an error?
        local isErrorRitem = false
        
        ritem = ritemSet[i]
        
        -- check geometry, here we don't check if the obj file exist,
        -- just the geometry.
        if GeoPart.GeometrySet[ritem.geometry] == nil then
            print("error: missing geometry")
            isErrorRitem = true
        end
        
        -- check material
        if MatPart.MaterialSet[ritem.material] == nil then
            print("error: missing material")
            isErrorRitem = true
        end
        
        if isErrorRitem then
            ritem:showDetail()
            -- notify the outer error flag.
            haveErrorRitem = true
        else
            PushRenderItem(ritem)
        end
    end
    
    return haveErrorRitem
end

-- check the Textures and push it into the queue
function CheckTextures()
    local haveErrorTexture = false
    -- arrange texture this must before the material
    for k, t in pairs(TexPart.TextureSet) do
        local isErrorTexture = false
        
        PushTexture(t)
    end
    
    return haveErrorTexture
end

-- check and push the material
function CheckMaterials()
    local haveErrorMat = false
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
            haveErrorMat = true
        else -- no error, add to a map using number as key.
            PushMaterial(m)
        end
    end
    return haveErrorMat
end

-- THE KEY FUNCTION TO BE RETURNED
function Assemble()    
    -- clear the previous queue
    assembleSet = {
        -- all the assets will be arrangeed into a array
        MaterialQueue = {n = 0}, 
        TextureQueue = {n = 0},
        GeometryQueue = {n = 0},
        RenderItemQueue = {n = 0}
    }
    
    
    -- Is there any error with all the ritem?
    local isError = false
    
    -- the Geomentry must be checked before the RenderItem
    print('ck geo')
    isError = CheckGeometries()
    print('ck ritem')
    isError = CheckRenderItems()
    -- the texture must be check before the Material
    print('ck tx')
    isError = CheckTextures()
    print('ch mt')
    isError = CheckMaterials()
    
    -- conclude
    if isError then
        print("Assembling failed!")
    else
        print("Assembling success.")
    end
    
    -- show the statics
    print("Texture Count:"..assembleSet.TextureQueue.n)
    print("Material Count:"..assembleSet.MaterialQueue.n)
    print("Geometry Count:"..assembleSet.GeometryQueue.n)
    print("RenderItem Count:"..assembleSet.RenderItemQueue.n)
    
    return isError, assembleSet
end

return Assemble
