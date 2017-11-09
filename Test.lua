-- This script is used to test all the module is correct.

TexPart   = require("TexturePart")
MatPart   = require("MaterialPart")
GeoPart   = require("GeometryPart")
RItemPart = require("RenderItemPart")

test_t_1 = Texture.new("brick", "d:/texture/brick.dds")
test_t_2 = Texture.new("tree", "d:/texture/tree.dds")

test_m_1 = Material.new("baseMat")
test_m_2 = Material.new("whiteMat")

test_g_1 = Geometry.new("box", "../base/box.obj")
test_g_2 = Geometry.new("sphere", "../base/geoSphere.obj")

test_ritem_1 = RenderItem.new(test_g_1.name, test_m_1.name, "opaque")
test_ritem_2 = RenderItem.new(test_g_2.name, test_m_2.name, "water")

print()
test_t_1:showDetail()
test_t_2:showDetail()
print()
test_m_1:showDetail()
test_m_2:showDetail()
print()
test_g_1:showDetail()
test_g_2:showDetail()
print()
test_ritem_1:showDetail()
test_ritem_2:showDetail()
print()
RItemPart.ShowRenderLayers()
print()

-- assemble by empty set
assem = loadfile("Assemble.lua")
assem()

print()

-- add each instance to specific set, 
-- then assemble.
test_t_1:addToGlobalSet()
test_t_2:addToGlobalSet()
--
test_m_1:addToGlobalSet()
test_m_2:addToGlobalSet()
--
test_g_1:addToGlobalSet()
test_g_2:addToGlobalSet()
--
test_ritem_1:addToGlobalSet()
test_ritem_2:addToGlobalSet()
-- assemble again
assem()
