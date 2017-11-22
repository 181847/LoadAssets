-- This script is used to check all the Material/Texture/RenderItem
-- exist, because all the reference is by name.
-- In the RenderItem, we will try to check that the 
-- Material exist,
-- and in the material, all the texture exist.
-- restrict the var name inside the script

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

function CheckSingleTexture(texture)
    local isError = false
    -- now just return false mean there is no error
    return isError
end

function CheckSingleMaterial(material)
    local isError = false
    -- check diffuse map
    
    if material.diffuseMap ~= nil then
        t = TexPart.TextureSet[material.diffuseMap]
        
        if t == nil then
            AssemblePart.logger("missing diffuseMap")
            isError = true
        else
            material.diffuseMapIndex = t.index
        end
    end
    
    
    if material.normalMap ~= nil then
        t = TexPart.TextureSet[material.normalMap]
        
        if t == nil then
            AssemblePart.logger("missing normalMap")
            isError = true
        else
            material.normalMapIndex = t.index
        end
    end
    return isError
end

-- assum that the sourceSet is a table,
-- the function will read all the key and index,
-- passing the elemet to the function'checker',
-- if checker return false, means no error, 
-- add the target into the targetQueue.
function CheckRoutine(sourceSet, checker, targetQueue, falseMessage)
    -- do each check for the elemt
    local function doCheck(elemt, koi)
        if checker(elemt, koi) then
            -- error, do nothing
            AssemblePart.logger('CheckRoutine Error:'..falseMessage, 'key Or Index:'..koi)
        else
            -- success
            PushAsset(elemt, targetQueue)
        end
    end
    
    -- for each key-value pairs
    for k, v in pairs(sourceSet) do
        AssemblePart.logger('ck pairs:', k, v)
        doCheck(v, k)
    end
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
    isError = CheckRoutine(
                GeoPart.GeometrySet,    -- from
                CheckSingleGeometry,    -- checkerFunction
                AssemblePart.assembleSet.GeometryQueue, --to
                'Geometry check')       -- errorMessage
            or isError;                 -- is there any error before
            
    AssemblePart.logger('ck ritem')
    isError = CheckRoutine(
                RItemPart.RenderItemSet,    -- from
                CheckSingleRenderItem,      -- checkerFunction
                AssemblePart.assembleSet.RenderItemQueue, --to
                'RenderItem check')         -- errorMessage
            or isError;                     -- is there any error before
    -- isError = CheckRenderItems() or isError
    -- the texture must be check before the Material
    AssemblePart.logger('ck tx')
    isError = CheckRoutine(
                TexPart.TextureSet,    -- from
                CheckSingleTexture,      -- checkerFunction
                AssemblePart.assembleSet.TextureQueue, --to
                'Texture check')         -- errorMessage
                or isError;                     -- is there any error before   
    AssemblePart.logger('ch mt')
    isError = CheckRoutine(
                MatPart.MaterialSet,    -- from
                CheckSingleMaterial,      -- checkerFunction
                AssemblePart.assembleSet.MaterialQueue, --to
                'Texture check')         -- errorMessage
                or isError;                     -- is there any error before 
    
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
