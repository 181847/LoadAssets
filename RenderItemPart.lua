require "NameObject"

-- The RenderItem class is global.
RenderItem = class()

local RItemPart = {}

RItemPart.RenderItem = RenderItem

RItemPart.RenderLayers = {}
RItemPart.RenderLayers.n = 0
RItemPart.RenderItemSet = {}

-- Add a new Layer with the layerName (if there is not the same name layer), 
--and returen the name itself.
function RItemPart.AddRenderLayer(layerName)
    assert(type(layerName) == 'string', 'The Name of RenderLayer should be a string.')
    allNum = RItemPart.RenderLayers.n
    
    -- Is the name already exist?
    if RItemPart.RenderLayers[layerName] == nil then
        RItemPart.RenderLayers[layerName] = allNum
        RItemPart.RenderLayers.n = allNum + 1
    end
    return layerName
end

-- This function to print all the renderLayer.
function RItemPart.ShowRenderLayers()
    print("LayerName\tLayerIndex")
    for k, v in pairs(RItemPart.RenderLayers) do
        print(k.."\t\t"..v);
    end
end

-- For the simplity, the model in the objfile is all in the one renderItem,
-- no matter how many groups in the file.
-- Remaind that the three argument are all string,
-- we don't use any reference in different object.
function RenderItem:ctor(geoName, material, renderLayerName)
    self.geometry = geoName
    self.renderLayer = RItemPart.AddRenderLayer(renderLayerName)
    self.material = material
end

-- Add the RenderItem to the global set.
function RenderItem:addToGlobalSet()
    RItemPart.RenderItemSet[#RItemPart.RenderItemSet + 1] = self
end

function RenderItem:showDetail()
    print("******* One RenderItem *********")
    print("Geometry:\t"..self.geometry)
    print("Material:\t"..self.material)
    print("Render Layer:\t"..self.renderLayer)
end

return RItemPart
