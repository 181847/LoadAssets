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

AssemblePart = {
    assembleSet = {}
}


-- this is a function that for print the error message
AssemblePart.logger = function(message, ...)
    print('####'..message, ...)
end

-- useful function to push asset into some queue(
-- assembleSet{MaterialQueue,TextureQueue, RenderItemQueue, GeometryQueue}.
function PushAsset(ast, targetQueue)
    local newCount = targetQueue.n + 1
    targetQueue.n = newCount
    targetQueue[newCount] = ast
    ast.index = newCount
    AssemblePart.logger('push called')
end

function PushMaterial(mat)
    PushAsset(mat, AssemblePart.assembleSet.MaterialQueue)
end

function PushTexture(text)
    PushAsset(text, AssemblePart.assembleSet.TextureQueue)
end

function PushGeometry(geo)
    PushAsset(geo, AssemblePart.assembleSet.GeometryQueue)
end

function PushRenderItem(ritem)
    PushAsset(ritem, AssemblePart.assembleSet.RenderItemQueue)
end

-- this is the funciton check a single geometry,
-- return true or false to signal the caller 
-- if there is any error,
-- return false means sucess,
-- return true means have error.
function CheckSingleGeometry(geometry)
    if geometry:readFile() then
        AssemblePart.logger(
            'Geometry Error:'..geometry.name, 
            'cannot read the file:', 
            geometry.file)
        return true
    else
        return false
    end
end

function CheckSingleRenderItem(renderItem)
    local isError = false;
    if GeoPart.GeometrySet[renderItem.geometry] == nil then
        AssemblePart.logger('RenderItem Error:', 'cannot find geometry', '"'..ritem.geometry..' "')
        isError = isError or true
    end
    
    -- check material
    if MatPart.MaterialSet[renderItem.material] == nil then
        AssemblePart.logger('RenderItem Error:', 'cannot find material', '"'..ritem.material..' "')
        isError = isError or true
    end
    return isError
end

-- assum that the sourceSet is a dict,
-- the function will read all the key and index,
-- passing the elemet to the function'checker',
-- if checker return false, means no error, 
-- add the target into the targetQueue.
function CheckRoutine(sourceSet, checker, targetQueue, falseMessage)
    -- do each check for the elemt
    local function doCheck(elemt, koi)
        if checker(v, koi) then
            -- error, do nothing
            AssemblePart.logger(falseMessage, 'key Or Index:'..koi)
        else
            -- success
            PushAsset(v, targetQueue)
        end
    end
    
    -- for each key-value pairs
    for k, v in pairs(sourceSet) do
        doCheck(v, k)
    end
    
    -- for each array element
    for i = 1, #sourceSet do
        doCheck(sourceSet[i], i)
    end
end
-- check and push geometry
function CheckGeometries(checker)
    local haveErrorGeometry = false
    for k, g in pairs(GeoPart.GeometrySet) do
        local isErrorGeometry = false
        
        -- checker is a function for checking single geometry,
        -- if there is any error, it wi
        if checker(g) then
            isErrorGeometry = true
            haveErrorGeometry = true
        else
            PushGeometry(g)
        end
    end
    return haveErrorGeometry
end

-- check the renderItems
function CheckRenderItems(checker)
    
    local haveErrorRitem = false
    -- use a local var to refer to the set, 
    -- because the name is too long.
    local ritemSet = RItemPart.RenderItemSet
    
    -- from the ritem aspect.
    for i = 1, #ritemSet do
        
        if checker(ritemSet[i]) then
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
            AssemblePart.logger("error: missing diffuseMap")
            isErrorMaterial = true
        elseif m.diffuseMap ~= nil then
            m.diffuseMapIndex = t.index
        end
        
        t = TexPart.TextureSet[m.normalMap]
        -- check normal map
        if m.normalMap ~= nil and t == nil then
            AssemblePart.logger("error: missing normalMap")
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
    AssemblePart.assembleSet = {
        -- all the assets will be arrangeed into a array
        MaterialQueue = {n = 0}, 
        TextureQueue = {n = 0},
        GeometryQueue = {n = 0},
        RenderItemQueue = {n = 0}
    }
    
    
    -- Is there any error with all the ritem?
    local isError = false
    
    -- the Geomentry must be checked before the RenderItem
    AssemblePart.logger('ck geo')
    isError = CheckGeometries(CheckSingleGeometry) or isError
    AssemblePart.logger('ck ritem')
    isError = CheckRenderItems() or isError
    -- the texture must be check before the Material
    AssemblePart.logger('ck tx')
    isError = CheckTextures() or isError
    AssemblePart.logger('ch mt')
    isError = CheckMaterials() or isError
    
    -- conclude
    if isError then
        AssemblePart.logger("Assembling failed!")
    else
        AssemblePart.logger("Assembling success.")
    end
    
    -- show the statics
    AssemblePart.logger("Texture Count:"..AssemblePart.assembleSet.TextureQueue.n)
    AssemblePart.logger("Material Count:"..AssemblePart.assembleSet.MaterialQueue.n)
    AssemblePart.logger("Geometry Count:"..AssemblePart.assembleSet.GeometryQueue.n)
    AssemblePart.logger("RenderItem Count:"..AssemblePart.assembleSet.RenderItemQueue.n)
    
    return isError, AssemblePart.assembleSet
end

return Assemble
