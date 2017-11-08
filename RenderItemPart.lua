require "class"

RenderItem = class()
-- Store all layer's name, using a asscii as the key，number as value.
gRenderLayers = {}
gRenderLayersNum = 0

-- Here store the wanted renderitem for rendering.
gRenderItemSet = {}

-- Add a new Layer with the layerName (if there is not the same name layer), 
--and returen the name itself.
local function AddRenderLayer(layerName)
    assert(type(layerName) == 'string', 'The Name of RenderLayer should be a string.')
    if gRenderLayers[layerName] == nil then
        gRenderLayers[layerName] = gRenderLayersNum
        gRenderLayersNum = gRenderLayersNum + 1
    end
    return layerName
end

-- Add renderItem the the gRenderItemSet, use the index as key.
function AddRenderItem(renderItemObject)
    gRenderItemSet[#gRenderItemSet + 1] = renderItemObject
end

-- For the simplity, the model in the objfile is all in the one renderItem,
-- no matter how many groups in the file.
-- Remaind that the three argument are all string,
-- we don't use any reference in different object.
function RenderItem:ctor(objFile, material, renderLayerName)
    self.objFile = objFile
    self.renderLayer = AddRenderLayer(renderLayerName)
    self.material = material
end

function RenderItem:showDetail()
    print("******* One RenderItem *********")
    print("Obj file from:\t"..self.objFile)
    print("Render Layer:\t"..self.renderLayer)
    print("Material:\t"..self.material)
end
