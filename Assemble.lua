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

AssembleModule = {
    assembleSet = {}
}


-- this is a function that for print the error message
function AssembleModule.logger(message, ...)
    print('####'..message, ...)
end

-- useful function to push asset into some queue(
-- assembleSet{MaterialQueue,TextureQueue, RenderItemQueue, GeometryQueue}.
function PushAsset(ast, targetQueue)
    local newCount = targetQueue.n + 1
    targetQueue.n = newCount
    targetQueue[newCount] = ast
    ast.index = newCount
    AssembleModule.logger('push called')
end

-- this is the funciton check a single geometry,
-- return true or false to signal the caller 
-- if there is any error,
-- return false means sucess,
-- return true means have error.
function CheckSingleGeometry(geometry)
    if not geometry:readFile() then
        AssembleModule.logger(
            'Geometry Error:'..geometry.name, 
            'cannot read the file:', 
            geometry.file)
        return false
    else
        return true
    end
end

function CheckSingleRenderItem(renderItem)
    local success   = true;
    geometry        = GeoPart.GeometrySet[renderItem.geometry]
    
    -- is the geometry exist?
    if geometry == nil then
        AssembleModule.logger('RenderItem Error:', 'cannot find geometry', '"'..ritem.geometry..' "')
        success = false
    else
        renderItem.geometryIndex = geometry.index
        
        -- check the subMesh
        local subMesh = geometry.subMeshes[renderItem.subMesh.name]
        if  subMesh == nil then 
            AssembleModule.logger(
                'RenderItem Error:', 
                'cannot find the submesh:', 
                renderItem.subMesh.name)
                success = false
        else
            -- log the start and end index
            renderItem.subMesh.startIndex   = subMesh.startIndex
            renderItem.subMesh.endIndex     = subMesh.endIndex
        end
    end
    
    -- check material
    if MatPart.MaterialSet[renderItem.material] == nil then
        AssembleModule.logger('RenderItem Error:', 'cannot find material', '"'..ritem.material..' "')
        success = false
    end
    return success
end

function CheckSingleTexture(texture)
    local success = true
    -- now just return false mean there is no error
    return success
end

function CheckSingleMaterial(material)
    local success = true
    -- check diffuse map
    
    -- have diffuseMap
    if material.diffuseMap then
        t = TexPart.TextureSet[material.diffuseMap]
        
        if not t then
            AssembleModule.logger("missing diffuseMap")
            success = false
        else
            material.diffuseMapIndex = t.index
        end
    end
    
    -- have normalMap
    if material.normalMap then
        t = TexPart.TextureSet[material.normalMap]
        
        if not t then
            AssembleModule.logger("missing normalMap")
            success = false
        else
            material.normalMapIndex = t.index
        end
    end
    return success
end

-- assum that the sourceSet is a table,
-- the function will read all the key and index,
-- passing the elemet to the function'checker',
-- if checker return false, means no error, 
-- add the target into the targetQueue.
-- In case of returning true(error happended),
-- the falseMessage will be print to identify different routin.
function CheckRoutine(sourceSet, checker, targetQueue, falseMessage)
    -- do each check for the elemt
    local success = true
    local function doCheck(elemt, koi)
        if not checker(elemt, koi) then
            -- error, do nothing
            AssembleModule.logger('CheckRoutine Error:'..falseMessage, 'key Or Index:'..koi)
            return false
        else
            -- success
            PushAsset(elemt, targetQueue)
            return true
        end
    end
    
    -- for each key-value pairs
    for k, v in pairs(sourceSet) do
        AssembleModule.logger('ck pairs:', k, v)
        success = success and doCheck(v, k)
    end
    
    return success
end


-- THE KEY FUNCTION IN THE MODULE
function AssembleModule.Assemble()    
    -- clear the previous queue
    AssembleModule.assembleSet = {
        -- all the assets will be arrangeed into a array
        MaterialQueue = {n = 0}, 
        TextureQueue = {n = 0},
        GeometryQueue = {n = 0},
        RenderItemQueue = {n = 0}
    }
    
    local success = true
    
    -- the Geomentry must be checked before the RenderItem
    AssembleModule.logger('ck geo')
    success = CheckRoutine(
                GeoPart.GeometrySet,    -- from
                CheckSingleGeometry,    -- checkerFunction
                AssembleModule.assembleSet.GeometryQueue, --to
                'Geometry check')       -- errorMessage
            and success;                 -- is there any error before
            
    AssembleModule.logger('ck ritem')
    success = CheckRoutine(
                RItemPart.RenderItemSet,    -- from
                CheckSingleRenderItem,      -- checkerFunction
                AssembleModule.assembleSet.RenderItemQueue, --to
                'RenderItem check')         -- errorMessage
            and success;                     -- is there any error before
    -- success = CheckRenderItems() or success
    -- the texture must be check before the Material
    AssembleModule.logger('ck tx')
    success = CheckRoutine(
                TexPart.TextureSet,    -- from
                CheckSingleTexture,      -- checkerFunction
                AssembleModule.assembleSet.TextureQueue, --to
                'Texture check')         -- errorMessage
                and success;                     -- is there any error before   
    
    AssembleModule.logger('ch mt')
    success = CheckRoutine(
                MatPart.MaterialSet,    -- from
                CheckSingleMaterial,      -- checkerFunction
                AssembleModule.assembleSet.MaterialQueue, --to
                'Texture check')         -- errorMessage
                and success;                     -- is there any error before 
    
    -- conclude
    print(success)
    if success then
        AssembleModule.logger("Assembling success.")
    else
        AssembleModule.logger("Assembling failed!")
    end
    
    -- show the statics
    AssembleModule.logger("Texture Count:"..AssembleModule.assembleSet.TextureQueue.n)
    AssembleModule.logger("Material Count:"..AssembleModule.assembleSet.MaterialQueue.n)
    AssembleModule.logger("Geometry Count:"..AssembleModule.assembleSet.GeometryQueue.n)
    AssembleModule.logger("RenderItem Count:"..AssembleModule.assembleSet.RenderItemQueue.n)
    
    return success, AssembleModule.assembleSet
end

return AssembleModule
