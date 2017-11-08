local print = print

require "class"

local RItemPart = {}
RItemPart.gRenderLayers = {}
RItemPart.gRenderLayersNum = 0
RItemPart.gRenderItemSet = {}

-- The RenderItem class is global.
RenderItem = class()

-- Store all layer's name, using a ascii as the key，number as value.
local gRenderLayers = RItemPart.gRenderLayers

-- Here store the renderitem for rendering.
local gRenderItemSet = RItemPart.gRenderItemSet

-- Add a new Layer with the layerName (if there is not the same name layer), 
--and returen the name itself.
function RItemPart.AddRenderLayer(layerName)
    assert(type(layerName) == 'string', 'The Name of RenderLayer should be a string.')
    allNum = RItemPart.gRenderLayersNum
    
    -- Is the name already exist?
    if gRenderLayers[layerName] == nil then
        gRenderLayers[layerName] = allNum
        RItemPart.gRenderLayersNum = allNum + 1
    end
    return layerName
end

-- This function to print all the renderLayer.
function RItemPart.ShowRenderLayers()
    print("LayerName\tLayerIndex")
    for k, v in pairs(gRenderLayers) do
        print(k.."\t\t"..v);
    end
end

-- Add renderItem the the gRenderItemSet, use the index as key.
function RItemPart.AddRenderItem(renderItemObject)
    gRenderItemSet[#gRenderItemSet + 1] = renderItemObject
end

-- For the simplity, the model in the objfile is all in the one renderItem,
-- no matter how many groups in the file.
-- Remaind that the three argument are all string,
-- we don't use any reference in different object.
function RenderItem:ctor(objFile, material, renderLayerName)
    self.objFile = objFile
    self.renderLayer = RItemPart.AddRenderLayer(renderLayerName)
    self.material = material
end

function RenderItem:showDetail()
    print("******* One RenderItem *********")
    print("Obj file from:\t"..self.objFile)
    print("Material:\t"..self.material)
    print("Render Layer:\t"..self.renderLayer)
end

return RItemPart
